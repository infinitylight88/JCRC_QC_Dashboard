library(shiny)

source(
  "modules/transfusion/grouping_server.R"
)

source(
  "modules/transfusion/antibody_screen_server.R"
)

source(
  "modules/transfusion/panel_server.R"
)

source(
  "modules/transfusion/history_server.R"
)

source(
  "modules/transfusion/lot_registration_server.R"
)

source(
  "modules/transfusion/test_registration_server.R"
)

source(
  "modules/transfusion/lot_dashboard_server.R"
)

btm_server <- function(id,pool){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      cat("\n====================================\n")
      cat("BTM SERVER LOADED\n")
      cat("Module ID:",id,"\n")
      cat("====================================\n")
      
      ####################################################
      # SHARED SCREEN STATUS
      ####################################################
      
      screen_positive <-
        
        reactiveVal(FALSE)
      
      ####################################################
      # HISTORY MODULE
      ####################################################
      
      history_server(
        
        "history",
        
        pool
        
      )
      
      ####################################################
      # TEST REGISTRATION
      ####################################################
      
      registration <-
        
        test_registration_server(
          
          "register",
          
          pool
          
        )
      
      ####################################################
      # CURRENT TEST OUTPUT
      ####################################################
      
      output$current_test <- renderText({
        
        req(
          registration()
        )
        
        registration()$test
        
      })
      
      outputOptions(
        
        output,
        
        "current_test",
        
        suspendWhenHidden = FALSE
        
      )
      
      ####################################################
      # GROUPING
      ####################################################
      
      grouping_server(
        
        "group",
        
        pool,
        
        registration
        
      )
      
      ####################################################
      # ANTIBODY SCREEN
      ####################################################
      
      antibody_screen_server(
        
        "screen",
        
        pool,
        
        screen_positive,
        
        registration
        
      )
      
      ####################################################
      # PANEL
      ####################################################
      
      panel_server(
        
        "panel",
        
        pool
        
      )
      
      ####################################################
      # LOT REGISTRATION
      ####################################################
      
      lot_dashboard_server(
        "lots",
        pool
      )
      
      lot_registration_server(
        
        "lot",
        
        pool
        
      )
      
      ####################################################
      # SCREEN POSITIVE OUTPUT
      ####################################################
      
      output$screen_positive <- renderText({
        
        if(screen_positive())
          
          "TRUE"
        
        else
          
          "FALSE"
        
      })
      
      outputOptions(
        
        output,
        
        "screen_positive",
        
        suspendWhenHidden = FALSE
        
      )
      
    }
    
  )
  
}