-- Purpose: compare both rider types across the combined set of each rider
-- type's ten highest-volume directed station pairs.
-- Grain: one row per selected directed station pair and rider type.
-- Expected rows: 40 (20 unique pairs x 2 rider types).
-- Tableau output: top_ten_directed_pairs_by_rider_type.csv.

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
    ORDER  BY route_count DESC, start_station DESC, end_station DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_count,
    SUM(route_count) OVER(
    PARTITION BY ride_type
    ) as total_count,
    ROW_NUMBER() OVER(
      PARTITION BY ride_type
      ORDER  BY route_count DESC, start_station DESC, end_station DESC
    ) AS pair_rank
  FROM route_counts
),

qualifying_pairs AS (
  SELECT DISTINCT
    start_station,
    end_station
  FROM running_route_counts
  WHERE pair_rank <= 10
)


SELECT
  running_route_counts.start_station,
  running_route_counts.end_station,
  ride_type,
  route_count / total_count * 100 AS route_percent_x_rider_type,
  route_count,
  running_count,
  total_count,
  pair_rank,
  running_count / total_count * 100 AS cumulative_route_percent
FROM running_route_counts
INNER JOIN qualifying_pairs
ON running_route_counts.start_station = qualifying_pairs.start_station
AND running_route_counts.end_station = qualifying_pairs.end_station
ORDER BY ride_type, pair_rank
