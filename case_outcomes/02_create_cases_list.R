## Data script to create cases dataset

# Load List of AMAG-II participants
amag_ii_participants <- read_csv(
  file.path(local_storage, "raw", "amag_ii_participants_list.csv"))

# Cases data
## Get the file names
files <- list.files(
  path = file.path(data_cej, "data_cleaned"),
  pattern = "*.csv",
  recursive = TRUE)

## Select reporte files
files_reportes <- files[str_detect(files, "file_report")]
files_reportes <- files_reportes[!str_detect(files_reportes, "2017")]

## Load datasets
reportes <- lapply(
  file.path(data_cej, "data_cleaned", files_reportes), read_csv) %>%
  bind_rows() %>%
  clean_names()

# Create master dataset (expediente level) -------------------------------

# Clean file reports dataset
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
  mutate(across(starts_with("juez"), ~ifelse(is.na(.x), "\\-", .x)))

# Perform fuzzy join to match participants

# Try apellido-nombre
matched_judge_name1 <- amag_ii_participants %>%
  select(participant_apellido_nombre, nrodocumento) %>%
  stringdist_left_join(judge_names, "lv", 2,
    by = c("participant_apellido_nombre" = "juez")) %>%
  filter(!is.na(juez)) %>%
  select(nrodocumento, juez)

# Try nombre-apellido
matched_judge_name2 <- amag_ii_participants %>%
  select(participant_nombre_apellido, nrodocumento) %>%
  stringdist_left_join(judge_names, "lv", 2,
    by = c("participant_nombre_apellido" = "juez")) %>%
  filter(!is.na(juez))  %>%
  select(nrodocumento, juez)

# Try apellido nombre for multiple judges
matched_judge_name3 <- amag_ii_participants %>%
  select(participant_nombre_apellido, nrodocumento) %>%
  stringdist_left_join(multiple_judge_names, "lv", 2,
    by = c("participant_nombre_apellido" = "juez3")) %>%
  filter(!is.na(juez))  %>%
  select(nrodocumento, juez)

matched_judge_name4 <- amag_ii_participants %>%
  select(participant_apellido_nombre, nrodocumento) %>%
  stringdist_left_join(multiple_judge_names, "lv", 2,
    by = c("participant_apellido_nombre" = "juez3")) %>%
  filter(!is.na(juez)) %>%
  select(nrodocumento, juez)

# Join  datasets
matched_judge_name <- matched_judge_name1 %>%
  bind_rows(matched_judge_name2) %>%
  bind_rows(matched_judge_name3) %>%
  bind_rows(matched_judge_name4)

# Check if there are duplicates
get_dupes(matched_judge_name, nrodocumento)

# Create dataset with all cases managed by an AMAG-II Judges
amag_ii_cases <- matched_judge_name %>%
  # Join with reportes dataset
  left_join(reportes, by = "juez") %>%
  # Join with participant's characteristics
  left_join(amag_ii_participants, by = "nrodocumento")

# Save datasets ----------------------------------------------------------

## Save raw datasets with identifying information and project id

amag_ii_cases %>%
  write_csv(file.path(local_storage, "raw", "amag_ii_cases.csv"))