# =========================================================
# FILE: helpers/interpretation_engine.R
# PURPOSE:
# Automatic CBC interpretation engine
# =========================================================

generate_interpretation <- function(results_df) {
  
  # =======================================================
  # CONVERT RESULTS INTO NAMED VECTOR
  # =======================================================
  
  values <- setNames(
    
    results_df$result_value,
    results_df$analyte
    
  )
  
  interpretation <- c()
  
  # =======================================================
  # ANEMIA DETECTION
  # =======================================================
  
  if ("HGB" %in% names(values)) {
    
    hgb <- as.numeric(values["HGB"])
    
    if (!is.na(hgb) && hgb < 7) {
      
      interpretation <- c(
        
        interpretation,
        "Critical severe anemia detected."
        
      )
      
    } else if (!is.na(hgb) && hgb < 10) {
      
      interpretation <- c(
        
        interpretation,
        "Moderate anemia present."
        
      )
      
    }
    
  }
  
  # =======================================================
  # THROMBOCYTOPENIA
  # =======================================================
  
  if ("PLT" %in% names(values)) {
    
    plt <- as.numeric(values["PLT"])
    
    if (!is.na(plt) && plt < 20) {
      
      interpretation <- c(
        
        interpretation,
        "Critical thrombocytopenia detected."
        
      )
      
    }
    
  }
  
  # =======================================================
  # LEUKOCYTOSIS
  # =======================================================
  
  if ("WBC" %in% names(values)) {
    
    wbc <- as.numeric(values["WBC"])
    
    if (!is.na(wbc) && wbc > 50) {
      
      interpretation <- c(
        
        interpretation,
        "Marked leukocytosis present."
        
      )
      
    }
    
  }
  
  # =======================================================
  # MICROCYTOSIS
  # =======================================================
  
  if ("MCV" %in% names(values)) {
    
    mcv <- as.numeric(values["MCV"])
    
    if (!is.na(mcv) && mcv < 80) {
      
      interpretation <- c(
        
        interpretation,
        "Microcytic red cell indices."
        
      )
      
    }
    
  }
  
  # =======================================================
  # FALLBACK
  # =======================================================
  
  if (length(interpretation) == 0) {
    
    interpretation <- "No major abnormalities detected."
    
  }
  
  paste(
    
    interpretation,
    
    collapse = "<br><br>"
    
  )
  
}