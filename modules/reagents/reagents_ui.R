# ====================================================
# REAGENT TRACKING UI
# ====================================================

library(shiny)
library(bs4Dash)
library(plotly)
library(DT)

reagents_ui <- function(id){
  
  ns <- NS(id)
  
  tabItem(
    
    tabName="reagents",
    
    fluidRow(
      
      bs4Card(
        
        title="Reagent Usage Monitoring",
        
        width=12,
        
        status="success",
        
        solidHeader=TRUE,
        
        DTOutput(ns("reagent_table"))
        
      )
      
    ),
    
    fluidRow(
      
      bs4Card(
        
        width=6,
        
        title="Usage By Lot",
        
        plotlyOutput(
          
          ns("usage_plot")
          
        )
        
      ),
      
      bs4Card(
        
        width=6,
        
        title="Remaining Reagent",
        
        plotlyOutput(
          
          ns("remaining_plot")
          
        )
        
      )
      
    )
    
  )
  
}