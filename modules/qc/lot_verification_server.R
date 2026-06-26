library(shiny)
library(DBI)
library(plotly)

lot_verification_server <- function(id,pool){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      lot_data <- reactive({
        
        DBI::dbGetQuery(
          
          pool,
          
          "

SELECT *

FROM qc_results

ORDER BY created_at DESC

LIMIT 200

"
          
        )
        
      })
      
      output$lot_plot <- renderPlotly({
        
        df <- lot_data()
        
        if(nrow(df)==0){
          
          return(NULL)
          
        }
        
        plot_ly(
          
          df,
          
          x=~created_at,
          
          y=~result_value,
          
          type="scatter",
          
          mode="markers"
          
        )
        
      })
      
    })
  
}