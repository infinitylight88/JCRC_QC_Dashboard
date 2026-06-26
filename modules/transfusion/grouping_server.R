# =========================================================
# FILE:
# modules/transfusion/grouping_server.R
# =========================================================

library(shiny)
library(DBI)

grouping_server <- function(id,pool, registration = reactive(NULL)){
  
  moduleServer(
    
    id,
    
    function(input,output,session){
      
      # =====================================================
      # SAVE GROUPING
      # =====================================================
      
      observeEvent(input$save_grouping,{
        req(registration())

        # Fetch registered case details from DB to associate grouping
        case_id <- registration()$case_id
        case_info <- DBI::dbGetQuery(
          pool,
          "SELECT * FROM transfusion_cases WHERE case_id=$1",
          params = list(case_id)
        )

        req(nrow(case_info) == 1)

        accession <- case_info$accession_number[1]
        patient_id <- case_info$patient_id[1]
        patient_age <- case_info$patient_age[1]
        doctor_name <- case_info$doctor_name[1]
        technologist <- case_info$technologist[1]

        # Simple interpretation helpers
        pos <- function(r) r %in% c("1+","2+","3+","4+","w+")

        # Forward ABO
        a_pos <- pos(input$anti_a)
        b_pos <- pos(input$anti_b)
        forward_group <- if(a_pos && !b_pos) "A"
        else if(b_pos && !a_pos) "B"
        else if(a_pos && b_pos) "AB"
        else if(!a_pos && !b_pos) "O"
        else "Undetermined"

        # Reverse ABO (patient plasma vs reagent cells)
        a_cell_pos <- pos(input$a_cells)
        b_cell_pos <- pos(input$b_cells)
        reverse_group <- if(a_cell_pos && !b_cell_pos) "B"
        else if(b_cell_pos && !a_cell_pos) "A"
        else if(a_cell_pos && b_cell_pos) "O"
        else if(!a_cell_pos && !b_cell_pos) "AB"
        else "Undetermined"

        # Rh
        rh <- if(pos(input$anti_d)) "+" else "-"

        final_group <- if(forward_group == reverse_group) paste0(forward_group, rh) else paste0("DISCREPANT (", forward_group, "/", reverse_group, ")")

        DBI::dbExecute(
          pool,
          "INSERT INTO abo_grouping_results(
            accession_number, patient_id, patient_age, doctor_name, technologist,
            anti_a, anti_b, anti_d, a_cells, b_cells, o_cells, auto_control,
            forward_group, reverse_group, final_group, case_id)
           VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)",
          params = list(
            accession, patient_id, patient_age, doctor_name, technologist,
            input$anti_a, input$anti_b, input$anti_d,
            input$a_cells, input$b_cells, input$o_cells, input$auto_control,
            forward_group, reverse_group, final_group, case_id
          )
        )

        output$group_result <- renderText({
          paste0("Forward: ", forward_group, " | Reverse: ", reverse_group, " | Final: ", final_group)
        })

        showNotification("ABO Grouping Saved", type = "message")

      })

    }
  
  )

}