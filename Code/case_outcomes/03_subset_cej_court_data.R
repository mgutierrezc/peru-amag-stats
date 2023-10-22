## Script for creating CEJ datasets

# Load raw data ---------------------------------------------------------

# Get the file names
files <- list.files(
  path = file.path(data_cej, "data_cleaned"),
  pattern = "*.csv",
  recursive = TRUE)

# Select files to load
files_reportes <- files[str_detect(files, "file_report")]
files_reportes <- files_reportes[!str_detect(files_reportes, "2017")]
files_follow_up <- files[str_detect(files, "follow_up")]
files_follow_up <- files_follow_up[!str_detect(files_follow_up, "2017")]
files_procedural_parts <- files[str_detect(files, "procedural_parts")]
files_procedural_parts <- files_procedural_parts[!str_detect(files_procedural_parts, "2017")]
files_downloads <- files[str_detect(files, "DOWNLOADS")]

# Load datasets
reportes <- lapply(
  file.path(data_cej, "data_cleaned", files_reportes), read_csv) %>%
  bind_rows() %>%
  clean_names()

follow_up <- lapply(
  file.path(data_cej, "data_cleaned", files_follow_up), read_csv) %>%
  bind_rows() %>%
  clean_names()

procedural_parts <- lapply(
  file.path(data_cej, "data_cleaned", files_procedural_parts), read_csv) %>%
  bind_rows() %>%
  clean_names()

downloads <- lapply(
  file.path(data_cej, "data_cleaned", files_downloads), read_csv) %>%
  bind_rows() %>%
  clean_names()

# Keep only AMAG-II cases and save raw datasets
amag_ii_cases %>%
  inner_join(reportes) %>%
write_csv(file.path(
  local_storage, "raw", "reportes_amag_ii_raw.csv"))

amag_ii_cases %>%
  inner_join(follow_up) %>%
write_csv(file.path(
  local_storage, "raw", "follow_up_amag_ii_raw.csv"))

amag_ii_cases %>%
  inner_join(procedural_parts) %>%
write_csv(file.path(
  local_storage, "raw", "procedural_parts_amag_ii_raw.csv"))

amag_ii_cases %>%
  inner_join(downloads, by = c("expediente_n" = "expediente_num")) %>%
write_csv(file.path(
  local_storage, "raw", "downloads_amag_ii_raw.csv"))