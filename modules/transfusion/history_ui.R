library(shiny)
library(bs4Dash)
library(DT)

history_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    box(
      
      width = 12,
      
      title = "Patient History / BTM Workload",
      
      status = "primary",
      
      solidHeader = TRUE,
      
      fluidRow(
        
        column(
          
          width = 3,
          
          textInput(
            
            ns("patient_filter"),
            
            "Patient ID",
            
            placeholder = "Search Patient ID"
            
          ),
          
          actionButton(
            
            ns("search_patient"),
            
            "Search Patient",
            
            icon = icon("search")
            
          )
          
        ),
        
        column(
          
          width = 3,
          
          dateInput(
            
            ns("from_date"),
            
            "From Date",
            
            value = as.Date("2026-04-01")
            
          )
          
        ),
        
        column(
          
          width = 3,
          
          dateInput(
            
            ns("to_date"),
            
            "To Date",
            
            value = as.Date("2026-04-30")
            
          )
          
        ),
        
        column(
          
          width = 3,
          
          br(),
          
          actionButton(
            
            ns("refresh"),
            
            "Refresh Workload",
            
            icon = icon("rotate")
            
          )
          
        )
        
      ),
      
      DTOutput(
        
        ns("history_table")
        
      )
      
    )
    
  )
  
}