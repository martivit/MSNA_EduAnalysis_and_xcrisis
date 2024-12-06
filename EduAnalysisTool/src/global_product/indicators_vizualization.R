# Load packages -----------------------------------------------------------
library(impactR.utils)
library(humind)
library(presentresults)
library(analysistools)

# Needed tidyverse packages
library(dplyr)
library(readxl)
library(openxlsx)
library(tidyr)
library(stringr)
library(ggplot2)
library(srvyr)
library(gt)
library(tidyr)
library(officer)
library(flextable)
library(ggplot2)




source("src/functions/functions_info_global.R")
source("src/functions/00_edu_helper.R")
source("src/functions/00_edu_function.R")
source("src/functions/global_analysis_function.R")


## combine datasets:
source("src/global_product/01_create_combined_dataset.R")
# --> labeled_binary_indicator_data
# --> barrier_data

## create global_plots
source("src/global_product/02_plot_binary_indicators.R")
generate_indicator_plot(indicator_list, labeled_binary_indicator_data, indicator_label_list, "overall", "output/global/plot")
generate_indicator_plot(indicator_list, labeled_binary_indicator_data, indicator_label_list, "level0", "output/global/plot/ECE")
generate_indicator_plot(indicator_list, labeled_binary_indicator_data, indicator_label_list, "level1", "output/global/plot/primary")
generate_indicator_plot(indicator_list, labeled_binary_indicator_data, indicator_label_list, "level2", "output/global/plot/level2")

## create country_snapshot
source("src/global_product/03_snapshot.R")


for (country in available_countries) {
  tryCatch({
    generate_snapshot(country)
  }, error = function(e) {
    message("Error generating snapshot for ", country, ": ", e$message)
  })
}
