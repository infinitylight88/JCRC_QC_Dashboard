library(shiny)
library(DBI)
library(plotly)

reagents_server <- function(id,pool){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      ns <- session$ns
      
      reagent_data <- reactive({
        
        DBI::dbGetQuery(
          
          pool,
          
          "

SELECT *

FROM reagent_usage

ORDER BY usage_date DESC

LIMIT 500

"
          
        )
        
      })
      
      output$reagent_plot <- renderPlotly({
        
        df <- reagent_data()
        
        if(nrow(df)==0){
          
          return(NULL)
          
        }
        
        plot_ly(
          
          df,
          
          x=~usage_date,
          
          y=~remaining_quantity,
          
          type="scatter",
          
          mode="lines+markers"
          
        )
        
      })
      
    })
  
}