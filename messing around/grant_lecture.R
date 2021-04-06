if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, DBI, duckdb, bigrquery, hrbrthemes, nycflights13, glue)
## My preferred ggplot2 theme (optional)
theme_set(hrbrthemes::theme_ipsum())

###########################################
# Playing with tidyverse SQL (and raw SQL)
###########################################
con = dbConnect(duckdb::duckdb(), path = ":memory:")
copy_to(
  dest = con, 
  df = nycflights13::flights, 
  name = "flights",
  temporary = FALSE, 
  indexes = list(
    c("year", "month", "day"), 
    "carrier", 
    "tailnum",
    "dest"
  )
)
flights_db = tbl(con, "flights")
flights_db %>% select(year:day, dep_delay, arr_delay)
flights_db %>% 
  group_by(dest) %>%
  summarise(mean_dep_delay = mean(dep_delay))

tailnum_delay_db = 
  flights_db %>%
  group_by(tailnum) %>%
  summarise(
    mean_dep_delay = mean(dep_delay),
    mean_arr_delay = mean(arr_delay),
    n = n()
  ) %>%
  filter(n>100) %>% 
  arrange(desc(mean_arr_delay))

#collect (store in R environment)

tailnum_delay = 
  tailnum_delay_db %>% 
  collect()

tailnum_delay %>% 
  ggplot(aes(x=mean_dep_delay, y=mean_arr_delay, size=n)) +
  geom_point(alpha=0.3) + 
  geom_abline(intercept = 0, slope = 1, col = "orange") +
  coord_fixed()

## Some local R variables
tbl = "flights"
d_var = "dep_delay"
d_thresh = 200

## The "glued" SQL query string
sql_query =
  glue_sql("
  SELECT *
  FROM {`tbl`}
  WHERE ({`d_var`} > {d_thresh})
  LIMIT 5
  ", .con = con)

## Run the query
dbGetQuery(con, sql_query)

flights_subquery = 
  glue_sql(
    "
    SELECT tailnum, COUNT(DISTINCT dep_delay)
    FROM flights
    WHERE year = 2013 
    group by tailnum
    "
  )

dbGetQuery(con, flights_subquery)

dbDisconnect(con)

####################
# BIG QUERY TIME
####################

#setting key
usethis::edit_r_environ()
readRenviron("~/.Renviron") 

billing_id = Sys.getenv("GCE_DEFAULT_PROJECT_ID")

bq_con =
  dbConnect(
    bigrquery::bigquery(),
    project = "publicdata",
    dataset = "samples",
    billing = billing_id
  )

dbListTables(bq_con)
natality = tbl(bq_con, "natality")

bw =
  natality %>%
  filter(!is.na(state)) %>% ## optional to remove some outliers
  group_by(year) %>%
  summarise(weight_pounds = mean(weight_pounds, na.rm=TRUE))

show_query(bw)
state = "CA"

test_query =
  glue_sql(
    "
    SELECT weight_pounds
    FROM natality
    WHERE year = 1975 AND month = 1 AND day = 1 AND state = `state`
    LIMIT 1000
    
    "
  )

dbGetQuery(bq_con, test_query)
vignette('sql', package = 'dbplyr')
