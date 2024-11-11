# Prepare loa_level
loa_level <- loa_country %>%
  mutate(
    group_var = str_replace_all(group_var, ",", " %/% "),
    group_var = str_squish(group_var)
  ) %>%
  filter(!!sym(tab_helper))

# Join and filter results
filtered_education_results_table_labelled <- education_results_table_labelled %>%
  right_join(unique(loa_level %>% select(analysis_var, group_var, !!sym(tab_helper))))

# Filter for analysis_var_value == "1" and clean up access column
filtered_education_results_table_labelled <- filtered_education_results_table_labelled %>%
  filter(
    !!sym(tab_helper),
    analysis_var_value != "0"
  ) %>%
  select(-!!sym(tab_helper))

filtered_education_results_table_labelled <- filtered_education_results_table_labelled %>%
  filter(!str_detect(group_var_value, "% NA"))

saveRDS(filtered_education_results_table_labelled, paste0("output/rds_results/", tab_helper, "_results_", country_assessment, ".rds"))

# Create the wider table using external functions
wider_table <- filtered_education_results_table_labelled %>%
  create_education_table_group_x_var(
    label_overall = label_overall,
    label_female = label_female,
    label_male = label_male
  )
if ("Overall %/% % of school-aged children accessing education outside of formal schools during the 2023-2024 school year %/% 1 %/% stat" %in% colnames(wider_table)) {
  wider_table <- wider_table %>%
    filter(!is.na(`Overall %/% % of school-aged children accessing education outside of formal schools during the 2023-2024 school year %/% 1 %/% stat`))
}

order_appearing <- c(label_overall, labels_with_ages, unique(wider_table$label_group_var_value)) %>%
  na.omit() %>%
  unique()

t1 <- wider_table |>
  create_education_gt_table(
    data_helper = data_helper[[tab_helper]],
    order_appearing
  )

t1
create_xlsx_education_table(t1, wb, tab_helper)

row_number <- row_number_lookup[[tab_helper]]

# Add a hyperlink to the table of content
writeFormula(wb, "Table_of_content",
             startRow = row_number,
             x = makeHyperlinkString(
               sheet = tab_helper, row = 1, col = 1,
               text = data_helper[[tab_helper]]$title
             )
)
