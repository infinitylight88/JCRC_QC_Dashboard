# =====================================================
# FILE: workload_server.R
# =====================================================

library(shiny)

library(readxl)

library(plotly)

library(DT)

library(dplyr)

library(tidyr)

library(stringr)

source("helpers/lims_cleaner.R")

# =====================================================
# SERVER
# =====================================================

workload_server <- function(id,pool=NULL){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      ns <- session$ns
      
      # =====================================================
      # STORAGE
      # =====================================================
      
      lims_data <- reactiveVal(NULL)
      
      raw_lims <- reactiveVal(NULL)
      
      selected_accession <- reactiveVal(NULL)
      
      # =====================================================
      # EXCEL UPLOAD
      # =====================================================
      
      observeEvent(
        
        input$lims_file,
        
        {
          
          req(input$lims_file)
          
          withProgress(
            
            message="Reading LIMS Export",
            
            value=0,
            
            {
              
              incProgress(.15)
              
              raw <-
                
                read_excel(
                  
                  input$lims_file$datapath,
                  
                  skip=2
                  
                )
              
              raw_lims(raw)
              
              incProgress(.45)
              
              cleaned <-
                
                clean_lims_data(
                  
                  raw
                  
                )
              
              incProgress(.75)
              
              processed <-
                
                build_accession_table(
                  
                  cleaned
                  
                )
              
              lims_data(
                
                processed
                
              )
              
              incProgress(1)
              
            }
            
          )
          
        }
        
      )
      
      
      
      # =====================================================
      # CARD HELPER
      # =====================================================
      
      make_card <- function(value,title,color){
        
        valueBox(
          
          value,
          
          title,
          
          color=color,
          
          width=NULL
          
        )
        
      }
      
      # =====================================================
      # CARD 1 CBC
      # =====================================================
      
      output$cbc_card <- renderValueBox({
        
        req(lims_data())
        
        df <- lims_data()
        
        cbc_diff <-
          
          sum(
            
            str_detect(
              
              toupper(df$test_name),
              
              "CBC/DIFF"
              
            )
            
          )
        
        ret <-
          
          sum(
            
            str_detect(
              
              toupper(df$test_name),
              
              "RET"
              
            )
            
          )
        
        total <- cbc_diff + ret
        
        valueBox(
          
          paste0(total),
          
          subtitle=paste(
            
            "DIFF:",cbc_diff,
            
            "| RET:",ret
            
          ),
          
          icon=icon("vial"),
          
          color="primary"
          
        )
        
      })
      
      # =====================================================
      # GENERIC TEST COUNTS
      # =====================================================
      
      count_test <- function(pattern){
        
        req(lims_data())
        
        sum(
          
          str_detect(
            
            toupper(
              
              lims_data()$test_name
              
            ),
            
            toupper(pattern)
            
          )
          
        )
        
      }
      
      output$bs_card <- renderValueBox({
        
        make_card(
          
          count_test("BS"),
          
          "B/S",
          
          "success"
          
        )
        
      })
      
      output$hgb_card <- renderValueBox({
        
        make_card(
          
          count_test("HGB"),
          
          "HGB ELECT",
          
          "warning"
          
        )
        
      })
      
      output$esr_card <- renderValueBox({
        
        make_card(
          
          count_test("ESR"),
          
          "ESR",
          
          "info"
          
        )
        
      })
      
      output$mrdt_card <- renderValueBox({
        
        make_card(
          
          count_test("MRDT"),
          
          "MRDT",
          
          "danger"
          
        )
        
      })
      
      output$abo_card <- renderValueBox({
        
        make_card(
          
          count_test("ABO"),
          
          "ABO SCREEN",
          
          "purple"
          
        )
        
      })
      
      output$crossmatch_card <- renderValueBox({
        
        make_card(
          
          count_test("CROSS"),
          
          "CROSSMATCH",
          
          "olive"
          
        )
        
      })
      
      output$scd_card <- renderValueBox({
        
        make_card(
          
          count_test("SCD"),
          
          "SCD",
          
          "teal"
          
        )
        
      })
      
      output$film_card <- renderValueBox({
        
        make_card(
          
          count_test("FILM"),
          
          "FILM COMM",
          
          "maroon"
          
        )
        
      })
      
      output$dcombs_card <- renderValueBox({
        
        make_card(
          
          count_test("DCOMBS"),
          
          "DCOMBS",
          
          "fuchsia"
          
        )
        
      })
      
      # =====================================================
      # PIE
      # =====================================================
      
      output$test_distribution <- renderPlotly({
        
        req(lims_data())
        
        x <-
          
          lims_data() %>%
          
          count(test_name)
        
        plot_ly(
          
          x,
          
          labels=~test_name,
          
          values=~n,
          
          type="pie"
          
        )
        
      })
      
      # =====================================================
      # STUDY GRAPH
      # =====================================================
      
      output$study_distribution <- renderPlotly({
        
        req(lims_data())
        
        x <-
          
          lims_data() %>%
          
          count(study)
        
        plot_ly(
          
          x,
          
          x=~study,
          
          y=~n,
          
          type="bar",
          
          text=~paste(
            
            "Count:",n
            
          ),
          
          hoverinfo="text"
          
        )
        
      })
      
      # =====================================================
      # TABLE
      # =====================================================
      
      output$cleaned_table <- renderDT({
        
        req(lims_data())
        
        df <- lims_data()
        
        # FIX LIST / OBJECT ISSUE
        df[] <- lapply(df, function(x) {
          if (is.list(x)) {
            sapply(x, function(i) paste(i, collapse = ", "))
          } else {
            x
          }
        })
        
        datatable(
          df,
          selection = "single",
          options = list(
            pageLength = 20,
            scrollX = TRUE
          )
        )
      })
      
      # =====================================================
      # ROW CLICK
      # =====================================================
      
      observeEvent(
        
        input$cleaned_table_rows_selected,
        
        {
          
          req(
            
            input$cleaned_table_rows_selected
            
          )
          
          row <-
            
            lims_data()[
              
              input$cleaned_table_rows_selected,
              
            ]
          
          selected_accession(
            
            row$accession_number
            
          )
          
        }
        
      )
      
      # =====================================================
      # SELECTED INFO
      # =====================================================
      
      output$selected_accession_info <- renderUI({
        
        req(
          
          selected_accession()
          
        )
        
        HTML(
          
          paste0(
            
            "<h4>Accession: ",
            
            selected_accession(),
            
            "</h4>"
            
          )
          
        )
        
      })
      
      # =====================================================
      # CBC RESULTS
      # =====================================================
      
      output$cbc_results <- renderDT({
        
        req(
          
          selected_accession(),
          
          raw_lims()
          
        )
        
        raw_lims() %>%
          
          filter(
            
            `Accession No`==selected_accession()
            
          ) %>%
          
          filter(
            
            str_detect(
              
              toupper(`Test Name`),
              
              "CBC"
              
            )
            
          ) %>%
          
          select(
            
            `Test Variable`,
            
            Result
            
          )
        
      })
      
      # =====================================================
      # OTHER RESULTS
      # =====================================================
      
      output$other_results <- renderDT({
        
        req(
          
          selected_accession(),
          
          raw_lims()
          
        )
        
        raw_lims() %>%
          
          filter(
            
            `Accession No`==selected_accession()
            
          ) %>%
          
          filter(
            
            !str_detect(
              
              toupper(`Test Name`),
              
              "CBC"
              
            )
            
          ) %>%
          
          select(
            
            `Test Name`,
            
            `Test Variable`,
            
            Result
            
          )
        
      })
      
    }
    
  )

}