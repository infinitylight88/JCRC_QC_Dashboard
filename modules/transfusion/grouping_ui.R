

# GROUPING UI 

library(shiny)

grouping_ui <- function(id){
  
  ns <- NS(id)
  
  reaction_choices <- c(
    "0",
    "w+",
    "1+",
    "2+",
    "3+",
    "4+"
  )
  
  box(
    
    width = 12,
    
    title = "ABO / Rh Grouping",
    
    status = "primary",
    
    solidHeader = TRUE,
    
    fluidRow(
      
      column(
        
        6,
        
        h4("Forward Grouping"),
        
        selectInput(
          ns("anti_a"),
          "Anti A",
          reaction_choices
        ),
        
        selectInput(
          ns("anti_b"),
          "Anti B",
          reaction_choices
        ),
        
        selectInput(
          ns("anti_d"),
          "Anti D",
          reaction_choices
        )
        
      ),
      
      column(
        
        6,
        
        h4("Reverse Grouping"),
        
        selectInput(
          ns("a_cells"),
          "A Cells",
          reaction_choices
        ),
        
        selectInput(
          ns("b_cells"),
          "B Cells",
          reaction_choices
        ),
        
        selectInput(
          ns("o_cells"),
          "O Cells",
          reaction_choices
        ),
        
        selectInput(
          ns("auto_control"),
          "Auto Control",
          reaction_choices
        )
        
      )
      
    ),
    
    hr(),
    
    h4("Automatic Interpretation"),
    
    verbatimTextOutput(
      ns("group_result")
    ),
    
    br(),
    
    actionButton(
      
      ns("save_grouping"),
      
      "Save Grouping",
      
      class = "btn-success"
      
    )
    
  )
  
}