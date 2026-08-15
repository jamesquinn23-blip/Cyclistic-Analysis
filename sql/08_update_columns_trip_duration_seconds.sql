--- Update `trip_duration_seconds` after cleaning DST-affected records with
--- `trip_duration` so it accurately reflects ride-time for all trips.

UPDATE trips_dated
SET trip_duration_seconds = EPOCH(trip_duration);

--- Confirm row_count: 5,932,212
SELECT
    COUNT(*) as row_count,
    COUNT(*) FILTER(trip_duration_seconds IS NULL) AS null_duration_rides,
    COUNT(*) FILTER(trip_duration_seconds != EPOCH(trip_duration)) AS mismatched_duration_rides
FROM trips_dated
