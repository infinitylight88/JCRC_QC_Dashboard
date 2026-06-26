# =====================================================
# FILE: helpers/lims_cleaner.R
# PURPOSE:
# Clean raw LIMS export
# Convert ugly Excel export into standardized columns
# =====================================================

library(dplyr)

clean_lims_data <- function(df){
  
  # -----------------------------------------
  # Rename columns to standard names
  # based on your LIMS export
  # -----------------------------------------
  
  names(df) <- c(
    
    "accession_number",
    "study",
    "patient_id",
    "sex",
    "age",
    "visit_type",
    "test_name",
    "test_variable",
    "result",
    "test_date",
    "result_date",
    "instrument"
    
  )
  
  # -----------------------------------------
  # Clean spaces
  # -----------------------------------------
  
  df <- df %>%
    
    mutate(
      
      accession_number=
        trimws(as.character(accession_number)),
      
      test_name=
        trimws(as.character(test_name)),
      
      test_variable=
        trimws(as.character(test_variable)),
      
      patient_id=
        trimws(as.character(patient_id))
      
    )
  
  # -----------------------------------------
  # Remove empty rows
  # -----------------------------------------
  
  df <- df %>%
    
    filter(
      
      !is.na(accession_number),
      
      accession_number!=""
      
    )
  
  return(df)
  
}


# =====================================================
# PURPOSE:
# Convert repeated analytes
# into accession-level objects
#
# CBC accession appears ONE TIME
#
# analytes stored together
# =====================================================

build_accession_table <- function(df){
  
  accession_table <-
    
    df %>%
    
    group_by(
      
      accession_number,
      
      study,
      
      patient_id,
      
      sex,
      
      age,
      
      visit_type,
      
      test_name,
      
      test_date,
      
      result_date,
      
      instrument
      
    ) %>%
    
    summarise(
      
      number_of_results=n(),
      
      analytes=list(
        
        data.frame(
          
          analyte=test_variable,
          
          result=result
          
        )
        
      ),
      
      .groups="drop"
      
    )
  
  accession_table
  
}