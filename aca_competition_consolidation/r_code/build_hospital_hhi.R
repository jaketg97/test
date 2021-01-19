##################################################
# Calling libraries
##################################################
library(readxl)
library(tigris)
library(geosphere)
data("fips_codes")

####################################################################
# Importing/subsetting/getting lat/lon for data
####################################################################
aha_2014 <- read_excel("AHA_2014.xlsx")
aha_2014$county <- gsub("(.*),.*", "\\1", aha_2014$`Hospital's County name`)
aha_2014$county <- paste(aha_2014$county, "County", sep=" ")
aha_2014 <- merge(aha_2014, fips_codes, by.x = c("State (physical)", "county"), by.y = c("state", "county"))
aha_2014$county_code <- paste(aha_2014$state_code, aha_2014$county_code, sep = "")

crosswalk <- read_excel("ratingarea_county_crosswalk.xlsx", sheet = "temp", col_types = c("text", "text", "text", "text", "text"))
crosswalk$county_code <- as.integer(crosswalk$county_code)
crosswalk <- as.data.frame(cbind(crosswalk$ratingarea, crosswalk$county_code, crosswalk$state_fips))
colnames(crosswalk) <- c("rating_area", "county_code", "state_fips")

aha_2014 <- merge(aha_2014, crosswalk, "county_code")
aha_2014$rating_area <- paste(aha_2014$state_fips, aha_2014$rating_area, sep = "") #marking rating area with state fips, to prevent repeats
aha_2014 <- subset(aha_2014, aha_2014$`State (physical)` %in% full_14_15$state)

#temp_14 <- geocode(location = aha_2014$`Address 1 (physical)`)
temp_14 <- read.csv("temp_14.csv")
aha_2014$lon <- temp_14$lon
aha_2014$lat <- temp_14$lat

aha_2015 <- read_excel("aha_2015.xlsx")
aha_2015$county <- gsub("(.*),.*", "\\1", aha_2015$`Hospital's County name`)
aha_2015$county <- paste(aha_2015$county, "County", sep=" ")
aha_2015 <- merge(aha_2015, fips_codes, by.x = c("State (physical)", "county"), by.y = c("state", "county"))
aha_2015$county_code <- paste(aha_2015$state_code, aha_2015$county_code, sep = "")

aha_2015 <- merge(aha_2015, crosswalk, "county_code")
aha_2015$rating_area <- paste(aha_2015$state_fips, aha_2015$rating_area, sep = "") #marking rating area with state fips, to prevent repeats
aha_2015 <- subset(aha_2015, aha_2015$`State (physical)` %in% full_15_16$state)

#temp_15 <- geocode(location = aha_2015$`Address 1 (physical)`)
temp_15 <- read.csv("temp_15.csv")
aha_2015$lon <- temp_15$lon
aha_2015$lat <- temp_15$lat

#adding rurality
rural_urban <- read_xls("ruralurbancodes2013.xls")
rural_urban$county_code <- rural_urban$FIPS
rural_urban <- data.frame(rural_urban$county_code, rural_urban$RUCC_2013)
colnames(rural_urban) <- c("county_code", "rucc_code")

aha_2014 <- merge(aha_2014, rural_urban, by="county_code")
aha_2015 <- merge(aha_2015, rural_urban, by="county_code")

#####################################################################
# Defining functions
#####################################################################

calc_hhi_helper <- function(x){
  if (dim(x)[1] == 0) {
    return(-99) 
  }
  x$id_1 <- ifelse(is.na(x$`System ID`), x$`AHA ID`, x$`System ID`)
  y <- aggregate(x$Admissions, by=list(x$id_1), FUN=sum, na.rm=TRUE)
  colnames(y) <- c("id", "total")
  total <- sum(y$total)
  y$share <- (y$total/total)*100
  hhi <- sum(y$share^2)
  return(hhi)
} 

calc_hhi_2014 <- function(x, y) {
  data <- aha_2014
  data$range <- ifelse(data$rucc_code<=3, 41.2, 45.7)
  data$new_lat <- x
  data$new_lon <- y
  data$distance <- distGeo(data.frame(data$lon, data$lat), data.frame(data$new_lon, data$new_lat))/1609.35
  data <- subset(data, data$distance <= data$range)
  hhi <- calc_hhi_helper(data)
  return(hhi)
}

calc_hhi_2015 <- function(x, y) {
  data <- aha_2015
  data$range <- ifelse(data$rucc_code<=3, 41.2, 45.7)
  data$new_lat <- x
  data$new_lon <- y
  data$distance <- distGeo(data.frame(data$lon, data$lat), data.frame(data$new_lon, data$new_lat))/1609.35
  data <- subset(data, data$distance <= data$range)
  hhi <- calc_hhi_helper(data)
  return(hhi)
}

###############################################################
# Generating HHIs
###############################################################
lat_2014 <- full_14_15$lat
lon_2014 <- full_14_15$lon
hhi_2014 <- mapply(calc_hhi_2014, lat_2014, lon_2014)
full_14_15$hospital_hhi_14 <- do.call(rbind, Map(data.frame, hospital_hhi = hhi_2014))

lat_2015 <- full_15_16$lat
lon_2015 <- full_15_16$lon
hhi_2015 <- mapply(calc_hhi_2015, lat_2015, lon_2015)
full_15_16$hospital_hhi_15 <- do.call(rbind, Map(data.frame, hospital_hhi = hhi_2015))

rm(aha_2014, aha_2015, lon_2014, lon_2015, lat_2014, lat_2015, hhi_2014, hhi_2015)
