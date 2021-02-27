###################################################################
# Calling libraries
###################################################################
library(readxl)
library(tidyverse)

###############################################################
# Reading in data
###############################################################
crosswalk <- read_excel("ratingarea_county_crosswalk.xlsx", sheet = "temp", col_types = c("text", "text", "text", "text", "text"))
#crosswalk$county_code <- as.integer(crosswalk$county_code)
crosswalk <- as.data.frame(cbind(crosswalk$ratingarea, crosswalk$county_code, crosswalk$state_fips))
colnames(crosswalk) <- c("rating_area", "county_code", "state_fips")

aca_2015 <- read_excel("2015-Issuer-Data-Final_.xlsx", sheet = "2015 Issuer")
aca_2015 <- as.data.frame(cbind(aca_2015$issuer_hios_id, aca_2015$tenant_id, aca_2015$plcy_county_fips_code, aca_2015$ever_enrolled_plan_sel))
colnames(aca_2015) <- c("issuer_id", "state", "county_code", "enrollment_count")
aca_2015 <- merge(crosswalk, aca_2015, by = "county_code")
aca_2015$rating_area <- paste(aca_2015$state_fips, aca_2015$rating_area, sep = "")
aca_2015 <- subset(aca_2015, aca_2015$state!="AK" & aca_2015$state!="NE")
aca_2015$enrollment_count <- as.numeric(as.character(aca_2015$enrollment_count))

aca_2016 <- read_excel("2016-Enrollment-Disenrollment-Report.xlsx", sheet = "M2_S")
aca_2016 <- as.data.frame(cbind(aca_2016$`HIOS ID`, aca_2016$`Tenant ID`, aca_2016$`Policy County FIPS Code`, aca_2016$`Ever Enrolled Count`))
colnames(aca_2016) <- c("issuer_id", "state", "county_code", "enrollment_count")
aca_2016 <- merge(crosswalk, aca_2016, by = "county_code")
aca_2016$rating_area <- paste(aca_2016$state_fips, aca_2016$rating_area, sep = "")
aca_2016 <- subset(aca_2016, aca_2016$state!="AK" & aca_2016$state!="NE")
aca_2016$enrollment_count <- as.numeric(as.character(aca_2016$enrollment_count))

###############################################################
# Defining functions
###############################################################

calc_hhi_helper <- function(x){
  x$id_1 <- x$issuer_id
  y <- aggregate(x$enrollment_count, by=list(x$id_1), FUN=sum, na.rm=TRUE)
  colnames(y) <- c("id", "total")
  total <- sum(y$total)
  y$share <- (y$total/total)*100
  hhi <- sum(y$share^2)
  return(hhi)
}

calc_num_insurers_helper <- function(x){
  x$id_1 <- x$issuer_id
  y <- aggregate(x$enrollment_count, by=list(x$id_1), FUN=sum, na.rm=TRUE)
  colnames(y) <- c("id", "total")
  number <- nrow(y)
  return(number)
}

calc_hhi <- function(x, y) {
  data <- subset(x, county_code == y)
  hhi <- calc_hhi_helper(data)
  return(hhi) 
}

calc_num_insurers <- function(x, y) {
  data <- subset(x, county_code == y)
  num <- calc_num_insurers_helper(data)
  return(num) 
}

###############################################################
# Generating HHIs
###############################################################
counties_2015 <- unique(aca_2015$county_code, margin = 1)
hhi_2015 <- lapply(counties_2015, calc_hhi, x=aca_2015)
insurer_hhi_2015 <- do.call(rbind, Map(data.frame, county_code=counties_2015, insurer_hhi_15=hhi_2015))

counties_2016 <- unique(aca_2016$county_code, margin = 1)
hhi_2016 <- lapply(counties_2016, calc_hhi, x=aca_2016)
insurer_hhi_2016 <- do.call(rbind, Map(data.frame, county_code=counties_2016, insurer_hhi_16=hhi_2016))

num_2015 <- lapply(counties_2015, calc_num_insurers, x=aca_2015)
insurer_hhi_2015$num_insurers_15 <- unlist(do.call(rbind, Map(data.frame, num_insurers_15=num_2015)))

num_2016 <- lapply(counties_2016, calc_num_insurers, x=aca_2016)
insurer_hhi_2016$num_insurers_16 <- unlist(do.call(rbind, Map(data.frame, num_insurers_16=num_2016)))

#rm(crosswalk, aca_2015, aca_2016, counties_2015, counties_2016, hhi_2015, hhi_2016)