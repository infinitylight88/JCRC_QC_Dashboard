library(shiny)

library(bs4Dash)

antibody_screen_ui <- function(id){
  
  ns <- NS(id)
  
  box(
    
    width = 12,
    
    title = "Antibody Screening",
    
    status = "danger",
    
    solidHeader = TRUE,
    
    uiOutput(
      ns("active_lot_info")
    ),
    
    hr(),
    
    uiOutput(
      ns("dynamic_panel")
    ),
    
    hr(),
    
    actionButton(
      ns("save_screen"),
      "Save Screen",
      class="btn-danger"
    ),
    
    br(),
    br(),
    
    uiOutput(
      ns("screen_summary")
    )
    
  )
  
}
