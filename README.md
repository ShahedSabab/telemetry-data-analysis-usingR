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
> fish_df <- read.csv(file = 'Telemetry Subset.csv')

### Number of detections per FishID
> fish_df %>% group_by(FishID) %>% tally()
