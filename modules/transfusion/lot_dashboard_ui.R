library(shiny)

library(bs4Dash)

library(DT)

lot_dashboard_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    box(
      
      width=12,
      
      title="Registered Screening LOTS",
      
      status="success",
      
      solidHeader=TRUE,
      
      h4("3 Cell LOTS"),
      
      DTOutput(
        ns("screening_lots")
      ),
      DTOutput(ns("screening_matrix")),
      
      br(),
      
      h4("10 Cell LOTS"),
      
      DTOutput(
        ns("id_lots")
      ),
      DTOutput(ns("id_matrix"))
      
    )
    
  )
  
}