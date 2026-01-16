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
