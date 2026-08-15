# Q3 — Start stations

Navigation: [[00 Cyclistic Analysis Map|Analysis map]] · Source: [[Cyclistic Bike share scratchpad 1|Original scratchpad]]

> **Primary question:** Do `member` and `casual` appear to start their rides from anywhere in particular?

> [!note] Boundary
> This station work emerged while inspecting duration cohorts, but it is collected here because its analytical subject is where rides begin.

### Inspecting `start_station_name` for rides between one and two hours

#### `casual` rides
```postgresql
WITH one_to_two_station_count AS (
SELECT
start_station_name,
COUNT(*) AS station_count,
FROM trips_dated
WHERE trip_duration_seconds >= 3600 AND trip_duration_seconds < 7200 AND member_casual = 'casual'
GROUP BY start_station_name
ORDER BY station_count DESC
)

SELECT
start_station_name,
station_count AS station_rides,
SUM(station_count) OVER () total_stations,
station_rides / total_stations * 100 AS station_percent
FROM one_to_two_station_count
```
![[Pasted image 20260728081024.png]]
> NULL is 7.33%
> Navy Pier is 5.15%
> DuSable Lake Shore Dr & Monroe St is 4.1%
> No extreme concentration per start_station_name. Perhaps these are located nearby each other, though.
#### `member` rides
```postgresql
WITH one_to_two_station_count_member AS (
SELECT
start_station_name,
COUNT(*) AS station_count,
FROM trips_dated
WHERE trip_duration_seconds >= 3600 AND trip_duration_seconds < 7200 AND member_casual = 'member'
GROUP BY start_station_name
ORDER BY station_count DESC
)
SELECT
start_station_name
station_count AS station_rides,
SUM(station_count) OVER () total_stations,
station_rides / total_stations * 100 AS station_percent
FROM one_to_two_station_count_member
```
![[Pasted image 20260728090232.png]]

### Inspecting `start_station_name` for  riders across all length of rides
#### `casual` rides
```postgresql
WITH total_station_count AS (
SELECT
start_station_name,
COUNT(*) AS station_count
FROM trips_dated
WHERE member_casual = 'casual'
GROUP BY start_station_name
ORDER BY station_count DESC
)

SELECT
start_station_name,
station_count AS station_rides,
SUM(station_count) OVER () AS total_stations,
station_rides / total_stations * 100 AS station_percentage
FROM total_station_count
```
![[Pasted image 20260728081134.png]]
> NULL is even more dominant at 20%
> Navy Pier is second, with a lower share ~2%
> > Perhaps the lower share is due to NULL being even more dominant
> Dusable Lake Shore Dr & Monroe St is third at ~1.6%
> > Perhaps the lower share is due to NULL being even more dominant!
#### `member` rides
```postgresql
WITH total_station_count_member AS (
SELECT
start_station_name,
COUNT(*) AS station_count
FROM trips_dated
WHERE member_casual = 'member'
GROUP BY start_station_name
ORDER BY station_count DESC
)

SELECT
start_station_name,
station_count AS station_rides,
SUM(station_count) OVER () AS total_stations,
station_rides / total_stations * 100 AS station_percentage
FROM total_station_count_member
```
![[Pasted image 20260728090459.png]]


### Inspecting rides under one hour by station
#### `casual` rides
```postgresql
WITH under_one_trips_casual AS(
SELECT
start_station_name,
COUNT(*) as station_count
FROM trips_dated
WHERE trip_duration_seconds < 3600 AND member_casual = 'casual'
GROUP BY start_station_name
ORDER BY station_count DESC
)

SELECT
start_station_name,
station_count AS station_rides,
SUM(station_count) OVER () as total_stations,
station_rides / total_stations * 100 AS station_percentage
FROM under_one_trips_casual
```
![[Pasted image 20260728085648.png]]
#### `member` rides
```postgresql
WITH under_one_trips_member AS(
SELECT
start_station_name,
COUNT(*) as station_count
FROM trips_dated
WHERE trip_duration_seconds < 3600 AND member_casual = 'member'
GROUP BY start_station_name
ORDER BY station_count DESC
)

SELECT
start_station_name,
station_count AS station_rides,
SUM(station_count) OVER () AS total_stations,
station_rides / total_stations * 100 AS station_percentage
FROM under_one_trips_member
```
![[Pasted image 20260728090550.png]]

#### Viz of above tables
![[Pasted image 20260728111242.png]]
![[Pasted image 20260728111257.png]]
![[Pasted image 20260728111315.png]]

#### Top 10 named stations for total rides![[Pasted image 20260729091857.png]]

#### Named stations percent of rides under one hour
![[Pasted image 20260729091949.png]]

#### Named stations percent of rides between one and two hours
![[Pasted image 20260729092029.png]]

#### Top ~10% of name station ride starts
![[Pasted image 20260730111827.png]]


