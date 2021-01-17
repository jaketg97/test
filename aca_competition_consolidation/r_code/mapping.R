library(urbnmapr)
library(ggplot2)
library(readxl)
library(maps)
library(dplyr)

x <- read_excel("/Volumes/GoogleDrive/My Drive/2018-2019/BA Thesis/Data/Cleaned2/total_2015_2.xlsx", sheet = "hospital_hhi_mapping", col_types = c("numeric",  "numeric"))
colnames(x)<-c("county_fips", "hospital_hhi")
hospital_hhi_2014 <- merge(x, counties, by = "county_fips") 
hospital_hhi_2014$hospital_hhi<-ifelse(hospital_hhi_2014$hospital_hhi==0, 10000, hospital_hhi_2014$hospital_hhi)
hospital_hhi_2014 %>%
  ggplot(aes(long, lat, group = group, fill = hospital_hhi)) +
  geom_polygon(color = NA) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  geom_polygon(data = states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  labs(fill = "Hospital HHI") + ggtitle("Hospital HHI, 2014")

x <- read_excel("/Volumes/GoogleDrive/My Drive/2018-2019/BA Thesis/Data/Cleaned2/total_2015_2.xlsx", sheet = "insurer_hhi", col_types = c("numeric",  "numeric"))
colnames(x)<-c("county_fips", "insurer_hhi")
insurer_hhi_2015 <- merge(x, counties, by = "county_fips") 
insurer_hhi_2015 %>%
  ggplot(aes(long, lat, group = group, fill = insurer_hhi)) +
  geom_polygon(color = NA) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  geom_polygon(data = states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  labs(fill = "Insurer HHI") + ggtitle("Insurer HHI, 2015")

x <- read_excel("/Volumes/GoogleDrive/My Drive/2018-2019/BA Thesis/Data/Cleaned2/total_2016_2.xlsx", sheet = "hospital_hhi_mapping", col_types = c("numeric",  "numeric"))
colnames(x)<-c("county_fips", "hospital_hhi")
hospital_hhi_2015 <- merge(x, counties, by = "county_fips") 
hospital_hhi_2015$hospital_hhi<-ifelse(hospital_hhi_2015$hospital_hhi==0, 10000, hospital_hhi_2015$hospital_hhi)
hospital_hhi_2015 %>%
  ggplot(aes(long, lat, group = group, fill = hospital_hhi)) +
  geom_polygon(color = NA) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  geom_polygon(data = states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  labs(fill = "Hospital HHI") + ggtitle("Hospital HHI, 2015")

x <- read_excel("/Volumes/GoogleDrive/My Drive/2018-2019/BA Thesis/Data/Cleaned2/total_2016_2.xlsx", sheet = "insurer_hhi", col_types = c("numeric",  "numeric"))
colnames(x)<-c("county_fips", "insurer_hhi")
insurer_hhi_2016 <- merge(x, counties, by = "county_fips") 
insurer_hhi_2016 %>%
  ggplot(aes(long, lat, group = group, fill = insurer_hhi)) +
  geom_polygon(color = NA) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  geom_polygon(data = states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  labs(fill = "Insurer HHI") + ggtitle("Insurer HHI, 2016")
