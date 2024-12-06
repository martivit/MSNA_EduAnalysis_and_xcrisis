# Define a function to process the metadata file and return required lists
process_metadata <- function(metadata_file_path, general_sheet_name, indicator_sheet_name) {

  # Read the general sheet
  general_data <- read_excel(metadata_file_path, sheet = general_sheet_name)
  
  # Create a named list of countries and their languages
  country_language_list <- general_data %>%
    filter(availability == "yes") %>%
    select(country_assessment, language_assessment) %>%
    deframe()
  
  # Create a separate list of available countries
  available_countries <- general_data %>%
    filter(availability == "yes") %>%
    pull(country_assessment)
  
  # Read the indicators sheet
  indicator_data <- read_excel(metadata_file_path, sheet = indicator_sheet_name)
  
  # Create a named list with indicator names and their labels
  indicator_label_list <- indicator_data %>%
    select(name, label) %>%
    deframe()
  
  indicators_list <- indicator_data %>%
    pull(name)
  
  # Return all the lists as a named list
  return(list(
    country_language_list = country_language_list,
    available_countries = available_countries,
    indicator_label_list = indicator_label_list,
    indicators_list = indicators_list
    
  ))
}

metadata_file_path <- "input_global/metadata_edu_global.xlsx"
general_sheet_name <- "general"
variables_sheet_name <- "variables"
strata_sheet_name <- "strata_variables"
indicator_sheet_name <-'indicators'

results <- process_metadata(metadata_file_path, general_sheet_name, indicator_sheet_name)
country_language_list <-results$country_language_list
available_countries <-results$available_countries 
indicator_label_list <-  results$indicator_label_list
indicator_list <- results$indicators_list
















