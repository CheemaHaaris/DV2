library(ggplot2)
library(data.table)
library(viridis)
library(rnaturalearth)
library(rnaturalearthdata)

# 0) Load the nycflights13 package and check what kind of datasets exist in the package,
# then create a copy of flights dataset into a data.table object, called flight_data.

# loading the package

library(nycflights13)

# checking the datasets in the package

data(package = 'nycflights13')

# copying flights datasets into a data table object

?nycflights13::flights
flight_data <- data.table(nycflights13::flights)
str(flight_data)

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

flight_data$date <- substr(flight_data$time_hour,1,10)

ggplot(flight_data[arr_delay > 20,.N, by = month], aes( x = month, y = N)) + geom_bar(aes(fill = N), stat = 'identity') +
  labs( x = 'Date', y = 'Number of Flights') + theme_bw() +
  scale_fill_gradient(low = "dodgerblue4", high = "firebrick2")

#### Issue - change x axis labels
  
# 6) Plot the departure delay of flights going to IAH and the related day's wind speed on a scatterplot!
# Is there any association between the two variables? Try adding a linear model.

weather <- nycflights13::weather 

merged_data_3 <- merge(flight_data, weather,  by = c('origin' ,'time_hour'))


merged_data_3[dest == 'IAH', .(mean_wind_speed = mean(wind_speed, na.rm =T), dep_delay, month.x, day.x) , by = .(time_hour, tailnum)][,.(avg_wind_speed = mean(mean_wind_speed)), by = .(month.x, day.x) ]


ggplot(merged_data_3[dest == 'IAH', .(mean_wind_speed = mean(wind_speed, na.rm =T), dep_delay, month.x, day.x) , by = .(time_hour, tailnum)][,.(avg_wind_speed = mean(mean_wind_speed), dep_delay), by = .(month.x, day.x) ],
       aes( x = dep_delay, y = avg_wind_speed)) +
            geom_point() + geom_smooth(method = 'lm') +
                labs( x = 'Departure delay', y = 'Mean of wind speed') +
                    theme_bw()

# 7) Plot the airports as per their geolocation on a world map, by mapping the number flights going to that 
# destination to the size of the symbol!

airports <- nycflights13::airports

world <- ne_countries(scale = "medium", returnclass = "sf")

ggplot() +
  geom_sf(data = world) +
  geom_point(data = airports, mapping = aes(x = lon, y = lat), colour = "black") + 
  coord_sf() + theme_bw() + labs( x = 'longitude', y = 'latitude')
