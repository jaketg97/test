library(readxl)
library(tigris)
library(ggmap)
library(geosphere)
library(tigris)
library(maptools)
library(urbnmapr)
library(kableExtra)
data("fips_codes")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
rm(list=ls())

####################################################################
# Write summary stats table
####################################################################
full_14_15 <- read.csv("../clean_data/full_14_15.csv")
full_15_16 <- read.csv("../clean_data/full_15_16.csv")
full_combined <- read.csv("../clean_data/full_combined.csv")
full_combined$medicaid_expansion <- ifelse(full_combined$medicaid_expansion == "Adopted", 1, 0)
full_combined$rep_state_govt <- full_combined$state_govt == "Rep"
full_combined <- subset(full_combined, single_county_RA == FALSE)
full_combined$counter = 1

names <- c("Insurer HHI", "Hospital HHI", "Number of Insurers", "Number of ind. Hospitals", "Number of Hospitals", "No Hospitals", "Poverty rate", "Median age", 
           "Percent white", "Percent Black", "Percent Native", "Medicare costs per-capita", "Counties per rating area", "Insurer \"selective entry\" rate", "Expanded Medicaid", "MLR rebate", "Republican state govt.")
vars <- c("insurer_hhi", "hospital_hhi", "num_insurers", "num_hospitals",  "unum_hospitals", "no_hospitals", "poverty_rate", "median_age", "white_popn_percent", "black_popn_percent",
          "native_popn_percent", "medicare_pc", "RA_size", "excluded", "medicaid_expansion", "mlr", "rep_state_govt")
colnames <- c("Variable", "Overall", "2015", "2016", "RUCC codes 1-3", "RUCC codes 4-6", "RUCC codes 7-9", "Northeast", "North Central", "South", "West")

sum_1 <- sum(full_combined$counter)
sum_2 <- sum(full_combined$year == 2015)
sum_3 <- sum(full_combined$year == 2016)
sum_4 <- sum(full_combined$rucc_code_13 <= 3)
sum_5 <- sum(full_combined$rucc_code_13>3 & full_combined$rucc_code_13<=6)
sum_6 <- sum(full_combined$rucc_code_13>6)
sum_7 <- sum(full_combined$region == "Northeast")
sum_8 <- sum(full_combined$region == "North Central")
sum_9 <- sum(full_combined$region == "South")
sum_10 <- sum(full_combined$region == "West")
sums <- c("Number of Observations", sum_1, sum_2, sum_3, sum_4, sum_5, sum_6, sum_7, sum_8, sum_9, sum_10)

get_means <- function(name, var) {
  mean_1 <- mean(full_combined[[var]], na.rm = TRUE)
  mean_1 <- round(mean_1, digits=3)
  sd_1 <- sd(full_combined[[var]], na.rm = TRUE)
  sd_1 <- round(sd_1, digits=3)
  mean_1 <- paste("\\makecell[t]{ ", mean_1, " \\\\ ", "{[}", sd_1,"{]}", " }")
  
  mean_2 <- mean(subset(full_combined, year == "2015")[[var]], na.rm = TRUE)
  mean_2 <- round(mean_2, digits=3)
  sd_2 <- sd(subset(full_combined, year == "2015")[[var]], na.rm = TRUE)
  sd_2 <- round(sd_2, digits=3)
  mean_2 <- paste("\\makecell[t]{ ", mean_2, " \\\\ ", "{[}", sd_2,"{]}", " }")
  
  mean_3 <- mean(subset(full_combined, year == "2016")[[var]], na.rm = TRUE)
  mean_3 <- round(mean_3, digits=3)
  sd_3 <- sd(subset(full_combined, year == "2016")[[var]], na.rm = TRUE)
  sd_3 <- round(sd_3, digits=3)
  mean_3 <- paste("\\makecell[t]{ ", mean_3, " \\\\ ", "{[}", sd_3,"{]}", " }")
  
  mean_4 <- mean(subset(full_combined, rucc_code_13 <= 3)[[var]], na.rm = TRUE)
  mean_4 <- round(mean_4, digits=3)
  sd_4 <- sd(subset(full_combined, rucc_code_13 <= 3)[[var]], na.rm = TRUE)
  sd_4 <- round(sd_4, digits=3)
  mean_4 <- paste("\\makecell[t]{ ", mean_4, " \\\\ ", "{[}", sd_4,"{]}", " }")
  
  mean_5 <- mean(subset(full_combined, rucc_code_13 > 3 & rucc_code_13 <=6)[[var]], na.rm = TRUE)
  mean_5 <- round(mean_5, digits=3)
  sd_5 <- sd(subset(full_combined, rucc_code_13 > 3 & rucc_code_13 <=6)[[var]], na.rm = TRUE)
  sd_5 <- round(sd_5, digits=3)
  mean_5 <- paste("\\makecell[t]{ ", mean_5, " \\\\ ", "{[}", sd_5,"{]}", " }")
  
  mean_6 <- mean(subset(full_combined, rucc_code_13 >= 7)[[var]], na.rm = TRUE)
  mean_6 <- round(mean_6, digits=3)
  sd_6 <- sd(subset(full_combined, rucc_code_13 >= 7)[[var]], na.rm = TRUE)
  sd_6 <- round(sd_6, digits=3)
  mean_6 <- paste("\\makecell[t]{ ", mean_6, " \\\\ ", "{[}", sd_6,"{]}", " }")
  
  mean_7 <- mean(subset(full_combined, region == "Northeast")[[var]], na.rm = TRUE)
  mean_7 <- round(mean_7, digits=3)
  sd_7 <- sd(subset(full_combined, region == "Northeast")[[var]], na.rm = TRUE)
  sd_7 <- round(sd_7, digits=3)
  mean_7 <- paste("\\makecell[t]{ ", mean_7, " \\\\ ", "{[}", sd_7,"{]}", " }")
  
  mean_8 <- mean(subset(full_combined, region == "North Central")[[var]], na.rm = TRUE)
  mean_8 <- round(mean_8, digits=3)
  sd_8 <- sd(subset(full_combined, region == "North Central")[[var]], na.rm = TRUE)
  sd_8 <- round(sd_8, digits=3)
  mean_8 <- paste("\\makecell[t]{ ", mean_8, " \\\\ ", "{[}", sd_8,"{]}", " }")
  
  mean_9 <- mean(subset(full_combined, region == "South")[[var]], na.rm = TRUE)
  mean_9 <- round(mean_9, digits=3)
  sd_9 <- sd(subset(full_combined, region == "South")[[var]], na.rm = TRUE)
  sd_9 <- round(sd_9, digits=3)
  mean_9 <- paste("\\makecell[t]{ ", mean_9, " \\\\ ", "{[}", sd_9,"{]}", " }")
  
  mean_10 <- mean(subset(full_combined, region == "West")[[var]], na.rm = TRUE)
  mean_10 <- round(mean_10, digits=3)
  sd_10 <- sd(subset(full_combined, region == "West")[[var]], na.rm = TRUE)
  sd_10 <- round(sd_10, digits=3)
  mean_10 <- paste("\\makecell[t]{ ", mean_10, " \\\\ ", "{[}", sd_10,"{]}", " }")
  
  
  return(c(name, mean_1, mean_2, mean_3, mean_4, mean_5, mean_6, mean_7, mean_8, mean_9, mean_10))
}


summary_stats <- mapply(get_means, names, vars)
summary_stats <- t(summary_stats)
colnames(summary_stats) <- colnames
summary_stats <- as.data.frame(summary_stats)

vars <- c("Overall", "2015", "2016", "RUCC codes 1-3", "RUCC codes 4-6", "RUCC codes 7-9", "Northeast", "North Central", "South", "West")
for(i in vars) {
  summary_stats[[i]] <- gsub(" ", "", summary_stats[[i]], fixed = TRUE)
}

summary_stats <- rbind(sums, summary_stats)

table <- kbl(summary_stats, "latex", booktabs = T, row.names = FALSE, escape = FALSE, linesep = "\\addlinespace", 
             centering = TRUE, align = "lcccccccccc")
table <- add_header_above(table, c("", "", "Year" = 2, "Rurality" = 3, "Region" = 4))
save_kable(table, "../paper/tables/summary_stats.tex")

####################################################################
# Getting hospital HHI change
####################################################################
full_14_15 <- read.csv("../clean_data/full_14_15.csv")
full_15_16 <- read.csv("../clean_data/full_15_16.csv")
full_combined <- read.csv("../clean_data/full_combined.csv")
full_combined$medicaid_expansion <- ifelse(full_combined$medicaid_expansion == "Adopted", 1, 0)
full_combined$rep_state_govt <- full_combined$state_govt == "Rep"
full_combined <- subset(full_combined, single_county_RA == FALSE)
full_combined$counter = 1

hospital_hhi_2014 <- data.frame(full_14_15$county_code, full_14_15$hospital_hhi_2014)
colnames(hospital_hhi_2014) <- c("county_code", "hhi_2014")
hospital_hhi_2015 <- data.frame(full_15_16$county_code, full_15_16$hospital_hhi_2015)
colnames(hospital_hhi_2015) <- c("county_code", "hhi_2015")
hhi_change <- merge(hospital_hhi_2014, hospital_hhi_2015, by = "county_code")
hhi_change$percent_change <- (hhi_change$hhi_2015-hhi_change$hhi_2014)/(hhi_change$hhi_2014)

# ####################################################################
# # Re-Importing/subsetting/getting lat/lon for data
# ####################################################################
# setwd("../raw_data")
# aha_2014 <- read_excel("AHA_2014.xlsx")
# aha_2014$county <- gsub("(.*),.*", "\\1", aha_2014$`Hospital's County name`)
# aha_2014$county <- paste(aha_2014$county, "County", sep=" ")
# aha_2014 <- merge(aha_2014, fips_codes, by.x = c("State (physical)", "county"), by.y = c("state", "county"))
# aha_2014$county_code <- paste(aha_2014$state_code, aha_2014$county_code, sep = "")
# 
# crosswalk <- read_excel("ratingarea_county_crosswalk.xlsx", sheet = "temp", col_types = c("text", "text", "text", "text", "text"))
# crosswalk <- as.data.frame(cbind(crosswalk$ratingarea, crosswalk$county_code, crosswalk$state_fips))
# colnames(crosswalk) <- c("rating_area", "county_code", "state_fips")
# 
# aha_2014 <- merge(aha_2014, crosswalk, "county_code")
# aha_2014$rating_area <- paste(aha_2014$state_fips, aha_2014$rating_area, sep = "") #marking rating area with state fips, to prevent repeats
# #aha_2014 <- subset(aha_2014, aha_2014$`State (physical)` %in% full_14_15$state)
# 
# #temp_14 <- geocode(location = aha_2014$`Address 1 (physical)`)
# #write.csv(temp_14, "temp_14.csv")
# temp_14 <- read.csv("temp_14.csv")
# aha_2014$lon <- temp_14$lon
# aha_2014$lat <- temp_14$lat
# 
# aha_2015 <- read_excel("aha_2015.xlsx")
# aha_2015$county <- gsub("(.*),.*", "\\1", aha_2015$`Hospital's County name`)
# aha_2015$county <- paste(aha_2015$county, "County", sep=" ")
# aha_2015 <- merge(aha_2015, fips_codes, by.x = c("State (physical)", "county"), by.y = c("state", "county"))
# aha_2015$county_code <- paste(aha_2015$state_code, aha_2015$county_code, sep = "")
# 
# aha_2015 <- merge(aha_2015, crosswalk, "county_code")
# aha_2015$rating_area <- paste(aha_2015$state_fips, aha_2015$rating_area, sep = "") #marking rating area with state fips, to prevent repeats
# #aha_2015 <- subset(aha_2015, aha_2015$`State (physical)` %in% full_15_16$state)
# 
# #temp_15 <- geocode(location = aha_2015$`Address 1 (physical)`)
# #write.csv(temp_15, "temp_15.csv")
# temp_15 <- read.csv("temp_15.csv")
# aha_2015$lon <- temp_15$lon
# aha_2015$lat <- temp_15$lat
# 
# #adding rurality
# rural_urban <- read_xls("ruralurbancodes2013.xls")
# rural_urban$county_code <- rural_urban$FIPS
# rural_urban <- data.frame(rural_urban$county_code, rural_urban$RUCC_2013)
# colnames(rural_urban) <- c("county_code", "rucc_code")
# 
# aha_2014 <- merge(aha_2014, rural_urban, by="county_code")
# aha_2015 <- merge(aha_2015, rural_urban, by="county_code")
# 
# full_14_15 <- read.csv("../clean_data/full_14_15.csv")
# full_15_16 <- read.csv("../clean_data/full_15_16.csv")
# full_combined <- read.csv("../clean_data/full_combined.csv")
# 
# 
# ####################################################################
# # Getting hospitals
# ####################################################################
# autuaga <- subset(full_14_15, county_code == 01001)
# 
# get_hosps <- function(x, y) {
#   data <- aha_2015
#   data$range <- ifelse(data$rucc_code<=3, 41.2, 45.7)
#   data$new_lat <- x
#   data$new_lon <- y
#   data$distance <- distGeo(data.frame(data$lon, data$lat), data.frame(data$new_lon, data$new_lat))/1609.35
#   data <- subset(data, data$distance <= data$range)
#   return(data)
# }
# 
# autuaga_hosps <- get_hosps(autuaga$county_lat, autuaga$county_lon)
# 
# autuaga_hosps %>%
#   ggplot(aes(lon, lat)) +
#   geom_polygon(color = NA)
# 
# write.csv(autuaga, "../paper/misc/HHI_example/autuaga.csv")
# write.csv(autuaga_hosps, "../paper/misc/HHI_example/autuaga_hosps.csv")
# 
# geodata <- tigris::counties(state = "AL")
# geodata <- subset(geodata, geodata@data[["GEOID"]]=="01001")
# 
