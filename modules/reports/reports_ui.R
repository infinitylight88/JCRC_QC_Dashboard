# =====================================================
# REPORT UI
# =====================================================

library(shiny)

library(bs4Dash)

reports_ui <- function(id){
  
  ns <- NS(id)
  
  tabItem(
    
    tabName="reports",
    
    fluidRow(
      
      bs4Card(
        
        width=12,
        
        title="Reporting Engine",
        
        status="success",
        
        solidHeader=TRUE,
        
        selectInput(
          
          ns("report_type"),
          
          "Report Type",
          
          choices=c(
            
            "QC Report",
            
            "Workload Report",
            
            "Daily Summary"
            
          )
          
        ),
        
        downloadButton(
          
          ns("download_report"),
          
          "Generate PDF"
          
        )
        
      )
      
    )
    
  )
  
}