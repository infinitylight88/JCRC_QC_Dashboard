library(shiny)

library(bs4Dash)

source("modules/transfusion/grouping_ui.R")
source("modules/transfusion/antibody_screen_ui.R")
source("modules/transfusion/panel_ui.R")
source("modules/transfusion/history_ui.R")
source("modules/transfusion/test_registration_ui.R")

source("modules/transfusion/lot_dashboard_ui.R")
source("modules/transfusion/lot_registration_inputs_ui.R")

btm_ui <- function(id){
  
  ns <- NS(id)
  
  tabItem(
    
    tabName = "btm",
    
    ####################################################
    # HEADER
    ####################################################
    
    fluidRow(
      
      box(
        
        width = 12,
        
        title = "Blood Transfusion Engine",
        
        status = "danger",
        
        solidHeader = TRUE,
        
        p(
          "ABO Grouping, Antibody Screening, Crossmatch and Extended Panels"
        )
        
      )
      
    ),
    
    ####################################################
    # PATIENT HISTORY
    ####################################################
    
    history_ui(
      ns("history")
    ),
    
    ####################################################
    # TEST REGISTRATION
    ####################################################
    
    test_registration_ui(
      ns("register")
    ),
    
    ####################################################
    # GROUPING
    ####################################################
    
    conditionalPanel(
      
      condition = "

      output.current_test=='ABO/D GROUP' ||

      output.current_test=='ABO+RH+ABSCREEN' ||

      output.current_test=='ABO+RH+ABSCREEN+CROSSMATCH' ||

      output.current_test=='1ST EXT ABO+RH+ABSCREEN (SCD)'

      ",
      
      grouping_ui(
        ns("group")
      )
      
    ),
    
    ####################################################
    # ANTIBODY SCREEN
    ####################################################
    
    conditionalPanel(
      
      condition = "

      output.current_test=='ABO+RH+ABSCREEN' ||

      output.current_test=='ABO+RH+ABSCREEN+CROSSMATCH' ||

      output.current_test=='1ST EXT ABO+RH+ABSCREEN (SCD)'

      ",
      
      antibody_screen_ui(
        ns("screen")
      )
      
    ),
    
    ####################################################
    # PANEL
    ####################################################
    
    conditionalPanel(
      
      condition = "

      output.current_test=='ABO+RH+ABSCREEN+CROSSMATCH' ||

      output.current_test=='1ST EXT ABO+RH+ABSCREEN (SCD)'

      ",
      
      panel_ui(
        ns("panel")
      )
      
    ),
    
    ####################################################
    # LOT MANAGEMENT
    ####################################################
    
    box(
      
      width = 12,
      
      title = "LOT Management",
      
      status = "warning",
      
      solidHeader = TRUE,
      
      collapsible = TRUE,
      
      collapsed = FALSE,
      
      tabsetPanel(
        
        ################################################
        # REGISTERED LOTS
        ################################################
        
        tabPanel(
          
          "Registered LOTS",
          
          lot_dashboard_ui(
            ns("lots")
          )
          
        ),
        
        ################################################
        # REGISTER LOT
        ################################################
        
        tabPanel(
          
          "Register LOT",
          
          lot_registration_inputs_ui(
            ns("lot")
          )
          
        )
        
      )
      
    )
    
  )
  
}