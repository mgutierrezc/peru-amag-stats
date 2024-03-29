# Preprocess and clean datasets -------------------------------

# Load AMAG II cases dataset
amag_ii_cases <- read_csv(file.path(
  local_storage, "raw", "amag_ii_cases.csv")) %>%
  select(expediente_n, nrodocumento)

# # Load gender dataset from AMAG-I
gender_dataset <- read_csv(file.path(
  data_amag_i, "02_raw", "master_monit", "raw_data", "07_others", "00_gender/harvard_set_gender.csv"))

# Downloads
downloads_amag <- read_csv(
  file.path(local_storage, "raw", "downloads_amag_ii_raw.csv")) %>%
  mutate(
    # Remove extra white space and lower text
    text = str_squish(tolower(text)),
    # Remove special characters from text
    text = stri_trans_general(text, id = "Latin-ASCII"))

# Follow_up
follow_up_amag <- read_csv(
  file.path(local_storage, "raw", "follow_up_amag_ii_raw.csv")) %>%
  # Create vars that identify resolution date and hour
  separate(fecha_de_resolucion_ingreso, c("date", "hour"),
    remove = FALSE,
    sep = " ") %>%
  mutate(
    # Convert date var to date format
    date = dmy(date),
    # Remove extra white space and lower acto
    acto = str_squish(tolower(acto)),
    # Remove extra white space and lower sumilla
    sumilla = str_squish(tolower(sumilla)),
    # Remove special characters from sumilla
    sumilla = stri_trans_general(sumilla, id = "Latin-ASCII"),
    # Remove extra white space and lower descripcion de usuario
    descripcion_de_usuario = str_squish(tolower(descripcion_de_usuario)),
    # Create variable that identifies rows with pdf
    # or docx file in downloads dataset
    download = if_else(str_detect(descripcion_de_usuario, "descargado"), 1, 0))

# Preprocess datasets -----------------------------------------------------

# Preprocess follow_up and downloads ------------------------------------

# Create id_dup and dup identifiers in downloads dataset
downloads_amag <- downloads_amag %>%
  select(-file_path) %>%
  distinct() %>%
  group_by(expediente_n) %>%
  mutate(
    id_dup = if_else(duplicated(num), 1, 0),
    dup = na_if(id_dup, 0)) %>%
  fill(dup, .direction = "downup") %>%
  arrange(expediente_n, id_dup, num)

# Create dataset of case_id/number of documents (duplicates)
list_downloads_dupes <- downloads_amag %>%
  filter(dup == 1) %>%
  group_by(expediente_n, id_dup) %>%
  summarise(count = n())

# Create dataset of unique case_id/number of documents
list_follow_up_unique <- follow_up_amag %>%
  filter(!is.na(link)) %>%
  group_by(expediente_n) %>%
  summarise(count = n())

# Merge both datasets and filter duplicates of case_id/number of documents
list_downloads_unique <- list_downloads_dupes %>%
  inner_join(list_follow_up_unique, by = c("expediente_n", "count")) %>%
  group_by(expediente_n) %>%
  mutate(
    id_dup2 = if_else(duplicated(count), 1, 0),
    dup2 = na_if(id_dup2, 0)) %>%
  fill(dup2, .direction = "downup") %>%
  filter(is.na(dup2)) %>%
  select(expediente_n, id_dup)  %>%
  mutate(unique_id = 1)

# Split downloads in unique and dup link
downloads_1 <- downloads_amag %>%
  filter(is.na(dup))

downloads_2 <- downloads_amag %>%
  filter(!is.na(dup)) %>%
  left_join(list_downloads_unique) %>%
  filter(unique_id == 1)

# Bind datasets and join with follow_up
downloads_full <- downloads_1 %>%
  bind_rows(downloads_2)

documents_amag <- follow_up_amag %>%
  left_join(downloads_full, by = c("expediente_n", "nrodocumento", "link"))

# Identify keywords from text, acto and sumilla columns ----------------
documents_amag <- documents_amag %>%
# Filter rows without information
filter(acto != "auto de saneamiento") %>%
filter(acto != "nota") %>%
  mutate(text = replace_na(text, "."))  %>%
  mutate(
    # Parte resolutiva
    parte_resolutiva = str_extract(text, "\\bresuelve\\s*([^\\n\\r]*)|\\bfallo\\s*([^\\n\\r]*)|\\bresuelvo\\s*([^\\n\\r]*)"),
    parte_resolutiva = replace_na(parte_resolutiva, "."),
    # Apela variable
    appeal = if_else(
      str_detect(acto, "apela") |
      str_detect(sumilla, "apela"), 1, 0),
    # Sentencia or final variable
    sentencia_acto = if_else(
      str_detect(acto, "sentencia"), 1, 0),
    sentencia_text = if_else(
      str_detect(text, "sentencia"), 1, 0),
    sentencia_sumilla = if_else(
      str_detect(sumilla, "sentencia"), 1, 0),
    sentencia = if_else(
      str_detect(acto, "sentencia") |
      str_detect(sumilla, "sentencia"), 1, 0),
    # Auto variable
    auto_final = if_else(
      str_detect(acto, "auto final") |
      str_detect(sumilla, "auto final"), 1, 0),
    auto_definitivo = if_else(
      str_detect(acto, "auto definitivo") |
      str_detect(sumilla, "auto definitivo"), 1, 0),
    # Final
    auto_improcedente = if_else(
      str_detect(acto, "auto que declara improcedente") |
      str_detect(sumilla, "auto que declara improcedente") |
      str_detect(sumilla, "auto improcedente") |
      str_detect(acto, "auto improcedente"), 1, 0),
    # Vista variable
    vista2 = if_else(
      str_detect(acto, "sentencia de vista") |
      str_detect(sumilla, "sentencia de vista") |
      str_detect(acto, "auto de vista") |
      str_detect(sumilla, "auto de vista"), 1, 0),
    # Revoca variable
    revoca2 = if_else(
      str_detect(acto, "vista que revoca"), 1, 0),
    # Anula variable
    nula2 = if_else(
      str_detect(acto, "vista que anula"), 1, 0),
    # Confirma variable
    confirma2 = if_else(
      str_detect(acto, "vista que confirma"), 1, 0),
    # Fundada variable
    fundada = if_else(
      str_detect(sumilla, "^\\Qfundada la demanda") |
      str_detect(sumilla, " fundada la demanda") |
      str_detect(parte_resolutiva, "^\\Qfundada la demanda") |
      str_detect(parte_resolutiva, " fundada la demanda") |
      str_detect(acto, "sentencia fundada") |
      str_detect(sumilla, "sentencia fundada"), 1, 0),
    # Fundada en parte
    fundada_parte = if_else(
      str_detect(sumilla, "fundada en parte") |
      str_detect(parte_resolutiva, "fundada en parte") |
      str_detect(acto, "fundada en parte"), 1, 0),
    # Infundada variable
    infundada = if_else(
      str_detect(sumilla, "infundada la demanda") |
      str_detect(parte_resolutiva, "infundada la demanda") |
      str_detect(acto, "sentencia infundada") |
      str_detect(sumilla, "sentencia infundada"), 1, 0),
    # Vista variable
    vista = if_else(
      str_detect(acto, "sentencia de vista") |
      str_detect(sumilla, "sentencia de vista") |
      str_detect(acto, "auto de vista") |
      str_detect(sumilla, "auto de vista"), 1, 0),
    # Revoca variable
    revoca = if_else(
      str_detect(acto, "vista que revoca") |
      str_detect(parte_resolutiva, "revocar la sentencia") |
      str_detect(parte_resolutiva, "revocar la resolucion") |
      str_detect(parte_resolutiva, "revocar la resolución") |
      str_detect(parte_resolutiva, "revocar en parte") |
      str_detect(parte_resolutiva, "revocaron la sentencia") |
      str_detect(parte_resolutiva, "revocaron la resolución") |
      str_detect(parte_resolutiva, "revocaron la resolucion") |
      str_detect(sumilla, "revocar la sentencia") |
      str_detect(sumilla, "revocar la resolucion") |
      str_detect(sumilla, "revocar la resolución") |
      str_detect(sumilla, "revocar en parte") |
      str_detect(sumilla, "revocaron la sentencia") |
      str_detect(sumilla, "revocaron la resolución") |
      str_detect(sumilla, "revocaron la resolucion"), 1, 0),
    # Anula variable
    nula = if_else(
      str_detect(acto, "vista que anula") |
      str_detect(parte_resolutiva, "declarar nula") |
      str_detect(parte_resolutiva, "declara nula") |
      str_detect(parte_resolutiva, "declara nulo") |
      str_detect(parte_resolutiva, "declarar nulo") |
      str_detect(parte_resolutiva, "declarar: nula") |
      str_detect(parte_resolutiva, "declarar la nulidad") |
      str_detect(parte_resolutiva, "declararon nula") |
      str_detect(sumilla, "declarar nula") |
      str_detect(sumilla, "declara nula") |
      str_detect(sumilla, "declara nulo") |
      str_detect(sumilla, "declarar nulo") |
      str_detect(sumilla, "declarar: nula") |
      str_detect(sumilla, "declarar la nulidad") |
      str_detect(sumilla, "declararon nula"), 1, 0),
    # Confirma variable
    confirma = if_else(
      str_detect(acto, "vista que confirma") |
      str_detect(sumilla, "confirmaron el auto") |
      str_detect(sumilla, "confirmaron la sentencia") |
      str_detect(sumilla, "aprobaron la sentencia") |
      str_detect(sumilla, "confirma sentencia") |
      str_detect(sumilla, "confirma la sentencia") |
      str_detect(sumilla, "confirmar la sentencia") |
      str_detect(sumilla, "confirmar resolucion") |
      str_detect(sumilla, "confirmar resolución") |
      str_detect(sumilla, "confirmar la resolucion") |
      str_detect(sumilla, "confirmar en parte") |
      str_detect(sumilla, "confirmar la resolución") |
      str_detect(parte_resolutiva, "confirmaron el auto") |
      str_detect(parte_resolutiva, "confirmaron la sentencia") |
      str_detect(parte_resolutiva, "aprobaron la sentencia") |
      str_detect(parte_resolutiva, "confirma sentencia") |
      str_detect(parte_resolutiva, "confirma la sentencia") |
      str_detect(parte_resolutiva, "confirmar la sentencia") |
      str_detect(parte_resolutiva, "confirmar resolucion") |
      str_detect(parte_resolutiva, "confirmar resolución") |
      str_detect(parte_resolutiva, "confirmar la resolucion") |
      str_detect(parte_resolutiva, "confirmar en parte") |
      str_detect(parte_resolutiva, "confirmar la resolución"), 1, 0))

# Preprocess reportes --------------------------------------------

reportes_amag <- read_csv(
  file.path(local_storage, "raw", "reportes_amag_ii_raw.csv")) %>%
  select(
    expediente_n, distrito_judicial, proceso,
    especialidad, estado, etapa_procesal)

# Preprocess procedural parts ---------------------------------

# Match gender dataset with procedural parts (first name)
procedural_parts_amag <- read_csv(
  file.path(local_storage, "raw", "procedural_parts_amag_ii_raw.csv")) %>%
  mutate(
  # Create parties variable
    parties = case_when(
      parte == "DEMANDANTE" ~ "plaintiff",
      parte == "AGRAVIADO" ~ "plaintiff",
      parte == "VÍCTIMA" ~ "plaintiff",
      parte == "VICTIMA" ~ "plaintiff",
      parte == "SOLICITANTE" ~ "plaintiff",
      parte == "DENUNCIANTE" ~ "plaintiff",
      parte == "DEMANDADO" ~ "defendant",
      parte == "AGRESOR" ~ "defendant",
      parte == "DENUNCIADO" ~ "defendant",
      TRUE ~ "other"),
    # Nombres to lower
    nombres = tolower(nombres),
    # Create legal entity identifier
    legal_entity = if_else(tipo_de_persona == "JURIDICA", 1, 0)) %>%
  # Filter defendant/plaintiff rows
  filter(parties == "plainltiff" | parties == "defendant") %>%
  separate(
  nombres, c("first_name", "second_name"),
  extra = "drop", fill = "right")

# Join with gender dataset
procedural_parts_amag <- procedural_parts_amag %>%
  # Join by first name
  left_join(gender_dataset, by = c("first_name" = "name")) %>%
  rename(female_first = female) %>%
  # Join by second name
  left_join(gender_dataset, by = c("second_name" = "name")) %>%
  rename(female_second = female) %>%
  mutate(
    female = case_when(
      female_first == 1 ~ 1,
      female_first == 0 ~ 0,
      female_second == 1 ~ 1,
      female_second == 0 ~ 0,
      # We prioritize the first name
      female_first == 1 & female_second == 0 ~ 1,
      female_first == 0 & female_second == 1 ~ 0))

# Collapse at the expediente level and reshape
procedural_parts_amag <- procedural_parts_amag %>%
  select(expediente_n, parties, female, legal_entity) %>%
  group_by(expediente_n, parties) %>%
  summarise(
    female_ratio = mean(female, na.rm = TRUE),
    legal_entity_ratio = mean(legal_entity, na.rm = TRUE),
    female_indicator = max(female),
    legal_entity_indicator = max(legal_entity)) %>%
  pivot_wider(
    names_from = parties,
    values_from = c(
      "female_ratio", "legal_entity_ratio",
      "female_indicator", "legal_entity_indicator"))

# Save datasets
write_csv(documents_amag,
  file.path(local_storage, "intermediate", "documents_amag_ii_clean.csv"))

write_csv(reportes_amag,
  file.path(local_storage, "intermediate", "reportes_amag_ii_clean.csv"))

write_csv(procedural_parts_amag,
  file.path(local_storage, "intermediate", "procedural_parts_amag_ii_clean.csv"))
