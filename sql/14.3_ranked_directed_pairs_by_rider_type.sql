-- Purpose: provide the ranked cumulative concentration curve for directed
-- station pairs within each rider type.
-- Grain: one row per rider type and directed-pair rank.
-- Inclusion: rides with non-null start and end station names.
-- Scope: ranks 1 through 650 for each rider type.
-- Expected rows: 1,300.
-- Tableau output: directed_pairs_ranked_by_ride_type.csv.

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
WHERE pair_rank <= 650
ORDER BY ride_type, pair_rank
