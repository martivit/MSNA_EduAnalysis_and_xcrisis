

# Define the output folder
output_folder <- "output/"
barrier_label <- read.csv("input_global/barrier_label.csv", header = TRUE, check.names = FALSE)
# Path to the ISCED file
path_ISCED_file <- "resources/UNESCO ISCED Mappings_MSNAcountries_consolidated.xlsx"


# Initialize an empty list to store data frames
pBI_all_data <- list()


pop_lookup <- tibble(
  country = names(pop_group_list),
  pop_keyword = unname(pop_group_list),
  host_keyword      = unname(host_list),
  idp_keyword = unname (idp_list),
  idp_host_keyword = unname (idp_host_list),
  idp_camp_keyword = unname (idp_camp_list),
  ret_keyword = unname (ret_list),
  refugee_keyword = unname (refugee_list),
  admin1_keyword = unname (admin1_list),
)
filter_lookup <- tibble(
  country = names(col1_list),      
  col1 = unname(col1_list),
  col2 = unname(col2_list),
  col3 = unname(col3_list),
  col4 = unname(col4_list)
)

setting_lookup <- tibble(
  country = names(setting_list),
  setting_keyword = unname(setting_list),
  urban_keyword = unname(urban_list),
  rural_keyword      = unname(rural_list),
  camp_keyword = unname (camp_list), 
  informal_keyword = unname (informal_list),
  other_setting_keyword = unname (other_setting_list)
)

# Loop through each country and process the corresponding CSV file
for (country in available_countries) {
  print(paste0 ('-------------------------   ', country))
  # Construct the file name
  file_name <- paste0(output_folder, "analysis_key_output", country, ".csv")
  
  # Check if the file exists
  if (file.exists(file_name)) {
    # Read the file
    pBI_data <- read_csv(file_name)
    
    # Select the required columns and add the country column
    pBI_processed_data <- pBI_data %>%
      select(analysis_var, analysis_var_value,group_var, group_var_value, stat, n_total) %>%
      mutate(country = country)
    
    # Append the processed data to the list
    pBI_all_data[[country]] <- pBI_processed_data
  }
}

# Combine all data frames into one
pBI_combined_data <- bind_rows(pBI_all_data)

# Filter data for rows where analysis_var is in the indicators_list (excluding edu_barrier_d)
pBI_indicator_data <- pBI_combined_data %>%
  mutate(analysis_var = str_replace_all(analysis_var, c("edu_attending_level123_and_level1_age_d" = "edu_attending_level1234_and_level1_age_d",
                                                        "edu_attending_level12_and_level1_age_d" = "edu_attending_level1234_and_level1_age_d",
                                                        "edu_attending_level23_and_level2_age_d" = "edu_attending_level234_and_level2_age_d",
                                                        "edu_attending_level2_and_level2_age_d" = "edu_attending_level234_and_level2_age_d",
                                                        "edu_attending_level3_and_level3_age_d"= "edu_attending_level34_and_level3_age_d")))

# Filter data for rows where analysis_var is in the indicators_list (excluding edu_barrier_d)
pBI_indicator_data <- pBI_indicator_data %>%
  filter(analysis_var %in% indicator_list &  analysis_var_value != 0 &  !is.na(analysis_var_value)) %>%
  mutate(group_var_value = str_replace_all(group_var_value, c("Filles" = "Girls", "Garcons" = "Boys")))



# Iterate over all available countries
for (country in available_countries) {
  # Get the language for the current country
  language <- country_language_list[[country]]
  
  # Process only rows for the current country
  processed_country_data <- process_country(
    country_code = country,
    language_assessment = language,
    path_ISCED_file = path_ISCED_file,
    binary_data = pBI_indicator_data
  )
  
  # Update the rows for the current country in the main dataset
  pBI_indicator_data <- pBI_indicator_data %>%
    filter(country != country) %>%  # Exclude rows for the current country
    bind_rows(processed_country_data)  # Add the updated rows back
}



# A helper that does partial substring replacement ONLY if
# both text and pattern are non-NA and the pattern is found.
replace_if_found <- function(text, pattern, replacement) {
  if (is.na(text) || is.na(pattern)) {
    return(text)
  }
  if (stringr::str_detect(text, stringr::fixed(pattern))) {
    stringr::str_replace_all(text, stringr::fixed(pattern), replacement)
  } else {
    text
  }
}
pluto <-pBI_indicator_data
pBI_indicator_data <-pluto
pBI_indicator_data <- pBI_indicator_data %>%
  left_join(pop_lookup, by = "country") %>%
  rowwise() %>%
  mutate(
    # 1) If you have something like "returning_idp" you want → "RET",
    #    do that first:
    group_var_value = replace_if_found(group_var_value, ret_keyword, "RET"),
    
    # 2) Then replace the simpler "idp" → "IDP":
    group_var_value = replace_if_found(group_var_value, idp_keyword, "IDP"),
    group_var_value = replace_if_found(group_var_value, idp_host_keyword, "IDP_HOST"),
    group_var_value = replace_if_found(group_var_value, idp_camp_keyword, "IDP_SITE"),
    # 3) The rest can be in any order (host, idp_host, idp_camp, etc.):
    group_var_value = replace_if_found(group_var_value, host_keyword,     "HOST"),

    group_var_value = replace_if_found(group_var_value, refugee_keyword,  "REFUGEE"),
    group_var = replace_if_found(group_var, admin1_keyword,   "ADMIN"),
    group_var       = replace_if_found(group_var,       pop_keyword,      "pop_group")
  ) %>%
  ungroup() %>%
  select(-pop_keyword, -host_keyword, -idp_keyword, -idp_host_keyword,
         -idp_camp_keyword, -ret_keyword, -refugee_keyword, -admin1_keyword)


pBI_indicator_data <- pBI_indicator_data %>%
  left_join(setting_lookup, by = "country") %>%
  rowwise() %>%
  mutate(
    group_var_value = replace_if_found(group_var_value, other_setting_keyword, "OTHER SETTING"),
    group_var_value = replace_if_found(group_var_value, rural_keyword, "RURAL"),
    group_var_value = replace_if_found(group_var_value, urban_keyword, "URBAN/PERI-URBAN"),
    group_var_value = replace_if_found(group_var_value, camp_keyword,     "CAMP/SITE"),
    group_var_value = replace_if_found(group_var_value, informal_keyword,     "INFORMAL SITE"),
    
    group_var       = replace_if_found(group_var,       setting_keyword,      "setting")
  ) %>%
  ungroup() %>%
  select(-rural_keyword, -urban_keyword, -camp_keyword,-informal_keyword, -other_setting_keyword,
         -setting_keyword)


get_admin <- function(x) {
  tok  <- stringr::str_split(x, "%/%", simplify = TRUE) |> stringr::str_trim()
  hit  <- tok[stringr::str_detect(tok, "^[A-Z]{2,}[0-9A-Z]*$")]
  if (length(hit)) hit[1] else NA_character_
}


pBI_indicator_data <- pBI_indicator_data %>%
  mutate(
    gender = case_when(
      str_detect(group_var_value, "Boys")  ~ "Boys",
      str_detect(group_var_value, "Girls") ~ "Girls",
      TRUE                                 ~ "Overall"
    ),
    school_cycle = case_when(
      str_detect(group_var_value, "level0") ~ "ECE",
      str_detect(group_var_value, "level1") ~ "Primary",
      str_detect(group_var_value, "level2") ~ "Intermediate-secondary",
      str_detect(group_var_value, "level3") ~ "Secondary",
      str_detect(group_var_value, "level4") ~ "Higher Education",
      
      TRUE                                  ~ "No disaggregation"
    ),
    pop_group = case_when(
      str_detect(group_var_value, "IDP_HOST")  ~ "IDP in host families",
      str_detect(group_var_value, "IDP_SITE")  ~ "IDP is camp/site",
      str_detect(group_var_value, "HOST")      ~ "Host community",
      str_detect(group_var_value, "REFUGEE")   ~ "Refugees",
      str_detect(group_var_value, "IDP")       ~ "IDP",
      str_detect(group_var_value, "RET")       ~ "Returnees",
      str_detect(group_var_value, "ndsp")      ~ "non-displaced stateless people",
      str_detect(group_var_value, "female_hoh")      ~ "Female head of HH",
      str_detect(group_var_value, "migrant")      ~ "Migrant",
      str_detect(group_var_value, "prl")      ~ "Palestine refugees registered in Lbeanon",
      str_detect(group_var_value, "prs")      ~ "Palestine Refugees from Syria",
      str_detect(group_var_value, "non_recentt_idp")      ~ "Non-recent IDP (Displaced between 7 - 24 months)",
      str_detect(group_var_value, "non_recent_returnee")      ~ "Non-recent Crossborder Returnee (Displaced between 7 - 24 months)",
      str_detect(group_var_value, "male_hoh")      ~ "Male head of HH",
      str_detect(group_var_value, "Displaced within settlement HHs")      ~ "Households displaced within their settlement",
      str_detect(group_var_value, "male_hoh")      ~ "Male head of HH",
      str_detect(group_var_value, "displaced_center")      ~ "Moved to a collective center",
      str_detect(group_var_value, "displaced_own")      ~ "Moved to individual accommodation (off-site, group center, and host family)",
      str_detect(group_var_value, "mixed_status_ndp_ridp")      ~ "Mixed status (some household members are non-displaced and some are returnees)",
      
      str_detect(group_var_value, "mixed_status_ndp_idp")      ~ "Mixed status (some housheold members are non-displaced and some are IDPs)",
      
      
      
      # ── new rule: it *is* a pop‑group split but not one of the above
      str_detect(group_var, fixed("pop_group")) ~ "other",
      
      # ── default: no pop‑group disaggregation
      TRUE                                       ~ "No disaggregation"
    ),
    admin_info = if_else(
      str_detect(group_var, fixed("ADMIN")),              # only for ADMIN rows
      map_chr(group_var_value, get_admin),                # vectorised helper
      "All-country"
    ),
    setting = case_when(
      str_detect(group_var_value, "RURAL") ~ "Rural",
      str_detect(group_var_value, "URBAN/PERI-URBAN") ~ "Urban/peri-urban",
      str_detect(group_var_value, "CAMP/SITE") ~ "Camp/site",
      str_detect(group_var_value, "INFORMAL SITE") ~ "Informal site",
      
      str_detect(group_var_value, "OTHER SETTING") ~ "Other setting",
      TRUE                                  ~ "No setting disaggregation"
    )
    
    
    )

pippo <- pBI_indicator_data
pBI_indicator_data <- pippo

pBI_indicator_data <- pBI_indicator_data %>%
  left_join(filter_lookup, by = "country") %>%
  # We do rowwise() so each row uses that row's col1–col4 for matching
  rowwise() %>%
  filter(
    # Keep the row if group_var == "overall"
    # or if group_var partially matches any of the colN patterns (which might be NA)
    str_detect(group_var, fixed("overall")) ||
      (!is.na(col1) && str_detect(group_var, regex(paste0("\\b", col1, "\\b"), ignore_case = FALSE))) ||
      (!is.na(col2) && str_detect(group_var, regex(paste0("\\b", col2, "\\b"), ignore_case = FALSE))) ||
      (!is.na(col3) && str_detect(group_var, regex(paste0("\\b", col3, "\\b"), ignore_case = FALSE))) ||
      (!is.na(col4) && str_detect(group_var, regex("\\bsetting\\b")))
  ) %>%
  ungroup() %>%
  select(-col1, -col2, -col3, -col4)  # drop the helper columns


pBI_indicator_data <- pBI_indicator_data %>%
  filter(
    # Keep all rows EXCEPT those that have `child_gender_d` in `group_var`
    # AND do not have "Boys" or "Girls" in `group_var_value`.
    !(
      str_detect(group_var, fixed("child_gender_d")) &
        !(
          str_detect(group_var_value, fixed("Boys")) |
            str_detect(group_var_value, fixed("Girls"))
        )
    )
  )

is_valid_group <- function(gv, allowed) {
  # split on  %/%  and trim spaces
  tokens <- str_split(gv, "\\s*%/%\\s*")[[1]] |> str_trim()
  # TRUE only if *every* token is in the allowed list
  all(tokens %in% allowed)
}

pBI_indicator_data <- pBI_indicator_data %>% 
  
  # join the country‑specific whitelist (col1–col4)
  left_join(filter_lookup, by = "country") %>% 
    # rowwise evaluation --------------------------------------------------------
  rowwise() %>% 
    filter({
      allowed_tokens <- c("overall", "pop_group", "child_gender_d",'setting',
                          col1, col2, col3, col4) |>
        na.omit()                 # drop NA columns
      is_valid_group(group_var, allowed_tokens)
    }) %>% 
    
    ungroup() %>% 
    select(-col1, -col2, -col3, -col4)            # remove helpers




pBI_indicator_data <- pBI_indicator_data %>% 
  filter(group_var != "disagg_ADMIN_pop") %>%
  mutate(
    stat_pct = round(stat, 3)
  )%>% 
  relocate(stat_pct, .after = stat)  %>% 
  mutate(
    indicator = indicator_label_list[analysis_var]    # look‑up by name
  ) %>% 
  relocate(indicator, .after = analysis_var)          # put it right after analysis_var


pBI_binary_indicator_data <- pBI_indicator_data %>%
  filter( analysis_var != "edu_barrier_d" )%>%
  select(-analysis_var_value, -group_var, -group_var_value, -stat)  

pBI_barrier_indicator_data <- pBI_indicator_data %>%
  filter( analysis_var == "edu_barrier_d" )%>%
  select(-group_var, -group_var_value, -stat_pct)  




pBI_binary_indicator_data_only_gender <- pBI_binary_indicator_data
pBI_binary_indicator_data_only_gender <- pBI_binary_indicator_data_only_gender %>%                                    
  # 1) map the three gender strings to the *column* names you want
  mutate(gender_col = case_when(
    gender == "Overall" ~ "ind_overall",
    gender == "Girls"   ~ "ind_girl",
    gender == "Boys"    ~ "ind_boy",
    TRUE                ~ NA_character_       # drop or keep as NA
  )) %>%
  # 2) reshape long → wide
  pivot_wider(
    id_cols    = c(country, analysis_var, school_cycle, indicator, admin_info, pop_group, setting),
    # ↑ keep any other constant cols you like
    names_from = gender_col,
    values_from = c(stat_pct, n_total),
    names_glue = "{.value}_{gender_col}"
  )
# pBI_binary_indicator_data_only_gender <- pBI_binary_indicator_data_only_gender %>%                                    
#   # 1) map the three gender strings to the *column* names you want
#   mutate(gender_col = case_when(
#     gender == "Overall" ~ "ind_overall",
#     gender == "Girls"   ~ "ind_girl",
#     gender == "Boys"    ~ "ind_boy",
#     TRUE                ~ NA_character_       # drop or keep as NA
#   )) %>%
#   count(country, analysis_var, school_cycle, indicator, admin_info, pop_group, setting, gender_col) %>%
#   filter(n > 1)

write_xlsx(pBI_binary_indicator_data_only_gender, "output/global_pBI/2024_MSNA_binary_only_gender.xlsx")
write_csv(pBI_binary_indicator_data_only_gender, "output/global_pBI/2024_MSNA_binary_only_gender.csv")




write_xlsx(pBI_indicator_data, "output/global_pBI/2024_MSNA_all_indicator_data.xlsx")
write_csv(pBI_indicator_data, "output/global_pBI/2024_MSNA_all_indicator_data.csv")
write_xlsx(pBI_binary_indicator_data, "output/global_pBI/2024_MSNA_binary_indicator_data.xlsx")
write_csv(pBI_binary_indicator_data, "output/global_pBI/2024_MSNA_binary_indicator_data.csv")


pBI_binary_indicator_data_clustering <- pBI_binary_indicator_data %>%
  # Remove unnecessary columns
  select(-indicator, -n_total) %>%
  
  # Keep only rows where gender is 'Overall'
  filter(gender == "Overall") %>%
  
  # Filter out 'All-country' from admin_info
  filter(admin_info != "All-country") %>%
  
  # Keep only rows with no disaggregation for pop_group and setting
  filter(
    pop_group == "No disaggregation",
    setting == "No setting disaggregation"
  ) %>%
  
  # Apply conditional filtering based on analysis_var and school_cycle
  filter(
    analysis_var %in% c(
      "edu_attending_level0_level1_and_level1_minus_one_age_d",
      "edu_attending_level1_and_level1_minus_one_age_d",
      "edu_attending_level1234_and_level1_age_d",
      "edu_attending_level234_and_level2_age_d",
      "edu_attending_level34_and_level3_age_d"
    ) |
      school_cycle == "No disaggregation"
  ) %>%
  # Also: if the first two vars above, require school_cycle to be ECE
  filter(
    !(analysis_var %in% c(
      "edu_attending_level0_level1_and_level1_minus_one_age_d",
      "edu_attending_level1_and_level1_minus_one_age_d"
    )) |
      school_cycle == "ECE"
  ) %>%
  # Remove disaggregation columns not needed for clustering
  select(-pop_group, -school_cycle, -gender, -setting)


  pBI_binary_clustering <- pBI_binary_indicator_data_clustering %>%
    pivot_wider(
      names_from = analysis_var,
      values_from = stat_pct
    )

  write_xlsx(pBI_binary_clustering, "output/global_pBI/2024_MSNA_binary_clustering_data.xlsx")
  write_csv(pBI_binary_clustering, "output/global_pBI/2024_MSNA_binary_clustering_data.csv")
  




















## barrier labeling
barrier_label_long <- barrier_label %>%
  pivot_longer(cols = everything(), names_to = "new_value", values_to = "old_value") %>%
  filter(!is.na(old_value)) # Remove any rows with NA in old_value
pBI_barrier_indicator_data <- pBI_barrier_indicator_data %>%
  left_join(barrier_label_long, by = c("analysis_var_value" = "old_value")) %>%
  mutate(analysis_var_value = ifelse(!is.na(new_value), new_value, analysis_var_value)) %>%
  select(-new_value)

# barrier dataframe
pBI_barrier_indicator_data <- pBI_barrier_indicator_data %>% 
  group_by(country, indicator, gender, school_cycle,
           pop_group, admin_info, setting) %>% 
  arrange(desc(stat), .by_group = TRUE) %>% 
  ungroup()%>%
  filter(!is.na(analysis_var_value) & !is.na(stat))

n_top_barrier = 10
pBI_barrier_indicator_data_arranged <- pBI_barrier_indicator_data %>%
  group_by(country, indicator, gender, school_cycle,
           pop_group, admin_info, setting) %>% 
  arrange(desc(stat), .by_group = TRUE) %>% # Sort by stat in descending order for each country
  slice_head(n = n_top_barrier) %>% # Select the top 7 rows for each country
  ungroup() # Ungroup after operation

pBI_barrier_indicator_data_arranged_top1 <- pBI_barrier_indicator_data %>%
  group_by(country, indicator, gender, school_cycle,
           pop_group, admin_info, setting) %>% 
  arrange(desc(stat), .by_group = TRUE) %>% # Sort by stat in descending order for each country
  slice_head(n = 1) %>% # Select the top 7 rows for each country
  ungroup() # Ungroup after operation

pBI_barrier_indicator_data_arranged_top1 <- pBI_barrier_indicator_data_arranged_top1 %>%
  filter(!is.na(admin_info))

pBI_barrier_indicator_data_arranged_top1 <- pBI_barrier_indicator_data_arranged_top1 %>%
  # Remove unnecessary columns
  select(-indicator, -n_total,-analysis_var ) %>%
  
  
  # Filter out 'All-country' from admin_info
  filter(admin_info != "All-country") %>%
  
  # Keep only rows with no disaggregation for pop_group and setting
  filter(
    pop_group == "No disaggregation",
    setting == "No setting disaggregation",
    school_cycle == "No disaggregation"
  ) %>%
  # Remove disaggregation columns not needed for clustering
  select(-pop_group, -school_cycle, -setting)


barrier_top1_clustering <- pBI_barrier_indicator_data_arranged_top1 %>%
  mutate(gender = case_when(
    gender == "Overall" ~ "barrier_overall",
    gender == "Boys"    ~ "barrier_boys",
    gender == "Girls"   ~ "barrier_girls",
    TRUE                ~ NA_character_
  )) %>%
  filter(!is.na(gender)) %>%  # just in case any NA slipped in
  select(admin_info, gender, analysis_var_value) %>%
  pivot_wider(
    names_from = gender,
    values_from = analysis_var_value,
    values_fn = list(analysis_var_value = dplyr::first)  # <-- this suppresses the warning
  )


write_xlsx(barrier_top1_clustering, "output/global_pBI/2024_MSNA_barrier_top1_indicator_data.xlsx")
write_csv(barrier_top1_clustering, "output/global_pBI/2024_MSNA_barrier_top1_indicator_data.csv")

pBI_combined_clustering <- pBI_binary_clustering %>%
  left_join(barrier_top1_clustering, by = "admin_info")
write_xlsx(pBI_combined_clustering, "output/global_pBI/2024_MSNA_combined_clustering_data.xlsx")
write_csv(pBI_combined_clustering, "output/global_pBI/2024_MSNA_combined_clustering_data.csv")


not_specified <- pBI_barrier_indicator_data %>% 
  group_by(country, indicator, gender, school_cycle,
           pop_group, admin_info, setting) %>% 
  slice_max(stat, n = n_top_barrier, with_ties = FALSE) %>% 
  summarise(
    analysis_var_value = "Other",
    stat  = pmax(0, 1 - sum(stat, na.rm = TRUE)),          # remainder; never < 0
    analysis_var = "edu_barrier_d",
    .groups = "drop"                                       # ungroup in one step
  )


pBI_barrier_indicator_data_top7 <- bind_rows(pBI_barrier_indicator_data_arranged, not_specified) %>%
  arrange(country, indicator, gender, school_cycle,
          pop_group, admin_info, setting,n_total, desc(stat)) # Arrange the final data by country and stat




pBI_barrier_indicator_data_top7 <- pBI_barrier_indicator_data_top7 %>% 
  mutate(
    stat_pct = round(stat, 3)
  )%>% 
  relocate(stat_pct, .after = stat)  %>% 
  select(-stat)  

pBI_barrier_indicator_data <- pBI_barrier_indicator_data %>% 
  mutate(
    stat_pct = round(stat, 3)
  )%>% 
  relocate(stat_pct, .after = stat) %>% 
  select(-stat)  





write_xlsx(pBI_barrier_indicator_data_top7, "output/global_pBI/2024_MSNA_barrier_top10_indicator_data.xlsx")
write_csv(pBI_barrier_indicator_data_top7, "output/global_pBI/2024_MSNA_barrier_top10_indicator_data.csv")
write_xlsx(pBI_barrier_indicator_data, "output/global_pBI/2024_MSNA_barrier_indicator_data.xlsx")
write_csv(pBI_barrier_indicator_data, "output/global_pBI/2024_MSNA_barrier_indicator_data.csv")



## preparing new sheet for powerbi
# Helper that turns any string into a legal Excel‑sheet name (≤31 chars, no []*/\?:)
clean_sheet <- function(x) {
  x <- str_replace_all(x, "[\\[\\]*/:\\?\\\\]", "_")  # replace illegal chars
  x <- str_trim(x)
  if (nchar(x) > 31) substr(x, 1, 31) else x
}

# ── 1. Workbook: one sheet per COUNTRY ───────────────────────────────────────
wb_binary_country <- createWorkbook()
wb_barrier_country <- createWorkbook()

for (ct in sort(unique(pBI_binary_indicator_data$country))) {
  sheet <- clean_sheet(ct)
  addWorksheet(wb_binary_country, sheet)
  writeData(
    wb_binary_country, sheet,
    pBI_binary_indicator_data %>% filter(country == ct)
  )
}
for (ct in sort(unique(pBI_barrier_indicator_data_top7$country))) {
  sheet <- clean_sheet(ct)
  addWorksheet(wb_barrier_country, sheet)
  writeData(
    wb_barrier_country, sheet,
    pBI_barrier_indicator_data_top7 %>% filter(country == ct)
  )
}

saveWorkbook(
  wb_binary_country,
  file = "output/global_pBI/2024_MSNA_binary_indicator_by_country.xlsx",
  overwrite = TRUE
)
saveWorkbook(
  wb_barrier_country,
  file = "output/global_pBI/2024_MSNA_barrier_indicator_by_country.xlsx",
  overwrite = TRUE
)

# ── 2. Workbook: one sheet per INDICATOR (analysis_var) ──────────────────────


wb_indicator <- createWorkbook()

for (ind in indicator_list) {               # or: unique(pBI_indicator_data$analysis_var)
  sheet <- clean_sheet(ind)
  
  # ensure sheet names are unique even if truncation makes duplicates
  if (sheet %in% names(wb_indicator$worksheets)) {
    sheet <- make.unique(c(names(wb_indicator$worksheets), sheet))[length(wb_indicator$worksheets)+1]
  }
  
  addWorksheet(wb_indicator, sheet)
  
  writeData(
    wb_indicator, sheet,
    pBI_binary_indicator_data %>% filter(analysis_var == ind)
  )
}

saveWorkbook(
  wb_indicator,
  file = "output/global_pBI/2024_MSNA_binary_indicator_by_each_indicator.xlsx",
  overwrite = TRUE
)




