interpret_screen <- function(
    
  panel,
  
  results
  
){
  
  positive_cells <- c()
  
  for(i in seq_along(results)){
    
    r <- results[[i]]
    
    if(
      
      any(
        
        r!="0"
        
      )
      
    ){
      
      positive_cells <-
        
        c(
          
          positive_cells,
          
          i
          
        )
      
    }
    
  }
  
  
  
  if(
    
    length(
      
      positive_cells
      
    )==0
    
  ){
    
    return(
      
      list(
        
        result="NEGATIVE",
        
        antibodies="None"
        
      )
      
    )
    
  }
  
  
  
  return(
    
    list(
      
      result="POSITIVE",
      
      antibodies=
        
        paste(
          
          "Investigate Positive Cells:",
          
          paste(
            
            positive_cells,
            
            collapse=","
            
          )
          
        )
      
    )
    
  )
  
}