# =========================================================
# FILE: helpers/reference_engine.R
# =========================================================

library(DBI)
library(dplyr)

# =========================================================
# NORMALIZE SEX VALUES
# =========================================================

normalize_sex <- function(sex){
  
  if(is.na(sex) || is.null(sex)) return(sex)
  
  sex <- as.character(sex)
  
  switch(
    tolower(sex),
    "m" = "Male",
    "male" = "Male",
    "f" = "Female",
    "female" = "Female",
    sex  # Return as-is if no match
  )
  
}

normalize_analyte <- function(analyte){
  
  if(is.null(analyte))
    return(analyte)
  
  if(length(analyte) == 0)
    return(analyte)
  
  analyte <- as.character(analyte)
  analyte <- trimws(analyte)
  analyte <- toupper(analyte)
  
  analyte
}

# =========================================================
# LOAD REFERENCE RANGES
# =========================================================

get_reference_ranges <- function(pool){
  
  rr <- DBI::dbGetQuery(
    pool,
    "
    SELECT *
    FROM reference_ranges
    WHERE active = TRUE
    "
  )
  
  # Normalize units: convert 10^3/uL format to 10*3/uL to match patient_results
  rr$units <- gsub("\\^", "*", rr$units)
  rr$analyte <- normalize_analyte(rr$analyte)
  rr$analyte <- toupper(rr$analyte)
  
  rr
  
}

# =========================================================
# LOAD DAIDS TABLE
# =========================================================

get_daids_grades <- function(pool){
  
  rr <- DBI::dbGetQuery(
    pool,
    "
    SELECT *
    FROM daids_grading_ranges
    WHERE active = TRUE
    "
  )
  
  rr$analyte <- normalize_analyte(rr$analyte)
  rr$analyte <- toupper(rr$analyte)
  rr
  
}

# =========================================================
# LOOKUP REFERENCE RANGE
# =========================================================

get_reference_range <- function(
    query_analyte,
    age_years,
    sex,
    reference_table
){
  
  query_analyte <- normalize_analyte(query_analyte)
  query_analyte <- toupper(query_analyte)
  sex_order <- c(sex, "Both")
  
  x <-
    reference_table %>%
    filter(
      analyte == !!query_analyte,
      sex %in% sex_order,
      !!age_years >= age_min_years,
      !!age_years <= age_max_years
    ) %>%
    mutate(
      sex_priority =
        ifelse(sex == !!sex, 1, 2)
    ) %>%
    arrange(sex_priority)
  
  if(nrow(x) == 0){
    
    return(NULL)
    
  }
  
  x[1, ]
  
}

# =========================================================
# RESULT FLAGGING
# =========================================================

classify_result <- function(
    value,
    analyte,
    age_years,
    sex,
    reference_table
){
  
  normalized_value <-
    value %>%
    as.character() %>%
    gsub(",", "", .) %>%
    gsub("%", "", .) %>%
    trimws()
  
  value <- suppressWarnings(as.numeric(normalized_value))
  
  if(is.na(value))
    return("UNKNOWN")
  
  rr <-
    get_reference_range(
      analyte,
      age_years,
      sex,
      reference_table
    )
  
  if(is.null(rr))
    return("UNKNOWN")
  
  if(value < rr$lower_limit)
    return("LOW")
  
  if(value > rr$upper_limit)
    return("HIGH")
  
  "NORMAL"
  
}

# =========================================================
# DAIDS LOOKUP
# =========================================================

get_daids_grade <- function(
    value,
    query_analyte,
    age_years,
    sex,
    daids_table
){
  
  query_analyte <- normalize_analyte(query_analyte)
  query_analyte <- toupper(query_analyte)
  
  normalized_value <-
    value %>%
    as.character() %>%
    gsub(",", "", .) %>%
    gsub("%", "", .) %>%
    trimws()
  
  value <- suppressWarnings(as.numeric(normalized_value))
  
  if(is.na(value))
    return(NULL)
  
  query_analyte <- normalize_analyte(query_analyte)
  sex_order <- c(sex, "Both")
  
  rows <-
    daids_table %>%
    filter(
      analyte == !!query_analyte,
      sex %in% sex_order,
      age_years >= age_min_years,
      age_years <= age_max_years
    )
  
  if(nrow(rows) == 0)
    return(NULL)
  
  for(i in seq_len(nrow(rows))){
    
    row <- rows[i, ]
    
    lower <- row$lower_limit
    upper <- row$upper_limit
    
    hit <- FALSE
    
    if(!is.na(lower) & !is.na(upper)){
      
      hit <- value >= lower & value <= upper
      
    }
    
    else if(is.na(lower) & !is.na(upper)){
      
      hit <- value <= upper
      
    }
    
    else if(!is.na(lower) & is.na(upper)){
      
      hit <- value >= lower
      
    }
    
    if(hit){
      
      return(
        list(
          grade = row$grade,
          classification = row$classification,
          analyte = row$analyte
        )
      )
      
    }
    
  }
  
  NULL
  
}

# =========================================================
# DAIDS LABEL
# =========================================================

daids_label <- function(grade){
  
  if(is.null(grade))
    return("")
  
  switch(
    as.character(grade),
    
    "1" = "Mild",
    
    "2" = "Moderate",
    
    "3" = "Severe",
    
    "4" = "Potentially Life Threatening",
    
    ""
  )
  
}

# =========================================================
# CRITICAL CHECK
# =========================================================

is_critical_result <- function(
    value,
    analyte,
    age_years,
    sex,
    daids_table
){
  
  x <-
    get_daids_grade(
      value,
      analyte,
      age_years,
      sex,
      daids_table
    )
  
  if(is.null(x))
    return(FALSE)
  
  x$grade >= 3
  
}

# =========================================================
# BUILD REFERENCE TABLE
# =========================================================

build_reference_report <- function(
    results_df,
    age_years,
    sex,
    reference_table
){
  
  out <- lapply(
    
    unique(results_df$analyte),
    
    function(a){
      
      rr <-
        get_reference_range(
          a,
          age_years,
          sex,
          reference_table
        )
      
      if(is.null(rr))
        return(NULL)
      
      data.frame(
        
        Analyte = a,
        
        Reference_Range =
          paste0(
            rr$lower_limit,
            " - ",
            rr$upper_limit
          ),
        
        Units = rr$units,
        
        stringsAsFactors = FALSE
        
      )
      
    }
    
  )
  
  bind_rows(out)
  
}

# =========================================================
# BUILD RESULT INTERPRETATION TABLE
# =========================================================

annotate_results <- function(
    results_df,
    age_years,
    sex,
    reference_table,
    daids_table
){
  
  results_df %>%
    
    rowwise() %>%
    
    mutate(
      
      Numeric_Result =
        suppressWarnings(
          as.numeric(result_value)
        ),
      
      Reference_Flag =
        classify_result(
          result_value,
          analyte,
          age_years,
          sex,
          reference_table
        ),
      
      DAIDS_Grade =
        {
          g <-
            get_daids_grade(
              result_value,
              analyte,
              age_years,
              sex,
              daids_table
            )
          
          # Ensure we always return a scalar, not a list
          if(is.null(g))
            NA_integer_
          else
            as.integer(g$grade)
        }
      
    ) %>%
    
    ungroup() %>%
    
    # Final safety: ensure all columns are atomic (not lists)
    {
      df <- .
      for(col in names(df)){
        if(is.list(df[[col]]) && !is.data.frame(df[[col]])){
          df[[col]] <- sapply(df[[col]], function(x){
            if(is.null(x)) return(NA_character_)
            paste(as.character(x), collapse = ";")
          }, USE.NAMES = FALSE)
        }
      }
      df
    }
  
}