#################################################
# Calling libraries
#################################################
library(readxl)
library(tidyverse)

#################################################
# Generate 2015 Insurer HHI (insurer_hhi_2015)
#################################################
crosswalk <- read_excel("ratingarea_county_crosswalk.xlsx", sheet = "temp", col_types = c("text", "text", "text", "text", "text"))
#crosswalk$county_code <- as.integer(crosswalk$county_code)
crosswalk <- as.data.frame(cbind(crosswalk$ratingarea, crosswalk$county_code, crosswalk$state_fips))
colnames(crosswalk) <- c("rating_area", "county_code", "state_fips")

x <- read_excel("2015-Issuer-Data-Final_.xlsx", sheet = "2015 Issuer")
x <- as.data.frame(cbind(x$issuer_hios_id, x$tenant_id, x$plcy_county_fips_code, x$ever_enrolled_plan_sel))
colnames(x) <- c("issuer_id", "state", "county_code", "enrollment_count")
x <- merge(crosswalk, x, by = "county_code")
x$rating_area <- paste(x$state_fips, x$rating_area, sep = "")

x <- subset(x, x$state!="AK" & x$state!="NE")
x$enrollment_count <- as.integer(x$enrollment_count)
x$id <- paste(x$rating_area, x$issuer_id)
x_1 <- aggregate(x$enrollment_count, by=list(x$id), FUN=sum, na.rm=TRUE)
colnames(x_1) <- c("id", "enrollment_count")
x_2 <- merge(x_1, x, "id")
y <- aggregate(x_2$enrollment_count.x, by=list(x_2$rating_area), FUN=sum, na.rm=TRUE)
colnames(y) <- c("rating_area", "enrollment_count")
z<-merge(x_2, y, "rating_area")
z$mkt_share_squared <- ((z$enrollment_count.x/z$enrollment_count)*100)^2
insurer_hhi_2015 <- aggregate(z$mkt_share_squared, by=list(z$rating_area), FUN=sum, na.rm=TRUE)
colnames(insurer_hhi_2015) <- c("state_fip_rating_area", "insurer_hhi")

crosswalk$state_fip_rating_area <- paste(crosswalk$state_fips, crosswalk$rating_area, sep = "")
insurer_hhi_2015 <- merge(crosswalk, insurer_hhi_2015, by = "state_fip_rating_area")

#################################################
# Generate 2016 Insurer HHI (insurer_hhi_2016)
#################################################
crosswalk <- read_excel("ratingarea_county_crosswalk.xlsx", sheet = "temp", col_types = c("text", "text", "text", "text", "text"))
#crosswalk$county_code <- as.integer(crosswalk$county_code)
crosswalk <- as.data.frame(cbind(crosswalk$ratingarea, crosswalk$county_code, crosswalk$state_fips))
colnames(crosswalk) <- c("rating_area", "county_code", "state_fips")

x <- read_excel("2016-Enrollment-Disenrollment-Report.xlsx", sheet = "M2_S")
x <- as.data.frame(cbind(x$`HIOS ID`, x$`Tenant ID`, x$`Policy County FIPS Code`, x$`Ever Enrolled Count`))
colnames(x) <- c("issuer_id", "state", "county_code", "enrollment_count")
x <- merge(crosswalk, x, by = "county_code")
x$rating_area <- paste(x$state_fips, x$rating_area, sep = "")

x <- subset(x, x$state!="AK" & x$state!="NE")
x$enrollment_count <- as.integer(x$enrollment_count)
x$id <- paste(x$rating_area, x$issuer_id)
x_1 <- aggregate(x$enrollment_count, by=list(x$id), FUN=sum, na.rm=TRUE)
colnames(x_1) <- c("id", "enrollment_count")
x_2 <- merge(x_1, x, "id")
y <- aggregate(x_2$enrollment_count.x, by=list(x_2$rating_area), FUN=sum, na.rm=TRUE)
colnames(y) <- c("rating_area", "enrollment_count")
z<-merge(x_2, y, "rating_area")
z$mkt_share_squared <- ((z$enrollment_count.x/z$enrollment_count)*100)^2
insurer_hhi_2016 <- aggregate(z$mkt_share_squared, by=list(z$rating_area), FUN=sum, na.rm=TRUE)
colnames(insurer_hhi_2016) <- c("state_fip_rating_area", "insurer_hhi")

crosswalk$state_fip_rating_area <- paste(crosswalk$state_fips, crosswalk$rating_area, sep = "")
insurer_hhi_2016 <- merge(crosswalk, insurer_hhi_2016, by = "state_fip_rating_area")

rm(x, x_1, x_2, y, z, crosswalk)

