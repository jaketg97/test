if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, DBI, duckdb, bigrquery, hrbrthemes, nycflights13, glue)
## My preferred ggplot2 theme (optional)
theme_set(hrbrthemes::theme_ipsum())
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