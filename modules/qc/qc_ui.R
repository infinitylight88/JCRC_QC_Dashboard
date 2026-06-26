# =========================================================
# FILE: qc_ui.R
# =========================================================

library(shiny)
library(bs4Dash)
library(plotly)
library(DT)

# =========================================================
# QC UI MODULE
# =========================================================

qc_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(
    
    tabName = "qc",
    
    # =====================================================
    # TITLE
    # =====================================================
    
    fluidRow(
      
      bs4Card(
        
        width = 12,
        
        title = "Quality Control Monitoring",
        
        status = "danger",
        
        solidHeader = TRUE,
        
        p("
          Monitor Levy Jennings charts,
          Westgard violations,
          trends,
          shifts,
          and QC performance.
        ")
        
      )
      
    ),
    
    # =====================================================
    # FILTERS
    # =====================================================
    
    fluidRow(
      
      bs4Card(
        
        width = 12,
        
        title = "QC Filters",
        
        status = "primary",
        
        solidHeader = TRUE,
        
        fluidRow(
          
          column(
            
            width = 4,
            
            selectInput(
              
              ns("parameter"),
              
              "Select Parameter",
              
              choices = c(
                "WBC",
                "RBC",
                "HGB",
                "PLT",
                "MCV"
              )
              
            )
            
          ),
          
          column(
            
            width = 4,
            
            selectInput(
              
              ns("qc_level"),
              
              "QC Level",
              
              choices = c(
                "LOW",
                "NORMAL",
                "HIGH"
              )
              
            )
            
          ),
          
          column(
            
            width = 4,
            
            numericInput(
              
              ns("days"),
              
              "Days to Display",
              
              value = 20,
              
              min = 5,
              
              max = 100
              
            )
            
          )
          
        )
        
      )
      
    ),
    
    # =====================================================
    # LEVY JENNINGS
    # =====================================================
    
    fluidRow(
      
      bs4Card(
        
        width = 8,
        
        title = "Levy Jennings Chart",
        
        status = "success",
        
        solidHeader = TRUE,
        
        plotlyOutput(ns("levy_plot"))
        
      ),
      
      bs4Card(
        
        width = 4,
        
        title = "QC Interpretation",
        
        status = "warning",
        
        solidHeader = TRUE,
        
        htmlOutput(ns("qc_interpretation"))
        
      )
      
    ),
    
    # =====================================================
    # QC TABLE
    # =====================================================
    
    fluidRow(
      
      bs4Card(
        
        width = 12,
        
        title = "QC Results Table",
        
        status = "info",
        
        solidHeader = TRUE,
        
        DTOutput(ns("qc_table"))
        
      )
      
    )
    
  )
}