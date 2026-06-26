library(shiny)

library(DBI)

library(DT)

library(pool)

lot_registration_server <- function(id,pool){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      ###################################################
      # EXISTING REGISTRATION CODE
      ###################################################
      
      # KEEP ALL YOUR CURRENT
      # observeEvent(create3)
      # observeEvent(create10)
      # EXACTLY AS THEY ARE
      
      ###################################################
      # SCREENING LOT TABLE
      ###################################################
      
      screening_data <- reactive({
        
        DBI::dbGetQuery(
          
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

active

FROM screening_lot_master

ORDER BY lot_id DESC

"
          
        )
        
      })
      
      output$screening_lots <- renderDT({
        
        datatable(
          
          screening_data(),
          
          rownames=FALSE,
          
          filter="top",
          
          selection="single",
          
          options=list(
            
            pageLength=10,
            
            scrollX=TRUE
            
          )
          
        )
        
      })
      
      ###################################################
      # ID PANEL LOT TABLE
      ###################################################
      
      id_data <- reactive({
        
        DBI::dbGetQuery(
          
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

active

FROM id_panel_lot_master

ORDER BY lot_id DESC

"
          
        )
        
      })
      
      output$id_lots <- renderDT({
        
        datatable(
          
          id_data(),
          
          rownames=FALSE,
          
          filter="top",
          
          selection="single",
          
          options=list(
            
            pageLength=10,
            
            scrollX=TRUE
            
          )
          
        )
        
      })
      
    }
    
  )
  
}