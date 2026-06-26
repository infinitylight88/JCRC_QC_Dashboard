# =====================================================
# FILE:
# modules/qc/delta_check_ui.R
#
# DELTA CHECK UI
# =====================================================

library(shiny)

library(bs4Dash)

library(DT)

delta_check_ui <- function(id){
  
  ns <- NS(id)
  
  tabItem(
    
    tabName="delta",
    
    fluidRow(
      
      bs4Card(
        
        width=12,
        
        title="Delta Checks",
        
        status="warning",
        
        solidHeader=TRUE,
        
        p(
          "Compare current patient results
against previous results to detect
significant changes."
        )
        
      )
      
    ),
    
    fluidRow(
      
      bs4Card(
        
        width=4,
        
        title="Patient Search",
        
        status="info",
        
        solidHeader=TRUE,
        
        textInput(
          
          ns("patient_id"),
          
          "Patient ID"
          
        ),
        
        actionButton(
          
          ns("run"),
          
          "Run Delta Check"
          
        )
        
      )
      
    ),
    
    bs4Card(
      
      width=8,
      
      title="Delta Check Results",
      
      status="primary",
      
      solidHeader=TRUE,
      
      DTOutput(
        
        ns("delta_table")
        
      )
      
    )
    
  )
  
  

}