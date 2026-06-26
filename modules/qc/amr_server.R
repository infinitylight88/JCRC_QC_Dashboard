amr_server <- function(id,pool){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      output$amr_plot <- renderPlotly({
        
        query <- "

SELECT

analyte,

AVG(result_value) avg_result

FROM qc_results

GROUP BY analyte

"
        
        df <- dbGetQuery(pool,query)
        
        plot_ly(
          
          df,
          
          x=~analyte,
          
          y=~avg_result,
          
          type="bar"
          
        )
        
      })
      
    }
    
  )
  
}