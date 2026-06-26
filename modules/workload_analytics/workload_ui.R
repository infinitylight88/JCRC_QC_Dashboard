# =========================================================
# FILE: workload_ui.R
# =========================================================

library(shiny)

library(bs4Dash)

library(plotly)

library(DT)

# =========================================================
# WORKLOAD UI
# =========================================================

workload_ui <- function(id){
  
  ns <- NS(id)
  
  tabItem(
    
    tabName="workload",
    
    # =====================================================
    # HEADER
    # =====================================================
    
    fluidRow(
      
      bs4Card(
        
        width=12,
        
        title="Workload Analytics & LIMS Integration",
        
        status="primary",
        
        solidHeader=TRUE,
        
        p(
          
          "Upload LIMS exports, clean workload data, group tests by accession number, and analyze workload."
          
        )
        
      )
      
    ),
    
    # =====================================================
    # FILE UPLOAD
    # =====================================================
    
    fluidRow(
      
      bs4Card(
        
        width=12,
        
        title="Upload LIMS Excel Export",
        
        status="info",
        
        solidHeader=TRUE,
        
        fileInput(
          
          ns("lims_file"),
          
          "Choose Excel File",
          
          accept=c(
            
            ".xls",
            
            ".xlsx"
            
          )
          
        ),
        
        downloadButton(
          
          ns("download_cleaned"),
          
          "Download Cleaned Data"
          
        )
        
      )
      
    ),
    
    # =====================================================
    # ANALYTICS
    # =====================================================
    
    fluidRow(
      
      bs4Card(
        
        width=6,
        
        title="Distribution By Test Name",
        
        status="primary",
        
        solidHeader=TRUE,
        
        plotlyOutput(
          
          ns("test_distribution"),
          
          height="450px"
          
        )
        
      ),
      
      bs4Card(
        
        width=6,
        
        title="Study Code Analytics",
        
        status="success",
        
        solidHeader=TRUE,
        
        plotlyOutput(
          
          ns("study_distribution"),
          
          height="450px"
          
        )
        
      )
      
    ),
    
    # =====================================================
    # MAIN CLEANED TABLE
    # =====================================================
    
    fluidRow(
      
      bs4Card(
        
        width=12,
        
        title="Accession Based Workload Table",
        
        status="warning",
        
        solidHeader=TRUE,
        
        DTOutput(
          
          ns("cleaned_table")
          
        )
        
      )
      
    ),
    
    # =====================================================
    # SELECTED ACCESSION DETAILS
    # =====================================================
    
    fluidRow(
      
      bs4Card(
        
        width=12,
        
        title="Selected Accession Results",
        
        status="danger",
        
        solidHeader=TRUE,
        
        htmlOutput(
          
          ns("selected_accession_info")
          
        ),
        
        br(),
        
        h4(
          
          "CBC / Differential Results"
          
        ),
        
        DTOutput(
          
          ns("cbc_results")
          
        ),
        
        br(),
        
        h4(
          
          "Other Associated Tests"
          
        ),
        
        DTOutput(
          
          ns("other_results")
          
        )
        
      )
      
    )
    
  )

  }