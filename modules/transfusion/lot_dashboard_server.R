library(shiny)

library(DBI)

library(DT)

lot_dashboard_server <- function(id,pool){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      ########################################################
      # SCREENING LOT MASTER
      ########################################################
      
      screening_master <- reactive({
        
        dbGetQuery(
          
          pool,
          
          "

SELECT

lot_id,

effective_date,

expiry_date,

alsevers_lot,

cellstab_lot,

cellmedia_lot,

technologist,

CASE

WHEN expiry_date < CURRENT_DATE

THEN 'EXPIRED'

ELSE 'ACTIVE'

END status

FROM screening_lot_master

ORDER BY lot_id DESC

"
          
        )
        
      })
      
      
      
      ########################################################
      # ID PANEL MASTER
      ########################################################
      
      id_master <- reactive({
        
        dbGetQuery(
          
          pool,
          
          "

SELECT

lot_id,

effective_date,

expiry_date,

panel_alsevers,

panel_cellstab,

panel_cellmedia,

papain_alsevers,

papain_cellstab,

papain_cellmedia,

lisp_panel,

technologist,

CASE

WHEN expiry_date < CURRENT_DATE

THEN 'EXPIRED'

ELSE 'ACTIVE'

END status

FROM id_panel_lot_master

ORDER BY lot_id DESC

"
          
        )
        
      })
      
      
      
      ########################################################
      # SCREENING LOT TABLE
      ########################################################
      
      output$screening_lots <- renderDT({
        
        datatable(
          
          screening_master(),
          
          selection = "single",
          
          rownames = FALSE,
          
          extensions = c("Buttons"),
          
          options = list(
            
            pageLength = 10,
            
            scrollX = TRUE,
            
            dom = "Bfrtip",
            
            buttons = c(
              
              "copy",
              
              "csv",
              
              "excel"
              
            )
            
          )
          
        )
        
      })
      
      
      
      ########################################################
      # ID PANEL TABLE
      ########################################################
      
      output$id_lots <- renderDT({
        
        datatable(
          
          id_master(),
          
          selection = "single",
          
          rownames = FALSE,
          
          extensions = c("Buttons"),
          
          options = list(
            
            pageLength = 10,
            
            scrollX = TRUE,
            
            dom = "Bfrtip",
            
            buttons = c(
              
              "copy",
              
              "csv",
              
              "excel"
              
            )
            
          )
          
        )
        
      })
      
      
      
      ########################################################
      # SCREENING MATRIX
      ########################################################
      
      output$screening_matrix <- renderDT({
        
        req(input$screening_lots_rows_selected)
        
        lot_id <-
          
          screening_master()$lot_id[
            input$screening_lots_rows_selected
          ]
        
        df <- dbGetQuery(
          
          pool,
          
          "

SELECT *

FROM screening_panel_cells
WHERE lot_id = $1
ORDER BY cell_number

",
          
          params=list(lot_id)
          
        )
        
        datatable(
          
          df,
          
          rownames = FALSE,
          
          options = list(
            
            scrollX = TRUE,
            
            pageLength = 20
            
          )
          
        )
        
      })
      
      
      
      ########################################################
      # ID PANEL MATRIX
      ########################################################
      
      output$id_matrix <- renderDT({
        
        req(input$id_lots_rows_selected)
        
        lot_id <-
          
          id_master()$lot_id[
            input$id_lots_rows_selected
          ]
        
        df <- dbGetQuery(
          
          pool,
          
          "

SELECT *

FROM id_panel_cells
WHERE lot_id = $1
ORDER BY cell_number

",
          
          params=list(lot_id)
          
        )
        
        datatable(
          
          df,
          
          rownames = FALSE,
          
          options = list(
            
            scrollX = TRUE,
            
            pageLength = 20
            
          )
          
        )
        
      })
      
    }
    
  )
  
}