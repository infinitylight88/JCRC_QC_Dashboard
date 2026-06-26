library(shiny)

library(DBI)

library(DT)

history_server <- function(id,pool){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      cat("\n================================\n")
      cat("HISTORY SERVER CONNECTED\n")
      cat("MODULE:",id,"\n")
      cat("================================\n")
      
      
      #########################################################
      # HISTORY DATA
      #########################################################
      
      history_data <- reactive({
        
        input$refresh
        
        cat("\n===========================\n")
        cat("HISTORY MODULE EXECUTING\n")
        cat("===========================\n")
        
        query <- "

SELECT

tc.case_id,

tc.accession_number,

tc.patient_id,

tc.requested_test,

COALESCE(
agr.final_group,
''
) blood_group,

COALESCE(
asr.reaction,
''
) antibody_screen,

COALESCE(
ai.confirmed_antibodies,
''
) antibodies,

COALESCE(
cr.crossmatch_result,
''
) crossmatch,

tc.test_date,

tc.result_date

FROM transfusion_cases tc

LEFT JOIN abo_grouping_results agr

ON tc.case_id=agr.case_id

LEFT JOIN antibody_screen_results asr

ON tc.case_id=asr.case_id

LEFT JOIN antibody_interpretations ai

ON tc.case_id=ai.case_id

LEFT JOIN crossmatch_results cr

ON tc.case_id=cr.case_id

WHERE 1=1

"
        
        #################################################
        # DATE FILTER
        #################################################
        
        if(
          
          !is.null(input$from_date)
          
          &&
          
          !is.null(input$to_date)
          
        ){
          
          query <- paste0(
            
            query,
            
            "

AND tc.test_date::date

BETWEEN '",
            
            input$from_date,
            
            "'

AND '",
            
            input$to_date,
            
            "'

"
            
          )
          
        }
        
        #################################################
        # PATIENT FILTER
        #################################################
        
        if(
          
          !is.null(input$patient_filter)
          
          &&
          
          input$patient_filter!=""
          
        ){
          
          query <- paste0(
            
            query,
            
            "

AND tc.patient_id='",
            
            input$patient_filter,
            
            "'

"
            
          )
          
        }
        
        #################################################
        # ORDERING
        #################################################
        
        query <- paste0(
          
          query,
          
          "

ORDER BY

tc.test_date DESC,

tc.case_id DESC

"
          
        )
        
        cat("\nQUERY:\n")
        
        cat(query)
        
        df <- tryCatch(
          
          {
            
            DBI::dbGetQuery(
              
              pool,
              
              query
              
            )
            
          },
          
          error=function(e){
            
            cat("\nDATABASE ERROR\n")
            
            print(e)
            
            data.frame()
            
          }
          
        )
        
        cat("\nROWS RETURNED:",nrow(df),"\n")
        
        df
        
      })
      
      
      
      #########################################################
      # DEBUG OUTPUT
      #########################################################
      
      
      #########################################################
      # HISTORY TABLE
      #########################################################
      
      output$history_table <- renderDT({
        
        cat("\nRENDERING HISTORY TABLE\n")
        
        datatable(
          
          history_data(),
          
          rownames=FALSE,
          
          selection="single",
          
          filter="top",
          
          options=list(
            
            pageLength=10,
            
            scrollX=TRUE,
            
            autoWidth=TRUE,
            
            order=list(
              
              list(8,'desc')
              
            )
            
          )
          
        )
        
      })
      
    }
    
  )
  
}