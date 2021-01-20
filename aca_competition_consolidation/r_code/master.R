#################################################
# MASTER FILE
#################################################

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(stargazer)

#################################################
# Building clean dataset
#################################################

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

#getting geodata for counties (from google)
#temp_c_14 <- geocode(location = full_14_15$county)
#write.csv(temp_c_14, "temp_c_14.csv")
temp_c_14 <- read.csv("temp_c_14.csv")
full_14_15$lon <- temp_c_14$lon
full_14_15$lat <- temp_c_14$lat

temp_c_15 <- data.frame(full_14_15$county_code, full_14_15$lon, full_14_15$lat) #reusing previously pulled data
colnames(temp_c_15) <- c("county_code", "lon", "lat")
full_15_16 <- merge(x=full_15_16, y=temp_c_15, by = "county_code")

#adding rurality
rural_urban <- read_xls("ruralurbancodes2013.xls")
rural_urban$county_code <- rural_urban$FIPS
rural_urban <- data.frame(rural_urban$county_code, rural_urban$RUCC_2013)
colnames(rural_urban) <- c("county_code", "rucc_code")

full_14_15 <- merge(full_14_15, rural_urban, by="county_code")
full_15_16 <- merge(full_15_16, rural_urban, by="county_code")

#adding hospital HHI
source("../r_code/build_hospital_hhi.R")

colnames(full_14_15) = c("county_code", "state_abb", "state_name", "county_name", "insurer_hhi_2015", "county_lon", "county_lat", "rucc_code_13", "hospital_hhi_2014")
colnames(full_15_16) = c("county_code", "state_abb", "state_name", "county_name", "insurer_hhi_2016", "county_lon", "county_lat", "rucc_code_13", "hospital_hhi_2015")


full_14_15$no_hospitals <- ifelse(full_14_15$hospital_hhi_2014 == -99, TRUE, FALSE)
full_14_15$hospital_hhi_2014[full_14_15$hospital_hhi_2014==-99] <- 10000
full_15_16$no_hospitals <- ifelse(full_15_16$hospital_hhi_2015 == -99, TRUE, FALSE)
full_15_16$hospital_hhi_2015[full_15_16$hospital_hhi_2015==-99] <- 10000

full_14_15$hospital_hhi_2014 <- unlist(full_14_15$hospital_hhi_2014)
full_15_16$hospital_hhi_2015 <- unlist(full_15_16$hospital_hhi_2015)

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
full_15_16$insurer_hhi_logged <- log(full_15_16$insurer_hhi_2016)
full_15_16$hospital_hhi_logged <- log(full_15_16$hospital_hhi_2015)

#adding census data
source("../r_code/add_census.R")

#putting it all together and removing shit
full_14_15$year <- 2015
full_15_16$year <- 2016
full_combined <- rbind(subset(full_14_15, select = -c(insurer_hhi_2015, hospital_hhi_2014)), subset(full_15_16, select = -c(insurer_hhi_2016, hospital_hhi_2015)))
full_combined$year.f <- factor(full_combined$year)

write.csv(full_14_15, "../clean_data/full_14_15.csv")
write.csv(full_15_16, "../clean_data/full_15_16.csv")
write.csv(full_combined, "../clean_data/full_combined.csv")

rm(insurer_hhi_2015, insurer_hhi_2016, temp_14, temp_15, temp_c_14, temp_c_15, calc_hhi, calc_hhi_2014, calc_hhi_2015, calc_hhi_helper, fips_codes, crosswalk, rural_urban)

#################################################
# Running linear models
#################################################

model_14_15 <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+rating_area.f, data=full_14_15)
model_15_16 <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+rating_area.f, data=full_15_16)
model_full <- lm(insurer_hhi_logged~hospital_hhi_logged+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+rating_area.f+year.f, data=full_combined)

#################################################
# Making tables
#################################################
stargazer(model_14_15, model_15_16, model_full, type = "latex", title = "Main results", dep.var.labels = 
            c("Logged Insurer HHI (2015)", "Logged Insurer HHI (2016)", "Logged Insurer HHI (combined)"), 
          covariate.labels = c("Logged Hospital HHI", "No hospitals in range", "Poverty rate", "Median age", "Rurality (RUCC Code)", "Year"), 
          omit = c("white_popn_percent", "black_popn_percent", "native_popn_percent", "rating_area.f"), out = "../paper/tables/main_results.tex")

binsreg(full_combined$insurer_hhi_logged, full_combined$hospital_hhi_logged, w=data.frame(c(full_combined$rating_area.f), c(full_combined$year.f), c(full_combined$rucc_code_13), c(full_combined$median_age)))
hhi_effect <- effect("hospital_hhi_logged", model_full)