library(raster)
library(rgdal)
library(sf)
library(sp)
library(rgeos)
library(terra)
library(lubridate)
library(openxlsx)
library(dplyr)


setwd("E:/GEOG_7973_term_project/GHCN/raw_data")

# Get a list of all CSV files in the directory
csv_files <- list.files(pattern = "\\.csv$")

# Create an empty list to store data frames
dataframes_list <- list()

# Loop through the CSV files, read each file, and append it to the list
for (file in csv_files) {
  data <- read.csv(file)
  dataframes_list <- append(dataframes_list, list(data))
}

# Combine all data frames into a single dataframe
raw_data <- do.call(rbind, dataframes_list)

# Print the first few rows of the combined dataframe to verify
head(raw_data)


gc()






# raw_data_LA <- read.csv("LA.csv")
# raw_data_MS <- read.csv("MS.csv")
# raw_data_UT <- read.csv("UT.csv")
# 
# raw_data_ID <- read.csv("ID.csv")
# raw_data_ND <- read.csv("ND.csv")
# 
# 
# 
# 
# data_frames <- lapply(ls(), function(x) get(x))
# data_frames <- data_frames[sapply(data_frames, is.data.frame)]
# 
# gc()
# 
# raw_data <- do.call(rbind, data_frames)




raw_data <- raw_data[-8]

duplicate_rows <- duplicated(raw_data)

gc()

raw_data <- raw_data[!duplicate_rows, ]

gc()

summary(raw_data)

raw_data <- na.omit(raw_data)




Date <- ymd(raw_data$DATE)

raw_data <- cbind(raw_data, Date)

summary(raw_data)


length(unique(raw_data$STATION))

gc()

station_data_availability <- as.data.frame(table(raw_data$STATION))

station_data_availability_sorted <- station_data_availability[order(station_data_availability$Freq, decreasing = TRUE), ]

station_data_availability_sorted <- station_data_availability_sorted[station_data_availability_sorted$Freq > 0.95*15340, ]

colnames(station_data_availability_sorted) <- c("STATION","freq")

stations_to_take <- station_data_availability_sorted$STATION

#Subset raw data to selected stations
raw_data_subset <- raw_data[raw_data$STATION %in% stations_to_take,]

length(unique(raw_data_subset$STATION))

raw_data_subset <- raw_data_subset[-6]

summary(raw_data_subset)

Date_obs <- seq.Date(from = as.Date("1981-01-01"), to = as.Date("2022-12-31"), by = "1 day")


station_info <- raw_data_subset[,1:5]

# Use distinct to get unique stations with their associated information
station_info <- station_info %>%
  distinct(STATION, .keep_all = TRUE)


setwd("E:/GEOG_7973_term_project/GHCN/shapefile")
US_shp <- readOGR(".", "continental_US_WGS84")


station_info <- station_info[grepl("^U", station_info$STATION), ]


station_shp <- st_as_sf(station_info, coords = c("LONGITUDE", "LATITUDE"), crs = 4326)
st_write(station_shp, "station.shp")

station_shp <- readOGR(".", "station") 

plot(US_shp, col = "transparent", border = "black", lwd = 1)
plot(station_shp, pch =20, add = TRUE, col = "red")


gc()






# Get unique values in the 'STATION' column
stations <- unique(station_info$STATION)




# Loop through each unique STATION and create separate CSV files
for (station in stations) {
  # Subset the dataframe for the current category
  raw_data_subset_station <- raw_data_subset[raw_data_subset$STATION == station, ]
  
  
  # Find the missing dates by comparing with the actual dates in the dataframe
  missing_dates <- Date_obs[!Date_obs %in% raw_data_subset_station$Date] 
  
  
  # Create a dataframe with missing dates, NA values for other columns, and arrange the dates
  if (length(missing_dates) > 0) {
    empty_rows <- data.frame(PRCP = NA,
                             Date = missing_dates)
    raw_data_subset_station <- bind_rows(raw_data_subset_station, empty_rows) %>%
      arrange(Date)  # arrange from dplyr
  } else {
    raw_data_subset_station <- raw_data_subset_station %>%
      arrange(Date)  # arrange from dplyr
  }
  
  
  raw_data_subset_station <- raw_data_subset_station[, -(1:5)]
  
  raw_data_subset_station <- raw_data_subset_station[, c("Date", "PRCP")]
  
  
  # Define the filename based on the category value
  filename <- paste(station, ".csv", sep = "")
  
  
  setwd("D:/LSU/Fall_2023/GEOG_7973/GHCN/csv_individual_stations")
  
  # Write the subset dataframe to a CSV file with the filename
  write.csv(raw_data_subset_station, file = filename, row.names = FALSE)
  
  # Print a message indicating the file creation
  cat("File", filename, "created.\n")
}







setwd("D:/LSU/Fall_2023/GEOG_7973/GHCN")
write.csv(station_info, "station_info.csv", row.names = FALSE)






