#####################################
# Calling libraries
#####################################
library(readxl)
library(tidyverse)
library(tigris)
library(tidycensus)
census_api_key("c06718681588c7ce50795f4242a42a42df1e2dbf")
data("fips_codes")

#####################################
# Defining functions
#####################################

add_acs_2014 <- function(x, y) {
  data <- full_14_15
  temp <- get_acs(geography = "county", variables = x, year = 2014)
  temp <- data.frame(temp$GEOID, temp$estimate)
  colnames(temp) <- c("county_code", y)
  data <- merge(data, temp, by = "county_code", all.x = TRUE)
  return(data)
}

add_acs_2015 <- function(x, y) {
  data <- full_15_16
  temp <- get_acs(geography = "county", variables = x, year = 2015)
  temp <- data.frame(temp$GEOID, temp$estimate)
  colnames(temp) <- c("county_code", y)
  data <- merge(data, temp, by = "county_code", all.x = TRUE)
  return(data)
}

full_14_15 <- add_acs_2014("S1701_C03_001E", "poverty_rate")
full_14_15 <- add_acs_2014("B01002_001E", "median_age")
full_14_15 <- add_acs_2014("B02001_001E", "total_popn")
full_14_15 <- add_acs_2014("B02001_002E", "white_popn")
full_14_15 <- add_acs_2014("B02001_003E", "black_popn")
full_14_15 <- add_acs_2014("B01001_004E", "native_popn")

full_14_15$white_popn_percent <- full_14_15$white_popn/full_14_15$total_popn
full_14_15$black_popn_percent <- full_14_15$black_popn/full_14_15$total_popn
full_14_15$native_popn_percent <- full_14_15$native_popn/full_14_15$total_popn

full_15_16 <- add_acs_2015("S1701_C03_001E", "poverty_rate")
full_15_16 <- add_acs_2015("B01002_001E", "median_age")
full_15_16 <- add_acs_2015("B02001_001E", "total_popn")
full_15_16 <- add_acs_2015("B02001_002E", "white_popn")
full_15_16 <- add_acs_2015("B02001_003E", "black_popn")
full_15_16 <- add_acs_2015("B01001_004E", "native_popn")

full_15_16$white_popn_percent <- full_15_16$white_popn/full_15_16$total_popn
full_15_16$black_popn_percent <- full_15_16$black_popn/full_15_16$total_popn
full_15_16$native_popn_percent <- full_15_16$native_popn/full_15_16$total_popn



