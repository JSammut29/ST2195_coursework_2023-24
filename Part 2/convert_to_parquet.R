# Directory containing the data files
data_dir <- "D:/University of London/Programming for Data Science ST2195/ST2195_coursework_2023-24/Part 2/dataverse_files"

# Function to read compressed CSV and convert to Parquet format
convert_to_parquet <- function(file, parquet_dir) {
  # Read the compressed CSV file using fread
  df <- fread(file)
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

# Get a list of files to process
files <- list.files(path = data_dir, pattern = "199[8-9].csv.bz2|200[0-7].csv.bz2", full.names = TRUE)

# Convert all files to Parquet format
parquet_files <- lapply(files, convert_to_parquet, parquet_dir = parquet_dir)
