library(DBI)

load_active_panel <- function(pool,panel_type){
  
  lot <-
    
    DBI::dbGetQuery(
      
      pool,
      
      "

SELECT lot_id

FROM panel_lots

WHERE active=TRUE

AND panel_type=$1

ORDER BY lot_id DESC

LIMIT 1

",
      
      params=list(panel_type)
      
    )
  
  if(nrow(lot)==0){
    
    return(NULL)
    
  }
  
  DBI::dbGetQuery(
    
    pool,
    
    "

SELECT *

FROM panel_definition

WHERE lot_id=$1

ORDER BY cell_number

",
    
    params=list(
      
      lot$lot_id[1]
      
    )
    
  )
  
}