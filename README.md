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

#### Number of detections per FishID
> fish_df %>% group_by(FishID) %>% tally()
```
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
