# =========================================================
# FILE: config/db_connection.R
# PURPOSE:
# PostgreSQL Connection
# =========================================================

pool <- dbPool(
  
  drv = RPostgres::Postgres(),
  
  dbname = "jcrc_hematology_db",
  
  host = "localhost",
  
  port = 5432,
  
  user = "postgres",
  
  password = "Qt22qt77!,."
  
)

print("PostgreSQL Connected Successfully")