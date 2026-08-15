-- Purpose: count the highest-ranked directed station pairs needed to account
-- for 10% of named-endpoint rides within each rider type.
-- Grain: one row per rider type.
-- Boundary rule: include a pair when cumulative rides before that pair are
-- below 10%; the included pair may carry the cumulative share past 10%.
-- Expected results: casual = 166 pairs; member = 650 pairs.
-- Tableau output: directed_pair_rider_type_share.csv.

WITH route_counts AS(
  SELECT
    member_casual AS ride_type,
    start_station_name AS start_station,
    end_station_name AS end_station,
    COUNT(*) AS route_count
  FROM trips_dated
  WHERE start_station_name IS NOT NULL
  AND end_station_name IS NOT NULL
  GROUP BY ride_type, start_station, end_station
),

running_route_counts AS (
  SELECT
    ride_type,
    start_station,
    end_station,
    route_count,
    SUM(route_count) OVER(
    PARTITION BY ride_type
    ORDER BY route_count DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_count,
    SUM(route_count) OVER(
    PARTITION BY ride_type
    ) AS total_count
  FROM route_counts
)

SELECT
  ride_type,
  COUNT(*) AS "directed_pairs_10%_rides"
FROM running_route_counts
WHERE running_count - route_count < total_count / 10.0
GROUP BY ride_type
ORDER BY ride_type
