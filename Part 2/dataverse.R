# Load Necessary Libraries
library(arrow)
library(data.table)
library(readr)
library(dplyr)
library(parallel)

# Directory containing the data files
data_dir <- "D:/University of London/Programming for Data Science ST2195/ST2195_coursework_2023-24/Part 2/dataverse_files"

# Get a list of files to process
files <- list.files(path = data_dir, 
                    pattern = "199[8-9].csv.bz2|200[0-7].csv.bz2", 
                    full.names = TRUE)

# Function to read compressed CSV and convert to Parquet format
convert_to_parquet <- function(file, parquet_dir) {
  # Read the compressed CSV file
  df <- read_csv(file)
  # Extract the year from the file name
  year <- gsub(".*(\\d{4}).*", "\\1", basename(file))
  # Create a parquet file name
  parquet_file <- file.path(parquet_dir, paste0("flights_data_", year, ".parquet"))
  # Write to Parquet format
  write_parquet(df, parquet_file)
  return(parquet_file)
}

# Directory to save Parquet files
parquet_dir <- file.path(data_dir, "parquet_files")
if (!dir.exists(parquet_dir)) {
  dir.create(parquet_dir)
}

# Convert all files to Parquet format
parquet_files <- lapply(files, convert_to_parquet, parquet_dir = parquet_dir)

# Create a dataset from the Parquet files using arrow
dataset <- open_dataset(parquet_dir)

# Define a function to compute summary statistics for a chunk
compute_summary_stats <- function(chunk) {
  chunk %>%
    summarise(
      total_flights = n(),
      mean_arrival_delay = mean(ArrDelay, na.rm = TRUE),
      mean_departure_delay = mean(DepDelay, na.rm = TRUE),
      min_arrival_delay = min(ArrDelay, na.rm = TRUE),
      max_arrival_delay = max(ArrDelay, na.rm = TRUE),
      min_departure_delay = min(DepDelay, na.rm = TRUE),
      max_departure_delay = max(DepDelay, na.rm = TRUE)
    )
}

# Initialize an empty list to store summaries
summary_list <- list()

# Process data in chunks
batch_size <- 1000000  # Adjust batch size as needed

# Collect the entire dataset to get row counts
row_counts <- dataset %>%
  collect() %>%
  summarise(total_rows = n()) %>%
  .$total_rows

n_batches <- ceiling(row_counts / batch_size)

for (i in seq_len(n_batches)) {
  chunk <- dataset %>%
    filter(row_number() > (i - 1) * batch_size & row_number() <= i * batch_size) %>%
    collect()
  summary_list[[i]] <- compute_summary_stats(chunk)
}

# Combine summary statistics
final_summary <- bind_rows(summary_list) %>%
  summarise(
    total_flights = sum(total_flights),
    mean_arrival_delay = weighted.mean(mean_arrival_delay, total_flights, na.rm = TRUE),
    mean_departure_delay = weighted.mean(mean_departure_delay, total_flights, na.rm = TRUE),
    min_arrival_delay = min(min_arrival_delay, na.rm = TRUE),
    max_arrival_delay = max(max_arrival_delay, na.rm = TRUE),
    min_departure_delay = min(min_departure_delay, na.rm = TRUE),
    max_departure_delay = max(max_departure_delay, na.rm = TRUE)
  )

print(final_summary)