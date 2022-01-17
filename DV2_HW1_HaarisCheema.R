library(ggplot2)
library(data.table)
library(viridis)
library(rnaturalearth)
library(rnaturalearthdata)
library(lubridate)
library(tidyverse)

# 0) Load the nycflights13 package and check what kind of datasets exist in the package,
# then create a copy of flights dataset into a data.table object, called flight_data.

# loading the package

library(nycflights13)

# checking the datasets in the package
# data(package = 'nycflights13')

flight_data <- data.table(nycflights13::flights)

# checking the variable structure
# str(flight_data)

# 1) Which destination had the lowest avg arrival delay from LGA with minimum 100 flight to that destination?

flight_data[origin == 'LGA' , .(number_of_flights = .N, mean_arr_delay = mean(arr_delay, na.rm = T) ) , by = dest ][number_of_flights > 100][order(mean_arr_delay)][1]


# 2) Which destination's flights were the most on time (avg arrival delay closest to zero)
# from LGA with minimum 100 flight to that destination?

flight_data[origin == 'LGA', .(number_of_flights = .N, mean_arr_delay = mean(arr_delay, na.rm = T) ), by = dest ][number_of_flights > 100][which.min(abs(mean_arr_delay))]

# 3) Who is the manufacturer of the plane, which flights the most to CHS destination?

planes <- nycflights13::planes

merged_data <- merge(flight_data, planes, by = 'tailnum')

merged_data[dest == 'CHS', .(number_of_flights = .N), by = .(tailnum, manufacturer)][which.max(number_of_flights)]

# 4) Which airline (carrier) flow the most by distance?

airlines <- nycflights13::airlines

merged_data_2 <- merge(flight_data, airlines, by = 'carrier')

merged_data_2[, .(sum_of_distance = sum(distance)), by = name][which.max(sum_of_distance)]

# 5) Plot the monthly number of flights with 20+ mins arrival delay!

flight_data$date <- as.Date(format(flight_data$time_hour,'%Y-%m-01'))

ggplot(flight_data[arr_delay > 20,.N, by = date], aes( x = date, y = N)) + geom_bar(aes(fill = N), stat = 'identity') +
  labs( x = 'Date', y = 'Number of Flights') + theme_bw() +
  scale_fill_gradient(low = "dodgerblue4", high = "firebrick2")


  
# 6) Plot the departure delay of flights going to IAH and the related day's wind speed on a scatterplot!
# Is there any association between the two variables? Try adding a linear model.


# restructuring the flights data 

delays <- flight_data[dest=='IAH', .(dep_delay, month, day, origin)]

# constructing the daily wind data (avg)

daily_wind_speed <- data.table(nycflights13::weather)[, .(mean_wind_speed = mean(wind_speed, na.rm= T)), by= .(month, day, origin)]

# merging the data

joined <- merge(delays, daily_wind_speed, by = c('month','day','origin'))


ggplot(joined, aes(x = dep_delay, y = mean_wind_speed, col = mean_wind_speed)) +
  geom_point() +
  geom_smooth( method= 'lm' , formula = 'y~x') +
  labs(x = 'Departure delay' , y = 'Mean of wind speed', title = 'Association between departure delay and mean wind speed') +
  theme_bw() +
  scale_colour_gradient(low = "dodgerblue4", high = "firebrick2")

# No obvious association observed between the variables.


# 7) Plot the airports as per their geolocation on a world map, by mapping the number flights going to that 
# destination to the size of the symbol!

airports <- data.table(nycflights13::airports)

dest <- flight_data[, .(flights = .N), by = dest]

merged_data_3 <- merge(dest, airports, by.x = 'dest', by.y = 'faa')


world <- map_data("world")

ggplot() +
  geom_map(
    data = world, map = world,
    aes(long, lat, map_id = region),
    color = "black", fill = "lightgray", size = 0.1
  )  +
  geom_point(data = merged_data_3, mapping = aes(x = lon, y = lat, size = flights, colour = flights)) + 
  coord_sf() + theme_bw() + labs( x = 'longitude', y = 'latitude', title = 'Airports and the number of flights arriving at them') +
  theme(legend.position="top",
        legend.text = element_text(size = 7),
        axis.title.x = element_blank(),
        axis.title.y = element_blank()) +
  scale_colour_gradient(low = "dodgerblue4", high = "firebrick2") +
  scale_x_continuous(breaks=seq(-100, 200, by = 100))




