# Q4 — End stations

Navigation: [[00 Cyclistic Analysis Map|Analysis map]] · Source: [[Cyclistic Bike share scratchpad 1|Original scratchpad]]

> **Primary question:** Do `member` and `casual` appear to end their rides at any station in particular?

## First inquiry - What are the most stopped at stations for `member` and `casual` respectively?

### `member` most stopped at stations with `end_lat` and `end_lng`

```postgresql
--- member end_station_counts
WITH member_end_station_counts AS(
SELECT
end_station_name,
AVG(end_lat) AS end_lat,
AVG(end_lng) AS end_lng,
COUNT() FILTER(member_casual = 'member') AS member_stops,
FROM trips_dated
WHERE end_station_name IS NOT NULL
GROUP BY end_station_name
)

SELECT
end_station_name,
end_lat,
end_lng,
member_stops,
(member_stops) / SUM(member_stops) OVER() * 100 AS percent_of_member_stops,
FROM member_end_station_counts
WHERE end_lat IS NOT NULL AND end_lng IS NOT NULL
ORDER BY member_stops DESC
```
![[Pasted image 20260729123903.png]]

### `casual` most stopped at stations with `end_lat` and `end_lng`
![[Pasted image 20260729123933.png]]

### Visualized in a heatmap on a map of chicago in tableau
![[Pasted image 20260729123957.png]]
> This has all the end stations, and is hard to discern what was or wasn't a popular one because there's so much overlap.

### Top ~10% of rides named end stations
