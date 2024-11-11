#!/bin/bash

# The dirty dataset is generated by `generate_dirty_data.py`
# Clean the raw data file:
## Remove comment lines
grep -v '^#' ms_data_dirty.csv > ms_data_no_comments.csv

## Remove empty lines
sed '/^$/d' ms_data_no_comments.csv > ms_data_no_empty.csv

## Remove extra commas
sed -e 's/,,*/,/g' ms_data_no_empty.csv > ms_data_no_commas.csv

## Extract records within a specific range of walking speeds
awk -F',' '$6 >= 2.0 && $6 <= 8.0' ms_data_no_commas.csv > ms_data_limited_speed.csv

## Extract essential columns: patient_id, visit_date, age, education_level, walking_speed
# First, get the header from the original file
head -n 1 ms_data_no_commas.csv | cut -d',' -f1,2,4,5,6 > ms_data.csv

# Then, extract the data rows and append to ms_data.csv
tail -n +2 ms_data_limited_speed.csv | cut -d',' -f1,2,4,5,6 >> ms_data.csv

# Create insurance.lst with types A, B, and C
echo -e "insurance_type\nA\nB\nC" > insurance.lst

# Check the cleaned data
## Count the total number of visits (rows, not including the header)
total_rows=$(tail -n +2 ms_data.csv | wc -l)
echo "Total number of visits: $total_rows"

## Display the first few records in ms_data.csv
echo "First few records in ms_data.csv:"
head ms_data.csv

## Display the first few records in insurance.lst
echo "Insurance types:"
head insurance.lst

# Check for any records with walking speeds outside 2.0-8.0 feet/second range
echo "Records with walking speeds < 2.0 or > 8.0:"
out_of_range_records=$(awk -F',' '$5 < 2.0 || $5 > 8.0' ms_data.csv)

# Clean up temporary files
rm ms_data_no_comments.csv ms_data_no_empty.csv ms_data_no_commas.csv ms_data_limited_speed.csv