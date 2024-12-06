
indicator <- indicator_list[1]


plot_title <- str_wrap(indicator_label_list[[indicator]], width = 100) # Automatically format title with line breaks


# Define a function to generate and save plots for an indicator
generate_indicator_plot <- function(indicator_list, labeled_binary_indicator_data, indicator_label_list, group_var_values_base, output_folder) {
  
  # Loop over each indicator in the indicator list
  for (indicator in indicator_list) {
    if (indicator == 'edu_barrier_d') next  # Skip 'edu_barrier_d'
    
    # Define the title and filter the data for the current indicator
    plot_title <- str_wrap(indicator_label_list[[indicator]], width = 100) # Automatically format title with line breaks
    if (group_var_values_base == 'level0') plot_title <- paste0(plot_title, ' (Subset of children who are one year below the primary school entry age)')
    if (group_var_values_base == 'level1') plot_title <- paste0(plot_title, ' (Subset of children within the primary school age range)')
    if (group_var_values_base == 'level2') plot_title <- paste0(plot_title, ' (Subset of children within the level 2 (middle level or secondary) school age range)')
    plot_title <- str_wrap(plot_title, width = 100) # Automatically format title with line breaks
    
    
    # Filter the data for the current indicator and the specified group_var_values
    base1 <- group_var_values_base
    base2 <- paste0(group_var_values_base,  " %/% Boys")
    base3 <- paste0(group_var_values_base,  " %/% Girls")
    
    
    plot_data <- labeled_binary_indicator_data %>%
      filter(
        analysis_var == indicator,
        group_var_value %in% c(base1, base2, base3)
      ) %>%
      mutate(
        group_label = case_when(
          group_var_value == base1 ~ "All children",
          group_var_value == base2 ~ "Boys",
          group_var_value == base3 ~ "Girls"
        )
      )
    
    # Prepare the data for plotting
    plot_data <- plot_data %>%
      mutate(
        country = factor(country, levels = rev(unique(country))), # Reverse the order of countries
        group_label = factor(group_label, levels = c("Girls", "Boys", "All children")), # Reverse the order of bars
        stat = stat * 100 # Convert percentages to a 100 scale
      )
    # Generate the plot
    p <- ggplot(plot_data, aes(x = country, y = stat, fill = group_label)) +
      geom_bar(stat = "identity", position = "dodge", alpha = 0.8) + # Added transparency to bars
      scale_fill_manual(values = c("All children" = "#EE5859", "Girls" = "#D2CBB8", "Boys" = "#58585A")) +
      coord_flip() +
      geom_errorbar(
        aes(
          ymin = stat_low * 100, # Convert to percentage scale
          ymax = stat_upp * 100, # Convert to percentage scale
          group = group_label
        ),
        position = position_dodge(width = 0.9),
        width = 0.25,
        alpha = 0.6, # Adjust transparency for error bars
        size = 0.5,
        color = "#C7C8CA" # Set error bars to light gray
      ) +
      geom_text(
        aes(
          y = stat_upp * 100 + 0.2, # Position text slightly above the end of the error bar
          label = paste0(round(stat, 1), "%"),
          color = group_label # Match percentage text color with group
        ),
        position = position_dodge(width = 0.9),
        hjust = -0.2,
        size = 3
      ) + # Add percentage labels for all groups
      scale_color_manual(
        values = c("All children" = "black", "Girls" = "gray40", "Boys" = "gray40"),
        guide = "none" # Remove legend for error bar and text colors
      ) +
      labs(
        title = plot_title,  # Automatically formatted title
        x = "",
        y = "",
        fill = "Group"
      ) +
      theme_minimal() +
      theme(
        text = element_text(size = 12),
        legend.position = "bottom",
        legend.title = element_blank(),
        plot.title = element_text(hjust = 0.5, size = 14), # Center-align and resize title
        panel.grid = element_blank(), # Remove grid lines
        axis.text.x = element_blank(), # Remove x-axis numbers
        axis.ticks.x = element_blank() # Remove x-axis ticks
      )
    
    # Save the plot to a file using the current indicator and group_var_values as part of the file name
    ggsave(
      filename = paste0(output_folder, "/", indicator, "_", paste(group_var_values_base, collapse = "_"), ".jpeg"),
      plot = p,
      width = 12,
      height = 8,
      dpi = 300
    )
  }
}





########################################################################################################################

# 
# # Loop over each indicator in the indicator list
# for (indicator in indicator_list) {
#   if (indicator == 'edu_barrier_d') next
#   
#   # Define the title and filter the data for the current indicator
#   plot_title <- str_wrap(indicator_label_list[[indicator]], width = 100) # Automatically format title with line breaks
#   
#   # Filter the data for the current indicator
#   plot_data <- labeled_binary_indicator_data %>%
#     filter(
#       analysis_var == indicator,
#       group_var_value %in% c("overall", "overall %/% Boys", "overall %/% Girls")
#     ) %>%
#     mutate(
#       group_label = case_when(
#         group_var_value == "overall" ~ "All children",
#         group_var_value == "overall %/% Boys" ~ "Boys",
#         group_var_value == "overall %/% Girls" ~ "Girls"
#       )
#     )
#   
#   # Prepare the data for plotting
#   plot_data <- plot_data %>%
#     mutate(
#       country = factor(country, levels = rev(unique(country))), # Reverse country order
#       group_label = factor(group_label, levels = c("Girls", "Boys", "All children")), # Reverse bar order
#       stat = stat * 100 # Convert percentages to a 100 scale
#     )
#   
#   # Generate the plot
#   p <- ggplot(plot_data, aes(x = country, y = stat, fill = group_label)) +
#     geom_bar(stat = "identity", position = "dodge", alpha = 0.8) + # Added transparency to bars
#     scale_fill_manual(values = c("All children" = "#EE5859", "Girls" = "#D2CBB8", "Boys" = "#58585A")) +
#     coord_flip() +
#     geom_errorbar(
#       aes(
#         ymin = stat_low * 100, # Convert to percentage scale
#         ymax = stat_upp * 100, # Convert to percentage scale
#         group = group_label
#       ),
#       position = position_dodge(width = 0.9),
#       width = 0.25,
#       alpha = 0.6, # Adjust transparency for error bars
#       size = 0.5,
#       color = "#C7C8CA" # Set error bars to light gray
#     ) +
#     geom_text(
#       aes(
#         y = stat_upp * 100 + 0.2, # Position text slightly above the end of the error bar
#         label = paste0(round(stat, 1), "%"),
#         color = group_label # Match percentage text color with group
#       ),
#       position = position_dodge(width = 0.9),
#       hjust = -0.2,
#       size = 3
#     ) + # Add percentage labels for all groups
#     scale_color_manual(
#       values = c("All children" = "black", "Girls" = "gray40", "Boys" = "gray40"),
#       guide = "none" # Remove legend for error bar and text colors
#     ) +
#     labs(
#       title = plot_title,  # Automatically formatted title
#       x = "",
#       y = "",
#       fill = "Group"
#     ) +
#     theme_minimal() +
#     theme(
#       text = element_text(size = 12),
#       legend.position = "bottom",
#       legend.title = element_blank(),
#       plot.title = element_text(hjust = 0.5, size = 14), # Center-align and resize title
#       panel.grid = element_blank(), # Remove grid lines
#       axis.text.x = element_blank(), # Remove x-axis numbers
#       axis.ticks.x = element_blank() # Remove x-axis ticks
#     )
#   
#   # Save the plot to a file using the current indicator as part of the file name
#   ggsave(
#     filename = paste0("output/global/plot/", indicator, ".jpeg"),
#     plot = p,
#     width = 12,
#     height = 8,
#     dpi = 300
#   )
# }
# 



