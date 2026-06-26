library(shiny)
library(bs4Dash)

lot_registration_inputs_ui <- function(id){
  
  ns <- NS(id)
  
  antigens <- c(
    
    "C","D","E","c","e","Cw",
    
    "M","N",
    
    "S","s",
    
    "P1",
    
    "Lua","Lub",
    
    "K","k",
    
    "Kpa","Kpb",
    
    "Lea","Leb",
    
    "Fya","Fyb",
    
    "Jka","Jkb",
    
    "Wra",
    
    "Cob"
    
  )
  
  make_grid <- function(prefix,cells){
    
    tagList(
      
      fluidRow(
        
        column(2,strong("Antigen")),
        
        lapply(
          
          cells,
          
          function(x){
            
            column(
              
              1,
              
              strong(
                
                paste0("Cell ",x)
                
              )
              
            )
            
          }
          
        )
        
      ),
      
      hr(),
      
      lapply(
        
        antigens,
        
        function(a){
          
          fluidRow(
            
            column(
              
              2,
              
              strong(a)
              
            ),
            
            lapply(
              
              cells,
              
              function(c){
                
                column(
                  
                  1,
                  
                  selectInput(
                    
                    ns(
                      
                      paste0(
                        
                        prefix,
                        
                        "_",
                        
                        a,
                        
                        "_",
                        
                        c
                        
                      )
                      
                    ),
                    
                    NULL,
                    
                    choices=c("0","+"),
                    
                    selected="0",
                    
                    width="70px"
                    
                  )
                  
                )
                
              }
              
            )
            
          )
          
        }
        
      )
      
    )
    
  }
  
  tagList(
    
    tabsetPanel(
      
      tabPanel(
        
        "3 Cell LOT",
        
        br(),
        
        dateInput(
          
          ns("three_effective"),
          
          "Effective Date",
          
          value=Sys.Date()
          
        ),
        
        dateInput(
          
          ns("three_expiry"),
          
          "Expiry Date"
          
        ),
        
        selectInput(
          
          ns("three_tech"),
          
          "Technologist",
          
          choices=c(
            
            "Mwanje J.B",
            
            "Faith B.L",
            
            "Roodney K"
            
          )
          
        ),
        
        textInput(
          
          ns("alsevers"),
          
          "Alsevers"
          
        ),
        
        textInput(
          
          ns("cellstab"),
          
          "CellStab"
          
        ),
        
        textInput(
          
          ns("cellmedia"),
          
          "CellMedia"
          
        ),
        
        hr(),
        
        h4("3 Cell Antigen Matrix"),
        
        make_grid(
          
          "three",
          
          1:3
          
        ),
        
        br(),
        
        actionButton(
          
          ns("create3"),
          
          "Register 3 Cell LOT"
          
        )
        
      ),
      
      tabPanel(
        
        "10 Cell LOT",
        
        br(),
        
        dateInput(
          
          ns("ten_effective"),
          
          "Effective Date",
          
          value=Sys.Date()
          
        ),
        
        dateInput(
          
          ns("ten_expiry"),
          
          "Expiry Date"
          
        ),
        
        selectInput(
          
          ns("ten_tech"),
          
          "Technologist",
          
          choices=c(
            
            "Mwanje J.B",
            
            "Faith B.L",
            
            "Roodney K"
            
          )
          
        ),
        
        textInput(
          
          ns("id_alsevers"),
          
          "ID Panel Alsevers"
          
        ),
        
        textInput(
          
          ns("id_cellstab"),
          
          "ID Panel CellStab"
          
        ),
        
        textInput(
          
          ns("id_cellmedia"),
          
          "ID Panel CellMedia"
          
        ),
        
        textInput(
          
          ns("pap_alsevers"),
          
          "Papainised Alsevers"
          
        ),
        
        textInput(
          
          ns("pap_cellstab"),
          
          "Papainised CellStab"
          
        ),
        
        textInput(
          
          ns("pap_cellmedia"),
          
          "Papainised CellMedia"
          
        ),
        
        textInput(
          
          ns("lisp"),
          
          "LISP"
          
        ),
        
        hr(),
        
        h4("10 Cell Antigen Matrix"),
        
        make_grid(
          
          "ten",
          
          1:10
          
        ),
        
        br(),
        
        actionButton(
          
          ns("create10"),
          
          "Register 10 Cell LOT"
          
        )
        
      )
      
    )
    
  )
  
}