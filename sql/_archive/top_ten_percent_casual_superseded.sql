-- ARCHIVED: superseded exploratory query; not part of the production workflow.

--- casual start_station_counts

WITH casual_start_station_counts AS (
    SELECT
        start_station_name,
        AVG(start_lat) AS start_lat,
        AVG(start_lng) AS start_lng,
        COUNT() FILTER(member_casual = 'casual') AS casual_starts
    FROM trips_dated
    WHERE start_station_name IS NOT NULL
    GROUP BY start_station_name
),

--- calculate the stations that represent ~10% of mappable casual-ride-stops

casual_running_counts AS (
    SELECT
        start_station_name,
        start_lat,
        start_lng,
        casual_starts,
        SUM(casual_starts) OVER(
            ORDER BY casual_starts DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_count
        SUM(casual_starts) OVER () AS total_count
    FROM casual_start_station_counts
    WHERE start_lat IS NOT NULL
        AND start_lng IS NOT NULL
    ORDER BY casual_starts DESC
)

SELECT
    start_station_name,
    start_lat,
    start_lng,
    casual_starts,
    casual_starts / total_count * 100 AS percent_of_casual_starts,
    running_count,
    total_count
FROM casual_running_counts
WHERE running_count - casual_starts < total_count / 10.0
ORDER BY casual_starts DESC
