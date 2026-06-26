library(shiny)

library(DBI)

library(DT)

source(
  "modules/transfusion/antibody_panel_logic.R"
)

antibody_screen_server <- function(
    id,
    pool,
    screen_positive,
    registration = reactive(NULL)
){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      ns <- session$ns
      
      ################################################
      # ACTIVE LOT
      ################################################
      
      active_lot <- reactive({
        
        dbGetQuery(
          
          pool,
          
          "

SELECT *

FROM screening_lot_master

WHERE active=TRUE

ORDER BY lot_id DESC

LIMIT 1

"
          
        )
        
      })
      
      ################################################
      # LOT DISPLAY
      ################################################
      
      output$active_lot_info <- renderUI({
        
        lot <- active_lot()
        
        req(nrow(lot)>0)
        
        tagList(
          
          strong(
            paste("LOT ID:", lot$lot_id)
          ),
          
          br(),
          
          paste(
            "Expiry:",
            lot$expiry_date
          )
          
        )
        
      })
      
      ################################################
      # PANEL DEFINITION
      ################################################
      
      panel_definition <- reactive({
        
        lot <- active_lot()
        
        req(nrow(lot)>0)
        
        dbGetQuery(
          
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
      # DYNAMIC PANEL
      ################################################
      
      output$dynamic_panel <- renderUI({
        
        panel <- panel_definition()
        
        req(nrow(panel)>0)
        
        tagList(
          
          lapply(
            
            unique(panel$cell_number),
            
            function(cell){
              
              fluidRow(
                
                column(
                  2,
                  strong(
                    paste("Cell",cell)
                  )
                ),
                
                column(
                  3,
                  selectInput(
                    ns(paste0("is_",cell)),
                    "IS",
                    c("0","w+","1+","2+","3+","4+")
                  )
                ),
                
                column(
                  3,
                  selectInput(
                    ns(paste0("37_",cell)),
                    "37C",
                    c("0","w+","1+","2+","3+","4+")
                  )
                ),
                
                column(
                  3,
                  selectInput(
                    ns(paste0("ahg_",cell)),
                    "AHG",
                    c("0","w+","1+","2+","3+","4+")
                  )
                )
                
              )
              
            }
            
          )
          
        )
        
      })
      
      ################################################
      # SAVE SCREEN
      ################################################
      
      observeEvent(input$save_screen,{
        
        panel <- panel_definition()
        
        cells <- unique(panel$cell_number)
        
        results <- list()
        
        for(c in cells){
          
          results[[paste0("cell",c)]] <- c(
            
            input[[paste0("is_",c)]],
            
            input[[paste0("37_",c)]],
            
            input[[paste0("ahg_",c)]]
            
          )
          
        }
        
        interpretation <- interpret_screen(
          
          panel,
          
          results
          
        )
        
        ################################################
        # SAVE TO DATABASE
        ################################################
        
        dbExecute(
          
          pool,
          
          "

INSERT INTO antibody_screen_results(

reaction,

probable_antibodies,

screen_date

)

VALUES(

$1,

$2,

CURRENT_TIMESTAMP

)

",
      
      params=list(
        
        interpretation$result,
        
        paste(
          interpretation$antibodies,
          collapse=", "
        )
        
      )
      
        )
  
  ################################################
  
  if(interpretation$result=="POSITIVE"){
    
    screen_positive(TRUE)
    
  }else{
    
    screen_positive(FALSE)
    
  }
  
  ################################################
  
  output$screen_summary <- renderUI({
    
    tagList(
      
      h4(
        
        paste(
          "Result:",
          interpretation$result
        )
        
      ),
      
      h4(
        
        paste(
          "Probable Antibodies:",
          paste(
            interpretation$antibodies,
            collapse=", "
          )
        )
        
      )
      
    )
    
  })
  
  showNotification(
    
    "Antibody Screen Saved",
    
    type="message"
    
  )
  
      })

    }
  
  )

}