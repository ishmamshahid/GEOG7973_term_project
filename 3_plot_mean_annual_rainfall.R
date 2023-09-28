library(raster)
library(sf)
library(tools)
library(stringr)
library(terra)
library(rgdal)
library(sp)
library(ncdf4)

setwd("E:/GEOG_7973_term_project/GHCN/shapefile")
shp_file <- "continental_US_WGS84.shp"
shp_data <- st_read(shp_file)
shp <- readOGR(".", "continental_US_WGS84")


setwd("E:/GEOG_7973_term_project/ERA5/ERA5_rainfall/_5_daily_ERA5_rainfall_mm_US_boundary")
ERA5_mean_annual_rainfall <- raster('ERA5_mean_annual_rainfall.nc')


ERA5_mean_annual_rainfall <- crop(ERA5_mean_annual_rainfall, extent(shp))
ERA5_mean_annual_rainfall <- mask(ERA5_mean_annual_rainfall, shp)


plot(ERA5_mean_annual_rainfall,axes= FALSE, col=colorRampPalette(c("red", "orange", "yellow",   "cyan", "dodgerblue2", 
                                                         "blue", "darkblue"))(100), main = "Mean annual rainfall (mm), (ERA5) 1981-2022")
plot(shp, add= TRUE, col = "transparent", border = "black", lwd =3 )










