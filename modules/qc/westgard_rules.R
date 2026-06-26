#=========================================
# WESTGARD RULES ENGINE
#=========================================

apply_westgard <- function(df){
  
  if(nrow(df)==0){
    
    df$rule <- character()
    
    return(df)
    
  }
  
  df$zscore <- (
    df$result_value -
      df$target_mean
  )/
    df$target_sd
  
  df$rule <- "PASS"
  
  df$rule[
    abs(df$zscore)>2
  ] <- "1_2S"
  
  df$rule[
    abs(df$zscore)>3
  ] <- "1_3S"
  
  df
  
}