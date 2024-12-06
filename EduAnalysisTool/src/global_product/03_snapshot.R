generate_snapshot <- function(country) {
  
  # Access to Education Data
  # Dynamically populate the Access to Education Data
  access_data <- data.frame(
    Metric = c("Overall", "Girls", "Boys"),
    Percentage = c(
      paste0(round(get_percentage(binary_indicator_data, "edu_ind_access_d","overall", "overall", country), 1), "%"),
      paste0(round(get_percentage(binary_indicator_data, "edu_ind_access_d","overall", "overall %/% Girls", country), 1), "%"),
      paste0(round(get_percentage(binary_indicator_data, "edu_ind_access_d", "overall","overall %/% Boys", country), 1), "%")
    )
  )
  ece1_data <- data.frame(
    Metric = c("Overall", "Girls", "Boys"),
    Percentage = c(
      paste0(round(get_percentage_indicator(binary_indicator_data, "edu_attending_level0_level1_and_level1_minus_one_age_d", "edu_school_cycle_d", country = country), 1), "%"),
      paste0(round(get_percentage_indicator(binary_indicator_data, "edu_attending_level0_level1_and_level1_minus_one_age_d", "edu_school_cycle_d %/% child_gender_d", country =country, gender = " %/% Girls"), 1), "%"),
      paste0(round(get_percentage_indicator(binary_indicator_data, "edu_attending_level0_level1_and_level1_minus_one_age_d", "edu_school_cycle_d %/% child_gender_d", country =country, gender = " %/% Boys"), 1), "%")
    )
  )
  ece2_data <- data.frame(
    Metric = c("Overall", "Girls", "Boys"),
    Percentage = c(
      paste0(round(get_percentage_indicator(binary_indicator_data, "edu_attending_level1_and_level1_minus_one_age_d", "edu_school_cycle_d", country = country), 1), "%"),
      paste0(round(get_percentage_indicator(binary_indicator_data, "edu_attending_level1_and_level1_minus_one_age_d", "edu_school_cycle_d %/% child_gender_d", country =country, gender = " %/% Girls"), 1), "%"),
      paste0(round(get_percentage_indicator(binary_indicator_data, "edu_attending_level1_and_level1_minus_one_age_d", "edu_school_cycle_d %/% child_gender_d", country =country, gender = " %/% Boys"), 1), "%")
    )
  )
  
  overage_primary_data <- data.frame(
    Metric = c("Overall", "Girls", "Boys"),
    Percentage = c(
      paste0(round(get_percentage(binary_indicator_data, "edu_level1_overage_learners_d","overall", "overall", country), 1), "%"),
      paste0(round(get_percentage(binary_indicator_data, "edu_level1_overage_learners_d","overall", "overall %/% Girls", country), 1), "%"),
      paste0(round(get_percentage(binary_indicator_data, "edu_level1_overage_learners_d", "overall","overall %/% Boys", country), 1), "%")
    )
  )
  overage_level2_data <- data.frame(
    Metric = c("Overall", "Girls", "Boys"),
    Percentage = c(
      paste0(round(get_percentage(binary_indicator_data, "edu_level2_overage_learners_d","overall", "overall", country), 1), "%"),
      paste0(round(get_percentage(binary_indicator_data, "edu_level2_overage_learners_d","overall", "overall %/% Girls", country), 1), "%"),
      paste0(round(get_percentage(binary_indicator_data, "edu_level2_overage_learners_d", "overall","overall %/% Boys", country), 1), "%")
    )
  )
  
  
  net_primary_data <- data.frame(
    Metric = c("Overall", "Girls", "Boys"),
    Percentage = c(
      paste0(round(get_percentage_indicator(binary_indicator_data, "edu_attending_level1234_and_level1_age_d", "edu_school_cycle_d", country = country), 1), "%"),
      paste0(round(get_percentage_indicator(binary_indicator_data, "edu_attending_level1234_and_level1_age_d", "edu_school_cycle_d %/% child_gender_d", country =country, gender = " %/% Girls"), 1), "%"),
      paste0(round(get_percentage_indicator(binary_indicator_data, "edu_attending_level1234_and_level1_age_d", "edu_school_cycle_d %/% child_gender_d", country =country, gender = " %/% Boys"), 1), "%")
    )
  )
  net_level2_data <- data.frame(
    Metric = c("Overall", "Girls", "Boys"),
    Percentage = c(
      paste0(round(get_percentage_indicator(binary_indicator_data, "edu_attending_level234_and_level2_age_d", "edu_school_cycle_d", country = country), 1), "%"),
      paste0(round(get_percentage_indicator(binary_indicator_data, "edu_attending_level234_and_level2_age_d", "edu_school_cycle_d %/% child_gender_d", country =country, gender = " %/% Girls"), 1), "%"),
      paste0(round(get_percentage_indicator(binary_indicator_data, "edu_attending_level234_and_level2_age_d", "edu_school_cycle_d %/% child_gender_d", country =country, gender = " %/% Boys"), 1), "%")
    )
  )
  
  
  # Example Usage
  age_group_data <- create_age_group_data(binary_indicator_data, "edu_ind_access_d", "edu_school_cycle_d", country = country)
  age_group_data_girls <- create_age_group_data_gender(binary_indicator_data, "edu_ind_access_d", "edu_school_cycle_d %/% child_gender_d", gender = "Girls", country = country)
  age_group_data_boys <- create_age_group_data_gender(binary_indicator_data, "edu_ind_access_d", "edu_school_cycle_d %/% child_gender_d", gender = "Boys", country = country)
  
  # View the results
  age_group_data <- age_group_data %>%
    select(-index) %>%                          # Remove the 'index' column
    rename(
      age_group = group_var_value,              # Rename 'group_var_value' to 'age_group'
      Overall = stat                            # Rename 'stat' to 'Overall'
    )
  
  # Clean group_var_value in girls and boys datasets
  age_group_data_girls <- age_group_data_girls %>%
    mutate(group_var_value = str_remove(group_var_value, " %/% Girls"))
  
  age_group_data_boys <- age_group_data_boys %>%
    mutate(group_var_value = str_remove(group_var_value, " %/% Boys"))
  
  # Add Girls and Boys columns to age_group_data
  age_group_data <- age_group_data %>%
    left_join(
      age_group_data_girls %>%
        select(group_var_value, stat) %>%
        rename(Girls = stat, age_group = group_var_value),
      by = "age_group"
    ) %>%
    left_join(
      age_group_data_boys %>%
        select(group_var_value, stat) %>%
        rename(Boys = stat, age_group = group_var_value),
      by = "age_group"
    )
  
  age_group_data <- age_group_data %>%
    mutate(
      # Extract the first age number using regex
      min_age = as.numeric(str_extract(age_group, "\\d+"))
    ) %>%
    arrange(min_age) %>%          # Sort by the extracted minimum age
    select(-min_age) %>%          # Remove the temporary column
    mutate(
      Overall = paste0(Overall, "%"),  # Add % to Overall column
      Girls = paste0(Girls, "%"),      # Add % to Girls column
      Boys = paste0(Boys, "%")         # Add % to Boys column
    )
  
  
  causes <- c()
  percentages <- c()
  colors <- c()
  
  add_disruption_data <- function(cause, percentage, color) {
    if (!is.null(percentage) && length(percentage) > 0) { # Check for numeric(0) explicitly
      causes <<- c(causes, cause)
      percentages <<- c(percentages, percentage)
      colors <<- c(colors, color)
    }
  }
  
  # Add disruption data components
  add_disruption_data("Teacher's absence", get_percentage(binary_indicator_data, "edu_disrupted_teacher_d", "overall", "overall", country), "#79797B")
  add_disruption_data("Natural hazard", get_percentage(binary_indicator_data, "edu_disrupted_hazards_d", "overall", "overall", country), "#E4DFD4")
  add_disruption_data("School used as IDP shelter", get_percentage(binary_indicator_data, "edu_disrupted_displaced_d", "overall", "overall", country), "#D2D3D4")
  add_disruption_data("School being occupied by armed groups", get_percentage(binary_indicator_data, "edu_disrupted_occupation_d", "overall", "overall", country), "#C7C8CA")
  
  # Create the disruption_data dataframe
  if (length(causes) > 0 && length(causes) == length(percentages) && length(percentages) == length(colors)) {
    disruption_data <- data.frame(
      Cause = causes,
      Percentage = percentages,
      Color = colors
    )
  } else {
    stop("Mismatch in lengths of causes, percentages, and colors vectors.")
  }
  
  # Disruption Plot
  disruption_plot <- ggplot(disruption_data, aes(x = reorder(Cause, Percentage), y = Percentage, fill = Cause)) +
    geom_bar(stat = "identity", show.legend = FALSE, width = 0.85) +
    geom_text(aes(label = paste0(round(Percentage, 1), "%")), hjust = -0.1, size = 4) +
    scale_fill_manual(values = disruption_data$Color) +
    coord_flip() +
    scale_y_continuous(expand = c(0, 0), limits = c(0, max(disruption_data$Percentage) * 1.15)) + # Set max to 5% above the max value
    labs(title = "", x = NULL, y = NULL) +
    theme_minimal() +
    theme(
      axis.text.y = element_text(size = 10),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank()
    )
  
  # Save the Disruption Plot as a PNG
  disruption_plot_file <- tempfile(fileext = ".png")
  ggsave(disruption_plot_file, plot = disruption_plot, width = 6, height = 2.5, dpi = 300)
  
  
  
  # Create Access Table without the header row
  access_table <- flextable(access_data) %>%
    delete_part(part = "header") %>%
    autofit()
  
  ece_table1 <- flextable(ece1_data) %>%
    delete_part(part = "header") %>%
    autofit()
  ece_table2 <- flextable(ece2_data) %>%
    delete_part(part = "header") %>%
    autofit()
  overage_primary_table <- flextable(overage_primary_data) %>%
    delete_part(part = "header") %>%
    autofit()
  overage_level2_table <- flextable(overage_level2_data) %>%
    delete_part(part = "header") %>%
    autofit()
  net_level2_table <- flextable(net_level2_data) %>%
    delete_part(part = "header") %>%
    autofit()
  net_primary_table <- flextable(net_primary_data) %>%
    delete_part(part = "header") %>%
    autofit()
  # Create Age Group Table with adjusted size
  age_group_table <- flextable(age_group_data) %>%
    autofit()
  
  custom_heading <- fpar(
    ftext(paste("Education Overview,", country), 
          prop = fp_text(color = "#F1797A", bold = TRUE, font.size = 18)) # Dark blue, bold, and larger text
  )
  
  
  
  
  # Create a Word Document with unnumbered headings
  doc <- read_docx() %>%
    body_add_fpar(custom_heading, style = "centered") %>%
    body_add_par(value = "Access to Education:", style = "heading 1") %>%
    body_add_par(value = "Percentage of school-aged children who attended school or any early childhood education program at any time during the 2023-2024 school year.", style = "Normal") %>%
    body_add_par(value = "") %>%  # Add an empty paragraph for spacing
    body_add_flextable(access_table) %>%
    body_add_par(value = "By age group associated with each school cycle and gender:", style = "toc 1") %>%
    body_add_flextable(age_group_table) %>%
    body_add_par(value = "Disruption of Education:", style = "heading 1") %>%
    body_add_par(value = "Percentage of school-aged children whose education was disrupted due to:", style = "Normal") %>%
    body_add_img(src = disruption_plot_file, width = 4, height = 2)%>%
    body_add_par(value = "Early childhood education:", style = "heading 1") %>%
    body_add_par(value = "Participation in Organized Learning", style = "heading 2") %>%
    body_add_par(value = "The percentage of children one year before the official primary school entry age who are enrolled in either an early childhood education program or primary school.", style = "Normal") %>%
    body_add_flextable(ece_table1) %>%
    body_add_par(value = "Early Enrollment in Primary Education", style = "heading 2") %>%
    body_add_par(value = "The percentage of children one year before the official primary school entry age who are already attending primary school.", style = "Normal") %>%
    body_add_flextable(ece_table2) %>%
    body_add_par(value = "Pupil's profile:", style = "heading 1") %>%
    body_add_par(value = "At the beginning of the school year, students' ages are assessed in relation to the grade and level they are attending. The analysis identifies whether their age aligns with the expected range for their grade and education cycle.", style = "Normal") %>%
    body_add_par(value = "") %>%  # Add an empty paragraph for spacing
    body_add_par(value = "Overaged learners", style = "heading 2") %>%
    body_add_par(value = "Percentage of school-aged children attending primary school (according to the context) who are at least 2 years above the intended age for their grade", style = "Normal") %>%
    body_add_flextable(overage_primary_table) %>%
    body_add_par(value = "Percentage of school-aged children attending level 2 (according to the context it can be middle school or secondary school) who are at least 2 years above the intended age for their grade", style = "Normal") %>%
    body_add_flextable(overage_level2_table)%>%
    body_add_par(value = "Net attendance", style = "heading 2") %>%
    body_add_par(value = "Percentage of school-aged children of primary school age currently attending primary or higher: this measures the proportion of children in the official primary school age range who are enrolled in primary school or a higher level, providing insight into their educational participation and progression.", style = "Normal") %>%
    body_add_flextable(net_primary_table) %>%
    body_add_par(value = "Percentage of school-aged children of level 2 age currently attending level 2 or higher (according to the context it can be middle school or secondary school)", style = "Normal") %>%
    body_add_flextable(net_level2_table)
  
  
  
  # Save the Word Document
  output_file <- paste0("output/global/docx/", country, "_snapshot.docx")
  print(doc, target = output_file)
  
  # Confirm the output
  message("Snapshot saved as Word document: ", output_file)
  
}