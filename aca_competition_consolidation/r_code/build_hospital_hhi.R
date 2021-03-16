##################################################
# Calling libraries
##################################################
library(readxl)
library(tigris)
library(ggmap)
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
crosswalk <- as.data.frame(cbind(crosswalk$ratingarea, crosswalk$county_code, crosswalk$state_fips))
colnames(crosswalk) <- c("rating_area", "county_code", "state_fips")

aha_2014 <- merge(aha_2014, crosswalk, "county_code")
aha_2014$rating_area <- paste(aha_2014$state_fips, aha_2014$rating_area, sep = "") #marking rating area with state fips, to prevent repeats
#aha_2014 <- subset(aha_2014, aha_2014$`State (physical)` %in% full_14_15$state)

#temp_14 <- geocode(location = aha_2014$`Address 1 (physical)`)
#write.csv(temp_14, "temp_14.csv")
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
#aha_2015 <- subset(aha_2015, aha_2015$`State (physical)` %in% full_15_16$state)

#temp_15 <- geocode(location = aha_2015$`Address 1 (physical)`)
#write.csv(temp_15, "temp_15.csv")
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

#defining parameters 
metro <- 10.4 + 2*8.5
non_metro <- 14.2 + 2*14.6

metro_1 <- 10.4 + 1*8.5
non_metro_1 <- 14.2 + 1*14.6

metro_2 <- 10.4 + 3*8.5
non_metro_2 <- 14.2 + 3*14.6

metro_3 <- 12.2 + 2*6.5
non_metro_3 <- 12.2 + 2*6.5

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

calc_num_hospitals_helper <- function(x){
  if (dim(x)[1] == 0) {
    return(-99) 
  }
  x$id_1 <- ifelse(is.na(x$`System ID`), x$`AHA ID`, x$`System ID`)
  y <- aggregate(x$Admissions, by=list(x$id_1), FUN=sum, na.rm=TRUE)
  number <- nrow(y)
  return(number)
}

calc_unum_hospitals_helper <- function(x){
  if (dim(x)[1] == 0) {
    return(-99) 
  }
  x$id_1 <- x$`AHA ID`
  y <- aggregate(x$Admissions, by=list(x$id_1), FUN=sum, na.rm=TRUE)
  number <- nrow(y)
  return(number)
}

calc_hhi_2014 <- function(x, y, m, n) {
  data <- aha_2014
  data$range <- ifelse(data$rucc_code<=3, m, n)
  data$new_lat <- x
  data$new_lon <- y
  data$distance <- distGeo(data.frame(data$lon, data$lat), data.frame(data$new_lon, data$new_lat))/1609.35
  data <- subset(data, data$distance <= data$range)
  hhi <- calc_hhi_helper(data)
  return(hhi)
}

calc_hhi_2015 <- function(x, y, m, n) {
  data <- aha_2015
  data$range <- ifelse(data$rucc_code<=3, m, n)
  data$new_lat <- x
  data$new_lon <- y
  data$distance <- distGeo(data.frame(data$lon, data$lat), data.frame(data$new_lon, data$new_lat))/1609.35
  data <- subset(data, data$distance <= data$range)
  hhi <- calc_hhi_helper(data)
  return(hhi)
}

calc_num_hospitals_2014 <- function(x, y) {
  data <- aha_2014
  data$range <- ifelse(data$rucc_code<=3, metro, non_metro)
  data$new_lat <- x
  data$new_lon <- y
  data$distance <- distGeo(data.frame(data$lon, data$lat), data.frame(data$new_lon, data$new_lat))/1609.35
  data <- subset(data, data$distance <= data$range)
  num <- calc_num_hospitals_helper(data)
  return(num)
}

calc_num_hospitals_2015 <- function(x, y) {
  data <- aha_2015
  data$range <- ifelse(data$rucc_code<=3, metro, non_metro)
  data$new_lat <- x
  data$new_lon <- y
  data$distance <- distGeo(data.frame(data$lon, data$lat), data.frame(data$new_lon, data$new_lat))/1609.35
  data <- subset(data, data$distance <= data$range)
  num <- calc_num_hospitals_helper(data)
  return(num)
}

calc_unum_hospitals_2014 <- function(x, y) {
  data <- aha_2014
  data$range <- ifelse(data$rucc_code<=3, metro, non_metro)
  data$new_lat <- x
  data$new_lon <- y
  data$distance <- distGeo(data.frame(data$lon, data$lat), data.frame(data$new_lon, data$new_lat))/1609.35
  data <- subset(data, data$distance <= data$range)
  num <- calc_unum_hospitals_helper(data)
  return(num)
}

calc_unum_hospitals_2015 <- function(x, y) {
  data <- aha_2015
  data$range <- ifelse(data$rucc_code<=3, metro, non_metro)
  data$new_lat <- x
  data$new_lon <- y
  data$distance <- distGeo(data.frame(data$lon, data$lat), data.frame(data$new_lon, data$new_lat))/1609.35
  data <- subset(data, data$distance <= data$range)
  num <- calc_unum_hospitals_helper(data)
  return(num)
}

###############################################################
# Generating HHIs
###############################################################
lat_2014 <- full_14_15$lat
lon_2014 <- full_14_15$lon
hhi_2014 <- mapply(calc_hhi_2014, lat_2014, lon_2014, m = metro, n = non_metro)
hhi_2014_1 <- mapply(calc_hhi_2014, lat_2014, lon_2014, m = metro_1, n = non_metro_1)
hhi_2014_2 <- mapply(calc_hhi_2014, lat_2014, lon_2014, m = metro_2, n = non_metro_2)
hhi_2014_3 <- mapply(calc_hhi_2014, lat_2014, lon_2014, m = metro_3, n = non_metro_3)
full_14_15$hospital_hhi_14 <- do.call(rbind, Map(data.frame, hospital_hhi = hhi_2014))
full_14_15$hospital_hhi_14_1 <- do.call(rbind, Map(data.frame, hospital_hhi = hhi_2014_1))
full_14_15$hospital_hhi_14_2 <- do.call(rbind, Map(data.frame, hospital_hhi = hhi_2014_2))
full_14_15$hospital_hhi_14_3 <- do.call(rbind, Map(data.frame, hospital_hhi = hhi_2014_3))

lat_2015 <- full_15_16$lat
lon_2015 <- full_15_16$lon
hhi_2015 <- mapply(calc_hhi_2015, lat_2015, lon_2015, m = metro, n = non_metro)
hhi_2015_1 <- mapply(calc_hhi_2015, lat_2015, lon_2015, m = metro_1, n = non_metro_1)
hhi_2015_2 <- mapply(calc_hhi_2015, lat_2015, lon_2015, m = metro_2, n = non_metro_2)
hhi_2015_3 <- mapply(calc_hhi_2015, lat_2015, lon_2015, m = metro_3, n = non_metro_3)
full_15_16$hospital_hhi_15 <- do.call(rbind, Map(data.frame, hospital_hhi = hhi_2015))
full_15_16$hospital_hhi_15_1 <- do.call(rbind, Map(data.frame, hospital_hhi = hhi_2015_1))
full_15_16$hospital_hhi_15_2 <- do.call(rbind, Map(data.frame, hospital_hhi = hhi_2015_2))
full_15_16$hospital_hhi_15_3 <- do.call(rbind, Map(data.frame, hospital_hhi = hhi_2015_3))

num_2014 <- mapply(calc_num_hospitals_2014, lat_2014, lon_2014)
full_14_15$num_hospitals_14 <- do.call(rbind, Map(data.frame, num_hospitals = num_2014))

num_2015 <- mapply(calc_num_hospitals_2015, lat_2015, lon_2015)
full_15_16$num_hospitals_15 <- do.call(rbind, Map(data.frame, num_hospitals = num_2015))

unum_2014 <- mapply(calc_unum_hospitals_2014, lat_2014, lon_2014)
full_14_15$unum_hospitals_14 <- do.call(rbind, Map(data.frame, unum_hospitals = unum_2014))

unum_2015 <- mapply(calc_unum_hospitals_2015, lat_2015, lon_2015)
full_15_16$unum_hospitals_15 <- do.call(rbind, Map(data.frame, unum_hospitals = unum_2015))

rm(aha_2014, aha_2015, lon_2014, lon_2015, lat_2014, lat_2015, hhi_2014, hhi_2015, num_2014, num_2015)
