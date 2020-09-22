# telemetry-data-analysis-usingR
A small subset of the Lake Winnipeg telemetry data is collected. The purpose is to analyze this data to find out interesting insights about the fish inhabitatns. A few highlights are as follows: the distribution of different species, the certain area where specific species can be found, and the time period of their perambulation. The data has the following attributes:

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
#### B.Number of detections per Species
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
#### C.Number of fish per Species
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
#### D.For each fish, total number of positions during daytime (>6am and <10pm) and night time (>=10pm and <=6am) period 
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
