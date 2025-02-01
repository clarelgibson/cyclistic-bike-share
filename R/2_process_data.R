# Summary -----------------------------------------------------------------
# This script performs data cleaning, feature engineering and dimensional
# modeling.

# Packages ----------------------------------------------------------------
library(here)
library(tibble)
library(snakecase)
library(tidyr)
library(lubridate)
library(hms)

# Scripts -----------------------------------------------------------------
source(here("R/1_read_data.R"))

# Data cleaning -----------------------------------------------------------
# Replace NAs with string to denote missing data
data <- 
  df |> 
  replace_na(
    list(
      start_station_id = "ID UNKNOWN",
      start_station_name = "NAME UNKNOWN",
      end_station_id = "ID UNKNOWN",
      end_station_name = "NAME UNKNOWN"
    )
  )

# Fix station names and IDs

# Pull out all the station names and IDs for start locations
start_stations <- 
  data |> 
  count(start_station_id, start_station_name) |> 
  rename(
    station_id = start_station_id,
    station_name = start_station_name
  )

# Pull out all the station names and IDs for end locations
end_stations <- 
  data |> 
  count(end_station_id, end_station_name) |> 
  rename(
    station_id = end_station_id,
    station_name = end_station_name
  )

# Bind the station ids and names together
stations <- 
  start_stations |> 
  bind_rows(end_stations) |> 
  distinct() |> 
  summarise(
    n = sum(n),
    .by = c(station_id, station_name)
  ) |> 
  arrange(desc(n)) |> 
  mutate(
    names_per_id = n_distinct(station_name),
    .by = station_id
  ) |> 
  mutate(
    ids_per_name = n_distinct(station_id),
    .by = station_name
  ) |> 
  group_by(station_name) |> 
  mutate(clean_id = first(station_id)) |> 
  ungroup() |> 
  group_by(clean_id) |> 
  mutate(clean_name = first(station_name)) |> 
  ungroup() |> 
  # manual fixes where still needed
  mutate(
    clean_id = if_else(
      station_id %in% c("393", "21393"),
      "21393",
      clean_id
    ),
    clean_name = if_else(
      station_id %in% c("393", "21393"),
      "Oketo Ave & Addison St",
      clean_name
    )
  )

# Make a reference df of Station IDs and clean IDs
clean_ids <- 
  stations |> 
  select(station_id, clean_id) |> 
  distinct() |> 
  arrange(station_id)

# Test that there is only one clean_id for every station_id
clean_ids_qc <- 
  clean_ids |> 
  count(station_id) |> 
  filter(n > 1)

# Make a reference df of Station names and clean names
clean_names <- 
  stations |> 
  select(station_name, clean_name) |> 
  distinct() |> 
  arrange(station_name)

# Test that there is only one clean_name for every station_name
clean_names_qc <- 
  clean_names |> 
  count(station_name) |> 
  filter(n > 1)

# Fix the station names and IDs in the main dataframe
data <- 
  data |> 
  # Fix the start station names
  left_join(clean_ids, by = join_by(start_station_id == station_id)) |> 
  # Fix the start station ids
  left_join(clean_names, by = join_by(start_station_name == station_name)) |> 
  # rename the clean columns as the true start columns
  select(!c(start_station_id, start_station_name)) |> 
  rename(
    start_station_id = clean_id,
    start_station_name = clean_name
  ) |> 
  # Fix the end station names
  left_join(clean_ids, by = join_by(end_station_id == station_id)) |> 
  # Fix the end station ids
  left_join(clean_names, by = join_by(end_station_name == station_name)) |> 
  # rename the clean columns as the true end columns
  select(!c(end_station_id, end_station_name)) |> 
  rename(
    end_station_id = clean_id,
    end_station_name = clean_name
  )

# Add feature for trip duration
data <- 
  data |> 
  mutate(
    trip_duration_mins = as.numeric(
      difftime(ended_at, started_at, units = "mins")
    )
  )

# Remove records where trip duration is negative
data <- 
  data |> 
  filter(trip_duration_mins >= 0)

# Round datetime values to nearest second
data <- 
  data |> 
  mutate(
    started_at = round_date(started_at),
    ended_at = round_date(ended_at)
  )

# Add features for date and time as separate columns
data <- 
  data |> 
  mutate(
    start_date_key = as_date(started_at),
    end_date_key = as_date(ended_at),
    start_time = as_hms(started_at),
    end_time = as_hms(ended_at)
  )

# Add feature to indicate if trip is round trip (start and end station is the
# same) or point to point (start and end stations are different)
data <- 
  data |> 
  mutate(
    trip_type = if_else(
      start_station_id == end_station_id,
      "Round",
      "Point to point"
    )
  )

# Dimensional model -------------------------------------------------------
# Dimension - rideables
dim_rideables <- 
  data |> 
  select(rideable_type) |> 
  distinct() |> 
  arrange(rideable_type) |> 
  rowid_to_column("rideable_key") |>  # primary key
  mutate(
    rideable_name = to_title_case(rideable_type),
    is_classic = if_else(rideable_type == "classic_bike", 1, 0),
    is_electric = if_else(rideable_type == "electric_bike", 1, 0),
    is_scooter = if_else(rideable_type == "electric_scooter", 1, 0)
  )

# Dimension - stations
dim_start_stations <- 
  data |> 
  select(start_station_id, start_station_name, start_lat, start_lng) |> 
  arrange(start_station_id) |> 
  group_by(start_station_id, start_station_name) |> 
  summarise(
    start_lat = mean(start_lat, na.rm = TRUE),
    start_lng = mean(start_lng, na.rm = TRUE)
  ) |> 
  ungroup() |> 
  arrange(start_station_id) |> 
  rowid_to_column("start_station_key")

dim_end_stations <- 
  data |> 
  select(end_station_id, end_station_name, end_lat, end_lng) |> 
  arrange(end_station_id) |> 
  group_by(end_station_id, end_station_name) |> 
  summarise(
    end_lat = mean(end_lat, na.rm = TRUE),
    end_lng = mean(end_lng, na.rm = TRUE)
  ) |> 
  ungroup() |> 
  arrange(end_station_id) |> 
  rowid_to_column("end_station_key")

# Dimension - riders
dim_riders <-  
  data |> 
  select(member_casual) |> 
  distinct() |> 
  arrange(member_casual) |> 
  rowid_to_column("rider_key") |> 
  mutate(
    is_member = if_else(member_casual == "member", 1, 0),
    is_casual = if_else(member_casual == "casual", 1, 0)
  )

# Dimension - source files
dim_sources <- 
  data |> 
  select(filename, short_filename) |> 
  distinct() |> 
  arrange(short_filename) |> 
  rowid_to_column("source_key")

# Dimension - times
dim_start_times <- 
  data |> 
  select(start_time) |> 
  distinct() |> 
  arrange(start_time) |> 
  rowid_to_column("start_time_key") |> 
  mutate(
    start_time_label = as.character(start_time),
    start_hour = hour(start_time),
    start_minute = minute(start_time),
    start_second = second(start_time),
    start_am_pm = if_else(start_hour < 12, "AM", "PM"),
    start_time_of_day = case_when(
      between(start_hour, 5, 8) ~ "Early morning",
      between(start_hour, 9, 11) ~ "Late morning",
      between(start_hour, 12, 16) ~ "Afternoon",
      between(start_hour, 17, 22) ~ "Evening",
      TRUE ~ "Night"
    )
  )

dim_end_times <- 
  data |> 
  select(end_time) |> 
  distinct() |> 
  arrange(end_time) |> 
  rowid_to_column("end_time_key") |> 
  mutate(
    end_time_label = as.character(end_time),
    end_hour = hour(end_time),
    end_minute = minute(end_time),
    end_second = second(end_time),
    end_am_pm = if_else(end_hour < 12, "AM", "PM"),
    end_time_of_day = case_when(
      between(end_hour, 5, 8) ~ "Early morning",
      between(end_hour, 9, 11) ~ "Late morning",
      between(end_hour, 12, 16) ~ "Afternoon",
      between(end_hour, 17, 22) ~ "Evening",
      TRUE ~ "Night"
    )
  )  

# Dimension - dates
dim_start_dates <- 
  data |> 
  select(start_date_key) |> 
  distinct() |> 
  arrange(start_date_key) |> 
  mutate(
    start_date_day = day(start_date_key),
    start_date_month = lubridate::month(start_date_key),
    start_date_month_label = lubridate::month(start_date_key, label = TRUE),
    start_date_season = case_when(
      between(start_date_month, 3, 5) ~ "Spring",
      between(start_date_month, 6, 8) ~ "Summer",
      between(start_date_month, 9, 11) ~ "Autumn",
      TRUE ~ "Winter"
    ),
    start_date_day_of_week = lubridate::wday(start_date_key, label = TRUE),
    start_date_weekend = if_else(
      start_date_day_of_week %in% c("Sat", "Sun"),
      "Weekend",
      "Weekday"
    )
  )

dim_end_dates <- 
  data |> 
  select(end_date_key) |> 
  distinct() |> 
  arrange(end_date_key) |> 
  mutate(
    end_date_day = day(end_date_key),
    end_date_month = lubridate::month(end_date_key),
    end_date_month_label = lubridate::month(end_date_key, label = TRUE),
    end_date_season = case_when(
      between(end_date_month, 3, 5) ~ "Spring",
      between(end_date_month, 6, 8) ~ "Summer",
      between(end_date_month, 9, 11) ~ "Autumn",
      TRUE ~ "Winter"
    ),
    end_date_day_of_week = lubridate::wday(end_date_key, label = TRUE),
    end_date_weekend = if_else(
      end_date_day_of_week %in% c("Sat", "Sun"),
      "Weekend",
      "Weekday"
    )
  )

# Dimension - trip types
dim_trips <- 
  data |> 
  select(trip_type) |> 
  distinct() |> 
  arrange(trip_type) |> 
  rowid_to_column("trip_key") |> 
  mutate(
    trip_type_abbreviated = if_else(
      trip_type == "Round",
      "R",
      "P2P"
    ),
    is_round_trip = if_else(
      trip_type == "Round",
      1,
      0
    ),
    is_point_to_point_trip = if_else(
      trip_type == "Point to point",
      1,
      0
    )
  )

# Facts
fct_trips <- 
  data |> 
  # add keys
  left_join(select(dim_sources, filename, source_key)) |> 
  left_join(select(dim_rideables, rideable_type, rideable_key)) |> 
  left_join(select(dim_riders, member_casual, rider_key)) |> 
  left_join(select(dim_start_stations, start_station_id, start_station_key)) |> 
  left_join(select(dim_end_stations, end_station_id, end_station_key)) |> 
  left_join(select(dim_start_times, start_time, start_time_key)) |> 
  left_join(select(dim_end_times, end_time, end_time_key)) |> 
  left_join(select(dim_trips, trip_type, trip_key)) |> 
  select(
    ends_with("_key"),
    trip_duration_mins,
    ride_id
  )
