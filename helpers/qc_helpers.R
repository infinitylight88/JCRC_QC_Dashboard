# =====================================================
# QC HELPERS
# WESTGARD ENGINE
# =====================================================

library(dplyr)

# =====================================================
# CALCULATE SD SCORE
# =====================================================

calculate_sd_score <- function(value, mean, sd){
  
  (value-mean)/sd
  
}

# =====================================================
# WESTGARD ENGINE
# =====================================================

evaluate_westgard_rules <- function(df){
  
  if(nrow(df)==0){
    
    return(df)
    
  }
  
  df <- df %>%
    
    arrange(run_date)
  
  df$rule_flag <- "PASS"
  
  df$sd_score <-
    
    calculate_sd_score(
      
      df$parameter_value,
      
      df$target_mean,
      
      df$target_sd
      
    )
  
  # =======================================
  # 1-2S
  # =======================================
  
  df$rule_flag[
    
    abs(df$sd_score)>=2
    
  ] <- "1-2S"
  
  # =======================================
  # 1-3S
  # =======================================
  
  df$rule_flag[
    
    abs(df$sd_score)>=3
    
  ] <- "1-3S REJECT"
  
  # =======================================
  # 2-2S
  # =======================================
  
  if(nrow(df)>=2){
    
    for(i in 2:nrow(df)){
      
      previous<-
        
        df$sd_score[i-1]
      
      current<-
        
        df$sd_score[i]
      
      if(
        
        abs(previous)>=2 &
        
        abs(current)>=2 &
        
        sign(previous)==sign(current)
        
      ){
        
        df$rule_flag[i] <-
          
          "2-2S REJECT"
        
      }
      
    }
    
  }
  
  # =======================================
  # R4S
  # =======================================
  
  if(nrow(df)>=2){
    
    for(i in 2:nrow(df)){
      
      diff<-
        
        abs(
          
          df$sd_score[i]-
            
            df$sd_score[i-1]
          
        )
      
      if(diff>=4){
        
        df$rule_flag[i] <-
          
          "R4S REJECT"
        
      }
      
    }
    
  }
  
  # =======================================
  # 4-1S
  # =======================================
  
  if(nrow(df)>=4){
    
    for(i in 4:nrow(df)){
      
      block<-
        
        df$sd_score[(i-3):i]
      
      if(
        
        all(block>1) |
        
        all(block<(-1))
        
      ){
        
        df$rule_flag[i] <-
          
          "4-1S REJECT"
        
      }
      
    }
    
  }
  
  # =======================================
  # 10X
  # =======================================
  
  if(nrow(df)>=10){
    
    for(i in 10:nrow(df)){
      
      block<-
        
        df$sd_score[(i-9):i]
      
      if(
        
        all(block>0) |
        
        all(block<0)
        
      ){
        
        df$rule_flag[i] <-
          
          "10X REJECT"
        
      }
      
    }
    
  }
  
  df
  
}

# =====================================================
# TREND DETECTION
# =====================================================

detect_trend <- function(values){
  
  if(length(values)<7){
    
    return("NO TREND")
    
  }
  
  increasing<-
    
    all(diff(values)>0)
  
  decreasing<-
    
    all(diff(values)<0)
  
  if(increasing){
    
    return("UPWARD TREND")
    
  }
  
  if(decreasing){
    
    return("DOWNWARD TREND")
    
  }
  
  "NO TREND"
  
}

# =====================================================
# SHIFT DETECTION
# =====================================================

detect_shift <- function(values,mean){
  
  if(length(values)<6){
    
    return("NO SHIFT")
    
  }
  
  above<-
    
    sum(values>mean)
  
  below<-
    
    sum(values<mean)
  
  if(above>=6){
    
    return("POSITIVE SHIFT")
    
  }
  
  if(below>=6){
    
    return("NEGATIVE SHIFT")
    
  }
  
  "NO SHIFT"
  
}