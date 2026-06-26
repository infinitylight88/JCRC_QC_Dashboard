library(shiny)

lot_verification_ui <- function(id){
  
  ns<-NS(id)
  
  tabItem(
    
    tabName="lot_verification",
    
    fluidRow(
      
      box(
        
        width=12,
        
        title="Lot Verification",
        
        status="primary",
        
        solidHeader=TRUE,
        
        selectInput(
          
          ns("parameter"),
          
          "Parameter",
          
          c(
            
            "WBC",
            
            "RBC",
            
            "HGB",
            
            "PLT"
            
          )
          
        ),
        
        plotlyOutput(
          
          ns("lot_plot"),
          
          height="500px"
          
        )
        
      )
      
    )
    
  )
  
}