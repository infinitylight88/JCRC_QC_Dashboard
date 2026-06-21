# =========================================================

# FILE: modules/home/home_server.R

# =========================================================

library(shiny)
library(bs4Dash)
library(DT)
library(plotly)
library(dplyr)
library(DBI)

home_server <- function(id, pool){
  
  moduleServer(
    
    
    id,
    
    function(input, output, session){
      
      ns <- session$ns
      
      # ===================================================
      # REFERENCE TABLES
      # ===================================================
      
      reference_table <- reactive({
        get_reference_ranges(pool)
      })
      
      daids_table <- reactive({
        get_daids_grades(pool)
      })
      
      # ===================================================
      # LOAD SAMPLES
      # ===================================================
      
      all_samples <- reactive({
        
        invalidateLater(
          900000,
          session
        )
        
        DBI::dbGetQuery(
          pool,
          "
      SELECT *
      FROM samples
      ORDER BY analyzer_date DESC,
               analyzer_time DESC
      "
        )
        
      })
      
      # ===================================================
      # LOAD RESULTS
      # ===================================================
      
      all_results <- reactive({
        
        DBI::dbGetQuery(
          pool,
          "
      SELECT *
      FROM patient_results
      "
        )
        
      })
      
      # ===================================================
      # FILTERED SAMPLES
      # ===================================================
      
      filtered_samples <- reactive({
        
        df <- all_samples()
        
        if(
          !is.null(input$accession_search) &&
          nzchar(input$accession_search)
        ){
          
          df <- df %>%
            
            filter(
              grepl(
                input$accession_search,
                accession_number,
                ignore.case = TRUE
              )
            )
          
        }
        
        df %>%
          
          arrange(
            desc(analyzer_date),
            desc(analyzer_time)
          )
        
      })
      
      # ===================================================
      # SAMPLE TABLE
      # ===================================================
      
      output$sample_table <- renderDT({
        
        x <-
          
          filtered_samples() %>%
          
          select(
            accession_number,
            patient_id,
          )
        
        datatable(
          x,
          rownames = FALSE,
          selection = "single",
          options = list(
            pageLength = 20,
            lengthChange = FALSE,
            pagingType = "simple",
            dom = "tp"
          )
        )
        
      })
      
      # ===================================================
      # AUTO SELECT FIRST ROW
      # ===================================================
      
      observe({
        
        df <- filtered_samples()
        
        req(nrow(df) > 0)
        
        proxy <- dataTableProxy(
          "sample_table",
          session = session
        )
        
        selectRows(
          proxy,
          1
        )
        
      })
      
      # ===================================================
      # SELECTED SAMPLE
      # ===================================================
      
      selected_sample <- reactive({
        
        req(input$sample_table_rows_selected)
        
        filtered_samples()[
          input$sample_table_rows_selected,
        ]
        
      })
      
      # ===================================================
      # PATIENT HEADER
      # ===================================================
      
      output$patient_header <- renderUI({
        
        req(selected_sample())
        
        s <- selected_sample()
        
        HTML(
          
          paste0(
            
            "<div style='font-size:15px;'>",
            
            "<b>Patient:</b> ",
            s$patient_name,
            
            " | <b>ID:</b> ",
            s$patient_id,
            
            " | <b>Age:</b> ",
            s$patient_age_years,
            
            " years",
            
            " | <b>Sex:</b> ",
            s$patient_sex,
            
            " | <b>Accession:</b> ",
            s$accession_number,
            
            " | <b>Study:</b> ",
            s$study_code,
            
            "</div>"
            
          )
          
        )
        
      })
      
      # ===================================================
      # RESULTS
      # ===================================================
      
      selected_results <- reactive({
        
        req(selected_sample())
        
        sid <- selected_sample()$id
        
        all_results() %>%
          
          filter(
            sample_id == sid
          )
        
      })
      
      # ===================================================
      # RESULTS WITH PATIENT INFO (JOIN)
      # ===================================================
      
      selected_results_with_patient_info <- reactive({
        
        req(selected_sample())
        req(selected_results())
        
        selected_results() %>%
          mutate(
            patient_age_years = selected_sample()$patient_age_years,
            patient_sex = selected_sample()$patient_sex
          )
        
      })
      
      # ===================================================
      # ANNOTATED RESULTS
      # ===================================================
      
      annotated_results <- reactive({
        req(selected_sample())

        normalized_sex <- normalize_sex(selected_sample()$patient_sex)

        annotate_results(
          results_df = selected_results_with_patient_info(),
          age_years = selected_sample()$patient_age_years,
          sex = normalized_sex,
          reference_table = reference_table(),
          daids_table = daids_table()
        )

      })
      
      # ===================================================
      # RESULT TABLE
      # ===================================================
      
      output$result_table <- renderDT({
        x <- annotated_results() %>%
          transmute(
            Analyte = analyte,
            Result = result_value,
            Units = units,
            Flag = Reference_Flag,
            Grade = DAIDS_Grade
          )

        dt <- datatable(
          x,
          rownames = FALSE,
          options = list(
            paging = FALSE,
            searching = FALSE,
            info = FALSE,
            ordering = FALSE,
            scrollY = "650px"
          )
        )

        dt <- formatStyle(
          dt,
          "Flag",
          target = "row",
          backgroundColor = styleEqual(
            c("LOW", "HIGH", "NORMAL"),
            c("#0D47A1", "#B26A00", "#1B5E20")
          ),
          color = styleEqual(
            c("LOW", "HIGH", "NORMAL"),
            c("white", "white", "white")
          ),
          fontWeight = "bold"
        )

        dt <- formatStyle(
          dt,
          "Grade",
          target = "row",
          backgroundColor = styleEqual(
            c(3, 4),
            c("#7B1E1E", "#D50000")
          ),
          color = styleEqual(
            c(3, 4),
            c("white", "white")
          ),
          fontWeight = "bold"
        )

        dt

      })
          

      
      # ===================================================
      # REFERENCE TABLE
      # ===================================================
      
      output$reference_table <- renderDT({
        
        req(selected_sample())
        
        build_reference_report(
          
          selected_results_with_patient_info(),
          
          age_years =
            selected_sample()$patient_age_years,
          
          sex =
            selected_sample()$patient_sex,
          
          reference_table =
            reference_table()
          
        ) %>%
          
          datatable(
            
            rownames = FALSE,
            
            options = list(
              dom = "t"
            )
            
          )
        
      })
      
      # ===================================================
      # DAIDS TABLE
      # ===================================================
      
      output$daids_table <- renderDT({
        
        annotated_results() %>%
          
          filter(
            !is.na(DAIDS_Grade)
          ) %>%
          
          select(
            analyte,
            result_value,
            DAIDS_Grade
          ) %>%
          
          datatable(
            
            rownames = FALSE,
            
            options = list(
              dom = "t"
            )
            
          )
        
      })
      
      # ===================================================
      # CRITICAL RESULTS
      # ===================================================
      
      critical_results <- reactive({
        
        annotated_results() %>%
          
          filter(
            !is.na(DAIDS_Grade),
            DAIDS_Grade >= 3
          )
        
      })
      
      # ===================================================
      # CRITICAL BANNER
      # ===================================================
      
      output$critical_banner <- renderUI({
        
        n <- nrow(
          critical_results()
        )
        
        if(n == 0){
          
          HTML(
            "<span style='color:green;font-weight:bold'>
        No Grade 3/4 Results Detected
        </span>"
          )
          
        } else {
          
          HTML(
            
            paste0(
              
              "<span style='color:red;font-weight:bold'>",
              
              n,
              
              " Critical DAIDS Grade 3/4 Results Require Review",
              
              "</span>"
              
            )
            
          )
          
        }
        
      })
      
      # ===================================================
      # KPI CARDS
      # ===================================================
      
      output$total_cbc <- renderValueBox({
        
        valueBox(
          
          sum(
            grepl(
              "CBC",
              filtered_samples()$test_type,
              ignore.case = TRUE
            )
          ),
          
          "CBC Samples",
          
          icon = icon("vial"),
          
          color = "primary"
          
        )
        
      })
      
      output$total_retics <- renderValueBox({
        
        valueBox(
          
          sum(
            grepl(
              "RET",
              filtered_samples()$test_type,
              ignore.case = TRUE
            )
          ),
          
          "Reticulocytes",
          
          icon = icon("microscope"),
          
          color = "success"
          
        )
        
      })
      
      output$total_studies <- renderValueBox({
        
        valueBox(
          
          n_distinct(
            filtered_samples()$study_code
          ),
          
          "Studies",
          
          icon = icon("flask"),
          
          color = "warning"
          
        )
        
      })
      
      output$today_runs <- renderValueBox({
        
        valueBox(
          
          sum(
            filtered_samples()$analyzer_date ==
              Sys.Date()
          ),
          
          "Today's Runs",
          
          icon = icon("clock"),
          
          color = "info"
          
        )
        
      })
      
      # ===================================================
      # WORKLOAD PIE
      # ===================================================
      
      output$cbc_plot <- renderPlotly({
        
        df <-
          
          filtered_samples() %>%
          
          count(test_type)
        
        plot_ly(
          df,
          labels = ~test_type,
          values = ~n,
          type = "pie"
        ) %>%
          layout(
            paper_bgcolor = "rgba(0,0,0,0)",
            plot_bgcolor  = "rgba(0,0,0,0)",
            font = list(
              color = "#FFFFFF"
            )
          )
        
      })
      
      # ===================================================
      # STUDY PLOT
      # ===================================================
      
      output$study_plot <- renderPlotly({
        
        df <-
          
          filtered_samples() %>%
          
          count(study_code)
        
        plot_ly(
          df,
          x = ~study_code,
          y = ~n,
          type = "bar"
        ) %>%
          layout(
            paper_bgcolor = "rgba(0,0,0,0)",
            plot_bgcolor  = "rgba(0,0,0,0)",
            font = list(
              color = "#FFFFFF"
            ),
            xaxis = list(
              color = "#FFFFFF"
            ),
            yaxis = list(
              color = "#FFFFFF"
            )
          )
        
      })
      
      # ===================================================
      # RERUN TABLE
      # ===================================================
      
      output$rerun_summary <- renderDT({
        
        reruns <-
          
          filtered_samples() %>%
          
          filter(
            !is.na(rerun_group_id)
          ) %>%
          
          group_by(
            rerun_group_id
          ) %>%
          
          summarise(
            
            accession_number =
              first(accession_number),
            
            patient_id =
              first(patient_id),
            
            runs =
              max(run_sequence),
            
            .groups = "drop"
            
          )
        
        datatable(
          
          reruns,
          
          rownames = FALSE,
          
          selection = "single",
          
          options = list(
            pageLength = 10,
            dom = "tip"
          )
          
        )
        
      })
      
    
    
        # ===================================================
        # Rerun Group
        # ===================================================

        selected_rerun <- reactive({
          
          req(
            input$rerun_summary_rows_selected
          )
          
          reruns <-
            
            filtered_samples() %>%
            
            filter(
              !is.na(rerun_group_id)
            ) %>%
            
            group_by(
              rerun_group_id
            ) %>%
            
            summarise(
              
              accession_number =
                first(accession_number),
              
              patient_id =
                first(patient_id),
              
              runs =
                max(run_sequence),
              
              .groups = "drop"
              
            )
          
          reruns[
            input$rerun_summary_rows_selected,
          ]
          
        })


      rerun_results <- reactive({
        
        req(
          selected_rerun()
        )
        
        group_id <-
          
          selected_rerun()$
          rerun_group_id
        
        runs <-
          
          filtered_samples() %>%
          
          filter(
            rerun_group_id == group_id
          )
        
        runs
  
})
      
      output$rerun_details <- renderDT({
        
        req(rerun_results())
        
        runs <- rerun_results()
        
        if(nrow(runs) < 2)
          return(NULL)
        
        comparison <- NULL
        
        for(i in seq_len(nrow(runs))){
          
          sid <- runs$id[i]
          
          seq_no <- runs$run_sequence[i]
          
          res <-
            
            all_results() %>%
            
            filter(
              sample_id == sid
            ) %>%
            
            select(
              analyte,
              result_value
            )
          
          names(res)[2] <-
            paste0(
              "Run_",
              seq_no
            )
          
          if(is.null(comparison)){
            
            comparison <- res
            
          } else {
            
            comparison <-
              
              full_join(
                comparison,
                res,
                by = "analyte"
              )
            
          }
          
        }
        
        ####################################################
        # % DIFFERENCE
        ####################################################
        
        if("Run_1" %in% names(comparison) &
           "Run_2" %in% names(comparison)){
          
          comparison <-
            
            comparison %>%
            
            mutate(
              
              Run_1_num =
                suppressWarnings(
                  as.numeric(Run_1)
                ),
              
              Run_2_num =
                suppressWarnings(
                  as.numeric(Run_2)
                ),
              
              Percent_Difference =
                
                round(
                  
                  abs(
                    Run_2_num - Run_1_num
                  ) /
                    
                    ((Run_1_num + Run_2_num)/2)
                  
                  * 100,
                  
                  2
                  
                ),
              
              Agreement = case_when(
                
                Percent_Difference <= 5
                ~ "Excellent",
                
                Percent_Difference <= 10
                ~ "Acceptable",
                
                TRUE
                ~ "Review"
                
              )
              
            )
          
        }
        
        comparison <-
          
          comparison %>%
          
          select(
            
            analyte,
            
            starts_with("Run_"),
            
            Percent_Difference,
            
            Agreement
            
          )
        
        dt <-
          
          datatable(
            
            comparison,
            
            rownames = FALSE,
            
            options = list(
              pageLength = 40,
              scrollX = TRUE,
              dom = "tip"
            )
            
          )
        
        ####################################################
        # COLOR AGREEMENT
        ####################################################
        
        dt <-
          
          formatStyle(
            
            dt,
            
            "Agreement",
            
            target = "row",
            
            backgroundColor = styleEqual(
              
              c(
                "Excellent",
                "Acceptable",
                "Review"
              ),
              
              c(
                "#1B5E20",
                "#B26A00",
                "#7B1E1E"
              )
              
            ),
            
            color = "white",
            
            fontWeight = "bold"
            
          )
        
        dt
        
      })
    }
  )}
  
  

