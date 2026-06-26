library(shiny)

library(bs4Dash)

panel_ui <- function(id){
  
  ns <- NS(id)
  
  box(
    
    width=12,
    
    title="10 Cell Identification Panel",
    
    status="warning",
    
    solidHeader=TRUE,
    
    uiOutput(
      
      ns("panel_table")
      
    ),
    
    hr(),
    
    actionButton(
      
      ns("run_panel"),
      
      "Interpret Panel"
      
    ),
    
    br(),
    br(),
    
    uiOutput(
      
      ns("panel_result")
      
    )
    
  )
  
}