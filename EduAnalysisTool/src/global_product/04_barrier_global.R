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
    "Cannot afford the direct costs of education" = "#6D9DC5", # Muted Blue
    "Child needs to work at home or on the household's own farm" = "#92C1C4", # Soft Teal
    "Child participating in income generating activities outside of the home" = "#9E94C5", # Lavender
    "Lack of appropriate and accessible school" = "#D7B5A6", # Pale Rose
    "Marriage, engagement and/or pregnancy" = "#BFA58A", # Taupe
    "No school in the area or school is too far" = "#A3C4C9", # Mist Blue
    "School does not have enough classrooms that are usable" = "#8CABA8", # Sage
    "School has been closed due to damage, natural disaster, conflict" = "#C5D8A6", # Soft Olive
    "School has been closed due to natural disaster" = "#D9CAB3", # Light Khaki
    "The child's disability or health issues prevents them from accessing school" = "#C5A49A", # Faded Peach
    "The child has already graduated from secondary education" = "#C9B1A4", # Sandstone
    "There is a ban preventing child from attending" = "#AFAFAF", # Neutral Gray
    "There is a lack of interest/Education is not a priority either for the child or the household" = "#B0A2B6", # Dusty Mauve
    "Too young" = "#8095C3", # Slate Blue
    "Unable to enroll in school due to recent displacement/return" = "#9CB3C1", # Light Slate
    "Other" = "#E6E3B0", # Warm Beige
    "Other, specify" = "#B3C0C7" # Soft Steel
  )
  
  
  # Create a pattern mapping (can be adjusted based on unique barriers)
  pattern_mapping <- setNames(
    c("none", "stripe", "stripe", "crosshatch", "none", "circle", "crosshatch", 
      "stripe", "none", "crosshatch", "circle", "stripe", "crosshatch", "circle", 
      "stripe", "none", "stripe"),
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