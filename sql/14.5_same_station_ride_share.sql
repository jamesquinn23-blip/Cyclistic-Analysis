-- Purpose: compare the within-rider-type share of rides that start and end at
-- the same named station. These are same-station rides, not proven round trips.
-- Grain: one row per rider type.
-- Denominator: rides with non-null start and end station names.
-- Expected results: casual = 7.92%; member = 2.23%.
-- Tableau output: same_station_rides_share.csv.

WITH same_station_rides AS (
    SELECT
    member_casual AS ride_type,
    COUNT(*) as same_station_rides_count
    FROM trips_dated
    WHERE start_station_name IS NOT NULL
    AND end_station_name IS NOT NULL
    AND start_station_name = end_station_name
    GROUP BY ride_type
),

ride_type_trip_counts AS(
  SELECT
    member_casual AS ride_type,
    COUNT(*) AS trip_count
  FROM trips_dated
  WHERE start_station_name IS NOT NULL
  AND end_station_name IS NOT NULL
  GROUP BY ride_type
)

SELECT
    same_station_rides.ride_type,
    same_station_rides_count,
    trip_count,
    same_station_rides_count/trip_count * 100 AS same_station_rides_share
FROM same_station_rides
INNER JOIN ride_type_trip_counts
ON same_station_rides.ride_type = ride_type_trip_counts.ride_type
