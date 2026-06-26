critical_flags <- function(results_df) {
  
  alerts <- c()
  
  if ("HGB" %in% names(results_df)) {
    
    if (as.numeric(results_df$HGB) < 6) {
      
      alerts <- c(alerts, "Critical Hemoglobin")
      
    }
    
  }
  
  if ("PLT" %in% names(results_df)) {
    
    if (as.numeric(results_df$PLT) < 20) {
      
      alerts <- c(alerts, "Critical Platelets")
      
    }
    
  }
  
  alerts
  
}