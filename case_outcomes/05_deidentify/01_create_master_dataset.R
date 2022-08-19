## Data script to create the Master Datasets

# Load data ---------------------------------------------------------------

# Randomization in round 1
randomization_round_1 <- read_csv(
  paste0(data_amag_raw, "raw_data/", "00_research_design/",
  "00_randomization/treatment_assignment_course1_PCA.csv"))

# Monitoring assignment (aula-round level)
monitoring_assign <- read_csv(
  paste0(data_amag_raw, "raw_data/", "00_research_design/",
  "00_randomization/monitoring_assignment_allrounds.csv"))

# Satisfaction data (teacher names)
satisfaction <- read_excel(
  paste0(data_amag_raw, "raw_data/", "01_satisfaction/",
  "Respuestas_Enc_Satisfacción_Final_14.12.2020.xlsx")) %>%
  clean_names()

# Teacher's characteristics
teachers_data <- read_excel(
  paste0(data_amag_raw, "raw_data/", "07_others/",
  "01_monitoring_reports/02_teacher_characteristics.xlsx")) %>%
  clean_names()

# Monitor's characteristics
monitors_data <- read_excel(
  paste0(data_amag_raw, "raw_data/", "07_others/",
  "01_monitoring_reports/03_df_monitoring_report.xlsx")) %>%
  clean_names()

# HR data
# hr_data <- read_csv(paste0(data_hr, "HR_present.csv")) %>%
#   clean_names()

# Student data
round_id <- list.files(paste0(data_amag_raw, "raw_data/", "06_matriculados"))
round_id <- round_id[str_detect(round_id, "Matriculados_09.09", negate = T)]
round_id <- round_id[str_detect(round_id, "Matriculados_14.10", negate = T)]

## Read files
participant_data <- lapply(
  paste0(data_amag_raw, "raw_data/", "06_matriculados/", round_id),
  read_excel, sheet = 2, col_types = "text")

## Add filename
for (i in seq_along(participant_data)) {
  participant_data[[i]] <- cbind(participant_data[[i]], round_id[i])
}

# Cases data
## Get the file names
files <- list.files(
  path = paste0(data_cej, "data_cleaned/"),
  pattern = "*.csv",
  recursive = TRUE)

## Select reporte files
files_reportes <- files[str_detect(files, "file_report")]
files_reportes <- files_reportes[!str_detect(files_reportes, "2021")]

## Load datasets
reportes <- lapply(
  paste0(data_cej, "data_cleaned/", files_reportes), read_csv) %>%
  bind_rows() %>%
  clean_names()

# Preprocess data --------------------------------------------------------

# Preprocess randomization data

randomization_round_1 <- randomization_round_1 %>%
  select(
    sede_rand1 = sede,
    aula_rand1 = aula,
    strata_rand1 = strata,
    curso_rand1 = curso,
    location_rand1 = location,
    treat_rand1 = treat)

# # Preprocess hr data
# hr_data <- hr_data %>%
#   rename(
#     dist_judicial_hr = distrito_judicial,
#     nrodocumento = dni,
#     institucion_hr = institucion,
#     cargo_actual_hr = cargo_actual) %>%
#   select(nrodocumento, institucion_hr, cargo_actual_hr, dist_judicial_hr)

# Preprocess monitoring assignment

# Preprocess teachers per aula-round
teachers_aula_round <- satisfaction %>%
  mutate(round = as.numeric(str_extract(bloque, "[0-9]{1,2}")),
         idcurso = as.character(idcurso)) %>%
  select(round, aula, idcurso, docente) %>%
  distinct()

# Join monitors and teachers data to randomization
monitoring_assign <- monitoring_assign %>%
  left_join(teachers_aula_round, by = c("aula", "round")) %>%
  left_join(teachers_data, by = "docente") %>%
  left_join(monitors_data) %>%
  select(aula, monitoreo, round, idcurso, teacher_female, monitor_female) %>%
  mutate(monitoring_status = case_when(
    monitoreo == 0 ~ "Control group",
    monitoreo == 1 & !is.na(monitor_female) ~ "Monitored",
    TRUE ~ "Not monitored"))

monitoring_assign_round1 <- monitoring_assign %>%
  filter(round == 1) %>%
  select(aula_round1 = aula, monitoreo_round1 = monitoreo)

monitoring_assign_round2 <- monitoring_assign %>%
  filter(round == 2) %>%
  select(aula_round2 = aula, monitoreo_round2 = monitoreo)

monitoring_assign_round3 <- monitoring_assign %>%
  filter(round == 3) %>%
  select(aula_round3 = aula, monitoreo_round3 = monitoreo)

monitoring_assign_round4 <- monitoring_assign %>%
  filter(round == 4) %>%
  select(aula_round4 = aula, monitoreo_round4 = monitoreo)

monitoring_assign_round5 <- monitoring_assign %>%
  filter(round == 5) %>%
  select(aula_round5 = aula, monitoreo_round5 = monitoreo)

monitoring_assign_round6 <- monitoring_assign %>%
  filter(round == 6) %>%
  select(aula_round6 = aula, monitoreo_round6 = monitoreo)

monitoring_assign_round7 <- monitoring_assign %>%
  filter(round == 7) %>%
  select(aula_round7 = aula, monitoreo_round7 = monitoreo)

monitoring_assign_round8 <- monitoring_assign %>%
  filter(round == 8) %>%
  select(aula_round8 = aula, monitoreo_round8 = monitoreo)

monitoring_assign_round9 <- monitoring_assign %>%
  filter(round == 9) %>%
  select(aula_round9 = aula, monitoreo_round9 = monitoreo)

# Preprocess participant data
participant_data <- participant_data %>%
  bind_rows() %>%
  clean_names()  %>%
  rename(nrodocumento = dni) %>%
  mutate(
    # Create round variable
    round = case_when(
      str_detect(round_id_i, "Base de matriculados 22") ~ 1,
      str_detect(round_id_i, "Matriculados 2do Bloque") ~ 2,
      str_detect(round_id_i, "Matriculados 3er Bloque") ~ 3,
      str_detect(round_id_i, "Matriculados 4to Bloque") ~ 4,
      str_detect(round_id_i, "Matriculados 5to Bloque") ~ 5,
      str_detect(round_id_i, "Matriculados 6to Bloque") ~ 6,
      str_detect(round_id_i, "07. Matriculados_23") ~ 7,
      str_detect(round_id_i, "08. Matriculados_20") ~ 8,
      str_detect(round_id_i, "9. Matriculados 22") ~ 9,
      str_detect(round_id_i, "Matriculados_10mo") ~ 10),
    # Aula variable
      aula = as.numeric(nro_aula)) %>%
    # Keep classes in the experiment
      filter(
        round != 10,
        aula < 40,
        !(aula == 16 & round == 8),
        !(aula == 5 & round == 5))

# Rounds participation
rounds_id <- participant_data %>%
  mutate(participant = 1) %>%
  select(nrodocumento, round, participant) %>%
  arrange(nrodocumento, round) %>%
  pivot_wider(
    names_from = round,
    names_glue = "participation_round{round}",
    values_from = participant,
    values_fill = 0) %>%
  ungroup()

# Aula
aula_id <- participant_data %>%
  select(nrodocumento, round, aula) %>%
  arrange(nrodocumento, round) %>%
  pivot_wider(
    names_from = round,
    names_glue = "aula_round{round}",
    values_from = aula)

# Gender
gender_id <- participant_data %>%
  filter(!is.na(genero)) %>%
  select(nrodocumento, round, genero) %>%
  group_by(nrodocumento) %>%
  summarise(genero = first(genero)) %>%
  mutate(participant_female = if_else(genero == "Femenino", 1, 0)) %>%
  select(nrodocumento, participant_female)

# Nivel postula
nivel_id <- participant_data %>%
  filter(!is.na(nivel_postula)) %>%
  select(nrodocumento, round, nivel_postula) %>%
  mutate(
    participant_level = case_when(
      nivel_postula == "2" ~ 2,
      nivel_postula == "3" ~ 3,
      nivel_postula == "4" ~ 4,
      nivel_postula == "Nivel 2" ~ 2,
      nivel_postula == "Nivel 3" ~ 3,
      nivel_postula == "Nivel 4" ~ 4,
      nivel_postula == "NIvel 2" ~ 2,
      nivel_postula == "NIvel 3" ~ 3)) %>%
  group_by(nrodocumento) %>%
  summarise(participant_level = first(participant_level)) %>%
  mutate(
    participant_level_2 = if_else(participant_level == 2, 1, 0),
    participant_level_3 = if_else(participant_level == 3, 1, 0))

# Participant is judge or prosecutor
institucion_id <- participant_data %>%
  filter(!is.na(institucion)) %>%
  filter(institucion != "NULL") %>%
  select(nrodocumento, round, institucion) %>%
  group_by(nrodocumento) %>%
  summarise(institucion = first(institucion)) %>%
  mutate(
    participant_judge = if_else(institucion == "Poder Judicial", 1, 0),
    participant_prosecutor = if_else(institucion == "Ministerio Público", 1, 0)) %>%
  select(nrodocumento, participant_judge, participant_prosecutor)

# Age
age_id_1 <- participant_data %>%
  filter(!is.na(fecha_nacimiento)) %>%
  filter(str_detect(fecha_nacimiento, "-")) %>%
  mutate(birth_date = ymd(fecha_nacimiento)) %>%
  select(nrodocumento, birth_date)

age_id_2 <- participant_data %>%
  filter(!is.na(fecha_nacimiento)) %>%
  filter(!str_detect(fecha_nacimiento, "-")) %>%
  mutate(birth_date = as.Date(as.numeric(fecha_nacimiento), "1899-12-30"), "%Y-%m-%d") %>%
  select(nrodocumento, birth_date)

age_id <- age_id_1 %>%
  bind_rows(age_id_2) %>%
  group_by(nrodocumento) %>%
  summarise(birth_date = first(birth_date)) %>%
  mutate(participant_age = 2020 - year(birth_date)) %>%
  select(nrodocumento, participant_age)

# Years tenure
years_tenure_1 <- participant_data %>%
  filter(!is.na(fechainiciofunciones)) %>%
  filter(str_detect(fechainiciofunciones, "-")) %>%
  mutate(date_tenure = ymd(fechainiciofunciones)) %>%
  select(nrodocumento, date_tenure)

years_tenure_2 <- participant_data %>%
  filter(!is.na(fechainiciofunciones)) %>%
  filter(!str_detect(fechainiciofunciones, "-")) %>%
  mutate(date_tenure = as.Date(as.numeric(fechainiciofunciones), "1899-12-30"), "%Y-%m-%d") %>%
  select(nrodocumento, date_tenure)

years_tenure_id <- years_tenure_1 %>%
  bind_rows(years_tenure_2) %>%
  group_by(nrodocumento) %>%
  summarise(date_tenure = first(date_tenure)) %>%
  mutate(participant_years_tenure = 2020 - year(date_tenure)) %>%
  select(nrodocumento, participant_years_tenure)

# Years in bar association
years_bar_association_1 <- participant_data %>%
  filter(!is.na(fecha_de_colegiatura)) %>%
  filter(str_detect(fecha_de_colegiatura, "-")) %>%
  mutate(date_bar_association = ymd(fecha_de_colegiatura)) %>%
  select(nrodocumento, date_bar_association)

years_bar_association_2 <- participant_data %>%
  filter(!is.na(fecha_de_colegiatura)) %>%
  filter(!str_detect(fecha_de_colegiatura, "-")) %>%
  mutate(date_bar_association = as.Date(as.numeric(fecha_de_colegiatura), "1899-12-30"), "%Y-%m-%d") %>%
  select(nrodocumento, date_bar_association)

years_bar_association_id <- years_bar_association_1 %>%
  bind_rows(years_bar_association_2) %>%
  group_by(nrodocumento) %>%
  summarise(date_bar_association = first(date_bar_association)) %>%
  mutate(participant_years_bar_assoc = 2020 - year(date_bar_association)) %>%
  select(nrodocumento, participant_years_bar_assoc)
  

# Criminal court or criminal prosecutors

criminal_court_id <- participant_data %>%
  filter(!is.na(nombre_despacho)) %>%
  filter(institucion == "Poder Judicial") %>%
  mutate(
    nombre_despacho = tolower(nombre_despacho),
    participant_criminal_court = if_else(str_detect(nombre_despacho, "penal|preparatoria"), 1, 0)) %>%
  group_by(nrodocumento) %>%
  summarise(participant_criminal_court = first(participant_criminal_court)) %>%
  select(nrodocumento, participant_criminal_court)

criminal_prosecutor_id <- participant_data %>%
  filter(!is.na(nombre_despacho)) %>%
  filter(institucion == "Ministerio Público") %>%
  mutate(
    nombre_despacho = tolower(nombre_despacho),
    participant_criminal_prosecutor = if_else(str_detect(nombre_despacho, "penal"),1, 0)) %>%
  group_by(nrodocumento) %>%
  summarise(participant_criminal_prosecutor = first(participant_criminal_prosecutor)) %>%
  select(nrodocumento, participant_criminal_prosecutor)

# Names
names_id <- participant_data %>%
  filter(!is.na(nombres)) %>%
  select(nrodocumento, round, nombres) %>%
  group_by(nrodocumento) %>%
  summarise(nombres = first(nombres))

# Apellido materno
apellido_materno_id <- participant_data %>%
  filter(!is.na(apellido_materno)) %>%
  select(nrodocumento, round, apellido_materno) %>%
  group_by(nrodocumento) %>%
  summarise(apellido_materno = first(apellido_materno))

# Apellido paterno
apellido_paterno_id <- participant_data %>%
  filter(!is.na(apellido_paterno)) %>%
  select(nrodocumento, round, apellido_paterno) %>%
  group_by(nrodocumento) %>%
  summarise(apellido_paterno = first(apellido_paterno))

# Join datasets
pca22_students <- rounds_id %>%
  left_join(aula_id, by = "nrodocumento") %>%
  left_join(nivel_id, by = "nrodocumento")  %>%
  left_join(institucion_id, by = "nrodocumento") %>%
  left_join(gender_id, by = "nrodocumento") %>%
  left_join(age_id, by = "nrodocumento") %>%
  left_join(years_tenure_id, by = "nrodocumento") %>%
  left_join(years_bar_association_id, by = "nrodocumento") %>%
  left_join(criminal_court_id, by = "nrodocumento") %>%
  left_join(criminal_prosecutor_id, by = "nrodocumento") %>%
  left_join(names_id, by = "nrodocumento") %>%
  left_join(apellido_materno_id, by = "nrodocumento") %>%
  left_join(apellido_paterno_id, by = "nrodocumento")

# Fill missing gender
pca22_students <- pca22_students %>%
  mutate(participant_female = case_when(
    nombres == "VERONICA MARILYN" ~ 1,
    nombres == "LEONOR" ~ 1,
    nombres == "ROBERTO GERARDO" ~ 0,
    nombres == "JAVIER OCTAVIO" ~ 0,
    nombres == "ROBERT LUIS" ~ 0,
    nombres == "MARINO" ~ 0,
    nombres == "ESTHER" ~ 1,
    nombres == "ESTANISLAO" ~ 0,
    nombres == "SANDRA ARTEMIA" ~ 1,
    nombres == "JENNIFER MILDRED" ~ 1,
    nombres == "CANCIA" ~ 1,
    nombres == "ALBA PAMELA" ~ 1,
    nombres == "ALDO ATILANO" ~ 0,
    nombres == "SOLEDAD" ~ 1,
    nombres == "VICTOR RAUL" ~ 0,
    nombres == "CONNIE CATHERINE" ~ 1,
    nombres == "VICTOR DANIEL" ~ 0,
    nombres == "HECTOR MANUEL" ~ 0,
    nombres == "DIANA BEATRIZ" ~ 1,
    TRUE ~ participant_female))

# Create master dataset - participant level -----------------------------------

masterdata_participant <- pca22_students %>%
  # Join with randomization in round 1
  left_join(randomization_round_1, by = c("aula_round1" = "aula_rand1")) %>%
  # Join with monitoring assignment for each round
  left_join(monitoring_assign_round1, by = "aula_round1") %>%
  left_join(monitoring_assign_round2, by = "aula_round2") %>%
  left_join(monitoring_assign_round3, by = "aula_round3") %>%
  left_join(monitoring_assign_round4, by = "aula_round4") %>%
  left_join(monitoring_assign_round5, by = "aula_round5") %>%
  left_join(monitoring_assign_round6, by = "aula_round6") %>%
  left_join(monitoring_assign_round7, by = "aula_round7") %>%
  left_join(monitoring_assign_round8, by = "aula_round8") %>%
  left_join(monitoring_assign_round9, by = "aula_round9") %>%
  # Join with HR data
  # left_join(hr_data, by = "nrodocumento") %>%
  # Create full name variable (nombre - apellido)
  unite(
    participant_nombre_apellido,
    c("nombres", "apellido_paterno", "apellido_materno"),
    remove = FALSE, sep = " ") %>%
  # Create full name variable (apellido - nombre)
  unite(participant_apellido_nombre,
    c("apellido_paterno", "apellido_materno", "nombres"),
    sep = " ") %>%
  rowwise() %>%
  # Create treatments
  mutate(
    n_treatment = sum(c_across(monitoreo_round1:monitoreo_round9), na.rm = TRUE),
    n_participation = sum(c_across(participation_round1:participation_round9), na.rm = TRUE),
    percent_monit = n_treatment / n_participation,
    ever_treated = if_else(!percent_monit == 0, 1, 0),
    always_treated = if_else(percent_monit == 1, 1, 0),
    always_treated_never_treated = case_when(
      percent_monit == 1 ~ 1,
      percent_monit == 0 ~ 0),
    treated_40 = if_else(percent_monit >= 0.4, 1, 0),
    treated_50 = if_else(percent_monit >= 0.5, 1, 0),
    treated_60 = if_else(percent_monit >= 0.6, 1, 0),
    treated_70 = if_else(percent_monit >= 0.7, 1, 0),
    treated_80 = if_else(percent_monit >= 0.8, 1, 0),
    treated_90 = if_else(percent_monit >= 0.9, 1, 0))

# Create master dataset (Participant-round level) ---------------------------

masterdata_participant_round <- masterdata_participant  %>%
  pivot_longer(
    cols = contains("_round"),
    names_to = c(".value", "round"),
    names_sep = "_") %>%
  filter(!participation == 0) %>%
  mutate(round = as.numeric(str_sub(round, 6, 6))) %>%
  left_join(monitoring_assign, by = c("round", "aula", "monitoreo"))

# Join teacher and monitor data to dataset at the participant level
teacher_monitor_data <- masterdata_participant_round %>%
  group_by(nrodocumento) %>%
  summarise(
    ratio_teacher_female = sum(teacher_female) / n(),
    ratio_female_monit = sum(monitor_female, na.rm = TRUE) / n())

masterdata_participant <- masterdata_participant %>%
  left_join(teacher_monitor_data, by = "nrodocumento")

# Create master dataset (expediente level) -------------------------------

reportes <- reportes %>%
  distinct() %>%
  mutate(
    juez = str_replace_all(juez, "\\(\\*\\)", ""),
    juez = str_replace_all(juez, "\\,", ""),
    juez = str_replace_all(juez, "\\([^()]{0,}\\)", ""),
    # Replace trailing whitespace and special characters
    juez = str_replace(juez, "^\\s", ""),
    juez = str_replace_all(juez, "\\,", ""),
    juez = str_replace(juez, "\\.$", ""),
    juez = str_replace(juez, " \\- JUZ$", ""),
    juez = str_replace(juez, "\\*", ""),
    # Replace others
    juez = str_replace(juez, "\\- MIXTO Y LIQ", ""),
    juez = str_replace(juez, "\\- MIXTO", ""),
    juez = str_replace(juez, "\\- JUZ\\. MIXTO", ""),
    juez = str_replace(juez, "- JM", ""),
    juez = str_replace(juez, "- INVESTIGACION", ""),
    juez = str_replace(juez, "- PAZ LETRADO", ""),
    juez = str_replace(juez, "SECOM - ", ""),
    juez = str_replace(juez, "- JT", ""),
    # Replace points
    juez = str_replace(juez, "ALFREDO E\\.", "ALFREDO E"),
    juez = str_replace(juez, "BERTHA F\\.", "BERTHA F"),
    juez = str_replace(juez, "CLAUDIO W\\.", "CLAUDIO W"),
    juez = str_replace(juez, "CLAVELITO L\\.", "CLAVELITO L"),
    juez = str_replace(juez, "ELMER L\\.", "ELMER L"),
    juez = str_replace(juez, "ERNESTO A\\.", "ERNESTO A"),
    juez = str_replace(juez, "HERBERT M\\.", "HERBERT M"),
    juez = str_replace(juez, "LUZ K\\.", "LUZ K"),
    juez = str_replace(juez, "NANCY S\\.", "NANCY S"),
    juez = str_replace(juez, "JESSICA E\\.", "JESSICA E"),
    juez = str_replace(juez, "PATRICIA C\\.", "PATRICIA C"),
    juez = str_replace(juez, "JESSICA P\\.", "JESSICA P"),
    juez = str_replace(juez, "YOLANDA B\\.", "YOLANDA B"),
    juez = str_replace(juez, "LUZ M\\.", "LUZ M"),
    juez = str_replace(juez, "EDGAR\\.", "EDGAR"),
    juez = str_replace(juez, "C\\. ARTURO", "C ARTURO"),
    juez = str_replace(juez, "ALEXANDER A\\.", "ALEXANDER A"),
    juez = str_replace(juez, "RENE G\\.", "RENE G"),
    juez = str_replace(juez, "GUILLERMO S\\.", "GUILLERMO S"),
    juez = str_replace(juez, "FANNY L\\. ", "FANNY L"),
    juez = str_replace(juez, "ELISA \\(LA", "ELISA"),
    juez = str_replace(juez, "JULIA \\(LA", "JULIA"),
    juez = str_replace(juez, "ACEVEDO DIEZ CECILIA", "ACEVEDO DIEZ CECILIA DEL PILAR"),
    # Remove whitespace
    juez = str_squish(juez)) %>%
  replace_na(list(juez = "<NO DEFINIDO>")) %>%
  select(expediente_n, juez)

# Create dataset with all judge names
judge_names <- reportes %>%
  group_by(juez) %>%
  summarise(juez = first(juez)) %>%
  mutate(
    # Create number of judges per case
    n_judges_case = str_count(juez, pattern = "\\.") + 1)

# Create dataset for cases with multiple judges
multiple_judge_names <- judge_names %>%
  filter(!n_judges_case == 1) %>%
  separate(juez,
    c("juez1", "juez2", "juez3", "juez4", "juez5", "juez6"),
    sep = "\\.",
    remove = FALSE) %>%
    mutate(across(starts_with("juez"), ~ifelse(is.na(.x),"\\-",.x)))

# Perform fuzzy join to match participants

# Try apellido-nombre
matched_judge_name1 <- masterdata_participant %>%
  select(participant_apellido_nombre, nrodocumento) %>%
  stringdist_left_join(judge_names,
    by = c("participant_apellido_nombre" = "juez"), "lv", 2) %>%
  filter(!is.na(juez)) %>%
  select(nrodocumento, juez)

# Try nombre-apellido
matched_judge_name2 <- masterdata_participant %>%
  select(participant_nombre_apellido, nrodocumento) %>%
  stringdist_left_join(judge_names, "lv", 2,
    by = c("participant_nombre_apellido" = "juez")) %>%
  filter(!is.na(juez))  %>%
  select(nrodocumento, juez)

# Try apellido nombre for multiple judges
matched_judge_name3 <- masterdata_participant %>%
  select(participant_nombre_apellido, nrodocumento) %>%
  stringdist_left_join(multiple_judge_names,
    by = c("participant_nombre_apellido" = "juez3"), method = "lv", max_dist = 2) %>%
  filter(!is.na(juez))  %>%
  select(nrodocumento, juez)

matched_judge_name4 <- masterdata_participant %>%
  select(participant_apellido_nombre, nrodocumento) %>%
  stringdist_left_join(multiple_judge_names,
    by = c("participant_apellido_nombre" = "juez3"), method = "lv", max_dist = 2) %>%
  filter(!is.na(juez)) %>%
  select(nrodocumento, juez)

# Join  datasets
matched_judge_name <- matched_judge_name1 %>%
  bind_rows(matched_judge_name2) %>%
  bind_rows(matched_judge_name3) %>%
  bind_rows(matched_judge_name4)

# Create dataset with all cases managed by an AMAG Judge
masterdata_case_id <- matched_judge_name %>%
  left_join(reportes, by = "juez") %>%
  left_join(masterdata_participant, by = "nrodocumento")

# Create new identifiers for each person and case-id

masterdata_participant <- masterdata_participant %>%
  arrange(nrodocumento) %>%
  rowid_to_column("participant_id")

masterdata_participant_round <- masterdata_participant %>%
  select(nrodocumento, participant_id) %>%
  left_join(masterdata_participant_round, by = "nrodocumento")

masterdata_case_id <- masterdata_participant %>%
  select(nrodocumento, participant_id) %>%
  inner_join(masterdata_case_id, by = "nrodocumento") %>%
  arrange(nrodocumento, expediente_n) %>%
  rowid_to_column("case_id")


# Save datasets ----------------------------------------------------------

## Save raw datasets with identifying information and project id

# Save master dataset - participant level
write_csv(masterdata_participant,
  paste0(data_amag_raw, "raw_data/", "00_research_design/",
  "01_master_datasets/master_dataset_participant_identified.csv"))

# Save master dataset - participant-round level
write_csv(masterdata_participant_round,
  paste0(data_amag_raw, "raw_data/", "00_research_design/",
  "01_master_datasets/master_dataset_participant_round_identified.csv"))

# Save master dataset - case id.
write_csv(masterdata_case_id,
  paste0(data_amag_raw, "raw_data/", "00_research_design/",
  "01_master_datasets/master_dataset_case_id_identified.csv"))

## Save project id datasets

# Save master dataset - participant level
masterdata_participant %>%
  select(nrodocumento, participant_id) %>%
  write_csv(paste0(data_amag_raw, "raw_data/", "00_research_design/",
    "02_project_ids/master_dataset_participant.csv"))

# Save master dataset - participant-round level
masterdata_participant_round %>%
  select(nrodocumento, participant_id, round) %>%
  write_csv(paste0(data_amag_raw, "raw_data/", "00_research_design/",
    "02_project_ids/master_dataset_participant_round.csv"))

# Save master dataset - case id.
masterdata_case_id %>%
  select(nrodocumento, participant_id, expediente_n, case_id) %>%
  write_csv(paste0(data_amag_raw, "raw_data/", "00_research_design/",
    "02_project_ids/master_dataset_case_id.csv"))

## Save de-identified master datasets

# Save master dataset - participant level
masterdata_participant %>%
  select(
    participant_id,
    participant_level_2,
    participant_level_3,
    participant_judge,
    participant_prosecutor,
    participant_female,
    participant_age,
    participant_years_tenure,
    participant_years_bar_assoc,
    participant_criminal_court,
    participant_criminal_prosecutor,
    location_rand1,
    percent_monit,
    ever_treated,
    always_treated,
    always_treated_never_treated,
    treated_60,
    ratio_teacher_female,
    ratio_female_monit) %>%
  write_csv(paste0(data_amag_raw, "raw_deidentified/", "00_research_design/",
    "master_dataset_participant.csv"))

# Save master dataset - participant-round level
masterdata_participant_round %>%
  select(
    participant_id,
    participant_level_2,
    participant_level_3,
    participant_judge,
    participant_prosecutor,
    participant_female,
    participant_age,
    participant_years_tenure,
    participant_years_bar_assoc,
    participant_criminal_court,
    participant_criminal_prosecutor,
    location_rand1,
    round,
    aula,
    idcurso,
    monitoreo,
    teacher_female,
    monitor_female) %>%
  write_csv(paste0(data_amag_raw, "raw_deidentified/", "00_research_design/",
    "master_dataset_participant_round.csv"))

# Save master dataset - case id.
masterdata_case_id %>%
  select(
    case_id,
    participant_id,
    participant_level_2,
    participant_level_3,
    participant_judge,
    participant_prosecutor,
    participant_female,
    participant_age,
    participant_years_tenure,
    participant_years_bar_assoc,
    participant_criminal_court,
    participant_criminal_prosecutor,
    location_rand1,
    percent_monit,
    ever_treated,
    always_treated,
    always_treated_never_treated,
    treated_60,
    ratio_teacher_female,
    ratio_female_monit) %>%
  write_csv(paste0(data_amag_raw, "raw_deidentified/", "00_research_design/",
    "master_dataset_case_id.csv"))
