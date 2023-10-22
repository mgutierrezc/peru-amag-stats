## Construct case outcomes

# Load datasets -----
amag_ii_participants <- read_csv(file.path(
  local_storage, "raw", "amag_ii_participants_list.csv"))

# Load cases list
amag_ii_cases <- read_csv(file.path(
  local_storage, "raw", "amag_ii_cases.csv"))

# Load case outcomes (case-id level)
case_outcomes <- read_csv(file.path(
  local_storage, "intermediate", "case_outcomes_amag_ii.csv"))

# ------------------------------------------------------------------


# Join datasets ----

# Create dataset at the case-id level
data_participant_caseid <- amag_ii_cases %>%
  inner_join(case_outcomes, by = c("expediente_n"))

length_resolution <- data_participant_caseid %>%
  filter(date_resolution > ymd(20180501)) %>%
  group_by(case_speciality) %>%
  summarise(
    median_length_resolution = median(length_auto_resolution, na.rm = TRUE),
    mean_length_resolution = mean(length_auto_resolution, na.rm = TRUE))

data_participant_caseid <- data_participant_caseid %>%
  mutate(timely_resolved = if_else(
    length_auto_resolution < length_resolution$mean_length_resolution, 1, 0))

# ------------------------------------------------------------------

# Construct variables ----

# Create case outcomes variables at the month-judge level
# For post-treatment regression

fundada_appeal_var <- data_participant_caseid %>%
  filter(sentence_after_treatment == 1) %>%
  group_by(nrodocumento, month_year_sentence) %>%
  summarise(
    var_fundada = mean(var_fundada, na.rm = TRUE),
    var_uncon_reversal = mean(var_uncon_reversal, na.rm = TRUE),
    var_appeal = mean(var_appeal, na.rm = TRUE)) %>%
  rename(month_year = month_year_sentence)  %>%
  ungroup()

resolution_var <- data_participant_caseid %>%
  filter(first_auto_after_treatment == 1) %>%
  group_by(nrodocumento, month_year_first_auto) %>%
  summarise(
    var_resolution = mean(var_resolution, na.rm = TRUE)) %>%
  rename(month_year = month_year_first_auto) %>%
  ungroup()

days_to_res_var <- data_participant_caseid %>%
  filter(resolution_after_treatment == 1) %>%
  group_by(nrodocumento, month_year_resolution) %>%
  summarise(
    var_timely_resolved = mean(timely_resolved, na.rm = TRUE),
    length_auto_resolution = mean(length_auto_resolution, na.rm = TRUE)) %>%
  rename(month_year = month_year_resolution) %>%
  ungroup()

# Create case outcomes variables at the month-judge level
# for DiD regression

fundada_appeal_var_did <- data_participant_caseid %>%
  filter(date_sentence > ymd(20180501)) %>%
  filter(!sentence_during_treatment == 1) %>%
  group_by(nrodocumento, month_year_sentence) %>%
  summarise(
    sentence_after_treatment = first(sentence_after_treatment),
    var_fundada = mean(var_fundada, na.rm = TRUE),
    var_uncon_reversal = mean(var_uncon_reversal, na.rm = TRUE),
    var_appeal = mean(var_appeal, na.rm = TRUE)) %>%
  rename(month_year = month_year_sentence)

resolution_var_did <- data_participant_caseid %>%
  filter(date_first_auto > ymd(20180501)) %>%
  filter(!first_auto_during_treatment == 1) %>%
  group_by(nrodocumento, month_year_first_auto) %>%
  summarise(
    first_auto_after_treatment = first(first_auto_after_treatment),
    var_resolution = mean(var_resolution, na.rm = TRUE)) %>%
  rename(month_year = month_year_first_auto) %>%
  ungroup()

days_to_res_var_did <- data_participant_caseid %>%
  filter(date_resolution > ymd(20180501)) %>%
  filter(!resolution_during_treatment == 1) %>%
  group_by(nrodocumento, month_year_resolution) %>%
  summarise(
    resolution_after_treatment = first(resolution_after_treatment),
    var_timely_resolved = mean(timely_resolved, na.rm = TRUE),
    length_auto_resolution = mean(length_auto_resolution, na.rm = TRUE)) %>%
  rename(month_year = month_year_resolution) %>%
  ungroup()

# Join datasets

# Create post-treatment datasets
fundada_appeal_data_post <- amag_ii_participants %>%
  inner_join(fundada_appeal_var)
fundada_appeal_judges <- fundada_appeal_data_post %>% select(nrodocumento) %>% unique()

resolution_data_post <- amag_ii_participants %>%
  inner_join(resolution_var)
resolution_judges <- resolution_data_post %>% select(nrodocumento) %>% unique()

days_to_res_data_post <- amag_ii_participants %>%
  inner_join(days_to_res_var)
days_to_res_judges <- days_to_res_data_post %>% select(nrodocumento) %>% unique()

# Create DiD datasets
fundada_appeal_data_did <- amag_ii_participants %>%
  inner_join(fundada_appeal_var_did) %>%
  inner_join(fundada_appeal_judges)

resolution_data_did <- amag_ii_participants %>%
  inner_join(resolution_var_did) %>%
  inner_join(resolution_judges)

days_to_res_data_did <- amag_ii_participants %>%
  inner_join(days_to_res_var_did) %>%
  inner_join(days_to_res_judges)

# Save analysis datasets ----

write_csv(data_participant_caseid,
  file.path(local_storage, "final", "dataset_participant_caseid.csv"))

write_csv(fundada_appeal_data_post,
  file.path(local_storage, "final", "dataset_caseid_month_fundada_post.csv"))

write_csv(resolution_data_post,
  file.path(local_storage, "final", "dataset_caseid_month_resolution_post.csv"))

write_csv(days_to_res_data_post,
  file.path(local_storage, "final", "dataset_caseid_month_days_to_res_post.csv"))

write_csv(fundada_appeal_data_did,
  file.path(local_storage, "final", "dataset_caseid_month_fundada_did.csv"))

write_csv(resolution_data_did,
  file.path(local_storage, "final", "dataset_caseid_month_resolution_did.csv"))

write_csv(days_to_res_data_did,
  file.path(local_storage, "final", "dataset_caseid_month_days_to_res_did.csv"))