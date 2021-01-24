library(tigris)
library(leaflet)
library(htmlwidgets)
library(urbnmapr)

setwd("../paper/maps")

mapping_14_15 <- sp::merge(counties, full_14_15, by.x = "county_fips", by.y = "county_code")
mapping_15_16 <- sp::merge(counties, full_15_16, by.x = "county_fips", by.y = "county_code")

mapping_14_15 %>%
  ggplot(aes(long, lat, group = group, fill = insurer_hhi_2015)) +
  geom_polygon(color = NA) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  geom_polygon(data = states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  labs(fill = "Insurer HHI") + ggtitle("Insurer HHI, 2015")

ggsave(filename = "../paper/maps/insurerHHI_2015.png", dpi = 1000)

mapping_14_15 %>%
  ggplot(aes(long, lat, group = group, fill = hospital_hhi_2014)) +
  geom_polygon(color = NA) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  geom_polygon(data = states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  labs(fill = "Hospital HHI") + ggtitle("Hospital HHI, 2014")

ggsave(filename = "../paper/maps/hospitalHHI_2014.png", dpi = 1000)

mapping_15_16 %>%
  ggplot(aes(long, lat, group = group, fill = insurer_hhi_2016)) +
  geom_polygon(color = NA) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  geom_polygon(data = states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  labs(fill = "Insurer HHI") + ggtitle("Insurer HHI, 2016")

ggsave(filename = "../paper/maps/insurerHHI_2016.png", dpi = 1000)

mapping_15_16 %>%
  ggplot(aes(long, lat, group = group, fill = hospital_hhi_2015)) +
  geom_polygon(color = NA) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  geom_polygon(data = states, mapping = aes(long, lat, group = group), fill = NA, color = "#ffffff") +
  labs(fill = "Hospital HHI") + ggtitle("Hospital HHI, 2015")

ggsave(filename = "../paper/maps/hospitalHHI_2015.png", dpi = 1000)