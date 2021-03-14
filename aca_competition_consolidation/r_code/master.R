#################################################
# MASTER FILE
#################################################

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(stargazer)
library(tigris)
library(binsreg)
library(effects)
library(ggplot2)
library(ggthemes)
library(RColorBrewer)
library(rgeos)
library(dplyr)
library(car)

#################################################
# Building clean dataset
#################################################

rm(list=ls()) #clear R

#insurer HHIs
setwd("../raw_data")
source("../r_code/build_insurer_hhi.R")

#creating master datasets
data("fips_codes")
full_14_15 <- insurer_hhi_2015
full_15_16 <- insurer_hhi_2016
fips_codes$county_code <- paste(fips_codes$state_code, fips_codes$county_code, sep = "")
fips_codes$state_code <- NULL
full_14_15 <- merge(fips_codes, full_14_15, by = "county_code")
full_15_16 <- merge(fips_codes, full_15_16, by = "county_code")
full_14_15$county <- paste(full_14_15$county, full_14_15$state, sep = ", ")
full_15_16$county <- paste(full_15_16$county, full_15_16$state, sep = ", ")

#getting geodata for counties (centroid of census boundaries)
geodata <- counties(state = full_14_15$state_abb)
geodata <- subset(geodata, geodata$GEOID %in% full_14_15$county_code)
#geodata <- subset(geodata, geodata@data[["GEOID"]] %in% full_14_15$county_code)
geodata_1 <- gCentroid(spgeom = methods::as( object = geodata, Class = "Spatial"), byid = TRUE)
#geodata <- data.frame(geodata@data[["GEOID"]], geodata_1@coords)
geodata <- data.frame(geodata$GEOID, geodata_1@coords)
colnames(geodata) <- c("county_code", "lon", "lat")

full_14_15 <- merge(geodata, full_14_15, by = "county_code", keep.y = TRUE)
full_15_16 <- merge(geodata, full_15_16, by = "county_code", keep.y = TRUE)

#adding rurality
rural_urban <- read_xls("ruralurbancodes2013.xls")
rural_urban$county_code <- rural_urban$FIPS
rural_urban <- data.frame(rural_urban$county_code, rural_urban$RUCC_2013)
colnames(rural_urban) <- c("county_code", "rucc_code")

full_14_15 <- merge(full_14_15, rural_urban, by="county_code")
full_15_16 <- merge(full_15_16, rural_urban, by="county_code")

#adding hospital HHI
source("../r_code/build_hospital_hhi.R")
full_14_15$hospital_hhi_14 <- unlist(full_14_15$hospital_hhi_14)
full_15_16$hospital_hhi_15 <- unlist(full_15_16$hospital_hhi_15)
full_14_15$hospital_hhi_14_1 <- unlist(full_14_15$hospital_hhi_14_1)
full_15_16$hospital_hhi_15_1 <- unlist(full_15_16$hospital_hhi_15_1)
full_14_15$hospital_hhi_14_2 <- unlist(full_14_15$hospital_hhi_14_2)
full_15_16$hospital_hhi_15_2 <- unlist(full_15_16$hospital_hhi_15_2)
full_14_15$num_hospitals_14 <- unlist(full_14_15$num_hospitals_14)
full_15_16$num_hospitals_15 <- unlist(full_15_16$num_hospitals_15)
full_14_15$unum_hospitals_14 <- unlist(full_14_15$unum_hospitals_14)
full_15_16$unum_hospitals_15 <- unlist(full_15_16$unum_hospitals_15)

colnames(full_14_15) = c("county_code", "county_lon", "county_lat", "state_abb", "state_name", "county_name", "insurer_hhi_2015", "num_insurers", "rucc_code_13", "hospital_hhi_2014", "hospital_hhi_2014_1", "hospital_hhi_2014_2", "num_hospitals", "unum_hospitals")
colnames(full_15_16) = c("county_code", "county_lon", "county_lat", "state_abb", "state_name", "county_name", "insurer_hhi_2016", "num_insurers", "rucc_code_13", "hospital_hhi_2015", "hospital_hhi_2015_1", "hospital_hhi_2015_2", "num_hospitals", "unum_hospitals")


full_14_15$no_hospitals <- ifelse(full_14_15$hospital_hhi_2014 == -99, TRUE, FALSE)
full_14_15$no_hospitals_1 <- ifelse(full_14_15$hospital_hhi_2014_1 == -99, TRUE, FALSE)
full_14_15$no_hospitals_2 <- ifelse(full_14_15$hospital_hhi_2014_2 == -99, TRUE, FALSE)
full_14_15$num_hospitals[full_14_15$hospital_hhi_2014==-99] <- 0
full_14_15$unum_hospitals[full_14_15$hospital_hhi_2014==-99] <- 0
full_14_15$hospital_hhi_2014[full_14_15$hospital_hhi_2014==-99] <- 10000
full_14_15$hospital_hhi_2014_1[full_14_15$hospital_hhi_2014_1==-99] <- 10000
full_14_15$hospital_hhi_2014_2[full_14_15$hospital_hhi_2014_2==-99] <- 10000
full_15_16$no_hospitals <- ifelse(full_15_16$hospital_hhi_2015 == -99, TRUE, FALSE)
full_15_16$no_hospitals_1 <- ifelse(full_15_16$hospital_hhi_2015_1 == -99, TRUE, FALSE)
full_15_16$no_hospitals_2 <- ifelse(full_15_16$hospital_hhi_2015_2 == -99, TRUE, FALSE)
full_15_16$num_hospitals[full_15_16$hospital_hhi_2015==-99] <- 0
full_15_16$unum_hospitals[full_15_16$hospital_hhi_2015==-99] <- 0
full_15_16$hospital_hhi_2015[full_15_16$hospital_hhi_2015==-99] <- 10000
full_15_16$hospital_hhi_2015_1[full_15_16$hospital_hhi_2015_1==-99] <- 10000
full_15_16$hospital_hhi_2015_2[full_15_16$hospital_hhi_2015_2==-99] <- 10000

#factoring RUCC and rating areas
full_14_15$rucc_code_13.f <- factor(full_14_15$rucc_code_13)
full_15_16$rucc_code_13.f <- factor(full_15_16$rucc_code_13)
full_14_15 <- merge(full_14_15, crosswalk, by = "county_code", all.x = TRUE)
full_15_16 <- merge(full_15_16, crosswalk, by = "county_code", all.x = TRUE)
full_14_15$rating_area_state <- paste(full_14_15$state_abb, full_14_15$rating_area, sep = "")
full_15_16$rating_area_state <- paste(full_15_16$state_abb, full_15_16$rating_area, sep = "")
full_14_15$rating_area.f <- factor(full_14_15$rating_area_state)
full_15_16$rating_area.f <- factor(full_15_16$rating_area_state)

full_14_15$insurer_hhi_logged <- log(full_14_15$insurer_hhi_2015)
full_14_15$hospital_hhi_logged <- log(full_14_15$hospital_hhi_2014)
full_14_15$hospital_hhi_logged_1 <- log(full_14_15$hospital_hhi_2014_1)
full_14_15$hospital_hhi_logged_2 <- log(full_14_15$hospital_hhi_2014_2)
full_15_16$insurer_hhi_logged <- log(full_15_16$insurer_hhi_2016)
full_15_16$hospital_hhi_logged <- log(full_15_16$hospital_hhi_2015)
full_15_16$hospital_hhi_logged_1 <- log(full_15_16$hospital_hhi_2015_1)
full_15_16$hospital_hhi_logged_2 <- log(full_15_16$hospital_hhi_2015_2)

#adding census data
source("../r_code/add_census.R")

#adding region
data("state")
regions <- data.frame(state.abb, state.region)
colnames(regions) <- c("state_abb", "region")
full_14_15 <- merge(full_14_15, regions, by = "state_abb")
full_15_16 <- merge(full_15_16, regions, by = "state_abb")
full_14_15$region.f <- factor(full_14_15$region)
full_15_16$region.f <- factor(full_15_16$region)

#Add other controls
MLR_14 <- read_excel("MLR_2014.xlsx")
colnames(MLR_14) <- c("state_abb", "mlr")
full_14_15 <- merge(full_14_15, MLR_14, by = "state_abb")
MLR_15 <- read_excel("MLR_2015.xlsx")
colnames(MLR_15) <- c("state_abb", "mlr")
full_15_16 <- merge(full_15_16, MLR_15, by = "state_abb")

medicaid_2014 <- read_excel("medicaid_2014.xlsx")
colnames(medicaid_2014) <- c("state_abb", "medicaid_expansion")
full_14_15 <- merge(full_14_15, medicaid_2014, by = "state_abb")
medicaid_2015 <- read_excel("medicaid_2015.xlsx")
colnames(medicaid_2015) <- c("state_abb", "medicaid_expansion")
full_15_16 <- merge(full_15_16, medicaid_2015, by = "state_abb")

state_govt <- read_excel("state_govt.xlsx")
colnames(state_govt) <- c("state_abb", "state_govt")
full_14_15 <- merge(full_14_15, state_govt, by = "state_abb")
full_15_16 <- merge(full_15_16, state_govt, by = "state_abb")

medicare_costs_2014 <- read.csv("medicare_2014.csv")
colnames(medicare_costs_2014) <- c("county_code", "medicare_pc")
medicare_costs_2014$medicare_pc <- as.numeric(medicare_costs_2014$medicare_pc)
full_14_15 <- merge(full_14_15, medicare_costs_2014, by = "county_code")
medicare_costs_2015 <- read.csv("medicare_2015.csv")
colnames(medicare_costs_2015) <- c("county_code", "medicare_pc")
medicare_costs_2015$medicare_pc <- as.numeric(medicare_costs_2015$medicare_pc)
full_15_16 <- merge(full_15_16, medicare_costs_2015, by = "county_code")

#putting it all together and removing shit
full_14_15$year <- 2015
full_15_16$year <- 2016
full_combined <- rbind(subset(full_14_15, select = -c(insurer_hhi_2015, hospital_hhi_2014, hospital_hhi_2014_1, hospital_hhi_2014_2)), subset(full_15_16, select = -c(insurer_hhi_2016, hospital_hhi_2015, hospital_hhi_2015_1, hospital_hhi_2015_2)))
full_combined$year.f <- factor(full_combined$year)

#adding binary
full_combined$insurer_hhi <- exp(full_combined$insurer_hhi_logged)
full_combined$hospital_hhi <- exp(full_combined$hospital_hhi_logged)
full_combined$competitive_hospital <- full_combined$num_hospitals >= 5

#creating binary for single county RAs
full_14_15$rating_area_state <- as.character(full_14_15$rating_area_state)
full_15_16$rating_area_state <- as.character(full_15_16$rating_area_state)
full_combined$rating_area_state <- as.character(full_combined$rating_area_state)
county_ra_counter <- data.frame(full_14_15$rating_area.f, full_14_15$county_code, 1)
county_ra_counter <- aggregate(county_ra_counter$X1, by = county_ra_counter["full_14_15.rating_area.f"], FUN=sum)
county_ra_counter <- subset(county_ra_counter, x==1)
colnames(county_ra_counter) <- c("rating_area.f", "num")
county_ra_counter$rating_area.f <- as.character(county_ra_counter$rating_area.f)
full_combined$single_county_RA <- full_combined$rating_area_state %in% county_ra_counter$rating_area.f
full_14_15$single_county_RA <- full_14_15$rating_area_state %in% county_ra_counter$rating_area.f
full_15_16$single_county_RA <- full_15_16$rating_area_state %in% county_ra_counter$rating_area.f

#removing duplicate rows (there's one county that causes this issue due to misentered data)
full_14_15 <- unique.data.frame(full_14_15)
full_15_16 <- distinct(full_15_16)
full_combined <- distinct(full_combined)
#removing counties with withheld insurer HHI data (because of limited enrollment)
full_14_15 <- subset(full_14_15, is.na(insurer_hhi_logged)==FALSE)
full_15_16 <- subset(full_15_16, is.na(insurer_hhi_logged)==FALSE)
full_combined <- subset(full_combined, is.na(insurer_hhi_logged)==FALSE)

# interested in number of counties per rating area, and percent of counties "excluded" by at least one insurer
full_combined$RA_size <- as.numeric(lapply(full_combined$rating_area_state, function(x){sum(subset(full_combined, year.f == 2015)$rating_area_state == x)}))
selective_entry <- function(ra, num, y) {
  data <- subset(full_combined, year.f == y & rating_area_state == ra)
  max <- max(data$num_insurers)
  return(ifelse(num<max, 1, 0))
}
full_combined$excluded <- as.numeric(mapply(selective_entry, full_combined$rating_area_state, full_combined$num_insurers, full_combined$year.f))

write.csv(full_14_15, "../clean_data/full_14_15.csv", row.names = FALSE)
write.csv(full_15_16, "../clean_data/full_15_16.csv", row.names = FALSE)
write.csv(full_combined, "../clean_data/full_combined.csv", row.names = FALSE)

#################################################
# Running linear models
#################################################
library(car)
library(tidyverse)
library(data.table)
rm(list=ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("../raw_data")

full_14_15 <- read.csv("../clean_data/full_14_15.csv")
full_15_16 <- read.csv("../clean_data/full_15_16.csv")
full_combined <- read.csv("../clean_data/full_combined.csv")
full_combined$year_dummy <- ifelse(full_combined$year == 2016, 1, 0)
full_combined$rucc.f <- Recode(full_combined$rucc_code_13, "1:3 = '1-3'; 4:6 = '4-6'; 7:9 = '7-9'")
full_combined$no_hospitals <- as.integer(full_combined$no_hospitals)
full_combined$county_code.f <- factor(full_combined$county_code)
full_combined$ra_year.f <- as.factor(paste(full_combined$rating_area_state, full_combined$year, sep = " "))
full_combined$st_year.f <- as.factor(paste(full_combined$state_abb, full_combined$year, sep =" "))

model_full <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc, data=subset(full_combined, single_county_RA==FALSE))
model_full_1 <- lm(insurer_hhi_logged~hospital_hhi_logged_1+no_hospitals_1+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc, data=subset(full_combined, single_county_RA==FALSE))
model_full_2 <- lm(insurer_hhi_logged~hospital_hhi_logged_2+no_hospitals_2+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc, data=subset(full_combined, single_county_RA==FALSE))

model_full_south <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc, data=subset(full_combined, single_county_RA==FALSE & region.f=="South"))
model_full_northcentral <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc, data=subset(full_combined, single_county_RA==FALSE & region.f=="North Central"))
model_full_northeast <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc, data=subset(full_combined, single_county_RA==FALSE & region.f=="Northeast"))
model_full_west <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc, data=subset(full_combined, single_county_RA==FALSE & region.f=="West"))

model_full_13 <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc, data=subset(full_combined, single_county_RA==FALSE & rucc.f=="1-3"))
model_full_46 <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc, data=subset(full_combined, single_county_RA==FALSE & rucc.f=="4-6"))
model_full_79 <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc, data=subset(full_combined, single_county_RA==FALSE & rucc.f=="7-9"))

model_stateFE <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+st_year.f+year_dummy+medicare_pc, data=full_combined)
model_stateFE_1 <- lm(insurer_hhi_logged~hospital_hhi_logged_1+no_hospitals_1+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+st_year.f+year_dummy+medicare_pc, data=full_combined)
model_stateFE_2 <- lm(insurer_hhi_logged~hospital_hhi_logged_2+no_hospitals_2+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+st_year.f+year_dummy+medicare_pc, data=full_combined)

model_noFE <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+medicare_pc+mlr+state_govt+medicaid_expansion+year_dummy, data = full_combined)
model_noFE_1 <- lm(insurer_hhi_logged~hospital_hhi_logged_1+no_hospitals_1+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+medicare_pc+mlr+state_govt+medicaid_expansion+year_dummy, data = full_combined)
model_noFE_2 <- lm(insurer_hhi_logged~hospital_hhi_logged_2+no_hospitals_2+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+medicare_pc+mlr+state_govt+medicaid_expansion+year_dummy, data = full_combined)

model_full_region <- lm(insurer_hhi_logged~hospital_hhi_logged+hospital_hhi_logged:region.f+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc, data=subset(full_combined, single_county_RA==FALSE))
model_full_rurality <-lm(insurer_hhi_logged~hospital_hhi_logged+hospital_hhi_logged:rucc.f+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc, data=subset(full_combined, single_county_RA==FALSE))

model_num_full <- lm(num_insurers~num_hospitals+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+ra_year.f+medicare_pc+year_dummy, data=subset(full_combined, single_county_RA==FALSE))
model_num_stateFE <- lm(num_insurers~num_hospitals+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+st_year.f+year_dummy+medicare_pc+year_dummy, data=full_combined)
model_num_noFE <- lm(num_insurers~num_hospitals+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+medicare_pc+mlr+state_govt+medicaid_expansion+year_dummy, data = full_combined)

#Making diagnostic plots real quick
library(ggplot2)
library(ggthemes)
library(ggpubr)
library(ggfortify)
library(jtools)

autoplot(model_full, which = 2:2) + 
  ggtitle("Normal Q-Q")+theme_stata(scheme="s2color")
ggsave(filename = "../paper/graphs/qq_mainmodel.png", height = 4, width = 5.5, dpi = 600)

resid <- data.frame(model_full$residuals)
ggplot(data = resid, aes(x=model_full.residuals)) +
  geom_histogram(aes(y=..count../sum(..count..)), alpha=.4, position = "identity", fill="red", bins = 50) + 
  labs(title="Distribution of residuals (main model)", y="Percent", x="Residuals") +
  theme_stata(scheme="s2color") + theme(plot.title=element_text(size=10)) 
ggsave(filename = "../paper/graphs/hist_resid_mainmodel.png", height = 4, width = 5.5, dpi = 600)

#################################################
# Making tables
#################################################
library(stargazer)
# generating helper function to have cluster SE in all output
clust <- function(m, cluster="county_code.f") { return(coef(summary(m, cluster = c(cluster)))[, 2]) }

stargazer(model_full, model_stateFE, model_noFE, se = list(clust(model_full), clust(model_stateFE), clust(model_noFE)), 
          type = "latex", column.labels = c("Main model", "Boozary et al. (2019)", "Griffith et al. (2018)"), font.size = "scriptsize", dep.var.labels = "Insurer HHI (logged)", 
          covariate.labels = c("Hospital HHI (logged)", "No hospitals in market", "Rurality (RUCC code)", "Year"), 
          omit = c("white_popn_percent", "black_popn_percent", "native_popn_percent", "rating_area.f", 
                   "ra_year.f", "st_year.f", "state_abb", "poverty_rate", "median_age", "medicare_pc", "state_govt", "mlr", "medicaid_expansion"), 
          notes = c("Also controlling for rating area/year fixed effects, and county/state covariates where appropriate."), float = FALSE,
          title = "Main results", out = "../paper/tables/main_results.tex")

stargazer(model_num_full, model_num_stateFE, model_num_noFE, se = list(clust(model_num_full), clust(model_num_stateFE), clust(model_num_noFE)), 
          type = "latex", column.labels = c("Main model", "Boozary et al. (2019)", "Griffith et al. (2018)"), font.size = "scriptsize", 
          dep.var.labels = "Number of insurers", 
          covariate.labels = c("Number of hospitals", "No hospitals in market", "Rurality (RUCC code)", "Year"), 
          omit = c("white_popn_percent", "black_popn_percent", "native_popn_percent", "rating_area.f", 
                   "ra_year.f", "st_year.f", "state_abb", "poverty_rate", "median_age", "medicare_pc", "state_govt", "mlr", "medicaid_expansion"), 
          notes = c("Also controlling for rating area/year fixed effects, and county/state covariates where appropriate."), float = FALSE,
          title = "Main results", out = "../paper/tables/main_num_results.tex")

stargazer(model_full_13, model_full_46, model_full_79, se = list(clust(model_full_13), clust(model_full_46), clust(model_full_79)), 
          type = "latex", column.labels = c("RUCC 1-3", "RUCC 4-6", "RUCC 7-9"), font.size = "scriptsize", dep.var.labels = "Insurer HHI (logged)", 
          covariate.labels = c("Hospital HHI (logged)", "No hospitals in market", "Rurality (RUCC code)", "Year"), 
          omit = c("white_popn_percent", "black_popn_percent", "native_popn_percent", "rating_area.f", 
                   "ra_year.f", "st_year.f", "state_abb", "poverty_rate", "median_age", "medicare_pc", 
                   "state_govt", "mlr", "medicaid_expansion"), 
          notes = c("Also controlling for rating area/year fixed effects, and county/state covariates where appropriate."), float = FALSE,
          title = "Results by rurality (main model)", out = "../paper/tables/main_results_rucc.tex")

stargazer(model_full_south, model_full_west, model_full_northcentral, model_full_northeast, 
          se = list(clust(model_full_south), clust(model_full_west), clust(model_full_northcentral), clust(model_full_northeast)), 
          type = "latex", column.labels = c("South", "West", "North Central", "Northeast"), font.size = "scriptsize", 
          dep.var.labels = "Insurer HHI (logged)", 
          covariate.labels = c("Hospital HHI (logged)", "No hospitals in market", "Rurality (RUCC code)", "Year"), 
          omit = c("white_popn_percent", "black_popn_percent", "native_popn_percent", "rating_area.f", 
                   "ra_year.f", "st_year.f", "state_abb", "poverty_rate", "median_age", "medicare_pc",
                   "state_govt", "mlr", "medicaid_expansion"), 
          notes = c("Also controlling for rating area/year fixed effects, and county/state covariates where appropriate."), float = FALSE,
          title = "Results by region (main model)", out = "../paper/tables/main_results_region.tex")

stargazer(model_full_1, model_stateFE_1, model_noFE_1, se = list(clust(model_full_1), clust(model_stateFE_1), clust(model_noFE_1)), 
          type = "latex", column.labels = c("Main model", "Boozary et al. (2019)", "Griffith et al. (2018)"), font.size = "scriptsize", dep.var.labels = "Insurer HHI (logged)", 
          covariate.labels = c("Hospital HHI (logged)", "No hospitals in market", "Rurality (RUCC code)", "Year"), 
          omit = c("white_popn_percent", "black_popn_percent", "native_popn_percent", "rating_area.f", 
                   "ra_year.f", "st_year.f", "state_abb", "poverty_rate", "median_age", "medicare_pc", "state_govt", "mlr", "medicaid_expansion"), 
          notes = c("Also controlling for rating area/year fixed effects, and county/state covariates where appropriate."), float = FALSE,
          title = "Main results (hospital market radius one SD lower)", out = "../paper/tables/main_results_1.tex")

stargazer(model_full_2, model_stateFE_2, model_noFE_2, se = list(clust(model_full_2), clust(model_stateFE_2), clust(model_noFE_2)), 
          type = "latex", column.labels = c("Main model", "Boozary et al. (2019)", "Griffith et al. (2018)"), font.size = "scriptsize", dep.var.labels = "Insurer HHI (logged)", 
          covariate.labels = c("Hospital HHI (logged)", "No hospitals in market", "Rurality (RUCC code)", "Year"), 
          omit = c("white_popn_percent", "black_popn_percent", "native_popn_percent", "rating_area.f", 
                   "ra_year.f", "st_year.f", "state_abb", "poverty_rate", "median_age", "medicare_pc", "state_govt", "mlr", "medicaid_expansion"),
          notes = c("Also controlling for rating area/year fixed effects, and county/state covariates where appropriate."), float = FALSE,
          title = "Main results (hospital market radius one SD higher)", out = "../paper/tables/main_results_2.tex")

stargazer(model_full_rurality, model_full_region, se=list(clust(model_full_rurality), clust(model_full_region)), type = "latex", 
          column.labels = c("Rurality (RUCC code) interaction", "Region interaction"), font.size = "scriptsize", dep.var.labels = "Insurer HHI (logged)", 
          covariate.labels = c("Hospital HHI (logged)", "No hospitals in market", "Year", "Hospital HHI (logged) * RUCC code 4-6", 
                               "Hospital HHI (logged) * RUCC code 7-9", "Hospital HHI (logged) * South", "Hospital HHI (logged) * North Central",
                               "Hospital HHI (logged) * West"), float = FALSE,
          omit = c("white_popn_percent", "black_popn_percent", "rucc_code_13", "native_popn_percent", "ra_year.f", "year_dummy", "poverty_rate", "median_age", "medicare_pc"), 
          notes = c("Also controlling for rating area/year fixed effects, and county covariates.", "Coefficient for Hospital HHI (logged) centered at RUCC codes 1-3 in (1), and Northeast region in (2)"),
          out = "../paper/tables/region_rurality_results.tex", title = "Results by rurality and region (main model)")

#################################################
# Making graphs and maps
#################################################
source("../r_code/make_graphs.R")
source("../r_code/make_maps.R")

#################################################
# MISC
#################################################
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
rm(list=ls())
source("misc.R")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
rm(list=ls())
source("bootstrap_mainmodel.R")
