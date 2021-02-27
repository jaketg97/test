library(urbnmapr)
library(ggplot2)
library(tidyverse)
library(grid)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("..")
full_14_15 <- read.csv("clean_data/full_14_15.csv", colClasses=c("county_code"="character"))
full_15_16 <- read.csv("clean_data/full_15_16.csv", colClasses=c("county_code"="character"))
full_combined <- read.csv("clean_data/full_combined.csv", colClasses=c("county_code"="character"))

full_14_15$county_fips <- full_14_15$county_code
full_15_16$county_fips <- full_15_16$county_code

mapping_14_15 <- left_join(select(full_14_15, -c("state_fips")), urbnmapr::counties, by="county_fips")
mapping_15_16 <- left_join(select(full_15_16, -c("state_fips")), urbnmapr::counties, by="county_fips")

mapping_14_15 %>%
  ggplot(aes(long, lat, group = group, fill = region.f)) +
  geom_polygon(color = NA) + 
  geom_polygon(data = urbnmapr::states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) + 
  labs(fill = "Region", x = "", y = "") + theme(axis.title.x=element_blank(),
  axis.text.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_blank(),
  axis.text.y=element_blank(),axis.ticks.y=element_blank()) 

ggsave(filename = "paper/maps/counties.png", height=5, width =10)

mapping_14_15 %>%
  ggplot(aes(long, lat, group = group, fill = insurer_hhi_2015)) +
  geom_polygon(color = NA) + 
  geom_polygon(data = urbnmapr::states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  labs(fill = "Insurer HHI", x = "", y = "") + theme(axis.title.x=element_blank(),
  axis.text.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_blank(),
  axis.text.y=element_blank(),axis.ticks.y=element_blank()) 

ggsave(filename = "paper/maps/insurerHHI_2015.png", height=5, width =10)

mapping_14_15 %>%
  ggplot(aes(long, lat, group = group, fill = num_insurers)) +
  geom_polygon(color = NA) + 
  geom_polygon(data = urbnmapr::states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  labs(fill = "Number of insurers", x = "", y = "") + theme(axis.title.x=element_blank(),
  axis.text.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_blank(),
  axis.text.y=element_blank(),axis.ticks.y=element_blank()) 

ggsave(filename = "paper/maps/numinsurers_2015.png", height=5, width =10)

mapping_14_15 %>%
  ggplot(aes(long, lat, group = group, fill = num_hospitals)) +
  geom_polygon(color = NA) + 
  geom_polygon(data = urbnmapr::states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  labs(fill = "Number of (independent) hospitals", x = "", y = "") + theme(axis.title.x=element_blank(),
  axis.text.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_blank(),
  axis.text.y=element_blank(),axis.ticks.y=element_blank()) 

ggsave(filename = "paper/maps/numhospitals_2014.png", height=5, width =10)

mapping_14_15 %>%
  ggplot(aes(long, lat, group = group, fill = hospital_hhi_2014)) +
  geom_polygon(color = NA) + 
  geom_polygon(data = urbnmapr::states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  labs(fill = "Hospital HHI", x = "", y = "") + theme(axis.title.x=element_blank(),
  axis.text.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_blank(),
  axis.text.y=element_blank(),axis.ticks.y=element_blank()) 

ggsave(filename = "paper/maps/hospitalHHI_2014.png", height=5, width =10)

mapping_15_16 %>%
  ggplot(aes(long, lat, group = group, fill = insurer_hhi_2016)) +
  geom_polygon(color = NA) + 
  geom_polygon(data = urbnmapr::states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  labs(fill = "Insurer HHI", x = "", y = "") + theme(axis.title.x=element_blank(),
  axis.text.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_blank(),
  axis.text.y=element_blank(),axis.ticks.y=element_blank()) 

ggsave(filename = "paper/maps/insurerHHI_2016.png", height=5, width =10)

mapping_15_16 %>%
  ggplot(aes(long, lat, group = group, fill = num_insurers)) +
  geom_polygon(color = NA) + 
  geom_polygon(data = urbnmapr::states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  labs(fill = "Number of insurers", x = "", y = "") + theme(axis.title.x=element_blank(),
  axis.text.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_blank(),
  axis.text.y=element_blank(),axis.ticks.y=element_blank()) 

ggsave(filename = "paper/maps/numinsurers_2016.png", height=5, width =10)

mapping_15_16 %>%
  ggplot(aes(long, lat, group = group, fill = num_hospitals)) +
  geom_polygon(color = NA) + 
  geom_polygon(data = urbnmapr::states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  labs(fill = "Number of (independent) hospitals", x = "", y = "") + theme(axis.title.x=element_blank(),
  axis.text.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_blank(),
  axis.text.y=element_blank(),axis.ticks.y=element_blank()) 

ggsave(filename = "paper/maps/numhospitals_2015.png", height=5, width =10)

mapping_15_16 %>%
  ggplot(aes(long, lat, group = group, fill = hospital_hhi_2015)) +
  geom_polygon(color = NA) + 
  geom_polygon(data = urbnmapr::states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  labs(fill = "Hospital HHI", x = "", y = "") + theme(axis.title.x=element_blank(),
  axis.text.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_blank(),
  axis.text.y=element_blank(),axis.ticks.y=element_blank()) 

ggsave(filename = "paper/maps/hospitalHHI_2015.png", height=5, width =10)



