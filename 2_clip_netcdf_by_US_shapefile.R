library(raster)
library(sf)
library(tools)
library(stringr)
library(terra)
library(rgdal)
library(sp)

setwd("D:/LSU/Summer/Climate/Rainfall/Extreme_indices/shp")
shp_file <- "US.shp"
shp_data <- st_read(shp_file)
shp <- readOGR(".", "US")


# Specify the input directory containing the NetCDF files
input_directory <- "D:/LSU/Fall_2023/GEOG_7973/ERA5/_4_daily_year_separated_box_mm"

# Specify the output directory where the new files will be saved
output_directory <- "E:/ERA5_rainfall/daily_ERA5_rainfall_mm_US_boundary"

# Get a list of all NetCDF files in the input directory
nc_files <- list.files(input_directory, pattern = "\\.nc$", full.names = TRUE)


# Loop over each NetCDF file
for (nc_file in nc_files) {
  # Read the NetCDF data
  nc_data <- brick(nc_file)
  
  # Create the output file name with the year
  file_name <- basename(nc_file)
  year <- str_extract(file_name, "[0-9]{4}")
  output_file <- file.path(output_directory, paste0("ERA5_daily_rainfall_mm_US_", year, ".nc"))
  
  shp_data <- st_transform(shp_data, crs=nc_data@crs)
  
  # Crop the NetCDF data using the extent of the shapefile
  nc_clip <- crop(nc_data, extent(shp_data))
  
  # Mask the NetCDF data using the shapefile
  nc_masked <- mask(nc_clip, shp_data)
  
  # Save the masked data to a new NetCDF file
  writeRaster(nc_masked, filename = output_file, overwrite = TRUE, format = "CDF",
              varname = "tp", varunit = "mm/day", longname = "Daily Precipitation",
              xname = "longitude", yname = "latitude", zname = "time")
}

