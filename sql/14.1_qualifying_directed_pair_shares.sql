-- Purpose: compare both rider types across the union of directed station pairs
-- that contribute to the first 10% of either rider type's named-endpoint rides.
-- Grain: one row per directed station pair and rider type.
-- Inclusion: rides with non-null start and end station names.
-- Expected rows: 1,522 (761 directed pairs x 2 rider types).
-- Tableau output: qualifying_directed_pair_shares_by_rider_type.csv.

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
    ) as total_count
  FROM route_counts
  ORDER BY route_count DESC
),

qualifying_pairs AS (
  SELECT DISTINCT
    start_station,
    end_station
  FROM running_route_counts
  WHERE running_count - route_count < total_count / 10.0
)



SELECT
  running_route_counts.start_station,
  running_route_counts.end_station,
  ride_type,
  route_count / total_count * 100 AS route_percent_x_rider_type,
  running_count,
  total_count
FROM running_route_counts
INNER JOIN qualifying_pairs
  ON running_route_counts.start_station = qualifying_pairs.start_station
  AND running_route_counts.end_station = qualifying_pairs.end_station
ORDER BY route_percent_x_rider_type DESC;
