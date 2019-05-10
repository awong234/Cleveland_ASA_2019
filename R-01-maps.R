# We install the ggmap package
# This only needs to be done ONE TIME.
install.packages("ggmap")

# We load the ggmap.  This needs to be done every time.
library(ggmap)

# Now we load the first several lines of a file
# that contains some of the taxi cab rides from NYC.
myDF <- read.csv("/depot/statclass/data/ASA/example1.csv")

# Here are the first 6 lines of this file:
head(myDF)
# and the dimensions of the file:
dim(myDF)

# These are the longitudes and latitudes:
myDF$pickup_longitude
myDF$pickup_latitude

# Now we build a new data.frame containing
# only the longitudes and latitudes.
mypoints <- data.frame(lon=myDF$pickup_longitude,lat=myDF$pickup_latitude)

register_google(key = "AIzaSyDYnLiu1jyxvo4hYqZJqqyZM7kx2fCpUls", write = TRUE)

# In preparation for making a map,
# we get the center of New York City from Google:
nyc_center = as.numeric(geocode("New York City"))
# Then we build a map of New York
NYCMap = ggmap(get_googlemap(center=nyc_center,zoom=10), extent="normal")
# and we display it.
NYCMap

# Finally, we add the points to the map
NYCMap <- NYCMap + geom_point(data=mypoints)
# and we display the map again.
NYCMap

