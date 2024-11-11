# Function to read a specific sheet and retrieve non-empty values for a country
get_country_data <- function(file_path, sheet_name, country_code) {
  # Read the sheet
  data <- read_excel(file_path, sheet = sheet_name)
  
  # Filter rows based on the country_code
  country_data <- data %>%
    filter(country_assessment == country_code)
  
  # Remove empty columns
  country_data <- country_data %>%
    select_if(~any(!is.na(.)))
  
  # Convert the non-empty values into a list
  list_data <- lapply(country_data, function(x) ifelse(is.na(x), NULL, x))
  
  return(list_data)
}
##-- 
get_strata_variables <- function(file_path, sheet_name, country_code) {
  # Read the sheet
  data <- read_excel(file_path, sheet = sheet_name)
  
  # Filter the data based on the country_code
  country_data <- data %>%
    filter(country_assessment == country_code)
  
  # List of column names to be converted into variables
  columns_to_extract <- colnames(country_data)
  
  # Loop through each column and assign the values to variables in the global environment
  for (column_name in columns_to_extract) {
    value <- country_data[[column_name]]
    
    # Assign NULL if the value is empty or NA
    if (is.na(value) || value == "") {
      value <- NULL
    }
    
    # Dynamically assign the variable in the global environment
    assign(column_name, value, envir = .GlobalEnv)
  }
  
  return(TRUE)
}

################################################################################################################
metadata_file_path <- "../metadata_edu.xlsx"
general_sheet_name <- "general"
variables_sheet_name <- "variables"
strata_sheet_name <- "strata_variables"


list_info_general          <- get_country_data(metadata_file_path, general_sheet_name, country_assessment)
list_variables             <- get_country_data(metadata_file_path, variables_sheet_name, country_assessment)
get_strata_variables (metadata_file_path, strata_sheet_name, country_assessment)
