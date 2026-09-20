
#Project: CTA L Ridership Analysis, Pre and Post COVID 
#Author: Rachel Zhu
#Date: 09-17-2026


# Packages ----

library(readxl)
library(writexl)
library(dplyr)
library(sf)


# import main dataset(s) ----

station_info <- read_excel("station_info.xlsx")
census_tracts <- read_excel("census_tracts.xlsx",sheet = "Census Tracts - clean")


# convert geom points to spatial data type using sf ----
  ## parameter "crs" tells us the coordinate mapping system to use (World Geodetic System 1984)

  stations_points <- st_as_sf(station_info, wkt = 1, crs = 4326)
  cen_tracts_points_poly <- st_as_sf(census_tracts, wkt = 1 ,crs=4326)

  
# join tables of geospatial points from census tracts and stations ----
  
  stations_tracts_joined_points <- st_join(stations_points, cen_tracts_points_poly, join = st_within, left=TRUE)


# plot of geospatial data ----
  ## CTA station points within census tract borders
  plot(st_geometry(cen_tracts_points_poly))
  plot(st_geometry(stations_points),add = TRUE, pch = 20)

  
# filtering for NAs ----
  na_stations <- stations_tracts_joined_points |> 
    filter(is.na(CENSUS_TRA))
    

# removing NA records
  stations_tracts_joined_points <- stations_tracts_joined_points |> 
    filter(!is.na(CENSUS_TRA))

# export as excel sheets ----
stations_tracts_export <- st_drop_geometry(stations_tracts_joined_points)

na_stations_export <- na_stations |> 
  select(STATION_ID,LONGNAME)

na_stations_export <- st_drop_geometry(na_stations_export)
  

write_xlsx(stations_tracts_export,"stations_tracts_joined.xlsx")

write_xlsx(na_stations_export,"na_stations.xlsx")

