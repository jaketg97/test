library(tigris)
library(leaflet)
library(htmlwidgets)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("..")
full_14_15 <- read.csv("clean_data/full_14_15.csv", colClasses=c("county_code"="character"))
full_15_16 <- read.csv("clean_data/full_15_16.csv", colClasses=c("county_code"="character"))
full_combined <- read.csv("clean_data/full_combined.csv", colClasses=c("county_code"="character"))
setwd("paper/maps")

counties <- tigris::counties(state = unique(full_combined$state_abb))
mapping_14_15 <- sp::merge(counties, full_14_15, by.x = "GEOID", by.y = "county_code")
mapping_15_16 <- sp::merge(counties, full_15_16, by.x = "GEOID", by.y = "county_code")

popup <- paste0("GEOID: ", mapping_14_15$GEOID, "<br>", "Insurer HHI: ", round(mapping_14_15$insurer_hhi_2015, .01))
pal <- colorNumeric(
  palette = "YlGnBu",
  domain = mapping_14_15$insurer_hhi_2015
)

map_insurerhhi_2015 <- leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = mapping_14_15, 
              fillColor = ~pal(insurer_hhi_2015), 
              color = "#b2aeae", # you need to use hex colors
              fillOpacity = 0.7, 
              weight = 1, 
              smoothFactor = 0.2,
              popup = popup) %>%
  addLegend(pal=pal,
            values = subset(mapping_14_15$insurer_hhi_2015, mapping_14_15$insurer_hhi_2015 != "NA"), 
            position = "bottomright", 
            title = "Insurer HHI") 

saveWidget(map_insurerhhi_2015, "map_insurerhhi_2015.html")

popup <- paste0("GEOID: ", mapping_15_16$GEOID, "<br>", "Insurer HHI: ", round(mapping_15_16$insurer_hhi_2016, .01))
pal <- colorNumeric(
  palette = "YlGnBu",
  domain = mapping_15_16$insurer_hhi_2016
)

map_insurerhhi_2016 <- leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = mapping_15_16, 
              fillColor = ~pal(insurer_hhi_2016), 
              color = "#b2aeae", # you need to use hex colors
              fillOpacity = 0.7, 
              weight = 1, 
              smoothFactor = 0.2,
              popup = popup) %>%
  addLegend(pal=pal,
            values = subset(mapping_15_16$insurer_hhi_2016, mapping_15_16$insurer_hhi_2016 != "NA"), 
            position = "bottomright", 
            title = "Insurer HHI") 

saveWidget(map_insurerhhi_2016, "map_insurerhhi_2016.html")