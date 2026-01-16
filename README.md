# Education MSNA Analysis Pipeline

## 1. Purpose
This pipeline produces education sector analytical outputs from MSNA data, aligned with MSNA education modules, UNESCO ISCED school structures, and HPC/HNO reporting requirements.

It transforms raw MSNA household and education-loop data into:
- harmonised child-level education indicators,
- weighted estimates using a country-specific LOA,
- labelled, publication-ready tables,
- Excel outputs and figures used for Education PiN and severity analysis.

The pipeline is metadata-driven: country-specific logic, variables, labels, and strata are controlled through configuration files rather than hard-coded logic.

---

## 2. What must be configured before running

### 2.1 Country selection
In the main script:
```r
country_assessment <- "<ISO3>"
```

### 2.2 Metadata (mandatory)
```
../metadata_edu.xlsx
```
Defines dataset paths, variables, strata, weights, and language.

### 2.3 Required inputs
- Country MSNA dataset (main + education loop)
- ISCED mapping file
- LOA template
- Helper tables
- Kobo survey and choices sheets

---

## 3. Conceptual workflow
Raw MSNA data → Indicators → LOA → Weighted analysis → Labelling → Tables & figures

---

## 4. Script-by-script explanation
See detailed description in the handover document.

---

## 5. Outputs
- loop_edu_recorded_<ISO3>.xlsx
- loa_analysis_<ISO3>.csv
- labeled_results_table_<ISO3>.RDS
- education_results_<ISO3>.xlsx
- graphs and maps

---

## 6. Known failure points
Metadata errors, ISCED mismatches, missing weights, duplicated Kobo labels.



# Education x-Crisis Global Analysis & PowerBI Dataset Preparation

> **Entry point:** `indicators_vizualization.R` (main orchestrator) fileciteturn7file14  
> **Scripts location:** `src/global_product/` (products) and `src/functions/` (shared logic / helpers) fileciteturn7file14

This pipeline takes **country-level MSNA education results** (one `analysis_key_output<COUNTRY>.csv` per country) and produces:
1) **Global x-crisis plots** (binary indicators) and **global barrier plots**, plus automated **country snapshots** (Word). fileciteturn7file14turn6file6turn7file2  
2) **PowerBI-ready datasets** (clean, flat tables) and **clustering-ready extracts**. fileciteturn7file16turn7file10turn7file18

The pipeline is **metadata-driven** via `input_global/metadata_edu_global.xlsx`, which controls:
- which countries are included,
- country language,
- indicators list and labels,
- how to interpret population group / setting / admin disaggregation strings. fileciteturn7file13turn7file0

---

## 0) What a new analyst must understand before running anything

### This pipeline is **not** a replacement for country education analysis
It only works if the country pipeline has already produced, for each country:
- `output/analysis_key_output<COUNTRY>.csv`  
(Example naming pattern in code: `analysis_key_output<country>.csv`) fileciteturn7file5turn7file16

If a country file is missing, that country will simply not be added to the global dataset (the script checks `file.exists`). fileciteturn7file5turn7file16

### The “source of truth” for comparability is the global metadata
The global pipeline does not guess which indicators to use: it reads them from the metadata and uses the same list across countries. fileciteturn7file13turn7file0

---

## 1) Repository structure and required files

### Main script
- `indicators_vizualization.R` (sources everything and launches products) fileciteturn7file14

### Global scripts (products)
Located in `src/global_product/` and sourced by the main script: fileciteturn7file14
- `01_create_combined_dataset.R` (global combined datasets + labeling) fileciteturn7file5
- `01_05_create_combined_dataset_powerBI.R` (PowerBI datasets + clustering extracts) fileciteturn7file16turn7file10
- `02_plot_binary_indicators.R` (global plots) fileciteturn6file3turn7file14
- `03_snapshot.R` (country snapshot Word docs) fileciteturn6file6turn7file14
- `04_barrier_global.R` (global barrier plots) fileciteturn7file2turn7file14

### Shared functions (logic / helpers)
Located in `src/functions/` and sourced by the main script: fileciteturn7file14
- `functions_info_global.R` (reads global metadata → builds lists used everywhere) fileciteturn7file13turn7file0
- `global_analysis_function.R` (country-specific relabeling using ISCED mappings; snapshot helpers) fileciteturn7file6
- `00_edu_helper.R` and `00_edu_function.R` (ISCED reading, education helper logic) fileciteturn7file4turn7file14

### Required inputs (files/folders)
- `input_global/metadata_edu_global.xlsx` (controls countries + indicator list + parsing keywords) fileciteturn7file13turn7file0
- `input_global/barrier_label.csv` (harmonises barrier response strings across countries) fileciteturn7file2turn7file16
- `resources/UNESCO ISCED Mappings_MSNAcountries_consolidated.xlsx` (school cycle mapping & age ranges) fileciteturn7file5turn7file4turn7file6
- `output/analysis_key_output<COUNTRY>.csv` (one per country; produced upstream) fileciteturn7file5turn7file16

---

## 2) Installation / R environment requirements

The main script loads a large set of packages including `tidyverse`, `readxl`, `openxlsx`, `officer`, `flextable`, `ggpattern`, `srvyr`, `showtext`. fileciteturn7file14

Minimum practical requirements for a new analyst:
- A working R installation where they can install packages
- Ability to read/write `.xlsx`, `.csv`, `.jpeg`, and `.docx`
- A system where custom fonts loading is not blocked (plots use `showtext` and font registration) fileciteturn6file3turn7file14

If fonts are missing (e.g., `segoeui.ttf`), plots can error. The plotting script explicitly calls `font_add` for Segoe UI. fileciteturn6file3

---

## 3) How to run (the only supported way)

### Run the main script
Open `indicators_vizualization.R` and run it top-to-bottom.  
It **sources** each script in the correct order and calls the key functions. fileciteturn7file14

### Execution order (exactly as implemented)
1. Read global metadata and prepare lists  
   `source("src/functions/functions_info_global.R")` fileciteturn7file14turn7file13
2. Load helper functions and relabeling logic  
   `00_edu_helper.R`, `00_edu_function.R`, `global_analysis_function.R` fileciteturn7file14turn7file6turn7file4
3. Build global combined datasets (binary + barrier)  
   `source("src/global_product/01_create_combined_dataset.R")` fileciteturn7file14turn7file5
4. Build PowerBI datasets and clustering exports  
   `source("src/global_product/01_05_create_combined_dataset_powerBI.R")` fileciteturn7file14turn7file16
5. Create global plots (binary indicators)  
   `source("src/global_product/02_plot_binary_indicators.R")`  
   then `generate_indicator_plot(...)` is called for: overall / level0 / level1 / level2 fileciteturn7file14turn6file3
6. Generate country snapshots (Word)  
   `source("src/global_product/03_snapshot.R")`  
   then `generate_snapshot(country)` for each available country with `tryCatch` fileciteturn7file14turn6file6
7. Create global barrier plots  
   `source("src/global_product/04_barrier_global.R")`  
   then `create_barrier_plot("overall")`, plus Boys and Girls variants fileciteturn7file14turn7file2

---

# PART I — Global x-Crisis Analysis & Visualisation

## 4) Global metadata: how countries and indicators are defined

### Script: `src/functions/functions_info_global.R`
This script reads `input_global/metadata_edu_global.xlsx` and builds the global lists used everywhere. fileciteturn7file13turn7file0

Key outputs created in memory (examples):
- `available_countries`: only countries where `availability == "yes"` fileciteturn7file13
- `country_language_list`: language per country fileciteturn7file13
- `indicator_list`: list of indicator variable names used in global pipeline fileciteturn7file0
- `indicator_label_list`: a named vector mapping indicator → label (for plot titles) fileciteturn7file1

It also creates keyword lists per country used to parse disaggregation strings (pop groups, admin, setting). fileciteturn7file13turn7file16

**For a new analyst:** if a country is not appearing in outputs, check:
1) metadata `availability`, and
2) whether `output/analysis_key_output<COUNTRY>.csv` exists. fileciteturn7file13turn7file16turn7file5

---

## 5) Global dataset build: binary + barrier data

### Script: `src/global_product/01_create_combined_dataset.R`
This script is responsible for creating the canonical “global analysis tables” used for plots and snapshots. fileciteturn7file5

#### 5.1 Input expectation
For each country in `available_countries`, it looks for:
- `output/analysis_key_output<COUNTRY>.csv` fileciteturn7file5

It reads and keeps (minimum):
- `analysis_var`, `analysis_var_value` (indicator and response/value)
- `group_var`, `group_var_value` (disaggregation definition)
- `stat`, `stat_low`, `stat_upp` (point estimate and CI)
- `n_total`
- adds `country` fileciteturn7file5

#### 5.2 Standardisation step (critical)
Before filtering, it normalises “equivalent” indicator names to a single target name (to support cross-country comparability). fileciteturn7file5

Example: multiple attendance variables collapse into `edu_attending_level1234_and_level1_age_d` etc. fileciteturn7file5

#### 5.3 Binary vs barrier split
- **Binary indicators**: keep rows where `analysis_var` is in `indicator_list`, exclude `edu_barrier_d`, and keep only `analysis_var_value == 1`. fileciteturn7file5
- **Barrier indicators**: keep only `analysis_var == "edu_barrier_d"`. fileciteturn7file5

Gender labels are harmonised from French to English (`Filles`→`Girls`, `Garcons`→`Boys`). fileciteturn7file5

#### 5.4 Country-specific relabeling using ISCED mappings
The script then produces `labeled_binary_indicator_data` by applying `process_country()` for each country. fileciteturn7file5turn7file6

`process_country()`:
- reads the country’s school structure from the UNESCO ISCED mapping file, fileciteturn7file6turn7file4
- derives age ranges per level,
- constructs a label string (language-specific),
- replaces label strings in `group_var_value` with standard `level0/level1/level2/...` codes. fileciteturn7file6

This is what allows the plotting script to rely on `group_var_value` containing consistent tokens like `level0`, `level1`, etc. fileciteturn6file3turn7file6

#### 5.5 Outputs written to disk
- `output/global/combined_data.csv`
- `output/global/binary_indicator_data.csv`
- `output/global/barrier_data.csv`
- `output/global/labeled_binary_indicator_data.csv` fileciteturn7file5

---

## 6) Global plots: binary indicators

### Script: `src/global_product/02_plot_binary_indicators.R`
This script defines `generate_indicator_plot(...)` and the main script calls it 4 times: fileciteturn7file14turn6file3
- `overall` → `output/global/plot`
- `level0` (ECE) → `output/global/plot/ECE`
- `level1` (Primary) → `output/global/plot/primary`
- `level2` → `output/global/plot/level2`

#### What the function does
For each indicator in `indicator_list`:
- skips `edu_barrier_d` by design, fileciteturn6file3
- filters `labeled_binary_indicator_data` for the indicator and the selected group set:
  - `base1 = <group>` (e.g., `overall`)
  - `base2 = <group> %/% Boys`
  - `base3 = <group> %/% Girls` fileciteturn6file3
- creates a horizontal bar chart with CI (`stat_low`, `stat_upp`) and value labels,
- saves one JPEG per indicator per group scope with filename pattern:  
  `.../<analysis_var>_<group>.jpeg` fileciteturn6file7

#### Plot labeling
Plot titles come from `indicator_label_list[[indicator]]` (metadata-driven). fileciteturn6file3turn7file1

---

## 7) Country snapshots (Word)

### Script: `src/global_product/03_snapshot.R`
The main script loops over `available_countries` and calls `generate_snapshot(country)` with `tryCatch` so one country failing does not stop the pipeline. fileciteturn7file14turn6file0

The snapshot uses `officer` + `flextable` to assemble:
- “Access to Education” table,
- age group breakdown table,
- disruption plot (saved as temporary PNG),
- ECE indicators tables,
- overage indicators tables,
- net attendance tables. fileciteturn6file6turn6file18

Output naming:
- `output/global/docx/<COUNTRY>_snapshot.docx` fileciteturn6file18

---

## 8) Global barrier plots

### Script: `src/global_product/04_barrier_global.R`
Defines `create_barrier_plot(group_plot, name_plot = "overall")`. fileciteturn7file2

Called by the main script for:
- `create_barrier_plot("overall")`
- `create_barrier_plot("overall %/% Boys", "boys")`
- `create_barrier_plot("overall %/% Girls", "girls")` fileciteturn7file14turn7file2

#### How barriers are harmonised
- Reads `input_global/barrier_label.csv`
- Reshapes wide → long and maps old barrier labels → a harmonised label
- Applies mapping on `analysis_var_value` fileciteturn7file2

#### Top-N logic
- Selects `n_top_barrier = 6` highest barriers per country
- Computes an “Other” category as the remainder (`1 - sum(top barriers)`)
- Converts `stat` to percentages and saves a stacked bar plot. fileciteturn7file2

Output naming:
- `output/global/plot/barriers_to_education_plot_<name_plot>.jpeg` fileciteturn7file3

---

# PART II — PowerBI Dataset Preparation

## 9) Why this part exists
PowerBI dashboards require:
- explicit dimensions (gender, school cycle, admin, pop group, setting),
- consistent category labels across countries,
- flat tables (one record per indicator × admin × disaggregation),
- separate extracts for clustering (no disaggregation, admin-only).

This is why the pipeline produces **a separate PowerBI dataset suite** rather than reusing the plot datasets.

---

## 10) PowerBI dataset construction

### Script: `src/global_product/01_05_create_combined_dataset_powerBI.R`
This script rebuilds a combined dataset from the same country CSVs but reshapes and standardises it for PowerBI. fileciteturn7file16turn7file10

#### 10.1 Input expectation
For each country:
- reads `output/analysis_key_output<COUNTRY>.csv`
- keeps: `analysis_var`, `analysis_var_value`, `group_var`, `group_var_value`, `stat`, `n_total` fileciteturn7file16

#### 10.2 Indicator filtering + standardisation
- Standardises “equivalent” attendance variables similarly to Part I. fileciteturn7file16
- Filters to keep only indicators in `indicator_list`
- Excludes zeros and missing values (script has a filter to drop `analysis_var_value == 0` and NAs). fileciteturn7file16

#### 10.3 Parsing disaggregation strings using per-country keywords
The script builds lookup tables from metadata lists:
- `pop_lookup` from `pop_group_list`, `host_list`, `idp_list`, etc. fileciteturn7file16turn7file0
- `setting_lookup` from `setting_list`, `urban_list`, `rural_list`, etc. fileciteturn7file16turn7file0
- `filter_lookup` from `col1_list ... col4_list` fileciteturn7file16turn7file0

Using `replace_if_found(...)`, it normalises tokens inside `group_var_value`, for example:
- `IDP_HOST`, `IDP_SITE`, `HOST`, `REFUGEE`, etc.
- `ADMIN` for admin disaggregation
- `setting` for setting disaggregation fileciteturn7file15turn7file12

#### 10.4 Deriving explicit PowerBI dimensions
From the normalised `group_var_value`, it derives:
- `gender` (Overall / Girls / Boys) fileciteturn7file12
- `school_cycle` (ECE / Primary / Intermediate-secondary / Secondary / Higher Education / No disaggregation) fileciteturn7file12
- `pop_group` (mapped to human-readable labels) fileciteturn7file12
- `setting` categories (urban/rural/camp/informal/other) fileciteturn7file15
- `admin_info` extracted from tokens in `group_var_value` with `get_admin()` fileciteturn7file12

---

## 11) PowerBI outputs (what each file is for)

All PowerBI outputs are written in `output/global_pBI/`. fileciteturn7file10turn7file18

### 11.1 All indicators (long format)
- `2024_MSNA_all_indicator_data.csv` and `.xlsx` fileciteturn6file15turn7file10

**Use in PowerBI:** exploration, slicers, “all indicators” pages.  
**One row means:** one `analysis_var` × one `analysis_var_value` × one disaggregation (gender/cycle/pop/setting/admin) × one country, with `stat_pct` and `n_total`.

### 11.2 Binary indicators (long format)
- `2024_MSNA_binary_indicator_data.csv` and `.xlsx` fileciteturn7file10

**Use in PowerBI:** standard visuals for binary indicators (attending, net attendance, etc.).

### 11.3 Binary indicators (gender-wide table)
- `2024_MSNA_binary_only_gender.csv` and `.xlsx` fileciteturn6file15turn7file10

This table pivots gender to columns (e.g., `stat_pct_ind_overall`, `stat_pct_ind_girl`, `stat_pct_ind_boy`). fileciteturn6file15  
**Use in PowerBI:** faster gender comparison visuals without measures.

### 11.4 Clustering dataset (binary only, strict filtering)
- `2024_MSNA_binary_clustering_data.csv` and `.xlsx` fileciteturn7file10

Strict rules applied in code:
- `gender == "Overall"` only fileciteturn7file10
- `admin_info != "All-country"` only fileciteturn7file10
- `pop_group == "No disaggregation"` and `setting == "No setting disaggregation"` fileciteturn7file10
- Only a specific subset of `analysis_var` is kept for school-cycle-specific attendance, and ECE rules are enforced for the two ECE attendance vars. fileciteturn7file10
- The table is pivoted wide: one row per `admin_info`, columns are indicators. fileciteturn7file10

**Use:** PCA / clustering outside PowerBI or within PowerBI custom visuals.

---

## 12) Barrier outputs for PowerBI (top-N and clustering)

### 12.1 Barrier tables (top 10 + “Other”)
- `2024_MSNA_barrier_indicator_data.csv/.xlsx` (full barrier table with `stat_pct`) fileciteturn6file5turn7file10
- `2024_MSNA_barrier_top10_indicator_data.csv/.xlsx` (top 10 per group + “Other”) fileciteturn6file5turn7file10

Harmonisation uses the same `barrier_label.csv` long mapping approach as Part I. fileciteturn7file10

### 12.2 Barrier “top 1” for clustering + merged clustering dataset
- `2024_MSNA_barrier_top1_indicator_data.csv/.xlsx` fileciteturn7file8turn7file19
- `2024_MSNA_combined_clustering_data.csv/.xlsx` (binary clustering + top barrier columns) fileciteturn7file8turn7file19

For the “top 1” barrier clustering table:
- keeps admin-only, no disaggregation, and pivots to:
  - `barrier_overall`, `barrier_boys`, `barrier_girls` columns. fileciteturn7file8

---

## 13) Convenience Excel workbooks (PowerBI users)
The PowerBI script also exports:
- `2024_MSNA_binary_indicator_by_country.xlsx`
- `2024_MSNA_barrier_indicator_by_country.xlsx`
- `2024_MSNA_binary_indicator_by_each_indicator.xlsx` fileciteturn7file18

These are “human browsing” outputs (not required for the dashboard model), created as:
- one sheet per country, and
- one sheet per indicator. fileciteturn7file18

---

## 14) Adding a new country (checklist)

A new analyst should follow this exact checklist:

1) **Generate the country-level file**  
   Confirm `output/analysis_key_output<NEWCOUNTRY>.csv` exists (produced by the country pipeline). fileciteturn7file16turn7file5

2) **Update global metadata** (`input_global/metadata_edu_global.xlsx`)  
   - In `general` sheet: set `availability = "yes"` for the country and set `language_assessment`. fileciteturn7file13
   - In `indicators` sheet: confirm indicator list and labels (global list is applied to all countries). fileciteturn7file1
   - In `strata_variables`, `pop_group_names`, and `setting_name`: fill the correct keyword strings so parsing works for that country. fileciteturn7file13turn7file16

3) **Barrier harmonisation (if needed)**  
   If the country uses new barrier response strings, add them in `input_global/barrier_label.csv` under the appropriate harmonised category. fileciteturn7file2turn7file10

4) **Run `indicators_vizualization.R`**  
   Verify the country appears in:
   - `output/global/labeled_binary_indicator_data.csv`
   - plots folders
   - `output/global/docx/<COUNTRY>_snapshot.docx`
   - `output/global_pBI/...` tables fileciteturn7file14turn7file5turn6file18turn7file10

---

## 15) Troubleshooting (what usually breaks)

### Country missing from outputs
- Check metadata `availability == "yes"` and that the country appears in `available_countries`. fileciteturn7file13
- Check the file exists: `output/analysis_key_output<COUNTRY>.csv`. fileciteturn7file16

### School cycle strings are not mapped (no level0/level1 tokens)
- Check ISCED mapping exists for the country code in the UNESCO file. `read_ISCED_info()` warns if country is not found. fileciteturn7file4
- Check `global_analysis_function.R` mapping logic for the language labels. fileciteturn7file6

### PowerBI dimensions (pop_group / setting / admin) are wrong or NA
- This is almost always metadata keywords not matching the `group_var_value` strings emitted by the country analysis.
- Fix the appropriate keyword cell for that country in `metadata_edu_global.xlsx` (pop groups, settings, admin variable name). fileciteturn7file16turn7file15

### Plotting errors related to fonts
- Plot script calls `font_add(...)` with Segoe UI TTF names; missing fonts can cause failures. fileciteturn6file3

---

## 16) Output map (quick reference)

### Global plots / docs
- `output/global/binary_indicator_data.csv` fileciteturn7file5
- `output/global/barrier_data.csv` fileciteturn7file5
- `output/global/labeled_binary_indicator_data.csv` fileciteturn7file5
- `output/global/plot/**.jpeg` (binary plots) fileciteturn6file7
- `output/global/plot/barriers_to_education_plot_*.jpeg` fileciteturn7file3
- `output/global/docx/<COUNTRY>_snapshot.docx` fileciteturn6file18

### PowerBI / clustering
- `output/global_pBI/2024_MSNA_all_indicator_data.csv` fileciteturn7file10
- `output/global_pBI/2024_MSNA_binary_indicator_data.csv` fileciteturn7file10
- `output/global_pBI/2024_MSNA_binary_only_gender.csv` fileciteturn6file15
- `output/global_pBI/2024_MSNA_binary_clustering_data.csv` fileciteturn7file10
- `output/global_pBI/2024_MSNA_barrier_indicator_data.csv` fileciteturn6file5
- `output/global_pBI/2024_MSNA_barrier_top10_indicator_data.csv` fileciteturn6file5
- `output/global_pBI/2024_MSNA_barrier_top1_indicator_data.csv` fileciteturn7file19
- `output/global_pBI/2024_MSNA_combined_clustering_data.csv` fileciteturn7file19
- plus “by country” and “by indicator” Excel browsing workbooks fileciteturn7file18


