if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, DBI, duckdb, bigrquery, hrbrthemes, nycflights13, glue)
## My preferred ggplot2 theme (optional)
theme_set(hrbrthemes::theme_ipsum())

billing_id = Sys.getenv("GCE_DEFAULT_PROJECT_ID")

bq_con =
  dbConnect(
    bigrquery::bigquery(),
    project = "ghtorrent-bq",
    dataset = "ght",
    billing = billing_id
  )

dbListTables(bq_con)

###########################################
# Stat 1: # of distinct teams working on 
###########################################
