##################################################
# Calling libraries
##################################################
library(readxl)
library(tigris)

data("fips_codes")

#################################################
# Generate 2014 Hospital HHI (hospital_hhi_2014)
#################################################


x <- read_excel("AHA_2014.xlsx")
x$county <- gsub("(.*),.*", "\\1", x$`Hospital's County name`)
x$county <- paste(x$county, "County", sep=" ")
x <- merge(x, fips_codes, by.x = c("State (physical)", "county"), by.y = c("state", "county"))
x$county_code <- paste(x$state_code, x$county_code, sep = "")

crosswalk <- read_excel("ratingarea_county_crosswalk.xlsx", sheet = "temp", col_types = c("text", "text", "text", "text", "text"))
#crosswalk$county_code <- as.integer(crosswalk$county_code)
crosswalk <- as.data.frame(cbind(crosswalk$ratingarea, crosswalk$county_code, crosswalk$state_fips))
colnames(crosswalk) <- c("rating_area", "county_code", "state_fips")

x <- merge(x, crosswalk, "county_code")
x$rating_area <- paste(x$state_code, x$rating_area, sep = "") #marking rating area with state fips, to prevent repeats

x$id_1 <- ifelse(is.na(x$`System ID`), x$`AHA ID`, x$`System ID`)
x$id_2 <-paste(x$id_1, x$rating_area)
y <- aggregate(x$Admissions, by=list(x$id_2), FUN=sum, na.rm=TRUE)
colnames(y)<-c("id_2", "system_admissions")
z <- merge(x, y, "id_2")
z$dup <-duplicated(z$id_2)
z <-subset(z, z$dup==FALSE)
y <- aggregate(z$Admissions, by=list(z$rating_area), FUN=sum, na.rm=TRUE)
colnames(y) <- c("rating_area", "county_admissions")
z <- merge(z, y, "rating_area")
z$mkt_share_squared <- ((z$Admissions/z$county_admissions)*100)^2
hospital_hhi_2014 <- aggregate(z$mkt_share_squared, by=list(z$rating_area), FUN=sum, na.rm=TRUE)
colnames(hospital_hhi_2014) <- c("state_fip_rating_area", "hospital_hhi")

crosswalk$state_fip_rating_area <- paste(crosswalk$state_fips, crosswalk$rating_area, sep = "")
hospital_hhi_2014 <-merge(crosswalk, hospital_hhi_2014, "state_fip_rating_area")

#################################################
# Generate 2015 Hospital HHI (hospital_hhi_2015)
#################################################

x <- read_excel("/Volumes/GoogleDrive/My Drive/2018-2019/BA Thesis/Data/Data Cleaning/AHA Data/AHA_2015.xlsx")
crosswalk <- read_excel("Enrollment Data/crosswalk.xlsx")
colnames(crosswalk)<-c("county_code", "rating_area")
x <- merge(x, crosswalk, "county_code")
x$id_1 <- ifelse(is.na(x$`System ID`), x$`AHA ID`, x$`System ID`)
x$id_2 <-paste(x$id_1, x$rating_area)
y <- aggregate(x$Admissions, by=list(x$id_2), FUN=sum, na.rm=TRUE)
colnames(y)<-c("id_2", "system_admissions")
z <- merge(x, y, "id_2")
z$dup <-duplicated(z$id_2)
z <-subset(z, z$dup==FALSE)
y <- aggregate(z$Admissions, by=list(z$rating_area), FUN=sum, na.rm=TRUE)
colnames(y) <- c("rating_area", "county_admissions")
z <- merge(z, y, "rating_area")
z$mkt_share_squared <- ((z$Admissions/z$county_admissions)*100)^2
hospital_hhi_2015 <- aggregate(z$mkt_share_squared, by=list(z$rating_area), FUN=sum, na.rm=TRUE)
colnames(hospital_hhi_2015) <- c("rating_area", "hospital_hhi")
hospital_hhi_2015 <-merge(crosswalk, hospital_hhi_2015, "rating_area")
colnames(hospital_hhi_2015)<-c("rating_area", "fips", "hospital_hhi")
