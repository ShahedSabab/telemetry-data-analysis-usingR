# telemetry-data-analysis-usingR
A small subset of the Lake Winnipeg telemetry data is collected. The purpose is to analyze this data to find out interesting insights about the fish inhabitants. A few highlights are as follows: the distribution of different species, the certain area where specific species can be found, and the time period of their perambulation. The data has the following attributes:

1. Date - A timestamp for when a receiver (station) detects a transmitter detection
2. Name - A unique station name for each receiver in the study
3. ReceiverLong - The longitude of the receiver
4. ReceiverLat - The latitude of the receiver
5. FishID - A unique identifier for each species tagged in the study
6. Species - Species of the tagged fish

# Analysis:

## 1. Data Summaries:

#### Read Data
> fish_df <- read.csv(file = 'Telemetry Subset.csv')

#### A.Number of detections per FishID
> fish_df %>% group_by(FishID) %>% tally()
```
# A tibble: 15 x 2
  FishID       n
  <fct>    <int>
1 BMBF001    854
2 BMBF033    562
3 BMBF078   1188
4 Carp-017  1956
5 Carp-021   650
6 Carp-030   800
7 CNCF047   1974
8 CNCF051    635
9 CNCF106    508
10 Drum-003   938
11 Drum-006  1939
12 Drum-070   626
13 Wall-119  1198
14 Wall-135  1320
15 Wall-219   656
```
#### B. Number of detections per Species
> fish_df %>% group_by(Species) %>% tally()
```
# A tibble: 5 x 2
  Species              n
  <fct>            <int>
1 Bigmouth Buffalo  2604
2 Channel Catfish   3117
3 Common Carp       3406
4 Drum              3503
5 Walleye           3174
```
#### C. Number of fish per Species
> fish_df %>% group_by(Species) %>% distinct(FishID, .keep_all = TRUE) %>% summarise(n_fish = n()) 
```
# A tibble: 5 x 2
  Species          n_fish
  <fct>             <int>
1 Bigmouth Buffalo      3
2 Channel Catfish       3
3 Common Carp           3
4 Drum                  3
5 Walleye               3
```
#### D. For each fish, total number of positions during daytime (>6am and <10pm) and night time (>=10pm and <=6am) period 
```
day <- subset(fish_df, hour(ymd_hms(fish_df$Date)) >= 6 & hour(ymd_hms(fish_df$Date)) < 22)

night <- subset(fish_df, (hour(ymd_hms(fish_df$Date)) >= 0 & hour(ymd_hms(fish_df$Date)) <= 5) | (hour(ymd_hms(fish_df$Date)) >= 22 & hour(ymd_hms(fish_df$Date)) < 24))

# A. Create a table that shows the number of detections per FishID.
d_table <- day %>% group_by(FishID) %>% tally()
d_table$DielPeriod <- "Day"

n_table <- night %>% group_by(FishID) %>% tally()
n_table$DielPeriod <- "Night"

# Add datasets vertically
combined_table <- rbind(d_table, n_table)

# Sort by FishID
combined_table_sorted <- combined_table[order(combined_table$FishID),]
combined_table_sorted
```
```
# A tibble: 30 x 3
  FishID       n DielPeriod
  <fct>    <int> <chr>     
1 BMBF001    458 Day       
2 BMBF001    396 Night     
3 BMBF033    430 Day       
4 BMBF033    132 Night     
5 BMBF078    752 Day       
6 BMBF078    436 Night     
7 Carp-017  1612 Day       
8 Carp-017   344 Night     
9 Carp-021   514 Day       
10 Carp-021   136 Night     
# ... with 20 more rows
```
## 2. Mean Daily Position:
#### A. Mean daily position for each fish
> fish_mean_pos <- fish_df %>% group_by(FishID,day(ymd_hms(Date))) %>% summarize(Mean_Lat = mean(ReceiverLat, na.rm=TRUE), Mean_Long = mean(ReceiverLong, na.rm=TRUE))
```
# A tibble: 293 x 4
# Groups:   FishID [15]
   FishID  `day(ymd_hms(Date))` Mean_Lat Mean_Long
   <fct>                  <int>    <dbl>     <dbl>
 1 BMBF001                    3     49.7     -97.1
 2 BMBF001                    4     49.7     -97.1
 3 BMBF001                    7     49.8     -97.1
 4 BMBF001                    8     49.8     -97.1
 5 BMBF001                   10     49.8     -97.1
 6 BMBF001                   11     49.8     -97.1
 7 BMBF001                   26     49.8     -97.1
 8 BMBF001                   27     49.8     -97.1
 9 BMBF033                   20     49.9     -97.1
10 BMBF033                   28     49.9     -97.1
# ... with 283 more rows
```
#### B. Plot mean dailty positions for FishID-Wall-135
> selected_data <- subset(fish_mean_pos, FishID == "Wall-135")

> ggplot(selected_data, aes(x = Mean_Lat, y = Mean_Long)) + geom_point()

![](daily_position.png?raw=true)

## 3. Fish Behaviour
#### A. Investigate the distribution for each species in certain areas by analyzing the latitude
```
#Waterbody and the value is set as "Red River" if the receiver latitude is less than 50.4, 
#if the latitude is in between 50.4 and 51.2 then the value is set as "South Basin", 
#if the latitude value is in between 51.2 and 51.75 then the value is set as "Narrows",
# fish with latitude value greater than 51.75 is set as "North Basin"

fish_df %>% 
  mutate(Waterbody = case_when(
    ReceiverLat < 50.4 ~ "Red River",
    ReceiverLat >= 50.4 & ReceiverLat < 51.2 ~ "South Basin",
    ReceiverLat >= 51.2 & ReceiverLat < 51.75 ~ "Narrows",
    ReceiverLat >= 51.75 ~ "North Basin"
  )) %>% 
  group_by(Species, Waterbody) %>% 
  summarise(dtcs = length(FishID),
            stations = length(unique(Name)))
```
```
# A tibble: 13 x 4
# Groups:   Species [5]
   Species          Waterbody    dtcs stations
   <fct>            <chr>       <int>    <int>
 1 Bigmouth Buffalo Red River    2604        7
 2 Channel Catfish  Red River    1974        1
 3 Channel Catfish  South Basin  1143        3
 4 Common Carp      Narrows      1498        7
 5 Common Carp      Red River     910        4
 6 Common Carp      South Basin   998       27
 7 Drum             Narrows      1094        6
 8 Drum             North Basin   626        1
 9 Drum             Red River     181        2
10 Drum             South Basin  1602       12
11 Walleye          Narrows       317        8
12 Walleye          North Basin   881        7
13 Walleye          South Basin  1976       31
```
Analyzing the distribution of each species, the following insights can be found:

1. Bigmouth Buffalo can only be found in Red River.
2. Channel Catfish can be found in Red River and South Basin, but this species is detected more in Red River.
3. Common Carp can be found in Narrows, Red River, and South Basin while more in Narrows.
4. Drum can be found in Narrows, North Basin, Red River, and South Basin, while more in South Basin.
5. Walleye can be found in Narrows, North Basin, and South Basin while more in South Basin 
South Basin can be a hot spot for Drum and Walleye. In Red River Channel Catfish and Bigmouth Buffalo species are frequently detected. There is a higher chance of getting Common Carp in the Narrows.

# How to run:
Please check the task_script.R file.
