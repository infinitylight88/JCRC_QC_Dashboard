# =========================================================
# FILE: global.R
# PURPOSE:
# Global libraries, PostgreSQL connection pool,
# helper loading and global dashboard settings
# =========================================================

# =========================================================
# LOAD REQUIRED LIBRARIES
# =========================================================

library(shiny)

library(bs4Dash)

library(DBI)

library(RPostgres)

library(pool)

library(DT)

library(plotly)

library(ggplot2)

library(dplyr)

library(tidyr)

library(lubridate)

library(glue)

library(shinyWidgets)

library(shinycssloaders)

library(bslib)

library(echarts4r)

# =========================================================
# POSTGRESQL CONNECTION POOL
# =========================================================
# IMPORTANT:
# We use dbPool() instead of direct connections
# because Shiny applications maintain many
# simultaneous reactive database requests.
# =========================================================

# =========================================================
# POSTGRES CONNECTION
# =========================================================

pool <- dbPool(
  
  drv=RPostgres::Postgres(),
  
  dbname="jcrc_hematology_db",
  
  host="localhost",
  
  port=5432,
  
  user="postgres",
  
  password="Qt22qt77!,."
  
)

print("PostgreSQL Connected Successfully")

print(
  DBI::dbGetQuery(
    pool,
    "
    SELECT
        accession_number,
        patient_id,
        requested_test,
        test_date
    FROM transfusion_cases
    LIMIT 10
    "
  )
)

# =========================================================
# LOAD HELPER FILES
# =========================================================
lapply(list.files("modules/transfusion", full.names = TRUE), source)

source("helpers/qc_helpers.R")

source("helpers/interpretation_engine.R")

source("helpers/alert_engine.R")

source("modules/qc/westgard_rules.R")

# =========================================================
# AUTO CLOSE DATABASE POOL
# =========================================================

onStop(function() {
  
  poolClose(pool)
  
})