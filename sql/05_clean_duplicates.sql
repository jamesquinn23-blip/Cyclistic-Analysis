--- Identify the 35 values of `ride_id` that are duplicated in the datatsets.
--- Expect 70 records representing 35 duplicated `ride_id`. 
WITH may_duplicates AS (
SELECT *
FROM trips_dated
WHERE filename = 'data\202605-divvy-tripdata.csv' AND date_started = '2026-04-30'
)
SELECT trips_dated.*
FROM trips_dated
INNER JOIN may_duplicates
ON trips_dated.ride_id =  may_duplicates.ride_id
ORDER BY trips_dated.ride_id;


--- Delete the 35 rows from the May 2026 file.

DELETE FROM trips_dated
WHERE filename = 'data\202605-divvy-tripdata.csv' and date_started = '2026-04-30'
RETURNING ride_id;

--- Confirm afterward
--- Expected rows: 5,932,212 rows
--- Expected Distinct `ride_id`s: 5,932,212
--- Remaining rows matching the unwanted May-file/April-30 condition: 0

SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT(ride_id)) AS distinct_ride_ids,
    COUNT(*) FILTER(
        (filename = 'data\202605-divvy-tripdata.csv')
        AND date_started = '2026-04-30') AS remaining_unwanted_rows
FROM trips_dated;


--- Expect: Remaining duplicates: 0 rows
--- This interface displays only the final result when the script is run.
--- Run each validation query individually to inspect both results.
SELECT
    ride_id
FROM trips_dated
GROUP BY ride_id
HAVING COUNT(ride_id) > 1;