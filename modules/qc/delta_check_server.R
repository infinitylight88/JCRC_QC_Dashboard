# =====================================================
# FILE:
# modules/qc/delta_check_server.R
# =====================================================

library(shiny)
library(DBI)
library(DT)
library(glue)

library(shiny)

delta_check_server <- function(id,pool){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      ns <- session$ns
      
      # Delta logic will come here
      
    })
  
}