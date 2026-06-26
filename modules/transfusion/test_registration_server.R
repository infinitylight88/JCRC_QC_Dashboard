library(shiny)
library(DBI)

test_registration_server <- function(id,pool){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      registered_case <- reactiveVal(NULL)
      
      observeEvent(
        
        input$register,
        
        {
          
          DBI::dbExecute(
            
            pool,
            
            "

INSERT INTO transfusion_cases(

accession_number,

patient_id,

patient_age,

requested_test,

doctor_name,

technologist

)

VALUES(

$1,$2,$3,$4,$5,$6

)

",
      
      params=list(
        
        input$accession,
        
        input$patient_id,
        
        input$age,
        
        input$requested_test,
        
        input$doctor,
        
        input$technologist
        
      )
      
          )
  
  observe({
    
    req(input$patient_id)
    
    previous <-
      
      DBI::dbGetQuery(
        
        pool,
        
        "

SELECT

accession_number,
requested_test,
created_at

FROM transfusion_cases

WHERE patient_id=$1

ORDER BY created_at DESC

LIMIT 10

",
        
        params=list(
          input$patient_id
        )
        
      )
    
    output$previous_tests <- renderTable(
      
      previous
      
    )
    
  })
  
  case_id <-
    
    DBI::dbGetQuery(
      
      pool,
      
      "

SELECT MAX(case_id)

FROM transfusion_cases

"
      
    )[1,1]
  
  registered_case(
    
    list(
      
      case_id=case_id,
      
      test=input$requested_test
      
    )
    
  )
  
  showNotification(
    
    "Test Registered"
    
  )
  
        }
  
      )

return(
  
  registered_case
  
)

    }

  )

}