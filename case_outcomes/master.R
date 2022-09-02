# Master script for cleaning case outcomes
rm(list = ls())
# Select actions ------------------------------------------------------------

create_amagii_judges_list <- 1
create_cases_dataset <- 1
subset_cej_court_data <- 1 # RAM intensive
clean_case_outcomes <- 1
construct_outcomes <- 1

# User path -----------------------------------------------------------------

data_path <- "/Users/brandonmora/Dropbox/Peru_Justice/02_Data"
code_path <- "/Users/brandonmora/GitHub/peru-amag-stats/case_outcomes"

# Folder globals ------------------------------------------------------------
data_amag_i <- file.path(data_path, "01_AMAG")
data_cej <- file.path(data_path, "08_CEJ_Web")
data_gender <- file.path(data_path, "07_Other/02_Raw/names_gender")
local_storage <- "/Users/brandonmora/Dropbox/World Bank/AMAG I/15_amag2/datasets"

# Packages used --------------------------------------------------------------
packages <- c(
  "zoo",
  "tidyverse",
  "readxl",
  "haven",
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

# Actions ----------------------------------------------------
if (create_amagii_judges_list) source(
  file.path(code_path, "01_create_amagii_judges_list.R"))

if (create_cases_dataset) source(
  file.path(code_path, "02_create_cases_dataset.R"))

if (subset_cej_court_data) source(
  file.path(code_path, "03_subset_cej_court_data.R"))

if (clean_case_outcomes) source(
  file.path(code_path, "04_clean_case_outcomes.R"))

if (construct_outcomes) source(
  file.path(code_path, "05_construct_outcomes.R"))