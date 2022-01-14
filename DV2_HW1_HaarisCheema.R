library(ggplot2)
library(data.table)
library(nycflights13)

# 0) Load the nycflights13 package and check what kind of datasets exist in the package,
# then create a copy of flights dataset into a data.table object, called flight_data.

library(nycflights13)

nycflights13




# 1) Which destination had the lowest avg arrival delay from LGA with minimum 100 flight to that destination?

# 2) Which destination's flights were the most on time (avg arrival delay closest to zero)
# from LGA with minimum 100 flight to that destination?

# 3) Who is the manufacturer of the plane, which flights the most to CHS destination?

# 4) Which airline (carrier) flow the most by distance?

# 5) Plot the monthly number of flights with 20+ mins arrival delay!

# 6) Plot the departure delay of flights going to IAH and the related day's wind speed on a scatterplot!
# Is there any association between the two variables? Try adding a linear model.

# 7) Plot the airports as per their geolocation on a world map, by mapping the number flights going to that destination
# to the size of the symbol!