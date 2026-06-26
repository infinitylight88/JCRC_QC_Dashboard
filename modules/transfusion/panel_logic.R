run_panel_engine <- function(
    
  panel,
  
  reactions
  
){
  
  positive_cells <-
    
    which(
      
      reactions!="0"
      
    )
  
  
  
  if(
    
    length(
      
      positive_cells
      
    )==0
    
  ){
    
    return(
      
      "NO ANTIBODY DETECTED"
      
    )
    
  }
  
  
  
  ######################################################
  
  # VERY SIMPLE RULE OUT ENGINE
  
  ######################################################
  
  possible <- c()
  
  
  
  for(cell in positive_cells){
    
    possible <-
      
      c(
        
        possible,
        
        paste(
          
          "Investigate Cell",
          
          cell
          
        )
        
      )
    
  }
  
  
  
  unique(
    
    possible
    
  )
  
}