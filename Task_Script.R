####
#
## 1. Data Summaries 
#
####


library(dplyr)
library(lubridate)
library(ggplot2)

setwd("D:/temp/R")
fish <- read.csv(file = 'Telemetry Subset.csv')
head(fish)


# A. Create a table that shows the number of detections per FishID.
fish %>% group_by(FishID) %>% tally()

# B. Create a table that shows the number of detections per Species.
fish %>% group_by(Species) %>% tally()

# C. Create a table that shows the number of fish per species were
#detected over this time period.

fish %>% group_by(Species) %>% distinct(FishID, .keep_all = TRUE) %>% summarise(n_fish = n()) 

# D. This will test your ability to manipulate POSIX (dates and times) in R. Assume the sun rises at 6am,
#    and sets at 10pm each day. For each fish, calculate the total number of positions during the daytime
#    period (>6 am and < 10pm) and night time (>= 10 pm and <= 6 am).

length(fish)

day <- subset(fish, hour(ymd_hms(fish$Date)) >= 6 & hour(ymd_hms(fish$Date)) < 22)

night <- subset(fish, (hour(ymd_hms(fish$Date)) >= 0 & hour(ymd_hms(fish$Date)) <= 5) | (hour(ymd_hms(fish$Date)) >= 22 & hour(ymd_hms(fish$Date)) < 24))

# A. Create a table that shows the number of detections per FishID.
d_table <- day %>% group_by(FishID) %>% tally()
d_table$DielPeriod <- "Day"

n_table <- night %>% group_by(FishID) %>% tally()
n_table$DielPeriod <- "Night"

# Add datasets vertically
combined_table <- rbind(d_table, n_table)

# Sort by FishID
combined_table_sorted <- combined_table[order(combined_table$FishID),]

####
#
## 2. Mean Daily Position
#
####

# A. Using the provided dataset, calculate the mean daily position for each fish

fish %>% group_by(FishID,day(ymd_hms(fish$Date))) %>% tally()

fish_mean_pos <- fish %>% group_by(FishID,day(ymd_hms(Date))) %>% summarize(Mean_Lat = mean(ReceiverLat, na.rm=TRUE), Mean_Long = mean(ReceiverLong, na.rm=TRUE))

# B. Using ggplot and the coordinates for the south basin of Lake Winnipeg (*.csv file attached),
#    plot the mean daily positions for FishID Wall-135

selected_data <- subset(fish_mean_pos, FishID == "Wall-135")

ggplot(selected_data, aes(x = Mean_Lat, y = Mean_Long)) + geom_point()


####
#
## 3. Code Interpretation and Fish Behaviour
#
####

# A. In a few sentences describe what the code section below is doing,
#    and briefly describe the distribution for each species

fish %>% 
  mutate(Waterbody = case_when(
    ReceiverLat < 50.4 ~ "Red River",
    ReceiverLat >= 50.4 & ReceiverLat < 51.2 ~ "South Basin",
    ReceiverLat >= 51.2 & ReceiverLat < 51.75 ~ "Narrows",
    ReceiverLat >= 51.75 ~ "North Basin"
  )) %>% 
  group_by(Species, Waterbody) %>% 
  summarise(dtcs = length(FishID),
            stations = length(unique(Name)))

# 	The code is adding a new column to the existing dataframe. The name of the column is Waterbody and the value is set as "Red River" if the receiver latitude is less than 50.4, if the latitude is in between 50.4 and 51.2 then the value is set as "South Basin", if the latitude value is in between 51.2 and 51.75 then the value is set as "Narrows", any fish with latitude value greater than 51.75 is set as "North Basin". The dataframe is grouped using Species and Waterbody, and count has been performed.

# Analyzing the distribution of each species, the following insights can be found:

# 1. Bigmouth Buffalo can only be found in Red River.
# 2. Channel Catfish can be found in Red River and South Basin, but this species is detected more in Red River.
# 3. Common Carp can be found in Narrows, Red River, and South Basin while more in Narrows.
# 4. Drum can be found in Narrows, North Basin, Red River, and South Basin, while more in South Basin.
# 5. Walleye can be found in Narrows, North Basin, and South Basin while more in South Basin 
# South Basin can be a hot spot for Drum and Walleye. In Red River, Channel Catfish and Bigmouth Buffalo species are frequently detected. There is a higher chance of getting Common Carp in the Narrows.

