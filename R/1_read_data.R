# Summary -----------------------------------------------------------------
# This script reads in the data required for the project

# Packages ----------------------------------------------------------------
library(here)
library(vroom)
library(dplyr)
library(stringr)

# Read data ---------------------------------------------------------------
# Get paths of data files
files <- list.files(here("data/src"), full.names = TRUE)

# Read to dataframe df
df <- vroom(files, id = "filename") |> 
  mutate(short_filename = str_extract(filename, "\\d{6}"))
