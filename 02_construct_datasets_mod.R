## Construct datasets script

# Load helper (standardize outcomes) functions
source(paste0(github_path, "utils/utils_standardize_outcomes.R"))

# Load datasets -----

# Load master dataset (participant level)
# this should be your list of AMAG-II participants
masterdata_participant <- read_dta(paste0(
  local_storage,
  "Clean_Full_Data12.dta"))

# Load master dataset (case-id level)
# this should be your list of AMAG-II cases (output from 01_create_master_dataset)
masterdata_case_id <- read_csv(paste0(
  local_storage,
  "master_dataset_case_id_identified.csv"))

# Case outcomes (case-id level)
# this should be your output of "04_clean_case_outcomes.R"
case_outcomes <- read_csv(paste0(
  data_amag_int, "05_case_outcomes/case_outcomes.csv"))

# ------------------------------------------------------------------

# Join datasets ----

# Create dataset at the case-id level
# here we are merging the list of amag-ii participants with the output from "04_clean_case_outcomes.R"
data_participant_caseid <- masterdata_case_id %>%
  inner_join(case_outcomes, by = c("case_id", "participant_id"))

# ------------------------------------------------------------------

# Construct variables ----

# THIS SECTION COLLAPSES THE OUTCOMES WE ARE INTERERESTED IN AT THE JUDGE-MONTH LEVEL:

# Create case outcomes variables at the month-judge level
# For post-treatment regression

fundada_appeal_var <- data_participant_caseid %>%
  filter(sentence_after_pca == 1) %>%
  group_by(participant_id, month_year_sentence) %>%
  summarise(
    var_fundada = mean(var_fundada, na.rm = TRUE),
    var_uncon_reversal = mean(var_uncon_reversal, na.rm = TRUE),
    var_appeal = mean(var_appeal, na.rm = TRUE)) %>%
  rename(month_year = month_year_sentence)  %>%
  ungroup()

resolution_var <- data_participant_caseid %>%
  filter(first_auto_after_pca == 1) %>%
  group_by(participant_id, month_year_first_auto) %>%
  summarise(
    percent_monit = first(percent_monit),
    var_resolution = mean(var_resolution, na.rm = TRUE)) %>%
  rename(month_year = month_year_first_auto) %>%
  ungroup() %>%
  # Standardize outcome
  std_outcome(var_resolution, var_resolution_std, percent_monit)

days_to_res_var <- data_participant_caseid %>%
  filter(resolution_after_pca == 1) %>%
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

# Create case outcomes variables at the month-judge level
# for DiD regression

fundada_appeal_var_did <- data_participant_caseid %>%
  filter(date_sentence > ymd(20180501)) %>%
  filter(!sentence_during_pca == 1) %>%
  group_by(participant_id, month_year_sentence) %>%
  summarise(
    sentence_after_pca = first(sentence_after_pca),
    var_fundada = mean(var_fundada, na.rm = TRUE),
    var_uncon_reversal = mean(var_uncon_reversal, na.rm = TRUE),
    var_appeal = mean(var_appeal, na.rm = TRUE)) %>%
  rename(month_year = month_year_sentence)

resolution_var_did <- data_participant_caseid %>%
  filter(date_first_auto > ymd(20180501)) %>%
  filter(!first_auto_during_pca == 1) %>%
  group_by(participant_id, month_year_first_auto) %>%
  summarise(
    percent_monit = first(percent_monit),
    first_auto_after_pca = first(first_auto_after_pca),
    var_resolution = mean(var_resolution, na.rm = TRUE)) %>%
  rename(month_year = month_year_first_auto) %>%
  ungroup()  %>%
  # Standardize outcome
  std_outcome(var_resolution, var_resolution_std, percent_monit)

days_to_res_var_did <- data_participant_caseid %>%
  filter(date_resolution > ymd(20180501)) %>%
  filter(!resolution_during_pca == 1) %>%
  group_by(participant_id, month_year_resolution) %>%
  summarise(
    percent_monit = first(percent_monit),
    resolution_after_pca = first(resolution_after_pca),
    var_timely_resolved = mean(timely_resolved, na.rm = TRUE),
    length_auto_resolution = mean(length_auto_resolution, na.rm = TRUE)) %>%
  rename(month_year = month_year_resolution) %>%
  ungroup()  %>%
  # Standardize outcome
  std_outcome(var_timely_resolved, var_timely_resolved_std, percent_monit) %>%
  std_outcome(length_auto_resolution, length_auto_resolution_std, percent_monit)

# Join datasets

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

# Create DiD datasets
fundada_appeal_data_did <- data_participant %>%
  inner_join(fundada_appeal_var_did) %>%
  inner_join(fundada_appeal_judges) %>%
  mutate(
    percent_monit_full = percent_monit,
    after_pca = sentence_after_pca,
    percent_monit = case_when(
    sentence_after_pca == 0 ~ 0,
    sentence_after_pca == 1 ~ percent_monit))

resolution_data_did <- data_participant %>%
  inner_join(resolution_var_did) %>%
  inner_join(resolution_judges)  %>%
  mutate(
    percent_monit_full = percent_monit,
    percent_monit = case_when(
    first_auto_after_pca == 0 ~ 0,
    first_auto_after_pca == 1 ~ percent_monit))

days_to_res_data_did <- data_participant %>%
  inner_join(days_to_res_var_did) %>%
  inner_join(days_to_res_judges) %>%
  mutate(
    percent_monit_full = percent_monit,
    percent_monit = case_when(
    resolution_after_pca == 0 ~ 0,
    resolution_after_pca == 1 ~ percent_monit))

# Save analysis datasets ----


write_csv(data_participant_caseid,
  paste0(local_storage, "dataset_participant_caseid.csv"))

write_csv(fundada_appeal_data_post,
  paste0(local_storage, "dataset_caseid_month_fundada_post.csv"))

write_csv(resolution_data_post,
  paste0(local_storage, "dataset_caseid_month_resolution_post.csv"))

write_csv(days_to_res_data_post,
  paste0(local_storage, "dataset_caseid_month_days_to_res_post.csv"))

write_csv(fundada_appeal_data_did,
  paste0(local_storage, "dataset_caseid_month_fundada_did.csv"))

write_csv(resolution_data_did,
  paste0(local_storage, "dataset_caseid_month_resolution_did.csv"))

write_csv(days_to_res_data_did,
  paste0(local_storage, "dataset_caseid_month_days_to_res_did.csv"))