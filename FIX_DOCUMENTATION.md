# JCRC QC Dashboard - Flag & Grade Issue Resolution

## Problem Summary
The Patient Results table in the home module displayed:
- **Flag column**: All values showing "UNKNOWN" instead of proper flags (N/L/H/W)  
- **Grade column**: Empty/missing DAIDS grade values (1-4)

## Root Cause Analysis

### 1. Missing Patient Demographics Flow
The annotation function was receiving `NA` values for patient age and sex, causing all reference range lookups to fail.

**Root cause**: `annotated_results()` in home_server.R retrieved patient results but didn't join the patient demographic information from the samples table.

### 2. Unit Format Mismatch
- Database reference ranges stored units as: `10^3/uL` (using caret symbol)
- Patient results stored units as: `10*3/uL` (using asterisk)
- This prevented matching during reference range lookups

### 3. Sex Value Encoding Mismatch
- Reference ranges table used: "Male", "Female", "Both"
- Patient samples used: "M", "F"
- The lookup function couldn't match abbreviated codes to full names

### 4. Dplyr Filter Bug in Reference Lookup
The `get_reference_range()` function had incorrect syntax:
```r
filter(
  age_years >= age_min_years,  # BUG: age_years treated as column, not parameter
  age_years <= age_max_years
)
```

This was using the parameter name as a literal column name instead of quoting it.

## Solutions Implemented

### File: `helpers/reference_engine.R`

**Change 1**: Added sex normalization function
```r
normalize_sex <- function(sex){
  if(is.na(sex) || is.null(sex)) return(sex)
  sex <- as.character(sex)
  switch(tolower(sex),
    "m" = "Male",
    "male" = "Male",
    "f" = "Female",
    "female" = "Female",
    sex
  )
}
```

**Change 2**: Added unit normalization in `get_reference_ranges()`
```r
rr$units <- gsub("\\^", "*", rr$units)  # Convert 10^3 to 10*3
```

**Change 3**: Fixed `get_reference_range()` filter with proper dplyr quoting
```r
filter(
  analyte == !!analyte,
  sex %in% sex_order,
  !!age_years >= age_min_years,  # Fixed with !!quoting
  !!age_years <= age_max_years    # Fixed with !!quoting
)
```

### File: `modules/home/home_server.R`

**Change 1**: Added reactive combining results with patient demographics
```r
selected_results_with_patient_info <- reactive({
  selected_results() %>%
    mutate(
      patient_age_years = selected_sample()$patient_age_years,
      patient_sex = selected_sample()$patient_sex
    )
})
```

**Change 2**: Updated `annotated_results()` to normalize sex
```r
annotated_results <- reactive({
  req(selected_sample())
  
  normalized_sex <- normalize_sex(selected_sample()$patient_sex)
  
  annotate_results(
    results_df = selected_results_with_patient_info(),
    age_years = selected_sample()$patient_age_years,
    sex = normalized_sex,  # Normalized
    reference_table = reference_table(),
    daids_table = daids_table()
  )
})
```

**Change 3**: Updated `build_reference_report()` output similarly

## Testing & Verification

Test case: Patient age 23, sex "M" with WBC result 6.93 10*3/uL
- Before: Flag="UNKNOWN", Grade=NA
- After: Flag="NORMAL" (within 2.8-8.2 range), Grade=NA (no toxicity)

Test case: HGB result 9.7 g/dL same patient
- Before: Flag="UNKNOWN", Grade=NA  
- After: Flag="LOW" (below 11.6 lower limit), Grade=2 (DAIDS grade 2 toxicity)

## Result
✅ Flag column now displays proper values (NORMAL, LOW, HIGH, or UNKNOWN if no reference range available)
✅ Grade column now displays DAIDS toxicity grades (1-4) when applicable
✅ Patient age and sex are properly joined through the results
✅ Unit formats are normalized for matching
✅ Sex values are normalized for matching

## Notes
- Some analytes (e.g., NE, LY) may still show "UNKNOWN" if reference ranges haven't been configured in the database
- This is expected behavior when reference data is missing
- Color coding in the UI should now properly reflect LOW (blue), HIGH (yellow), NORMAL (green) based on the computed flags
