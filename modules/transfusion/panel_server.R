library(shiny)

library(DBI)

library(DT)

source(
  "modules/transfusion/panel_logic.R"
)

panel_server <- function(id,pool){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      ns <- session$ns
      
      
      
      ################################################
      
      # ACTIVE 10 CELL LOT
      
      ################################################
      
      panel_lot <- reactive({
        
        DBI::dbGetQuery(
          
          pool,
          
          "

SELECT *

FROM screening_lot_master

WHERE panel_type='10CELL'

AND expiry_date>=CURRENT_DATE

ORDER BY expiry_date DESC

LIMIT 1

"
          
        )
        
      })
      
      
      
      ################################################
      
      # LOAD PANEL
      
      ################################################
      
      panel_definition <- reactive({
        
        lot <- panel_lot()
        
        req(
          
          nrow(lot)>0
          
        )
        
        DBI::dbGetQuery(
          
          pool,
          
          "

SELECT *

FROM screening_panel_cells

WHERE lot_id=$1

ORDER BY cell_number

",
          
          params=list(
            
            lot$lot_id[1]
            
          )
          
        )
        
      })
      
      
      
      ################################################
      
      # BUILD PANEL
      
      ################################################
      
      output$panel_table <- renderUI({
        
        panel <- panel_definition()
        
        req(
          
          nrow(panel)>0
          
        )
        
        cells <-
          
          unique(
            
            panel$cell_number
            
          )
        
        tagList(
          
          fluidRow(
            
            column(
              
              2,
              
              strong("Cell")
              
            ),
            
            column(
              
              2,
              
              strong("Reaction")
              
            )
            
          ),
          
          hr(),
          
          lapply(
            
            cells,
            
            function(c){
              
              fluidRow(
                
                column(
                  
                  2,
                  
                  strong(
                    
                    paste(
                      
                      "Cell",
                      
                      c
                      
                    )
                    
                  )
                  
                ),
                
                column(
                  
                  2,
                  
                  selectInput(
                    
                    ns(
                      
                      paste0(
                        
                        "reaction_",
                        
                        c
                        
                      )
                      
                    ),
                    
                    NULL,
                    
                    choices=c(
                      
                      "0",
                      
                      "w+",
                      
                      "1+",
                      
                      "2+",
                      
                      "3+",
                      
                      "4+"
                      
                    )
                    
                  )
                  
                )
                
              )
              
            })
          
        )
      
      })
  
  
  
  ################################################
  
  # RUN INTERPRETATION
  
  ################################################
  
  observeEvent(
    
    input$run_panel,
    
    {
      
      panel <- panel_definition()
      
      cells <- unique(panel$cell_number)
      
      rxns <- c()
      
      for(c in cells){
        
        rxns[c] <-
          
          input[[
            
            paste0(
              
              "reaction_",
              
              c
              
            )
            
          ]]
        
      }
      
      
      
      result <-
        
        run_panel_engine(
          
          panel,
          
          rxns
          
        )
      
      
      
      output$panel_result <- renderUI({
        
        tagList(
          
          h3(
            
            paste(
              
              "Probable Antibody:"
              
            )
            
          ),
          
          h2(
            
            paste(
              
              result,
              
              collapse=", "
              
            )
            
          )
          
        )
        
      })
      
      
      
    }
    
  )
  
    }
  
  )

}

