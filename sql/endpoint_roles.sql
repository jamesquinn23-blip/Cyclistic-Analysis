--- `endpoint_role` station_counts
--- Purpose: identify the smallest set of highest-volume, mappable named stations needed to reach approximately
--- 10% of activity within each rider-type/endpoint population, then return all four available comparisons for those
--- stations.
--- Grain: one row per `station_name` x `rider_type` x `endpoint_role`.
--- Expected: rows: 100 (25 stations * 2 rider_types * 2 endpoint_roles).
--- Expected: casual starts total_count: 1,619,877.
--- Expected: casual ends total_count: 1,573,500.
--- Expected: member starts total_count: 2,982,462.
--- Expected: member ends total_count: 2,990,853.
--- Expected: the independently qualifying stations sum to just over 10% within each rider-type/endpoint group;
--- the expanded comparison output is expected to exceed 10%.

WITH start_station_counts AS (
  SELECT
    start_station_name AS station_name,
    AVG(start_lat) AS station_lat,
    AVG(start_lng) AS station_lng,
    'start' AS endpoint_role,
    member_casual AS rider_type,
    COUNT(*) AS ride_count
  FROM trips_dated
  WHERE start_station_name IS NOT NULL
  GROUP BY start_station_name, member_casual
),

end_station_counts AS (
  SELECT
  end_station_name AS station_name,
  AVG(end_lat) AS station_lat,
  AVG(end_lng) AS station_lng,
  'end' AS endpoint_role,
  member_casual AS rider_type,
  COUNT(*) AS ride_count
  FROM trips_dated
  WHERE end_station_name IS NOT NULL
  GROUP BY end_station_name, member_casual
),


station_counts AS (
  SELECT
  station_name,
  station_lat,
  station_lng,
  endpoint_role,
  rider_type,
  ride_count
  FROM start_station_counts UNION ALL
    SELECT
        station_name,
        station_lat,
        station_lng,
        endpoint_role,
        rider_type,
        ride_count
    FROM end_station_counts
),


running_counts AS (
  SELECT
  station_name,
  station_lat,
  station_lng,
  endpoint_role,
  rider_type,
  ride_count,
  SUM(ride_count) OVER(
    PARTITION BY rider_type, endpoint_role
    ORDER BY ride_count DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_count,
  SUM(ride_count) OVER(
    PARTITION BY rider_type, endpoint_role
  ) as total_count
  FROM station_counts
  WHERE station_lat IS NOT NULL
  AND station_lng IS NOT NULL
  ORDER BY endpoint_role DESC
),


qualifying_stations AS (
  SELECT
    DISTINCT(station_name)
  FROM running_counts
  WHERE running_count - ride_count < total_count / 10.0
)



SELECT     
  running_counts.station_name,
  station_lat,
  station_lng,
  rider_type,
  endpoint_role,
  ride_count / total_count * 100.0 AS percent_of_endpoint_role_x_rider_type,
  running_count,
  total_count
FROM running_counts
INNER JOIN qualifying_stations
  ON running_counts.station_name = qualifying_stations.station_name
ORDER BY endpoint_role DESC 



--- Validate: `output_rows` = 100
--- Validate: `unique_stations` = 25
--- This interface only supplies one output per query, so you must run this in separate cells.

WITH start_station_counts AS (
  SELECT
    start_station_name AS station_name,
    AVG(start_lat) AS station_lat,
    AVG(start_lng) AS station_lng,
    'start' AS endpoint_role,
    member_casual AS rider_type,
    COUNT(*) AS ride_count
  FROM trips_dated
  WHERE start_station_name IS NOT NULL
  GROUP BY start_station_name, member_casual
),

end_station_counts AS (
  SELECT
  end_station_name AS station_name,
  AVG(end_lat) AS station_lat,
  AVG(end_lng) AS station_lng,
  'end' AS endpoint_role,
  member_casual AS rider_type,
  COUNT(*) AS ride_count
  FROM trips_dated
  WHERE end_station_name IS NOT NULL
  GROUP BY end_station_name, member_casual
),


station_counts AS (
  SELECT
  station_name,
  station_lat,
  station_lng,
  endpoint_role,
  rider_type,
  ride_count
  FROM start_station_counts UNION ALL
    SELECT
        station_name,
        station_lat,
        station_lng,
        endpoint_role,
        rider_type,
        ride_count
    FROM end_station_counts
),


running_counts AS (
  SELECT
  station_name,
  station_lat,
  station_lng,
  endpoint_role,
  rider_type,
  ride_count,
  SUM(ride_count) OVER(
    PARTITION BY rider_type, endpoint_role
    ORDER BY ride_count DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_count,
  SUM(ride_count) OVER(
    PARTITION BY rider_type, endpoint_role
  ) as total_count
  FROM station_counts
  WHERE station_lat IS NOT NULL
  AND station_lng IS NOT NULL
  ORDER BY endpoint_role DESC
),


qualifying_stations AS (
  SELECT
    DISTINCT(station_name)
  FROM running_counts
  WHERE running_count - ride_count < total_count / 10.0
)



SELECT
  COUNT(*) AS output_rows,
  COUNT(DISTINCT running_counts.station_name) AS unique_stations
FROM running_counts
INNER JOIN qualifying_stations
  ON running_counts.station_name = qualifying_stations.station_name;