# =========================================================
# FILE: app.R
# MAIN APPLICATION ENTRY POINT
# =========================================================
library(DT)

library(shiny)
library(bs4Dash)
library(shinyjs)

# =========================================================
# LOAD GLOBALS
# =========================================================

source("global.R")

# =========================================================
# LOAD HELPERS
# =========================================================

source("helpers/qc_helpers.R")

source("helpers/interpretation_engine.R")

source("helpers/alert_engine.R")

source("helpers/pdf_report_generator.R")

source("helpers/reference_engine.R")

# =========================================================
# LOAD HOME MODULE
# =========================================================

source("modules/home/home_ui.R")

source("modules/home/home_server.R")

# =========================================================
# LOAD QC MODULE
# =========================================================

source("modules/qc/qc_ui.R")

source("modules/qc/qc_server.R")

source("modules/qc/westgard_rules.R")

source("modules/qc/lot_verification_ui.R")

source("modules/qc/lot_verification_server.R")

source("modules/qc/amr_ui.R")

source("modules/qc/amr_server.R")

source("modules/qc/delta_check_ui.R")

source("modules/qc/delta_check_server.R")

# =========================================================
# LOAD WORKLOAD MODULE
# =========================================================

source("modules/workload_analytics/workload_ui.R")

source("modules/workload_analytics/workload_server.R")

# =========================================================
# LOAD TRANSFUSION MODULE
# =========================================================

source(
  "modules/transfusion/grouping_ui.R"
)

source(
  "modules/transfusion/grouping_server.R"
)

source(
  "modules/transfusion/antibody_screen_ui.R"
)

source(
  "modules/transfusion/antibody_screen_server.R"
)

source(
  "modules/transfusion/panel_ui.R"
)

source(
  "modules/transfusion/panel_server.R"
)



source(
  "modules/transfusion/lot_registration_server.R"
)

source(
  "modules/transfusion/history_ui.R"
)

source(
  "modules/transfusion/history_server.R"
)

# =========================================================
# LOAD REAGENT MODULE
# =========================================================

source("modules/reagents/reagents_ui.R")

source("modules/reagents/reagents_server.R")

# =========================================================
# LOAD REPORT MODULE
# =========================================================

source("modules/reports/reports_ui.R")

source("modules/reports/reports_server.R")



# =========================================================
# DASHBOARD UI
# =========================================================

ui <- dashboardPage(
  
  dark = TRUE,   # default light mode
  
  header = bs4DashNavbar(
    
    skin = "dark",
    
    border = FALSE,
    
    sidebarIcon = icon("bars"),
    
    controlbarIcon = icon("moon"),
    
    title = "MJB",
    
    titleWidth = "100%"
    
  ),
  
  dashboardSidebar(
    collapsed = TRUE,

  title = "",

  tags$div(

    class = "sidebar-brand",

    #   tags$img(src = "logo.png",class = "sidebar-logo"),

    #  tags$div(class = "sidebar-org-name","JCRC")

  ),
    
    sidebarMenu(
      
      menuItem(
        "Dashboard Home",
        tabName="home",
        icon=icon("house")
      ),
      
      menuItem(
        "Workload Analytics",
        tabName="workload",
        icon=icon("chart-line")
      ),
      
      menuItem(
        
        "QC Monitoring",
        
        icon=icon("flask"),
        
        startExpanded=TRUE,
        
        menuSubItem(
          "Levy Jennings",
          tabName="qc"
        ),
        
        menuSubItem(
          "Lot Verification",
          tabName="lot_verification"
        ),
        
        menuSubItem(
          "AMR / Linearity",
          tabName="amr"
        ),
        
        menuSubItem(
          "Delta Checks",
          tabName="delta"
        )
        
      ),
      
      menuItem(
        "Reagent Monitoring",
        tabName="reagents",
        icon=icon("vial")
      ),
      
      menuItem(
        "Blood Transfusion",
        tabName="btm",
        icon=icon("droplet")
      ),
      
      menuItem(
        "Reports",
        tabName="reports",
        icon=icon("file")
      )
      
    )
    
  ),
  
  dashboardBody(

  tags$head(

    tags$style(HTML("

      /* ==========================
         DASHBOARD TITLE
         ========================== */

      .dashboard-title-container{

        text-align:center;

        padding-top:5px;
        padding-bottom:10px;

      }

      .dashboard-title-main{

        font-size:28px;
        font-weight:700;

      }

      .dashboard-title-sub{

        font-size:13px;
        opacity:0.75;

        margin-top:2px;

      }

      /* Light Mode */

      body:not(.dark-mode) .dashboard-title-main,
      body:not(.dark-mode) .dashboard-title-sub{

        color:#1f2937;

      }

      /* Dark Mode */

      .dark-mode .dashboard-title-main,
      .dark-mode .dashboard-title-sub{

        color:white;

      }

    ")),

    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "custom.css"
    )

  ),

  ####################################################
  # DASHBOARD HEADER
  ####################################################

  tags$div(

    class = "dashboard-title-container",

    tags$div(
      class = "dashboard-title-main",
      "JCRC Hematology & BTM Dashboard"
    ),

    tags$div(
      class = "dashboard-title-sub",
      "• Quality Control | • Reference Ranges | • DAIDS Toxicity Grading  | • Laboratory Analytics"
    )

  ),

  useShinyjs(),

  ####################################################
  # MODULES
  ####################################################

  tabItems(

    home_ui("home"),

    workload_ui("workload"),

    qc_ui("qc"),

    lot_verification_ui("lot_verification"),

    amr_ui("amr"),

    delta_check_ui("delta"),

    reagents_ui("reagents"),

    btm_ui("btm"),

    reports_ui("reports")

  )

)
  
)

# =========================================================
# SERVER
# =========================================================

server <- function(input, output, session){
  
  home_server(
    id="home",
    pool=pool
  )
  
  workload_server(
    id="workload",
    pool=pool
  )
  
  qc_server(
    id="qc",
    pool=pool
  )
  
  lot_verification_server(
    id="lot_verification",
    pool=pool
  )
  
  delta_check_server(
    id="delta",
    pool=pool
  )
  
  reagents_server(
    id="reagents",
    pool=pool
  )
  
  btm_server(
    
    id="btm",
    
    pool=pool
    
  )
  
  reports_server(
    id="reports",
    pool=pool
  )
  
}

# =========================================================
# RUN APP
# =========================================================

shinyApp(
  ui,
  server,
  options = list(
    host = "0.0.0.0",
    port = 3838
  )
)