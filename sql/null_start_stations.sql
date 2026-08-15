--- how many rides across the dataset have NULL for start_station?

WITH total_ride_counter AS (
  SELECT
    start_station_name,
    COUNT(*) AS station_starts,
  FROM trips_dated
  
  GROUP BY start_station_name
)

SELECT
  start_station_name,
  station_starts,
  SUM(station_starts) OVER() as total_rides,
  station_starts / total_rides * 100 as station_percent_of_rides
FROM total_ride_counter
ORDER BY station_percent_of_rides DESC

--- confirm: 20.16% of total rides originate with NULL for start_station_name
--- confirm: total_rides = 5,764,481


-- - how many rides for member riders start at NULL?
WITH member_ride_counter AS (
  SELECT
    start_station_name,
    COUNT(*) AS station_starts,
    member_casual
  FROM trips_dated
  WHERE member_casual = 'member'
  GROUP BY start_station_name, member_casual
)

SELECT
  start_station_name,
  member_casual,
  station_starts,
  SUM(station_starts) OVER() as total_rides,
  station_starts / total_rides * 100 as station_percent_of_rides
FROM member_ride_counter
ORDER BY station_percent_of_rides DESC

--- confirm 20.10% for member riders
--- confirm: total_rides = 3,732,737


--- how many rides for casual riders start at NULL?
WITH casual_ride_counter AS (
  SELECT
    start_station_name,
    COUNT(*) AS station_starts,
    member_casual
  FROM trips_dated
  WHERE member_casual = 'casual'
  GROUP BY start_station_name, member_casual
)

SELECT
  start_station_name,
  member_casual,
  station_starts,
  SUM(station_starts) OVER() as total_rides,
  station_starts / total_rides * 100 as station_percent_of_rides
FROM casual_ride_counter
ORDER BY station_percent_of_rides DESC

--- confirm: 20.27% for casual riders
--- confirm: total_rides = 2,031,745