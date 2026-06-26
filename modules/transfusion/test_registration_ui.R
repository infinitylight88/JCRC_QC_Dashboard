library(shiny)

test_registration_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    box(
      
      width=12,
      
      title="Register Transfusion Test",
      
      status="primary",
      
      solidHeader=TRUE,
      
      textInput(
        
        ns("accession"),
        
        "Accession Number"
        
      ),
      
      textInput(
        
        ns("patient_id"),
        
        "Patient ID"
        
      ),
      
      textInput(
        
        ns("age"),
        
        "Age"
        
      ),
      
      selectInput(
        
        ns("requested_test"),
        
        "Select Test",
        
        choices=c(
          
          "ABO/D GROUP",
          
          "ABO+RH+ABSCREEN",
          
          "ABO+RH+ABSCREEN+CROSSMATCH",
          
          "1ST EXT ABO+RH+ABSCREEN (SCD)"
          
        )
        
      ),
      
      textInput(
        
        ns("doctor"),
        
        "Doctor"
        
      ),
      
      selectInput(
        
        ns("technologist"),
        
        "Technologist",
        
        choices=c(
          
          "Mwanje J.B",
          
          "Faith B.L",
          
          "Roodney K"
          
        )
        
      ),
      
      actionButton(
        
        ns("register"),
        
        "Register Test"
        
      ),
      tableOutput(
        ns("previous_tests")
      )
      
    )
    
  )
  
}