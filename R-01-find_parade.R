# Setup ------------------------------------------

library(ggmap)
library(dplyr)
library(sp)

# Obtain data ---------------------------------------

taxi_df = read.csv(file = '/depot/statclass/data/taxi2018/yellow_tripdata_2013-11.csv')

save(taxi_df, file = '/scratch/scholar/train20/taxi_df.Rdata')
load(file = '/scratch/scholar/train20/taxi_df.Rdata')

# Clean data ----------------------------------------

# obviously want the day of the 25th



taxi_df_tg = taxi_df %>% 
  mutate(pickup_datetime = as.POSIXct(pickup_datetime, format = "%Y-%m-%d %H:%M:%S"),
         dropoff_datetime = as.POSIXct(dropoff_datetime, format = "%Y-%m-%d %H:%M:%S")) %>% 
  filter(pickup_datetime > as.POSIXct(format(as.Date("2013-11-25"))),
         pickup_datetime < as.POSIXct(format(as.Date("2013-11-26")))
                             )

test_df = sample_n(tbl = taxi_df_tg, size = 10000)
test_df_sp_pu = test_df
coordinates(test_df_sp_pu) = ~pickup_longitude + pickup_latitude

ny_state = maps::map(database = 'state', regions = 'New York')
ny_state_df = data.frame(lon = ny_state$x, lat = ny_state$y)
ny_state_df = ny_state_df[complete.cases(ny_state_df), ]
ny_state_df = Polygon(ny_state_df)
ny_state_df = Polygons(list(ny_state_df), ID = "ny")
ny_state_df = SpatialPolygons(list(ny_state_df))

taxi_df_sp_pickup = taxi_df_tg
coordinates(taxi_df_sp_pickup) = ~pickup_longitude + pickup_latitude

bbox_ny = bbox(ny_state_df)
bbox_taxi = bbox(taxi_df_sp_pickup)

lines(maps::map("state", "New York"))
points(data = test_df, pickup_latitude~pickup_longitude)

pt_in_state = sp::over(taxi_df_sp_pickup, ny_state_df, fn = NULL) %>% 
  replace(x = ., list = is.na(.), values = F) %>% 
  as.logical

taxi_df_sp_pickup = taxi_df_sp_pickup[pt_in_state, ]

# Find parade route ---------------------------------

register_google(key = "AIzaSyDYnLiu1jyxvo4hYqZJqqyZM7kx2fCpUls", write = TRUE)

nyc_center = as.numeric(geocode("New York City"))

# trim to dist to nyc center

distmat = fields::rdist(nyc_center %>% t %>% as.data.frame, coordinates(taxi_df_sp_pickup) %>% as.data.frame)
distmat = as.numeric(distmat)

taxi_df_sp_pickup_ctr = taxi_df_sp_pickup[which(distmat < 0.067), ]

NYCMap = ggmap(get_googlemap(center=nyc_center,zoom=12), extent="normal")

NYCMap + 
  geom_point(data = coordinates(taxi_df_sp_pickup_ctr) %>% as.data.frame, 
             aes(x = pickup_longitude, y = pickup_latitude), alpha = 0.1, color = 'red4')
