library(shiny)

library(bs4Dash)

library(plotly)

library(DT)

home_ui <- function(id){
  
  ns <- NS(id)
  
  tabItem(
    
    tabName="home",
    
    ###################################################
    # CARDS
    ###################################################
    
    fluidRow(
      
      valueBoxOutput(
        ns("total_cbc"),
        width=3
      ),
      
      valueBoxOutput(
        ns("total_retics"),
        width=3
      ),
      
      valueBoxOutput(
        ns("total_studies"),
        width=3
      ),
      
      valueBoxOutput(
        ns("today_runs"),
        width=3
      )
      
    ),
    
    ###################################################
    # REAL TIME OUTPUT
    ###################################################
    
    fluidRow(
      
      box(
        
        width=12,
        
        title="SYSMEX XN550 Real-Time Output",
        
        status="primary",
        
        solidHeader=TRUE,
        
        fluidRow(
          
          column(
            
            3,
            
            dateInput(
              
              ns("from"),
              
              "From",
              
              Sys.Date()-7
              
            )
            
          ),
          
          column(
            
            3,
            
            dateInput(
              
              ns("to"),
              
              "To",
              
              Sys.Date()
              
            )
            
          ),
          
          column(
            
            2,
            
            br(),
            
            downloadButton(
              
              ns("excel_export"),
              
              "Excel"
              
            )
            
          ),
          
          column(
            
            2,
            
            br(),
            
            downloadButton(
              
              ns("pdf_export"),
              
              "PDF"
              
            )
            
          )
          
        ),
        
        hr(),
        
        DTOutput(
          
          ns("daily_workload")
          
        )
        
      )
      
    ),
    
    ###################################################
    # SELECTED RESULTS
    ###################################################
    
    fluidRow(
      
      box(
        
        width=12,
        
        title="Selected CBC Results",
        
        status="info",
        
        solidHeader=TRUE,
        
        DTOutput(
          
          ns("selected_table")
          
        )
        
      )
      
    ),
    
    ###################################################
    # CRITICAL VALUES
    ###################################################
    
    fluidRow(
      
      box(
        
        width=12,
        
        title="Critical Values Monitor",
        
        status="danger",
        
        solidHeader=TRUE,
        
        DTOutput(
          
          ns("critical_table")
          
        )
        
      )
      
    ),
    
    ###################################################
    # ANALYTICS
    ###################################################
    
    fluidRow(
      
      box(
        
        width=6,
        
        title="CBC/DIFF vs CBC/DIFF+RET",
        
        status="success",
        
        solidHeader=TRUE,
        
        plotlyOutput(
          
          ns("cbc_plot"),
          
          height="350px"
          
        )
        
      ),
      
      box(
        
        width=6,
        
        title="Study Distribution",
        
        status="warning",
        
        solidHeader=TRUE,
        
        plotlyOutput(
          
          ns("study_plot"),
          
          height="350px"
          
        )
        
      )
      
    )
    
  )
  
}