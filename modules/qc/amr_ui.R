library(shiny)

amr_ui<-function(id){
  
  ns<-NS(id)
  
  tabItem(
    
    tabName="amr",
    
    fluidRow(
      
      box(
        
        width=12,
        
        title="AMR / Linearity",
        
        status="success",
        
        solidHeader=TRUE,
        
        fileInput(
          
          ns("file"),
          
          "Upload Verification"
          
        ),
        
        plotlyOutput(
          
          ns("linearity")
          
        )
        
      )
      
    )
    
  )
  
}