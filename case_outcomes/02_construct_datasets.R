## Construct datasets script

# Load helper (standardize outcomes) functions
source(paste0(github_path, "utils/utils_standardize_outcomes.R"))

# Load datasets -----

# Load master dataset (participant level)
masterdata_participant <- read_csv(paste0(
  data_amag_raw, "raw_deidentified/", "00_research_design/",
  "master_dataset_participant.csv"))

# Load master dataset (participant-round level)
masterdata_participant_round <- read_csv(paste0(
  data_amag_raw, "raw_deidentified/", "00_research_design/",
  "master_dataset_participant_round.csv"))

# Load master dataset (case-id level)
masterdata_case_id <- read_csv(paste0(
  data_amag_raw, "raw_deidentified/", "00_research_design/",
  "master_dataset_case_id.csv"))

# Load IAT data (participant level)
iat_data <- read_csv(paste0(
  data_amag_int, "03_iat/iat_data_clean.csv"))

# Load logs-blackboard data (participant-round level)
logs_data <- read_csv(paste0(
  data_amag_int, "07_logs_blackboard/log_blackboard_participant_round.csv"))

# Load satisfaction data (participant-round-meeting level)
satisfaction_data <- read_csv(paste0(
  data_amag_int, "01_satisfaction/monitoring_satisfaction.csv"))

# Load grade data (participant-round level)
grade_data <- read_csv(paste0(
  data_amag_int, "02_grades/all_grades.csv"))

# Case outcomes (case-id level)
case_outcomes <- read_csv(paste0(
  data_amag_int, "05_case_outcomes/case_outcomes.csv"))

# ------------------------------------------------------------------

# Join datasets ----

# Create dataset at the participant level
data_participant <- masterdata_participant %>%
  left_join(iat_data, by = "participant_id")

# Create dataset at the participant-round level
data_participant_round <- masterdata_participant_round %>%
  # Join datasets
  left_join(logs_data, by = c("participant_id", "round")) %>%
  left_join(grade_data, by = c("participant_id", "round")) %>%
  mutate(
    # Create male and female arms for treatment
    monitoring_two_arms = replace_na(monitor_female, 2))

# Create dataset at the participant_round_meeting level
data_participant_round_meeting <- masterdata_participant_round %>%
  left_join(satisfaction_data, by = c("participant_id", "round", "aula"))

# Create dataset at the case-id level
data_participant_caseid <- masterdata_case_id %>%
  inner_join(case_outcomes, by = c("case_id", "participant_id"))

# ------------------------------------------------------------------

# Construct variables ----

data_participant <- data_participant %>%
  # Standardize IAT scores
  std_outcome(iat_score, iat_score_std, percent_monit)

data_participant_round <- data_participant_round %>%
  # Standardize grade outcomes
  std_outcome(nota_foro, nota_foro_std, monitoreo) %>%
  std_outcome(nota_lectura, nota_lectura_std, monitoreo) %>%
  std_outcome(nota_practica_final, nota_practica_final_std, monitoreo) %>%
  std_outcome(examen_final, examen_final_std, monitoreo) %>%
  std_outcome(promedio_final, promedio_final_std, monitoreo) %>%
  mutate(
  # Replace NAs with zero for participants
  participant_criminal_court = replace_na(participant_criminal_court, 0),
  participant_criminal_prosecutor = replace_na(participant_criminal_prosecutor, 0),
  # Create two arms treatment
  two_arms = replace_na(monitor_female, 2))

data_participant_round_meeting <- data_participant_round_meeting %>%
  # Standardize satisfaction outcomes
  std_outcome(sobre_las_expectativas, sobre_las_expectativas_std, monitoreo) %>%
  std_outcome(sobre_el_docente, sobre_el_docente_std, monitoreo) %>%
  # Replace NAs with zero for participants
  mutate(
    participant_criminal_court = replace_na(participant_criminal_court, 0),
    participant_criminal_prosecutor = replace_na(participant_criminal_prosecutor, 0))

# Create additional variables

# Create speciality covariates
speciality_data <- data_participant_caseid %>%
  filter(date_first_auto > ymd(20210101)) %>%
  group_by(participant_id) %>%
  summarise(
    speciality_civil_m = mean(speciality_civil),
    speciality_familia_civil_m = mean(speciality_familia_civil),
    speciality_familia_tutelar_m = mean(speciality_familia_tutelar),
    speciality_laboral_m = mean(speciality_laboral),
    speciality_otro_m = mean(speciality_otro))

# Create process covariates
process_data <- data_participant_caseid %>%
  group_by(participant_id) %>%
  summarise(
    process_unico_m = mean(process_unico),
    process_ejecucion_m = mean(process_ejecucion),
    process_sumarisimo_m = mean(process_sumarisimo),
    process_abreviado_m = mean(process_abreviado),
    process_conocimiento_m = mean(process_conocimiento),
    process_no_contencioso_m = mean(process_no_contencioso),
    process_constitucional_m = mean(process_constitucional))

# Create pre-treatment variables
pre_treat_fundada_appeal <- data_participant_caseid %>%
  filter(date_sentence > ymd(20180501)) %>%
  filter(date_sentence < ymd(20200501)) %>%
  group_by(participant_id) %>%
  summarise(
    mean_pretreat_fundada = mean(var_fundada, na.rm = TRUE),
    mean_pretreat_uncon_reversal = mean(var_uncon_reversal, na.rm = TRUE),
    mean_pretreat_reversal = mean(var_reversal, na.rm = TRUE),
    mean_pretreat_appeal = mean(var_appeal, na.rm = TRUE))

pre_treat_resolution <- data_participant_caseid %>%
  filter(date_first_auto > ymd(20180501)) %>%
  filter(date_first_auto < ymd(20200501)) %>%
  group_by(participant_id) %>%
  summarise(
    mean_pretreat_resolution = mean(var_resolution, na.rm = TRUE))

pre_treat_length_resolution <- data_participant_caseid %>%
  filter(date_resolution > ymd(20180501)) %>%
  filter(date_resolution < ymd(20200501)) %>%
  group_by(participant_id) %>%
  summarise(
    mean_pretreat_length_resolution = mean(length_auto_resolution, na.rm = TRUE))

length_resolution <- data_participant_caseid %>%
  filter(date_resolution > ymd(20180501)) %>%
  group_by(case_speciality) %>%
  summarise(
    median_length_resolution = median(length_auto_resolution, na.rm = TRUE),
    mean_length_resolution = mean(length_auto_resolution, na.rm = TRUE))

 data_participant_caseid <- data_participant_caseid %>%
  mutate(timely_resolved = if_else(length_auto_resolution < length_resolution$mean_length_resolution, 1, 0))

# Create case outcome variables

# Create case outcomes variables at the month-judge level
# For post-treatment regression

fundada_appeal_var <- data_participant_caseid %>%
  group_by(participant_id, month_year_sentence) %>%
  summarise(
    var_fundada = mean(var_fundada, na.rm = TRUE),
    var_uncon_reversal = mean(var_uncon_reversal, na.rm = TRUE),
    var_appeal = mean(var_appeal, na.rm = TRUE)) %>%
  rename(month_year = month_year_sentence)  %>%
  ungroup()

resolution_var <- data_participant_caseid %>%
  group_by(participant_id, month_year_first_auto) %>%
  summarise(
    percent_monit = first(percent_monit),
    var_resolution = mean(var_resolution, na.rm = TRUE)) %>%
  rename(month_year = month_year_first_auto) %>%
  ungroup() %>%
  # Standardize outcome
  std_outcome(var_resolution, var_resolution_std, percent_monit)

days_to_res_var <- data_participant_caseid %>%
  group_by(participant_id, month_year_resolution) %>%
  summarise(
    percent_monit = first(percent_monit),
    var_timely_resolved = mean(timely_resolved, na.rm = TRUE),
    length_auto_resolution = mean(length_auto_resolution, na.rm = TRUE)) %>%
  rename(month_year = month_year_resolution) %>%
  ungroup() %>%
  # Standardize outcome
  std_outcome(var_timely_resolved, var_timely_resolved_std, percent_monit) %>%
  std_outcome(length_auto_resolution, length_auto_resolution_std, percent_monit)

# Join datasets

data_participant <- data_participant %>%
  left_join(pre_treat_fundada_appeal, by = "participant_id") %>%
  left_join(pre_treat_resolution, by = "participant_id") %>%
  left_join(pre_treat_length_resolution, by = "participant_id") %>%
  left_join(speciality_data, by = "participant_id")  %>%
  left_join(process_data, by = "participant_id")

data_participant_caseid <- data_participant_caseid %>%
  left_join(pre_treat_fundada_appeal, by = "participant_id") %>%
  left_join(pre_treat_resolution, by = "participant_id") %>%
  left_join(pre_treat_length_resolution, by = "participant_id") %>%
  left_join(speciality_data, by = "participant_id") %>%
  left_join(process_data, by = "participant_id") %>%
  left_join(length_resolution, by = "case_speciality")

# Create post-treatment datasets
fundada_appeal_data_post <- data_participant %>%
  inner_join(fundada_appeal_var)
fundada_appeal_judges <- fundada_appeal_data_post %>% select(participant_id) %>% unique()

resolution_data_post <- data_participant %>%
  inner_join(resolution_var)
resolution_judges <- resolution_data_post %>% select(participant_id) %>% unique()

days_to_res_data_post <- data_participant %>%
  inner_join(days_to_res_var)
days_to_res_judges <- days_to_res_data_post %>% select(participant_id) %>% unique()


# Save analysis datasets ----

write_csv(data_participant,
  paste0(data_amag_fin, "00_analysis/dataset_participant.csv"))

write_csv(data_participant_round,
  paste0(data_amag_fin, "00_analysis/dataset_participant_round.csv"))

write_csv(data_participant_round_meeting,
  paste0(data_amag_fin, "00_analysis/dataset_participant_round_meeting.csv"))

write_csv(data_participant_caseid,
  paste0(data_amag_fin, "00_analysis/dataset_participant_caseid.csv"))

write_csv(fundada_appeal_data_post,
  paste0(data_amag_fin, "00_analysis/dataset_caseid_month_fundada_post.csv"))

write_csv(resolution_data_post,
  paste0(data_amag_fin, "00_analysis/dataset_caseid_month_resolution_post.csv"))

write_csv(days_to_res_data_post,
  paste0(data_amag_fin, "00_analysis/dataset_caseid_month_days_to_res_post.csv"))
