# Load datasets ----
documents_amag_clean <- read_csv(
  file.path(local_storage, "intermediate", "documents_amag_ii_clean.csv"))

reportes_amag_clean <- read_csv(
  file.path(local_storage, "intermediate", "reportes_amag_ii_clean.csv"))

procedural_parts_amag_clean <- read_csv(
  file.path(local_storage, "intermediate", "procedural_parts_amag_ii_clean.csv"))

# Create case outcomes ----

# Create fundada outcomes
fundada_var <- documents_amag_clean %>%
  group_by(expediente_n) %>%
  summarise(
    fundada = max(fundada, na.rm = TRUE),
    fundada_parte = max(fundada_parte, na.rm = TRUE),
    infundada = max(infundada, na.rm = TRUE)) %>%
  mutate(
    var_fundada = case_when(
      fundada == 1 & infundada == 0 ~ 1,
      fundada == 0 & infundada == 1 ~ 0,
      fundada_parte == 1 ~ 1,
      fundada == 1 & infundada == 1 ~ 1)) %>%
  select(expediente_n, var_fundada)

# Identify resolutions
resolution_var <- documents_amag_clean %>%
  group_by(expediente_n) %>%
  summarise(
    vista2 = max(vista2, na.rm = TRUE),
    revoca2 = max(revoca2, na.rm = TRUE),
    nula2 = max(nula2, na.rm = TRUE),
    confirma2 = max(confirma2, na.rm = TRUE),
    auto_improcedente = max(auto_improcedente, na.rm = TRUE),
    auto_final = max(auto_final, na.rm = TRUE),
    auto_definitivo = max(auto_definitivo, na.rm = TRUE),
    fundada = max(fundada, na.rm = TRUE),
    fundada_parte = max(fundada_parte, na.rm = TRUE),
    infundada = max(infundada, na.rm = TRUE)) %>%
  mutate(var_resolution = if_else(
    vista2 == 1 |
    revoca2 == 1 |
    nula2 == 1 |
    confirma2 == 1 |
    auto_improcedente == 1 |
    auto_final == 1 |
    auto_definitivo == 1 |
    fundada == 1 |
    fundada_parte == 1 |
    infundada == 1, 1, 0)) %>%
  select(expediente_n, var_resolution)

# Create appeal outcome
appeal_var <- documents_amag_clean %>%
  separate(
    expediente_n,
    remove = FALSE,
    c("c1", "c2", "c3", "c4", "c5", "c6", "c7"), "-") %>%
  arrange(c2, c5, c6, c7, c4, c1, c3, date) %>%
  mutate(
    decision = if_else(fundada == 1 | fundada_parte == 1 | infundada == 1, 1, 0),
    decision_na = na_if(decision, 0)) %>%
  group_by(expediente_n) %>%
  fill(decision_na, .direction = "down") %>%
  filter(!is.na(decision_na)) %>%
  summarise(var_appeal = max(appeal)) %>%
  select(expediente_n, var_appeal)

# Create reversal outcome

reversal_var <- documents_amag_clean %>%
  group_by(expediente_n) %>%
  summarise(
    vista = max(vista, na.rm = TRUE),
    revoca = max(revoca, na.rm = TRUE),
    nula = max(nula, na.rm = TRUE),
    confirma = max(confirma, na.rm = TRUE)) %>%
  mutate(
    revoca_nula = if_else(revoca == 1 | nula == 1, 1, 0),
    var_reversal = case_when(
      revoca_nula == 1 & confirma == 1 ~ 1,
      revoca_nula == 0 & confirma == 1 ~ 0,
      revoca_nula == 1 & confirma == 0 ~ 1)) %>%
  left_join(appeal_var, by = "expediente_n") %>%
  filter(var_appeal == 1) %>%
  select(expediente_n, var_reversal)

# Create first auto outcome
date_first_auto_var <- documents_amag_clean %>%
  group_by(expediente_n) %>%
  summarise(date_first_auto = min(date, na.rm = TRUE))

# Create end date for resolutions
date_resolution_var <- documents_amag_clean %>%
  filter(
    vista2 == 1 |
    revoca2 == 1 |
    nula2 == 1 |
    confirma2 == 1 |
    auto_improcedente == 1 |
    auto_definitivo == 1 |
    auto_final == 1 |
    fundada == 1 |
    fundada_parte == 1 |
    infundada == 1) %>%
  group_by(expediente_n) %>%
  top_n(-1, date) %>%
  rename(date_resolution = date) %>%
  select(date_resolution, expediente_n) %>%
  distinct()

# Create end date for sentences
date_sentence_var <- documents_amag_clean %>%
  filter(fundada == 1 | fundada_parte == 1 | infundada == 1) %>%
  group_by(expediente_n) %>%
  top_n(-1, date) %>%
  rename(date_sentence = date) %>%
  select(date_sentence, expediente_n) %>%
  distinct()

# Create end date for reversals
date_reversal_var <- documents_amag_clean %>%
  filter(revoca == 1 | nula == 1 | confirma == 1) %>%
  group_by(expediente_n) %>%
  top_n(-1, date) %>%
  rename(date_reversal = date) %>%
  left_join(reversal_var, by = c("expediente_n")) %>%
  filter(!is.na(var_reversal)) %>%
  distinct() %>%
  # Keep reversals with positive date since sentence
  left_join(date_sentence_var) %>%
  mutate(length_sentence_reversal = as.numeric(date_reversal - date_sentence)) %>%
  filter(length_sentence_reversal > 0) %>%
  select(date_reversal, expediente_n)

# Join datasets -----

case_outcomes <- fundada_var %>%
  left_join(reversal_var, by = "expediente_n") %>%
  left_join(appeal_var, by = "expediente_n") %>%
  left_join(resolution_var, by = "expediente_n") %>%
  left_join(date_first_auto_var, by = "expediente_n") %>%
  left_join(date_sentence_var, by = "expediente_n") %>%
  left_join(date_reversal_var, by = "expediente_n") %>%
  left_join(date_resolution_var, by = "expediente_n") %>%
  left_join(reportes_amag_clean, by = "expediente_n") %>%
  left_join(procedural_parts_amag_clean, by = "expediente_n")

# Create additional outcome variables
case_outcomes <- case_outcomes %>%
  mutate(
    # Year
    year = year(date_first_auto),
    month_year_first_auto = format(as.Date(date_first_auto), "%Y-%m"),
    month_year_sentence = format(as.Date(date_sentence), "%Y-%m"),
    month_year_resolution = format(as.Date(date_resolution), "%Y-%m"),
    # Case start during/after treatment
    first_auto_before_treatment = if_else(
      date_first_auto < "2021-06-05",
      1, 0),
    first_auto_during_treatment = if_else(
      date_first_auto >= "2021-06-05" & date_first_auto < "2021-07-21",
      1, 0),
    first_auto_duringafter_treatment = if_else(
      date_first_auto >= "2021-06-05",
      1, 0),
    first_auto_after_treatment = if_else(
      date_first_auto >= "2021-07-21",
      1, 0),
    # Sentence during/after treatment
    sentence_before_treatment = if_else(
      date_sentence < "2021-06-05",
      1, 0),
    sentence_during_treatment = if_else(
      date_sentence >= "2021-06-05" & date_sentence < "2021-07-21",
      1, 0),
    sentence_duringafter_treatment = if_else(
      date_sentence >= "2021-06-05",
      1, 0),
    sentence_after_treatment = if_else(
      date_sentence >= "2021-07-21",
      1, 0),
    # Reversal during/after treatment
    reversal_before_treatment = if_else(
      date_reversal < "2021-06-05",
      1, 0),
    reversal_during_treatment = if_else(
      date_reversal >= "2021-06-05" & date_reversal < "2021-07-21",
      1, 0),
    reversal_duringafter_treatment = if_else(
      date_reversal >= "2021-06-05",
      1, 0),
    reversal_after_treatment = if_else(
      date_reversal >= "2021-07-21",
      1, 0),
    # Resolution during/after treatment
    resolution_before_treatment = if_else(
      date_resolution < "2021-06-05",
      1, 0),
    resolution_during_treatment = if_else(
      date_resolution >= "2021-06-05" & date_resolution < "2021-07-21",
      1, 0),
    resolution_duringafter_treatment = if_else(
      date_resolution >= "2021-06-05",
      1, 0),
    resolution_after_treatment = if_else(
      date_resolution >= "2021-07-21",
      1, 0),
    # Length between first auto and resolution
    length_auto_resolution = as.numeric(date_resolution - date_first_auto),
    # Length between first auto and sentence
    length_auto_sentence = as.numeric(date_sentence - date_first_auto),
    # Length between first auto and reversal
    length_auto_reversal = as.numeric(date_reversal - date_first_auto),
    # Length between sentence and reversal
    length_sentence_reversal = as.numeric(date_reversal - date_sentence),
    # Unconditional reversal variable
    var_uncon_reversal = case_when(
      is.na(var_reversal) ~ 0,
      var_reversal == 0 ~ 0,
      var_reversal == 1 ~ 1),
    # Process and speciality variables
    especialidad = replace_na(especialidad, "OTRO"),
    case_speciality = case_when(
      especialidad == "CIVIL" ~ "civil",
      especialidad == "FAMILIA CIVIL" ~ "familia civil",
      especialidad == "FAMILIA TUTELAR" ~ "familia tutelar",
      especialidad == "LABORAL" ~ "laboral",
      especialidad == "COMERCIAL" ~ "otro",
      especialidad == "CONTENCIOSO ADM." ~ "otro",
      especialidad == "DERECHO CONSTITUCIONAL" ~ "otro",
      especialidad == "OTRO" ~ "otro"),
    speciality_civil = if_else(case_speciality == "civil", 1, 0),
    speciality_familia_civil  = if_else(case_speciality == "familia civil", 1, 0),
    speciality_familia_tutelar = if_else(case_speciality == "familia tutelar", 1, 0),
    speciality_laboral = if_else(case_speciality == "laboral", 1, 0),
    speciality_otro = if_else(case_speciality == "otro", 1, 0),
    proceso =  replace_na(proceso, "OTRO"),
    case_process = case_when(
      proceso == "UNICO" ~ "unico",
      proceso == "EJECUCION" ~ "ejecucion",
      proceso == "EJECUTIVO" ~ "ejecucion",
      proceso == "UNICO DE EJECUCION" ~ "ejecucion",
      proceso == "SUMARISIMO" ~ "sumarisimo",
      proceso == "ABREVIADO" ~ "abreviado",
      proceso == "CONOCIMIENTO" ~ "conocimiento",
      proceso == "NO CONTENCIOSO" ~ "no_contencioso",
      proceso == "CONSTITUCIONAL" ~ "constitucional",
      proceso == "CONTENCIOSO ADMINISTRATIVO" ~ "otro",
      proceso == "ESPECIAL" ~ "otro",
      proceso == "ESPECIAL LEY 30364" ~ "otro",
      proceso == "EXHORTO" ~ "otro",
      proceso == "INVESTIGACION TUTELAR" ~ "otro",
      proceso == "ORDINARIO" ~ "otro",
      proceso == "CAUTELAR" ~ "otro",
      proceso == "PROCEDIMIENTOS CIVILES" ~ "otro",
      proceso == "URGENTE" ~ "otro",
      proceso == "OTRO" ~ "otro"),
    process_unico = if_else(case_process == "unico", 1, 0),
    process_ejecucion = if_else(case_process == "ejecucion", 1, 0),
    process_sumarisimo = if_else(case_process == "sumarisimo", 1, 0),
    process_abreviado = if_else(case_process == "abreviado", 1, 0),
    process_conocimiento = if_else(case_process == "conocimiento", 1, 0),
    process_no_contencioso = if_else(case_process == "no_contencioso", 1, 0),
    process_constitucional = if_else(case_process == "constitucional", 1, 0),
    process_otro = if_else(case_process == "otro", 1, 0)) %>%
  select(-proceso, especialidad)

# Save datasets ----

write_csv(case_outcomes, file.path(
  local_storage, "intermediate", "case_outcomes_amag_ii.csv"))
