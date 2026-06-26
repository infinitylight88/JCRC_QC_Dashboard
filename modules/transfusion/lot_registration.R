library(shiny)

library(bs4Dash)

library(DT)

lot_registration_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    box(
      
      width=12,
      
      title="LOT Management",
      
      status="warning",
      
      solidHeader=TRUE,
      
      tabsetPanel(
        
        ####################################################
        # REGISTERED SCREENING LOTS
        ####################################################
        
        tabPanel(
          
          "Registered Screening LOTS",
          
          br(),
          
          DTOutput(
            ns("screening_lots")
          )
          
        ),
        
        ####################################################
        # REGISTERED ID PANEL LOTS
        ####################################################
        
        tabPanel(
          
          "Registered ID Panel LOTS",
          
          br(),
          
          DTOutput(
            ns("id_lots")
          )
          
        ),
        
        ####################################################
        # REGISTER NEW LOT
        ####################################################
        
        tabPanel(
          
          "Register LOT",
          
          accordion(
            
            id=ns("lot_accordion"),
            
            accordionItem(
              
              title="LOT Registration",
              
              collapsed=TRUE,
              
              lot_registration_inputs_ui(
                id
              )
              
            )
            
          )
          
        )
        
      )
      
    )
    
  )
  
}