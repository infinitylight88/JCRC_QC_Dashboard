# =====================================================
# PDF REPORT GENERATOR
# =====================================================

library(rmarkdown)

generate_pdf_report <- function(
    
  file,
  
  report_type
  
){
  
  temp <- tempfile(
    
    fileext=".Rmd"
    
  )
  
  writeLines(
    
    c(
      
      "---",
      
      "title: 'Dashboard Report'",
      
      "output: pdf_document",
      
      "---",
      
      "",
      
      paste(
        
        "#",
        
        report_type
        
      ),
      
      "",
      
      paste(
        
        "Generated:",
        
        Sys.time()
        
      )
      
    ),
    
    temp
    
  )
  
  rmarkdown::render(
    
    temp,
    
    output_file=file,
    
    quiet=TRUE
    
  )
  
}