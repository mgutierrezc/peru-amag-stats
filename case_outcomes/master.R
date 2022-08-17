# Master script for AMAG1 (Monitoring intervention)
rm(list = ls())
# Select actions ------------------------------------------------------------

# Cleaning
clean_satisfaction_data <- 1 # Cleans satisfaction data
clean_grade_data  <- 1 # Cleans 22th PCA grade data
clean_iat_data  <- 1 # Cleans AMAG I exit exercises
clean_case_outcomes <- 1 # Cleans case outcomes variables from CEJ dataset
clean_logs_blackboard <- 1 # Cleans logs from Blackboard platform

# Construct monitoring dataset
construct_dataset_monit <- 1 # Constructs main analysis datasets

# Output for paper
table01_balance <- 1 # Creates balance table
table02_grades_satisfaction <- 1 # Creates satisfaction/grades table
table03_iat_scores <- 1 # Create IAT table
table04_case_outcomes <- 1 # Creates case outcome table
table05_satisfaction_feedback <- 1 # Creates satisfaction and feedback table
table06_monitoring_gender <- 1 # Creates monit table  by participant gender
table07_monitoring_two_arms <- 1 # Creates monit table by monitor gener

# User path -----------------------------------------------------------------

# Brandon's data and github path
if (Sys.getenv("USER") == "brandonmora") {
  data_path <- "/Users/brandonmora/Dropbox/Peru_Justice/02_Data/"
  github_path <- "/Users/brandonmora/GitHub/peru-legal-aid/02_Data/01_AMAG/05_Code/01_master_monit/"
  Sys.setenv(RSTUDIO_PANDOC = "/Applications/RStudio.app/Contents/MacOS/quarto/bin")
}

# Folder globals ------------------------------------------------------------
data_amag <- paste0(data_path, "01_AMAG/")
data_cej <- paste0(data_path, "08_CEJ_Web/")
data_hr <- paste0(data_path, "04_Poder_Judicial/02_Raw/")
data_gender <- paste0(data_path, "07_Other/02_Raw/names_gender/")
output_paper <- paste0(data_amag, "06_Outputs/01_Monitoring/")

data_amag_raw <- paste0(data_amag, "02_Raw/master_monit/")
data_amag_int <- paste0(data_amag, "03_Intermediate/master_monit/")
data_amag_fin <- paste0(data_amag, "04_Final/master_monit/")

# Packages used --------------------------------------------------------------
packages <- c(
  "zoo",
  "tidyverse",
  "readxl",
  "stringi",
  "janitor",
  "lubridate",
  "lfe",
  "car",
  "fuzzyjoin",
  "ggpubr",
  "fixest",
  "modelsummary",
  "kableExtra")

# Install packages
sapply(packages, function(x) {
  if (!(x %in% installed.packages())) {
    install.packages(x, dependencies = TRUE)
  }
})
  
# Load packages
invisible(sapply(packages, require, character.only = TRUE))

# Actions ---------------------------------------------------------------

# Cleaning

if (clean_satisfaction_data) source(
  paste0(github_path, "code/01_clean/", "01_clean_satisfaction_data.R"))

if (clean_grade_data) source(
  paste0(github_path, "code/01_clean/", "02_clean_grade_data.R"))

if (clean_iat_data) source(
  paste0(github_path, "code/01_clean/", "03_clean_iat_data.R"))

if (clean_case_outcomes) source(
  paste0(github_path, "code/01_clean/", "04_clean_case_outcomes.R"))

if (clean_logs_blackboard) source(
  paste0(github_path, "code/01_clean/", "05_clean_logs_blackboard.R"))

# Construct
if (construct_dataset_monit) source(
  paste0(github_path, "code/02_construct_datasets.R"))

# Output for paper
if (table01_balance) source(
  paste0(github_path, "code/03_outputs/tables/", "table01_balance.R"))

if (table02_grades_satisfaction) source(
  paste0(github_path, "code/03_outputs/tables/", "table02_grades_satisfaction.R"))

if (table03_iat_scores) source(
  paste0(github_path, "code/03_outputs/tables/", "table03_iat_scores.R"))

if (table04_case_outcomes) source(
  paste0(github_path, "code/03_outputs/tables/", "table04_case_outcomes.R"))

if (table05_satisfaction_feedback) source(
  paste0(github_path, "code/03_outputs/tables/", "table05_satisfaction_feedback.R"))

if (table06_monitoring_gender) source(
  paste0(github_path, "code/03_outputs/tables/", "table06_monitoring_gender.R"))

if (table07_monitoring_two_arms) source(
  paste0(github_path, "code/03_outputs/tables/", "table07_monitoring_two_arms.R"))
