create_barrier_plot <- function(group_plot, name_plot = "overall") {
  
  n_top_barrier = 6
  
  
  barrier_label <- read.csv("input_global/barrier_label.csv", header = TRUE, check.names = FALSE)
  
  barrier_label_long <- barrier_label %>%
    pivot_longer(cols = everything(), names_to = "new_value", values_to = "old_value") %>%
    filter(!is.na(old_value)) # Remove any rows with NA in old_value
  barrier_data_filtered <- barrier_data %>%
    left_join(barrier_label_long, by = c("analysis_var_value" = "old_value")) %>%
    mutate(analysis_var_value = ifelse(!is.na(new_value), new_value, analysis_var_value)) %>%
    select(-new_value)
  
  
  barrier_data_filtered <- barrier_data_filtered %>%
    filter(group_var_value == group_plot)
  
  # Order the rows for each country by the stat column in descending order
  barrier_data_filtered <- barrier_data_filtered %>%
    group_by(country) %>%        # Group by country
    arrange(desc(stat), .by_group = TRUE) %>% # Arrange within each group
    ungroup()                    # Ungroup after ordering
  
  barrier_data_filtered <- barrier_data_filtered %>%
    filter(!is.na(analysis_var_value) & !is.na(stat))
  
  
  barrier_data_top7 <- barrier_data_filtered %>%
    group_by(country) %>% # Group by country
    arrange(desc(stat), .by_group = TRUE) %>% # Sort by stat in descending order for each country
    slice_head(n = n_top_barrier) %>% # Select the top 7 rows for each country
    ungroup() # Ungroup after operation
  
  
  not_specified  <- barrier_data_filtered %>%
    group_by(country) %>%
    arrange(desc(stat), .by_group = TRUE) %>%
    slice_head(n = n_top_barrier) %>%
    summarise(
      analysis_var_value = "Other", 
      stat = 1 - sum(stat, na.rm = TRUE), # Calculate the remaining value
      analysis_var = 'edu_barrier_d',
      group_var_value = group_plot,
      group_var = group_plot
    ) %>%
    ungroup()
  
  
  barrier_data_final <- bind_rows(barrier_data_top7, not_specified) %>%
    arrange(country, desc(stat)) # Arrange the final data by country and stat
  
  
  
  # Ensure the stat column is formatted as percentages
  barrier_data_final <- barrier_data_final %>%
    mutate(
      stat = round(stat * 100, 1), # Convert stat to percentages
      analysis_var_value = factor(analysis_var_value) # Factorize for consistent plotting
    )
  
  
  
  
  
  values <- c(
    "Cannot afford the direct costs of education" = "#6D9DC5",
    "Not enough food for the family and school does not provide school feeding" = "#7FA8C9",
    
    "The child is too young" = "#8095C3",
    "The child has already graduated from secondary education" = "#C9B1A4",
    "The child has already completed compulsory school grades" = "#CDB8AD",
    
    "There is a lack of interest for formal education" = "#B0A2B6",
    "Education is not a priority either for the child or the household" = "#B0A2B6",
    "There is a lack of interest/Education is not a priority either for the child or the household" = "#B0A2B6",
    "Curriculum and/or the certificates issued by school are not perceived to be useful for the household" = "#B8AFC3",
    "Differentiations and community perceptions affecting participation" = "#B7ADC6",
    
    "Lack of appropriate and accessible school" = "#D7B5A6",
    "No school in the area or school is too far" = "#A3C4C9",
    "Unable to enrol in school due to lack of enrolment space" = "#A8C6CC",
    "No education programmes available in the community/camp" = "#AACBCF",
    
    "School does not have enough classrooms that are usable" = "#8CABA8",
    "School's water, sanitation or handwashing facilities are in poor condition or not available" = "#9CBFB9",
    "Inadequate or damaged infrastructure for learning in a safe environment (e.g. damaged school facilities, no or inadequate bomb shelter)" = "#8FB1AD",
    "Lack of quiet and safe space to attend or listen to online learning classes" = "#9FB9B4",
    
    "School has been closed due to conflict" = "#C5D8A6",
    "School has been closed due to natural disaster" = "#D9CAB3",
    "School has been closed due to damage, natural disaster, conflict" = "#C5D8A6",
    "School being occupied by armed forces/non-state armed groups" = "#B6C59A",
    "School being hit by munitions/burning or theft/looting" = "#B3C08F",
    "School used to host displaced people" = "#B8C8A4",
    
    "Protection/safety risks while commuting to school" = "#808080",
    "Protection/safety risks while at school" = "#8E8E8E",
    "Protection risks whilst travelling to the school" = "#808080",
    "Child is associated with armed forces or armed groups" = "#7A7A7A",
    
    "Child needs to work at home or on the household's own farm, i.e. is not earning an income for these activities, but may allow other family members to earn an income" = "#92C1C4",
    "Child needs to work at home or on the household's own farm" = "#92C1C4",
    "Child participating in income generating activities outside of the home" = "#9E94C5",
    
    "Marriage or engagement" = "#BFA58A",
    "Pregnancy" = "#C2A092",
    "Marriage, engagement and/or pregnancy" = "#BFA58A",
    "Personal or family responsibilities, for female" = "#C5AE9E",
    
    "Physical constraints to the facilities especially for persons with disability, building not accessible, transport not accessible, too far, etc./Personel not trained or equipped to support persons with disabilities" = "#C5A49A",
    "The child's disability or other health issues prevent them from accessing school" = "#C5A49A",
    "The child's disability prevent them from accessing school" = "#C8A89E",
    "The child's health issues prevent them from accessing school" = "#CBAFA6",
    
    "Unable to enroll in school due to lack of documentation" = "#AFAFAF",
    "Unable to enroll in school due to recent displacement/return,displacement since after the start of the school year" = "#9CB3C1",
    "Unable to enroll in school due to recent displacement/return" = "#9CB3C1",
    "Forced return from abroad interrupted their school year" = "#A7B7C2",
    "There is a ban preventing child from attending" = "#AFAFAF",
    "There is a limitation preventing the child from attending" = "#B5B5B5",
    
    "Discrimination or stigmatization of the child for any reason" = "#B6B6C9",
    "Language issues" = "#B3B9CC",
    
    "Unavailability of menstrual hygiene supplies and facilities in schools" = "#C7B2C2",
    
    "Lack of appropriate IT equipment (laptop, tablet, etc)" = "#9FB3C8",
    "Internet connection of bad quality  or no internet connection" = "#A5BBD0",
    "Lack of other school supplies (notebook, pencil, textbooks, etc. )" = "#B0C3D1",
    
    "Other (open response from respondent)" = "#E6E3B0",
    "Other" = "#E6E3B0",
    "Don't know" = "#D0D0D0",
    "Prefer not to answer" = "#DADADA"
  )
  
  # Create a pattern mapping (can be adjusted based on unique barriers)
  pattern_mapping <- setNames(
    c("none","stripe","none","none","none","none","circle","circle","circle","circle","circle","stripe","stripe","stripe","stripe","crosshatch","crosshatch","crosshatch","crosshatch","crosshatch","circle","crosshatch","crosshatch","crosshatch","crosshatch","stripe","stripe","stripe","stripe","circle","circle","circle","none","none","none","none","circle","circle","circle","circle","stripe","stripe","stripe","stripe","stripe","circle","circle","circle","stripe","stripe","stripe","none","none","none","none")
    ,
    names(values)
  )
  
  barrier_data_final <- barrier_data_final %>%
    mutate(country = factor(country, levels = rev(unique(country))))
  
  # Create the plot with colors only (no patterns)
  barrier_plot <- ggplot(barrier_data_final, aes(
    x = country,
    y = stat,
    fill = analysis_var_value
    
  )) +
    geom_bar(
      stat = "identity",
      position = "stack",
      width = 0.8,
      alpha = 0.8
    ) +
    geom_text(
      aes(
        label = ifelse(stat >= 2.5, paste0(round(stat, 1), "%"), ""),  # Only display label if stat >= 2.5
        angle = ifelse(stat >= 5, 0, 45)      # Tilt labels for values below 5%
      ),
      position = position_stack(vjust = 0.5), 
      size = 2.5        # Smaller size for values below 5%
    )  +
    scale_fill_manual(
      values = values, # Use predefined colors
      name = "Barrier to access education"
    )+
    labs(
      x = "",
      y = "",
      title = paste0("Top 6 Barriers to Education by Country, ",name_plot),
      subtitle = "% of school-aged children not attending school or any early childhood education program at any time during the 2023-2024 school year, by main reason"
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_blank(),              # Remove X-axis numbers
      axis.ticks.x = element_blank(),             # Remove X-axis ticks
      axis.text.y = element_text(size = 8, color = "black"),  # Reduce Y-axis text size
      legend.position = "right",                  # Place legend on the right
      legend.title = element_text(size = 8),      # Smaller legend title
      legend.text = element_text(size = 7),       # Smaller legend text
      legend.key.size = unit(0.5, "cm"),          # Adjust legend key size
      axis.title.y = element_blank(),             # Remove Y-axis title
      plot.title = element_text(size = 10, hjust = 0.5), # Smaller title
      plot.subtitle = element_text(size = 6)      # Smaller subtitle text
    ) +
    coord_flip()
  
  # Save the plot
  
  output_file <- paste0("output/global/plot/barriers_to_education_plot_", name_plot, ".jpeg")
  ggsave(output_file, plot = barrier_plot, width = 10, height = 6, dpi = 300)
  
  
  




}