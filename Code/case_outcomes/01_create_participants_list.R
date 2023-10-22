# Data Import

df <- read_dta(file.path(local_storage, "raw", "Clean_Full_Data12.dta"))

# Data Cleaning

df <- df %>%
  mutate(
  # Create single column for judge names
  participant_nombre_apellido = paste(Nombres, ApellidoPaterno, ApellidoMaterno, sep = " "),
  participant_apellido_nombre = paste(ApellidoPaterno, ApellidoMaterno, Nombres, sep = " "),
  # Remove whitespace
  participant_apellido_nombre = str_squish(participant_apellido_nombre),
  participant_nombre_apellido = str_squish(participant_nombre_apellido)) %>%
  rename(nrodocumento = DNI)

# Subset DF to create list of Judges Names and DNI Numbers
df_subset <- df %>%
  select(nrodocumento, participant_nombre_apellido, participant_apellido_nombre) %>%
# Drop duplicate observations
  distinct() %>%
# Remove NA values for DNI| nrodocumento
  drop_na(nrodocumento)

# Create CSV output
write.csv(df_subset,
  file.path(local_storage, "raw", "amag_ii_participants_list.csv"),
  row.names = FALSE)