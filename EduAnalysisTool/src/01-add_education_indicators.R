
#--------------------------------------------------------------------------------------------------------
# Read in the main and loop datasets
main <- read_xlsx(data_file,
                  na = c("NA", "#N/A", "", " ", "N/A"),
                  sheet = main_sheet)

loop <- read_xlsx(data_file,
                  na = c("NA", "#N/A", "", " ", "N/A"),
                  sheet = loop_sheet)

#check if start is NULL
if (is.null(survey_start_date) || is.na(survey_start_date)) {
  main$start <- as.POSIXct("2024-06-01 11:54:54.574")
  survey_start_date = 'start'
}

occupation_col <- if (!is.null(list_variables$occupation)) paste0(list_variables$occupation, "_d") else NULL
hazards_col <- paste0(list_variables$hazards, "_d")
displaced_col <- paste0(list_variables$displaced, "_d")
teacher_col <- paste0(list_variables$teacher, "_d")

loop <- loop %>%
  mutate(!!ind_age := as.numeric(.data[[ind_age]]))

# columns_to_convert <- c(
#   "edu_access_only_formal", 
#   "edu_access_only_nonformal", 
#   "edu_access_formal_OR_structured_nonformal", 
#   "edu_access_formal_AND_nonformal", 
#   "edu_access_formal_OR_nonformal"
# )
# 
# loop <- loop %>%
#   mutate(across(all_of(columns_to_convert), ~ as.numeric(.)))

#--------------------------------------------------------------------------------------------------------
# Apply transformations to loop dataset
loop <- loop |>
  # Education from Humind
  add_loop_edu_ind_age_corrected(main = main, id_col_loop = id_col_loop, id_col_main = id_col_main, survey_start_date = survey_start_date, school_year_start_month = school_year_start_month, ind_age = ind_age) |>
  add_loop_edu_access_d(ind_access = ind_access,  pnta = pnta, dnk = dnk, yes= yes,no =no) |>
  add_loop_edu_disrupted_d(occupation = occupation, hazards = hazards, displaced = displaced, teacher = teacher, levels = c(yes, no, dnk, pnta))
  
  
loop <- loop %>%
    dplyr::rename(
      edu_disrupted_hazards_d = !!rlang::sym(hazards_col),
      edu_disrupted_displaced_d = !!rlang::sym(displaced_col),
      edu_disrupted_teacher_d = !!rlang::sym(teacher_col)
  )

# Conditionally rename occupation if it is not NULL
if (!is.null(occupation_col)) {
    loop <- loop %>%
      dplyr::rename(edu_disrupted_occupation_d = !!rlang::sym(occupation_col))
}

# from 00_edu_function.R
loop <- loop |>
  # Add a column edu_school_cycle with ECE, primary (1 or 2 cycles) and secondary
  add_edu_school_cycle(country_assessment = country_code, path_ISCED_file = path_ISCED_file, language_assessment =language_assessment) |>

# IMPORTANT: THE INDICATOR MUST COMPLAY WITH THE MSNA GUIDANCE AND LOGIC --> data/edu_ISCED/UNESCO ISCED Mappings_MSNAcountries_consolidated
# Add columns to use for calculation of the composite indicators: Net attendance, early-enrollment, overage learners
  add_edu_level_grade_indicators(country_assessment = country_code, path_ISCED_file = path_ISCED_file, education_level_grade = education_level_grade, id_col_loop = id_col_loop, pnta = pnta, dnk = dnk)

#harmonized variable to use the loa_edu
loop <- loop |>
  add_loop_edu_barrier_d(barrier = barrier)|>
  add_loop_child_gender_d (ind_gender = ind_gender, language_assessment = language_assessment)

# OPTIONAL, non-core indicators, remove if not present in the MSNA
#add_loop_edu_optional_nonformal_d(edu_other_yn = "edu_other_yn",edu_other_type = 'edu_non_formal_type',yes = "yes",no = "no",pnta = "pnta",dnk = "dnk" )|>
#add_loop_edu_optional_community_modality_d(edu_community_modality = "edu_community_modality" )|>

if (!is.null(nonformal) && !is.na(nonformal)) {
  loop <- loop |>
    add_loop_edu_optional_nonformal_d(edu_other_yn = nonformal, edu_other_type = nonformal_type, pnta = pnta, dnk = dnk, yes= yes,no =no)
}


############## WGS!!

if (!is.null(wsg_seeing) && !is.na(wsg_seeing) &&
    !is.null(wsg_hearing) && !is.na(wsg_hearing) &&
    !is.null(wsg_walking) && !is.na(wsg_walking) &&
    !is.null(wsg_remembering) && !is.na(wsg_remembering) &&
    !is.null(wsg_selfcare) && !is.na(wsg_selfcare) &&
    !is.null(wsg_communicating) && !is.na(wsg_communicating)) {
  loop <- loop |>
    add_loop_wgq_ss (ind_age = 'edu_ind_age_corrected', vision = wsg_seeing, hearing = wsg_hearing,
                     mobility = wsg_walking, cognition = wsg_remembering, self_care = wsg_selfcare, communication = wsg_communicating, 
                     no_difficulty = no_difficulty, some_difficulty = some_difficulty, lot_of_difficulty = lot_of_difficulty, cannot_do = cannot_do, 
                     undefined = c(dnk, pnta))
}

if (country_assessment == "MMR") {
  loop <- loop %>%
    mutate(
      school_cycle_pop = NA_character_,
      disagg_pop_wgq_dis_3 = NA_character_,
      disagg_pop_wgq_dis_2 = NA_character_,
      disagg_pop_access = NA_character_
    )
}
#--------------------------------------------------------------------------------------------------------
# Merge main info into loop dataset
# add strata inf from the main dataframe, IMPORTAN: weight and the main strata
check_and_set_merge_column <- function(loop, main_col) {
    if (main_col %in% colnames(loop)) NULL else main_col
}
  
  
add_col6_merge <- if (!is.null(add_col6)) check_and_set_merge_column(loop, add_col6) else NULL
add_col7_merge <- if (!is.null(add_col7)) check_and_set_merge_column(loop, add_col7) else NULL
add_col8_merge <- if (!is.null(add_col8)) check_and_set_merge_column(loop, add_col8) else NULL
add_col9_merge <- if (!is.null(add_col9)) check_and_set_merge_column(loop, add_col9) else NULL
#add_col4 = 'edu_community_modality'
  
loop <- merge_main_info_in_loop(loop = loop, main = main, id_col_loop = id_col_loop, id_col_main = id_col_main,
                                admin1 = admin1, admin2 = admin2, admin3 = admin3, stratum = stratum, 
                                additional_stratum = additional_stratum, weight = weight_col, 
                                add_col1 = add_col1, add_col2 = add_col2, add_col3 = add_col3, 
                                add_col4 = add_col4, add_col5 = add_col5, add_col6 = add_col6_merge, 
                                add_col7 = add_col7_merge, add_col8 = add_col8_merge,  add_col9 = add_col9_merge)

if (country_assessment == "MMR") {
  loop <- loop %>%
    mutate(
      school_cycle_pop = paste(pop_group, edu_school_cycle_d, sep = "#"),
      disagg_pop_wgq_dis_3 = paste(pop_group, wgq_dis_3, sep = "#"),
      disagg_pop_wgq_dis_2 = paste(pop_group, wgq_dis_2, sep = "#"),
      disagg_pop_access= paste(pop_group, edu_ind_access_d, sep = "#")
    )
}

# keep only school-age children
loop <- loop |> filter(edu_ind_schooling_age_d == 1)
if (country_assessment == "AFG"){
  loop <- loop |> filter(edu_ind_age_corrected != 5)
}
loop_edu_recorded <- loop


#--------------------------------------------------------------------------------------------------------
# Save the final output to an Excel file
loop |> write.xlsx(paste0('output/loop_edu_recorded_',country_assessment,'.xlsx'))
  




