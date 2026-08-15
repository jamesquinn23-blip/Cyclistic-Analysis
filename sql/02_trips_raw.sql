-- Combine all monthly CSV files as one persistent raw table.

CREATE OR REPLACE TABLE trips_raw AS
SELECT *
FROM read_csv(
    'data/*-divvy-tripdata.csv',
    union_by_name = true,
    filename = true
);


-- Confirm the result.
--- Expected `total_rows`: 5,932,349
--- Expected `files_loaded`: 12
--- Expected `distinct_ride_ids`: 5932314
--- Expected excess rows relative to distinct IDs: 35

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT filename) AS files_loaded,
    COUNT(DISTINCT ride_id) AS distinct_ride_ids
FROM trips_raw;