# Summary -----------------------------------------------------------------
# This script exports the clean data to CSV and RDA format

# Packages ----------------------------------------------------------------
library(data.table)

# Scripts -----------------------------------------------------------------
source(here("R/2_process_data.R"))

# Export data -------------------------------------------------------------
# Save as CSV
fwrite(fct_trips, file = here("data/cln/fct_trips.csv"))
fwrite(dim_end_dates, file = here("data/cln/dim_end_dates.csv"))
fwrite(dim_end_stations, file = here("data/cln/dim_end_stations.csv"))
fwrite(dim_end_times, file = here("data/cln/dim_end_times.csv"))
fwrite(dim_rideables, file = here("data/cln/dim_rideables.csv"))
fwrite(dim_riders, file = here("data/cln/dim_riders.csv"))
fwrite(dim_sources, file = here("data/cln/dim_sources.csv"))
fwrite(dim_start_dates, file = here("data/cln/dim_start_dates.csv"))
fwrite(dim_start_stations, file = here("data/cln/dim_start_stations.csv"))
fwrite(dim_start_times, file = here("data/cln/dim_start_times.csv"))
fwrite(dim_trips, file = here("data/cln/dim_trips.csv"))