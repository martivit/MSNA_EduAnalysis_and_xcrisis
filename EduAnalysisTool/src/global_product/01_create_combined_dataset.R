

# Define the output folder
output_folder <- "output/"

# Initialize an empty list to store data frames
all_data <- list()

# Loop through each country and process the corresponding CSV file
for (country in available_countries) {
  # Construct the file name
  file_name <- paste0(output_folder, "analysis_key_output", country, ".csv")
  
  # Check if the file exists
  if (file.exists(file_name)) {
    # Read the file
    data <- read_csv(file_name)
    
    # Select the required columns and add the country column
    processed_data <- data %>%
      select(analysis_var, analysis_var_value,group_var, group_var_value, stat, stat_low, stat_upp, n_total) %>%
      mutate(country = country)
    
    # Append the processed data to the list
    all_data[[country]] <- processed_data
  }
}

# Combine all data frames into one
combined_data <- bind_rows(all_data)

# Filter data for rows where analysis_var is in the indicators_list (excluding edu_barrier_d)
binary_indicator_data <- combined_data %>%
  mutate(analysis_var = str_replace_all(analysis_var, c("edu_attending_level123_and_level1_age_d" = "edu_attending_level1234_and_level1_age_d",
                                                        "edu_attending_level12_and_level1_age_d" = "edu_attending_level1234_and_level1_age_d",
                                                        "edu_attending_level23_and_level2_age_d" = "edu_attending_level234_and_level2_age_d",
                                                        "edu_attending_level2_and_level2_age_d" = "edu_attending_level234_and_level2_age_d",
                                                        "edu_attending_level3_and_level3_age_d"= "edu_attending_level34_and_level3_age_d")))

# Filter data for rows where analysis_var is in the indicators_list (excluding edu_barrier_d)
binary_indicator_data <- binary_indicator_data %>%
  filter(analysis_var %in% indicator_list & analysis_var != "edu_barrier_d" & analysis_var_value == 1) %>%
  mutate(group_var_value = str_replace_all(group_var_value, c("Filles" = "Girls", "Garcons" = "Boys")))




# Filter data for rows where analysis_var is edu_barrier_d
barrier_data <- combined_data %>%
  filter(analysis_var == "edu_barrier_d")




# Save the resulting data frames as CSVs (optional)
write_csv(binary_indicator_data, "output/global/binary_indicator_data.csv")
write_csv(barrier_data, "output/global/barrier_data.csv")
write_csv(combined_data, "output/global/combined_data.csv")




# Initialize the labeled dataset with the original binary_indicator_data
labeled_binary_indicator_data <- binary_indicator_data

# Path to the ISCED file
path_ISCED_file <- "resources/UNESCO ISCED Mappings_MSNAcountries_consolidated.xlsx"

# Iterate over all available countries
for (country in available_countries) {
  # Get the language for the current country
  language <- country_language_list[[country]]
  
  # Process only rows for the current country
  processed_country_data <- process_country(
    country_code = country,
    language_assessment = language,
    path_ISCED_file = path_ISCED_file,
    binary_data = labeled_binary_indicator_data
  )
  
  # Update the rows for the current country in the main dataset
  labeled_binary_indicator_data <- labeled_binary_indicator_data %>%
    filter(country != country) %>%  # Exclude rows for the current country
    bind_rows(processed_country_data)  # Add the updated rows back
}

# Save the final dataset
write_csv(labeled_binary_indicator_data, "output/global/labeled_binary_indicator_data.csv")


