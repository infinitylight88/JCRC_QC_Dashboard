# =========================================================
# FILE: modules/qc/qc_server.R
# =========================================================

library(shiny)
library(plotly)
library(DT)
library(DBI)
library(dplyr)

source("helpers/qc_helpers.R")

# =========================================================
# QC SERVER MODULE
# =========================================================

qc_server <- function(id, pool){
  
  moduleServer(
    
    id,
    
    function(input, output, session){
      
      ns <- session$ns
      
      
      # =====================================================
      # LOAD QC DATA
      # =====================================================
      
      qc_data <- reactive({
        
        query <- "

SELECT

qc_date,
qc_time,
qc_level,
lot_number,
analyte,
result_value,
target_mean,
target_sd,
instrument

FROM qc_results

ORDER BY qc_date DESC

"
        
        DBI::dbGetQuery(
          pool,
          query
        )
        
      })
      
      
      # =====================================================
      # PROCESS QC
      # =====================================================
      
      processed_qc <- reactive({
        
        df <- qc_data()
        
        if(nrow(df)==0){
          
          return(data.frame())
          
        }
        
        df <- df %>%
          
          mutate(
            
            z_score=
              (result_value-target_mean)/target_sd
            
          )
        
        df
        
      })
      
      
      # =====================================================
      # LEVEY JENNINGS
      # =====================================================
      
      output$levy_plot <- renderPlotly({
        
        df <- processed_qc()
        
        req(nrow(df)>0)
        
        plot_ly(
          
          df,
          
          x=~qc_date,
          
          y=~result_value,
          
          color=~qc_level,
          
          type="scatter",
          
          mode="lines+markers"
          
        )
        
      })
      
      
      # =====================================================
      # QC TABLE
      # =====================================================
      
      output$qc_table <- renderDT({
        
        datatable(
          
          processed_qc(),
          
          options=list(
            
            scrollX=TRUE,
            
            pageLength=10
            
          )
          
        )
        
      })
      
    })
  

}