# Education MSNA Analysis Pipeline

**Table of Contents**

1. [Analysis workflow/pipeline](#analysis-workflowpipeline)
2. [Analysis Overview](#analysis-overview)
3. [Analysis Implementation, single country](#analysis-implementation-single-country)
   - [Repository structure](#0-Repository-structure)
   - [Install functions and load Data](#1-Install-functions-and-load-Data)
   - [What must be configured before running](2-What-must-be-configured-before-running)
   - [Add Education Indicators](#3-Add-Education-Indicators)
   - [Run Education Analysis](#4-Run-Education-Analysis)
   - [Import Labels](#5-Label-Data)
   - [Final output - I: Tables](#6-Create-Tables)
   - [Final output - II: Graphs](#7-Create-Graphs)
4. [X-Crisis Analysis](#x-crisis-analysis)

 
## Analysis workflow/pipeline

The education analysis workflow is organised into four sequential and interdependent components:

1. **Single-country education analysis**  
   It transforms clean MSNA household and education-loop data into:
    - harmonized child-level education indicators,
    - weighted estimates using a country-specific LOA,
    - labelled, publication-ready tables,
    - Excel outputs and figures used for Education PiN and severity analysis.  
   This step is mandatory and constitutes the foundation of all subsequent analyses.

2. **x-crisis analysis (global combined dataset and plots)**  
   Aggregation of country-level outputs into a single cross-country dataset, enabling global comparisons, x-crisis visualizations, and standardized country snapshots.

3. **PowerBI / dashboard dataset preparation**  
   Transformation of global combined data into clean, flat, analysis-ready tables optimized for PowerBI dashboards and interactive exploration.

4. **Dataset preparation for clustering (PiN workflow)**  
   Construction of strictly filtered, admin-level datasets designed for PCA and clustering analyses supporting PiN severity workflows.

Each step depends on the successful execution of the previous one and should be run in the order listed above.

The pipeline is metadata-driven: country-specific logic, variables, labels, and strata are controlled through configuration files rather than hard-coded logic.

## Content of the Analysis structure
### Analysis Overview

The analysis should be conducted at the individual level and can be divided into two main categories:<br>
A. <span style="color:blue">**Children accessing education**</span>: Focus on their profiles and the challenges they face while attending school.<br>
B. <span style="color:blue">**Children not accessing education – Out-of-school (OSC)**</span>: Focus on identifying the main barriers preventing their access.<br><br>

#### **1. Analysis of Children Accessing Education**
Two key dimensions are essential for this analysis: access to education and the impact of significant events on education during the school year.<br>

- **Access to education**: Analyse the percentage of children aged 5 to 17 who attended school or any early childhood education program at any time during the 202x-202x+1 school year.

- **Education disruption**: Assess whether any significant events disrupted education during the school year, with a focus on factors such as:

  - Natural hazards (e.g., floods, cyclones, droughts, wildfires, earthquakes)
  - Teacher absences
  - Schools being used as shelters for displaced persons
  - Direct attack on education / Schools occupied by armed forces or non-state armed groups (if applicable in your MSNA)

##### Sub-School-Age Categories Analysis
The analysis should account for sub-school-age categories to capture more detailed insights into access to education. These categories can be broken down as follows:<br>

-	**5-year-olds**: one year before the official primary school entry age.
-	**Primary/intermediate/secondary School Age**: Children who fall within the age range for primary school. Key areas of analysis include access to education, net attendance rates,net attendance (adjusted) rates and over-age attendance (see below).


Breaking down the important dimension by school-age category:<br>
For **5-year-old** children, analysis should focus on the already mentioned access, disruption, and additionally Early Childhood Education indicators:

-	*ECE Access*: Participation rate in organized learning (one year before the official primary entry age). This refers to the percentage of children attending an early childhood education program or primary school.
-	*Early Enrolment in Primary Grades*: The percentage of children one year before the official primary school entry age attending primary school.

For children in the **primary school-age** category (and similarly for older age groups), access and disruption can be analysed along with:

-	*Net Attendance (adjusted) Rates*: The percentage of school-aged children in primary school, lower secondary, or upper secondary school who are currently attending school.
-	*Over-Age Attendance*: The percentage of school-aged children attending school who are at least two years older than the intended age for their grade, specifically at the primary school level.


#### **2. Analysis of Children Not Accessing Education, OoS**
Two key dimensions are essential for this analysis: the out-of-school rate and the barriers preventing access to education.
- **Out-of-School Rate**: Analyse the percentage of school-aged children who are not attending any level of education.
- **Barriers to Education**: Identify the main barriers preventing children from attending school.

#### **3. Additional analysis**
- *non-formal education*
- *disaggregation and analysis of WGS indicators*

**All the mentioned dimensions and indicators should always be disaggregated by gender, and, where possible, by population group and administrative level**


---

## Analysis Implementation, single country

### 0. Repository structure 

This repository is designed to process and analyze educational data from various sources. It provides a systematic approach to adding indicators, running analyses, and generating tables for different educational metrics. The script is modular and can be adapted for different countries, datasets, and languages.

The Main.R script and repository are organized to follow a systematic approach to process and analyze educational data. The structure is divided into several steps, each corresponding to specific functions or scripts that move the data from clean input to final analysis and output.

### 1. Install packages and source needed functions and Data Preparation

```
if(!require(devtools)) install.packages("devtools")
devtools::install_github("impact-initiatives-hppu/humind")
devtools::install_github("impact-initiatives/analysistools")
devtools::install_github("impact-initiatives/presentresults")

library(humind) 
library(analysistools)
library(presentresults)
```
##### Additional functions 
```
source ('src/functions/00_edu_helper.R')
source ('src/functions/00_edu_function.R')
source("src/functions/create_education_table_group_x_var.R")
source("src/functions/create_education_xlsx_table.R")

source('src/01-add_education_indicators.R')
source('src/02-education_analysis.R')
source('src/03-education_labeling.R')
source('src/04-01-make-table-access-overaged-barriers.R')
source('src/04-02-make-level-table.R')
source('src/05-01-make-graphs-and-maps-tables.R')
```

### 2. What must be configured before running

#### 2.1 Country selection
In the main script:
```r
country_assessment <- "<ISO3>"
```

#### 2.2 Metadata (mandatory)
```
../metadata_edu.xlsx
```
Defines dataset paths, variables, strata, weights, and language.

#### 2.3 Required inputs
- Country MSNA dataset (main + education loop)
- ISCED mapping file
- LOA template
- Helper tables
- Kobo survey and choices sheets

Define paths to all input data files: Dataset folder and  ISCED mappings
```
path_ISCED_file <- 'resources/UNESCO ISCED Mappings_MSNAcountries_consolidated.xlsx'
data_file <- paste0('../DATA/',country_assessment, '/',list_info_general$dataset)
kobo_path <- paste0('../DATA/',country_assessment, '/',list_info_general$dataset)
```

#### Conceptual workflow
Clean MSNA data → Indicators → LOA → Weighted analysis → Labelling → Tables & figures


### 3. Add Education Indicators
The function processes the cleaned data by adding relevant education indicators. It adds the following indicators and information:

- Access 

- Education disruption

- School-cycle age categorization: Add a column edu_school_cycle with ECE, primary (1 or 2 cycles) and secondary

- Level-grade composite indicators: Net attendance, early-enrollment, overage learners.

- OPTIONAL non-core indicators, non-formal and community modality

- Merge the loop with the main script to retrieve weight and strata information, such as admin levels, population groups, etc.

- Filter for School-Age Children


The function is defined in **01-add_education_indicators.R**. 

It uses Humind package (https://github.com/impact-initiatives-hppu/humind) and additional education functions defined in 00_edu_function.R
```
source('src/01-add_education_indicators.R')

```
The processed dataset with the recorded education indicators is saved in the *output/loop_edu_recorded.xlsx* file. It serves as the foundation for the further steps.

### 4. Run Education Analysis

This function runs the analysis based on the data with the added indicators. It includes generating summary statistics and applying filters based on predefined variables and thresholds.

It is defined in **02-education_analysis.R**

It uses analysistools::create_analysis() function from the **impact-initiatives/analysistools** package https://github.com/impact-initiatives/analysistools/blob/main/R/create_analysis.R

```
source('src/02-education_analysis.R')
```
The output is saved here: *output/grouped_other_education_results_loop.RDS*

### 5. Label Data

After running the analysis, this function ensures that the correct labels are applied to the indicators for easy interpretation. It converts technical names into user-friendly labels according to the KOBO survey and choices and the edu_indicator_labeling.xlsx
This labeling step is crucial for aligning the analysis output with the desired format for reporting and visualization, ensuring consistency across the dataset and tables.


The function is defined here: **03-education_labeling.R**.

```
source('src/03-education_labeling.R')  ## OUTPUT: output/labeled_results_table.RDS  ---- df: education_results_table_labelled
```
The output is saved here: *output/labeled_results_table.RDS  ---- df: education_results_table_labelled*

### 6. Create Tables 
First create workbook for tables
```
education_results_table_labelled <- readRDS("output/labeled_results_table.RDS")

wb <- openxlsx::createWorkbook("education_results")
addWorksheet(wb, "Table_of_content")
writeData(wb, sheet = "Table_of_content", x = "Table of Content", startCol = 1, startRow = 1)

row_number_lookup <- c(
  "access" = 2,
  "overaged" = 3,
  "out_of_school" = 4,
  "ece" = 5,
  "level1" = 6,
  "level2" = 7,
  "level3" = 8,
  "level4" = 9
)

```

##### Create **Analysis of Children Accessing Education** 

It generates a table showing data on disruptions to education (e.g., due to teacher absence, school occupation, hazards).
```
tab_helper <- "access"
source("src/04-01-make-table-access-overaged-barriers.R")
```
It generates a table showing data on overaged learners.
```
tab_helper <- "overaged"
source("src/04-01-make-table-access-overaged-barriers.R")
```
##### Create **Analysis of Children Not Accessing Education, OoS** 

IMPORTANT: open grouped_other_education_results_loop and copy the first (in decreasing order) 5 edu_barrier_d results in the edu_table_helper_FR.xlsx.  
```
tab_helper <- "out_of_school"
source("src/04-01-make-table-access-overaged-barriers.R")
```

##### Create **Early childhood education and early enrollment** 

It generates a table specifically for indicators related to children one year before they reach the age to start primary school.
```
tab_helper <- "ece"
source("src/04-02-make-level-table.R")
```

##### Create **School Attendance Profile** 

To repeat according to the number of levels (except ECE) in the country's school system

```
tab_helper <- "level1"
source("src/04-02-make-level-table.R")

tab_helper <- "level2"
source("src/04-02-make-level-table.R")

tab_helper <- "level3"
source("src/04-02-make-level-table.R")

openxlsx::saveWorkbook(wb, "output/education_results.xlsx", overwrite = T)
openxlsx::openXL("output/education_results.xlsx")
```

#### Final Output and Workbook Creation

A workbook is created using openxlsx, which consolidates all the tables and analysis results into one Excel file. It can be found here: **output/education_results.xlsx**.

It includes a Table of Contents: a summary sheet that hyperlinks to each table in the workbook is created for easy navigation.

### 7. Create Graphs 
```
tab_helper <- "access"
results_filtered <- "output/rds_results/access_results.rds"
source("src/05-01-make-graphs-and-maps-tables.R")

tab_helper <- "overaged"
results_filtered <- "output/rds_results/overaged_results.rds"
source("src/05-01-make-graphs-and-maps-tables.R")

tab_helper <- "out_of_school"
results_filtered <- "output/rds_results/out_of_school_results.rds"
source("src/05-01-make-graphs-and-maps-tables.R")

tab_helper <- "ece"
results_filtered <- "output/rds_results/ece_results.rds"
source("src/05-01-make-graphs-and-maps-tables.R")

tab_helper <- "level1"
results_filtered <- "output/rds_results/level1_results.rds"
source("src/05-01-make-graphs-and-maps-tables.R")

tab_helper <- "level2"
results_filtered <- "output/rds_results/level2_results.rds"
source("src/05-01-make-graphs-and-maps-tables.R")

tab_helper <- "level3"
results_filtered <- "output/rds_results/level3_results.rds"
source("src/05-01-make-graphs-and-maps-tables.R")
```



---

# X-Crisis Analysis

> **Entry point:** `indicators_vizualization.R` (main orchestrator)   
> **Scripts location:** `src/global_product/` (products) and `src/functions/` (shared logic / helpers) 

This pipeline takes **country-level MSNA education results** (one `analysis_key_output<COUNTRY>.csv` per country) and produces:
1) **Global x-crisis plots** (binary indicators) and **global barrier plots**, plus automated **country snapshots** (Word).   
2) **PowerBI-ready datasets** (clean, flat tables) and **clustering-ready extracts**. 

The pipeline is **metadata-driven** via `input_global/metadata_edu_global.xlsx`, which controls:
- which countries are included,
- country language,
- indicators list and labels,
- how to interpret population group / setting / admin disaggregation strings. 



## 0) Before running anything

### This pipeline is **not** a replacement for country education analysis
It only works if the country pipeline has already produced, for each country:
- `output/analysis_key_output<COUNTRY>.csv`  
(Example naming pattern in code: `analysis_key_output<country>.csv`) 

If a country file is missing, that country will simply not be added to the global dataset (the script checks `file.exists`). 

### The “source of truth” for comparability is the global metadata
The global pipeline does not guess which indicators to use: it reads them from the metadata and uses the same list across countries. 



## 1) Repository structure and required files

### Main script
- `indicators_vizualization.R` (sources everything and launches products) 

### Global scripts (products)
Located in `src/global_product/` and sourced by the main script: 
- `01_create_combined_dataset.R` (global combined datasets + labeling) 
- `01_05_create_combined_dataset_powerBI.R` (PowerBI datasets + clustering extracts) 
- `02_plot_binary_indicators.R` (global plots) 
- `03_snapshot.R` (country snapshot Word docs) 
- `04_barrier_global.R` (global barrier plots) 

### Shared functions (logic / helpers)
Located in `src/functions/` and sourced by the main script: 
- `functions_info_global.R` (reads global metadata → builds lists used everywhere) 
- `global_analysis_function.R` (country-specific relabeling using ISCED mappings; snapshot helpers) 
- `00_edu_helper.R` and `00_edu_function.R` (ISCED reading, education helper logic) 

### Required inputs (files/folders)
- `input_global/metadata_edu_global.xlsx` (controls countries + indicator list + parsing keywords) 
- `input_global/barrier_label.csv` (harmonises barrier response strings across countries) 
- `resources/UNESCO ISCED Mappings_MSNAcountries_consolidated.xlsx` (school cycle mapping & age ranges) 
- `output/analysis_key_output<COUNTRY>.csv` (one per country; produced upstream) 



## 2) How to run 

### Run the main script
Open `indicators_vizualization.R` and run it top-to-bottom.  
It **sources** each script in the correct order and calls the key functions. 

### Execution order (exactly as implemented)
1. Read global metadata and prepare lists  
   `source("src/functions/functions_info_global.R")` 
2. Load helper functions and relabeling logic  
   `00_edu_helper.R`, `00_edu_function.R`, `global_analysis_function.R` 
3. Build global combined datasets (binary + barrier)  
   `source("src/global_product/01_create_combined_dataset.R")` 
4. Build PowerBI datasets and clustering exports  
   `source("src/global_product/01_05_create_combined_dataset_powerBI.R")` 
5. Create global plots (binary indicators)  
   `source("src/global_product/02_plot_binary_indicators.R")`  
   then `generate_indicator_plot(...)` is called for: overall / level0 / level1 / level2 
6. Generate country snapshots (Word)  
   `source("src/global_product/03_snapshot.R")`  
   then `generate_snapshot(country)` for each available country with `tryCatch` 
7. Create global barrier plots  
   `source("src/global_product/04_barrier_global.R")`  
   then `create_barrier_plot("overall")`, plus Boys and Girls variants 


## PART I — Global x-Crisis Analysis & Visualisation

### 4) Global metadata: how countries and indicators are defined

### Script: `src/functions/functions_info_global.R`
This script reads `input_global/metadata_edu_global.xlsx` and builds the global lists used everywhere. 

Key outputs created in memory (examples):
- `available_countries`: only countries where `availability == "yes"` 
- `country_language_list`: language per country 
- `indicator_list`: list of indicator variable names used in global pipeline 
- `indicator_label_list`: a named vector mapping indicator → label (for plot titles) 

It also creates keyword lists per country used to parse disaggregation strings (pop groups, admin, setting). 

**Tips:** if a country is not appearing in outputs, check:
1) metadata `availability`, and
2) whether `output/analysis_key_output<COUNTRY>.csv` exists. 



### 5) Global dataset build: binary + barrier data

### Script: `src/global_product/01_create_combined_dataset.R`
This script is responsible for creating the canonical “global analysis tables” used for plots and snapshots. 

#### 5.1 Input expectation
For each country in `available_countries`, it looks for:
- `output/analysis_key_output<COUNTRY>.csv` 

It reads and keeps (minimum):
- `analysis_var`, `analysis_var_value` (indicator and response/value)
- `group_var`, `group_var_value` (disaggregation definition)
- `stat`, `stat_low`, `stat_upp` (point estimate and CI)
- `n_total`
- adds `country` 

#### 5.2 Standardisation step (critical)
Before filtering, it normalises “equivalent” indicator names to a single target name (to support cross-country comparability). 

Example: multiple attendance variables collapse into `edu_attending_level1234_and_level1_age_d` etc. 

#### 5.3 Binary vs barrier split
- **Binary indicators**: keep rows where `analysis_var` is in `indicator_list`, exclude `edu_barrier_d`, and keep only `analysis_var_value == 1`. 
- **Barrier indicators**: keep only `analysis_var == "edu_barrier_d"`. 

Gender labels are harmonised from French to English (`Filles`→`Girls`, `Garcons`→`Boys`). 

#### 5.4 Country-specific relabeling using ISCED mappings
The script then produces `labeled_binary_indicator_data` by applying `process_country()` for each country. 

`process_country()`:
- reads the country’s school structure from the UNESCO ISCED mapping file, 
- derives age ranges per level,
- constructs a label string (language-specific),
- replaces label strings in `group_var_value` with standard `level0/level1/level2/...` codes. 

This is what allows the plotting script to rely on `group_var_value` containing consistent tokens like `level0`, `level1`, etc. 

#### 5.5 Outputs
- `output/global/combined_data.csv`
- `output/global/binary_indicator_data.csv`
- `output/global/barrier_data.csv`
- `output/global/labeled_binary_indicator_data.csv` 



### 6) Global plots: binary indicators

### Script: `src/global_product/02_plot_binary_indicators.R`
This script defines `generate_indicator_plot(...)` and the main script calls it 4 times: 
- `overall` → `output/global/plot`
- `level0` (ECE) → `output/global/plot/ECE`
- `level1` (Primary) → `output/global/plot/primary`
- `level2` → `output/global/plot/level2`

#### What the function does
For each indicator in `indicator_list`:
- skips `edu_barrier_d` by design, 
- filters `labeled_binary_indicator_data` for the indicator and the selected group set:
  - `base1 = <group>` (e.g., `overall`)
  - `base2 = <group> %/% Boys`
  - `base3 = <group> %/% Girls` 
- creates a horizontal bar chart with CI (`stat_low`, `stat_upp`) and value labels,
- saves one JPEG per indicator per group scope with filename pattern:  
  `.../<analysis_var>_<group>.jpeg` 

#### Plot labeling
Plot titles come from `indicator_label_list[[indicator]]` (metadata-driven). 



### 7) Country snapshots (Word)

### Script: `src/global_product/03_snapshot.R`
The main script loops over `available_countries` and calls `generate_snapshot(country)`. 

The snapshot uses `officer` + `flextable` to assemble:
- “Access to Education” table,
- age group breakdown table,
- disruption plot (saved as temporary PNG),
- ECE indicators tables,
- overage indicators tables,
- net attendance tables. 

Output naming:
- `output/global/docx/<COUNTRY>_snapshot.docx` 



### 8) Global barrier plots

### Script: `src/global_product/04_barrier_global.R`
Defines `create_barrier_plot(group_plot, name_plot = "overall")`. 

Called by the main script for:
- `create_barrier_plot("overall")`
- `create_barrier_plot("overall %/% Boys", "boys")`
- `create_barrier_plot("overall %/% Girls", "girls")` 

#### How barriers are harmonised
- Reads `input_global/barrier_label.csv`
- Reshapes wide → long and maps old barrier labels → a harmonised label
- Applies mapping on `analysis_var_value` 

#### Top-N logic
- Selects `n_top_barrier = 6` highest barriers per country
- Computes an “Other” category as the remainder (`1 - sum(top barriers)`)
- Converts `stat` to percentages and saves a stacked bar plot. 

Output naming:
- `output/global/plot/barriers_to_education_plot_<name_plot>.jpeg` 

---

## PART II — PowerBI Dataset Preparation

### 9) Why this part exists
PowerBI dashboards require:
- explicit dimensions (gender, school cycle, admin, pop group, setting),
- consistent category labels across countries,
- flat tables (one record per indicator × admin × disaggregation),
- separate extracts for clustering (no disaggregation, admin-only).

This is why the pipeline produces **a separate PowerBI dataset suite** rather than reusing the plot datasets.

#### **This part of the pipeline is less robust than the others and requires more changes and fixes. The examples below illustrate some of the issues that may occur, but be prepared for additional, potentially tedious work to resolve them.**



### 10) PowerBI dataset construction

#### Script: `src/global_product/01_05_create_combined_dataset_powerBI.R`
This script rebuilds a combined dataset from the same country CSVs but reshapes and standardises it for PowerBI. 

#### 10.1 Input expectation
For each country:
- reads `output/analysis_key_output<COUNTRY>.csv`
- keeps: `analysis_var`, `analysis_var_value`, `group_var`, `group_var_value`, `stat`, `n_total` 

#### 10.2 Indicator filtering + standardisation
- Standardises “equivalent” attendance variables similarly to Part I. 
- Filters to keep only indicators in `indicator_list`
- Excludes zeros and missing values (script has a filter to drop `analysis_var_value == 0` and NAs). 

### 10.3 Metadata inputs used for PowerBI parsing (`metadata_edu_global.xlsx`)

The PowerBI dataset preparation relies on **country-specific keyword lists** stored in  
`input_global/metadata_edu_global.xlsx` and loaded by  
`src/functions/functions_info_global.R`.

The following sheets from `metadata_edu_global.xlsx` are used by the PowerBI pipeline:

#### `general`
Used to build:
- `available_countries`: only countries where `availability == "yes"`
- `country_language_list`: mapping between `country_assessment` and `language_assessment`

#### `indicators`
Used to build:
- `indicator_list`: global whitelist of indicators retained in PowerBI datasets
- `indicator_label_list`: mapping from technical indicator name to human-readable label  
  (used to populate the `indicator` column in outputs)

#### `strata_variables`
Used to build parsing keywords for:
- administrative disaggregation (`admin1_list`)
- population group variable name (`pop_group_list`)
- allowed / whitelisted disaggregation variables (`col1_list` … `col4_list`),  
  used to filter `group_var` and validate token combinations

#### `pop_group_names`
Used to build country-specific population group keyword lists:
- `host_list`
- `idp_list`
- `idp_host_list`
- `idp_camp_list`
- `ret_list`
- `refugee_list`

These keyword lists are used to detect and standardise population-group disaggregation in
`group_var_value`.

#### `setting_name`
Used to build country-specific setting keyword lists:
- `setting_list`
- `urban_list`
- `rural_list`
- `camp_list`
- `informal_list`
- `other_setting_list`

These keyword lists are used to standardise settlement / setting disaggregation.

#### `variables`
Used to load the original barrier variable name per country
(`barrier_orginal_name_list`).

In the PowerBI pipeline, barriers are subsequently harmonised using
`input_global/barrier_label.csv`.

The sheet name `pop_group_string` is defined in the metadata but is **not used**
by `process_metadata()` as currently implemented.

#### 10.3 Parsing disaggregation strings using per-country keywords
The script builds lookup tables from metadata lists:
- `pop_lookup` from `pop_group_list`, `host_list`, `idp_list`, etc. 
- `setting_lookup` from `setting_list`, `urban_list`, `rural_list`, etc. 
- `filter_lookup` from `col1_list ... col4_list` 

Using `replace_if_found(...)`, it normalises tokens inside `group_var_value`, for example:
- `IDP_HOST`, `IDP_SITE`, `HOST`, `REFUGEE`, etc.
- `ADMIN` for admin disaggregation
- `setting` for setting disaggregation 


### 10.4 Parsing and standardising population group, setting, and administrative disaggregation

A core challenge for PowerBI is that `group_var` and `group_var_value` strings are
**not consistent across countries**.

This script standardises them using **metadata-driven keyword replacement**, ensuring
cross-country comparability.

#### Step 1 — Build lookup tables from metadata

For each country, three lookup tables are constructed:

##### `pop_lookup`
Used to detect:
- population group categories (IDP, host, refugees, returnees),
- the country-specific admin variable name.

Built from:
- `strata_variables`: `pop_group` and `admin1`
- `pop_group_names`: country-specific population group keyword lists

##### `setting_lookup`
Used to detect and standardise settlement / setting categories  
(urban, rural, camp, informal, other).

Built from:
- `setting_name`

##### `filter_lookup`
Used as a **quality-control filter** to:
- keep only approved disaggregation variables in `group_var`,
- drop unexpected or invalid combinations of disaggregation tokens.

Built from:
- `strata_variables` (`col1_list` … `col4_list`)

#### Step 2 — Standardise population-group tokens in `group_var_value`

The script applies substring replacement using `replace_if_found()`.

**Order matters** to avoid partial matches overriding more specific categories.
The replacement is executed in the following order:

1. Returnees keyword → `RET`
2. IDP keyword → `IDP`
3. IDP-host keyword → `IDP_HOST`
4. IDP-camp keyword → `IDP_SITE`
5. Host keyword → `HOST`
6. Refugee keyword → `REFUGEE`

At the same time, `group_var` itself is standardised:
- if `group_var` contains the country-specific admin variable name → replaced by `ADMIN`
- if `group_var` contains the country-specific population group variable name → replaced by `pop_group`

This makes all downstream logic independent of country-specific variable names.



#### Step 3 — Standardise setting tokens in `group_var_value`

Using `setting_lookup`, the following replacements are applied:

- “other setting” keyword → `OTHER SETTING`
- rural keyword → `RURAL`
- urban keyword → `URBAN/PERI-URBAN`
- camp keyword → `CAMP/SITE`
- informal keyword → `INFORMAL SITE`

At the same time, `group_var` is standardised:
- country-specific setting variable name → `setting`



#### Step 4 — Extract administrative codes (`admin_info`)

Administrative information is derived **only** when `group_var == "ADMIN"`.

The helper function `get_admin()`:
- splits `group_var_value` on `%/%`,
- extracts the first token matching a PCODE-like pattern (`^[A-Z]{2,}[0-9A-Z]*$`).

This produces:
- `admin_info = "<PCODE>"` for administrative disaggregation rows
- `admin_info = "All-country"` for national-level rows

---

### 10.5 Deriving PowerBI dimensions (final harmonised fields)

After standardisation, explicit PowerBI dimensions are derived from the cleaned
disaggregation strings:

#### `gender`
- contains “Boys” → `Boys`
- contains “Girls” → `Girls`
- otherwise → `Overall`

#### `school_cycle`
- `level0` → ECE
- `level1` → Primary
- `level2` → Intermediate-secondary
- `level3` → Secondary
- `level4` → Higher Education
- otherwise → No disaggregation

#### `pop_group`
Derived from standardised tokens:
- `IDP_HOST` → IDP in host families
- `IDP_SITE` → IDP in camp / site
- `HOST` → Host community
- `REFUGEE` → Refugees
- `IDP` → IDP
- `RET` → Returnees

Project-specific categories (e.g. PRL / PRS, mixed-status households) are handled
explicitly in the script.

If `group_var == "pop_group"` but no known token is detected → `other`.  
Otherwise → `No disaggregation`.

#### `setting`
- `RURAL` → Rural
- `URBAN/PERI-URBAN` → Urban / peri-urban
- `CAMP/SITE` → Camp / site
- `INFORMAL SITE` → Informal site
- `OTHER SETTING` → Other setting
- otherwise → No setting disaggregation

Finally, the dataset is filtered using `filter_lookup` rules so that **only approved
disaggregation variables and valid token combinations** remain.

This final filtering step is critical to prevent invalid or inconsistent
disaggregations from entering PowerBI dashboards.


## Troubleshooting Example – PowerBI Gender Pivot Duplication

This section documents a **common PowerBI preparation issue** encountered during the
creation of the gender-wide binary indicator table
(`pBI_binary_indicator_data_only_gender`) and explains how to identify, understand,
and fix it.


### 1. Problem description

During execution of `01_05_create_combined_dataset_powerBI.R`, the following warning
may appear in the R console:

```text
Values from `n_total` and `stat_pct` are not uniquely identified;
output will contain list-cols.
```

This warning means that **more than one value exists for the same combination of
PowerBI dimensions**, causing `pivot_wider()` to create list-columns instead of numeric
columns.

This breaks PowerBI compatibility.



### 2. Where the issue occurs in the code

The issue arises during the reshaping of binary indicators from long to wide format:

```r
pBI_binary_indicator_data_only_gender <- pBI_binary_indicator_data_only_gender %>%
  mutate(gender_col = case_when(
    gender == "Overall" ~ "ind_overall",
    gender == "Girls"   ~ "ind_girl",
    gender == "Boys"    ~ "ind_boy",
    TRUE                ~ NA_character_
  )) %>%
  pivot_wider(
    id_cols = c(country, analysis_var, school_cycle, indicator,
                admin_info, pop_group, setting),
    names_from = gender_col,
    values_from = c(stat_pct, n_total),
    names_glue = "{.value}_{gender_col}"
  )
```


### 3. How the issue manifests

#### 3.1 Console warning

![issue](https://github.com/martivit/MSNA_2024_EduAnalysis/blob/main/docs/screenshots/pivot_warning.png)

#### 3.2 Output table symptom

In the resulting PowerBI table, numeric columns may contain multiple values, for example:

```
c("0.392", "0.370")
```


![Duplicated](https://github.com/martivit/MSNA_2024_EduAnalysis/blob/main/docs/screenshots/duplicate_rows_powerbi.png)



### 4. Root cause

This issue is **not a code bug**.

It occurs when the source country file  
`analysis_key_output<COUNTRY>.csv` contains **two rows that collapse into the same
PowerBI grouping**.

Typical causes include:
- duplicated indicator rows for the same disaggregation,
- the presence of a non-informative response category (e.g. `dnk`)
  alongside a valid estimate.


### 5. How to identify the problematic country

From the warning or the PowerBI table:
- identify the affected `country` (e.g. `SOM`),
- identify the problematic `analysis_var`.


### 6. How to fix the issue (manual but controlled)

#### Step 1 — Open the source file

```
output/analysis_key_outputSOM.csv
```


#### Step 2 — Locate duplicated rows

Filter the CSV by:
- `analysis_var`,
- identical `group_var`,
- identical `group_var_value`.


![ CSV](https://github.com/martivit/MSNA_2024_EduAnalysis/blob/main/docs/screenshots/source_cvs_issue.png)


#### Step 3 — Remove the non-informative value

In most cases, remove rows where:
- `analysis_var_value == "dnk"` (or equivalent non-response category).

**Rules**:
- Only remove analytically invalid categories.
- Never remove valid estimates.


#### Step 4 — Re-run the pipeline

```r
source("indicators_vizualization.R")
```

Confirm that:
- the warning no longer appears,
- PowerBI tables contain numeric values only.

### 7. Why this fix is intentional

- PowerBI requires one value per dimension combination.
- Automatic aggregation would hide data-quality issues.
- Manual correction preserves transparency and traceability.

This step is a **data validation checkpoint**, not a workaround.


## 11) PowerBI outputs (what each file is for)

All PowerBI outputs are written in `output/global_pBI/`. 

### 11.1 All indicators (long format)
- `2024_MSNA_all_indicator_data.csv` and `.xlsx` 

**Use in PowerBI:** exploration, slicers, “all indicators” pages.  
**One row means:** one `analysis_var` × one `analysis_var_value` × one disaggregation (gender/cycle/pop/setting/admin) × one country, with `stat_pct` and `n_total`.

### 11.2 Binary indicators (long format)
- `2024_MSNA_binary_indicator_data.csv` and `.xlsx` 

**Use in PowerBI:** standard visuals for binary indicators (attending, net attendance, etc.).

### 11.3 Binary indicators (gender-wide table)
- `2024_MSNA_binary_only_gender.csv` and `.xlsx` 

This table pivots gender to columns (e.g., `stat_pct_ind_overall`, `stat_pct_ind_girl`, `stat_pct_ind_boy`).   
**Use in PowerBI:** faster gender comparison visuals without measures.

### 11.4 Clustering dataset (binary only, strict filtering)
- `2024_MSNA_binary_clustering_data.csv` and `.xlsx` 

Strict rules applied in code:
- `gender == "Overall"` only 
- `admin_info != "All-country"` only 
- `pop_group == "No disaggregation"` and `setting == "No setting disaggregation"` 
- Only a specific subset of `analysis_var` is kept for school-cycle-specific attendance, and ECE rules are enforced for the two ECE attendance vars. 
- The table is pivoted wide: one row per `admin_info`, columns are indicators. 

**Use:** PCA / clustering outside PowerBI or within PowerBI custom visuals.

---

## 12) Barrier outputs for PowerBI (top-N and clustering)

### 12.1 Barrier tables (top 10 + “Other”)
- `2024_MSNA_barrier_indicator_data.csv/.xlsx` (full barrier table with `stat_pct`) 
- `2024_MSNA_barrier_top10_indicator_data.csv/.xlsx` (top 10 per group + “Other”) 

Harmonisation uses the same `barrier_label.csv` long mapping approach as Part I. 

### 12.2 Barrier “top 1” for clustering + merged clustering dataset
- `2024_MSNA_barrier_top1_indicator_data.csv/.xlsx` 
- `2024_MSNA_combined_clustering_data.csv/.xlsx` (binary clustering + top barrier columns) 

For the “top 1” barrier clustering table:
- keeps admin-only, no disaggregation, and pivots to:
  - `barrier_overall`, `barrier_boys`, `barrier_girls` columns. 

---

## 13) Convenience Excel workbooks (PowerBI users)
The PowerBI script also exports:
- `2024_MSNA_binary_indicator_by_country.xlsx`
- `2024_MSNA_barrier_indicator_by_country.xlsx`
- `2024_MSNA_binary_indicator_by_each_indicator.xlsx` 

These are “human browsing” outputs (not required for the dashboard model), created as:
- one sheet per country, and
- one sheet per indicator. 

---

## 14) Adding a new country (checklist)

A new analyst should follow this exact checklist:

1) **Generate the country-level file**  
   Confirm `output/analysis_key_output<NEWCOUNTRY>.csv` exists (produced by the country pipeline). 

2) **Update global metadata** (`input_global/metadata_edu_global.xlsx`)  
   - In `general` sheet: set `availability = "yes"` for the country and set `language_assessment`. 
   - In `indicators` sheet: confirm indicator list and labels (global list is applied to all countries). 
   - In `strata_variables`, `pop_group_names`, and `setting_name`: fill the correct keyword strings so parsing works for that country. 

3) **Barrier harmonisation (if needed)**  
   If the country uses new barrier response strings, add them in `input_global/barrier_label.csv` under the appropriate harmonised category. 

4) **Run `indicators_vizualization.R`**  
   Verify the country appears in:
   - `output/global/labeled_binary_indicator_data.csv`
   - plots folders
   - `output/global/docx/<COUNTRY>_snapshot.docx`
   - `output/global_pBI/...` tables 

---

## 15) Troubleshooting (what usually breaks)

### Country missing from outputs
- Check metadata `availability == "yes"` and that the country appears in `available_countries`. 
- Check the file exists: `output/analysis_key_output<COUNTRY>.csv`. 

### School cycle strings are not mapped (no level0/level1 tokens)
- Check ISCED mapping exists for the country code in the UNESCO file. `read_ISCED_info()` warns if country is not found. 
- Check `global_analysis_function.R` mapping logic for the language labels. 

### PowerBI dimensions (pop_group / setting / admin) are wrong or NA
- This is almost always metadata keywords not matching the `group_var_value` strings emitted by the country analysis.
- Fix the appropriate keyword cell for that country in `metadata_edu_global.xlsx` (pop groups, settings, admin variable name). 

### Plotting errors related to fonts
- Plot script calls `font_add(...)` with Segoe UI TTF names; missing fonts can cause failures. 

---

## 16) Output map (quick reference)

### Global plots / docs
- `output/global/binary_indicator_data.csv` 
- `output/global/barrier_data.csv` 
- `output/global/labeled_binary_indicator_data.csv` 
- `output/global/plot/**.jpeg` (binary plots) 
- `output/global/plot/barriers_to_education_plot_*.jpeg` 
- `output/global/docx/<COUNTRY>_snapshot.docx` 

### PowerBI / clustering
- `output/global_pBI/2024_MSNA_all_indicator_data.csv` 
- `output/global_pBI/2024_MSNA_binary_indicator_data.csv` 
- `output/global_pBI/2024_MSNA_binary_only_gender.csv` 
- `output/global_pBI/2024_MSNA_binary_clustering_data.csv` 
- `output/global_pBI/2024_MSNA_barrier_indicator_data.csv` 
- `output/global_pBI/2024_MSNA_barrier_top10_indicator_data.csv` 
- `output/global_pBI/2024_MSNA_barrier_top1_indicator_data.csv` 
- `output/global_pBI/2024_MSNA_combined_clustering_data.csv` 
- plus “by country” and “by indicator” Excel browsing workbooks 



