
--- Begin hourly ride-volume section.
--- Purpose: compare average hourly ride volume distributions by weekday, hour and rider type.
--- ride_count / day_occurrences = avg_rides
--- Grain: one row per weekday x hour x rider type.
--- Expected rows: 336 (7 weekdays × 2 rider types × 24 hours).
--- Expected sum of ride_count: 5,764,481.
--- Expected: Tuesday - 53, all other days 52.
--- Weekdays are ordered using ISO weekday numbering, Monday = 1 through Sunday = 7.

WITH dates_observed_count AS(
SELECT
  COUNT(DISTINCT(date_started)) AS day_occurrences,
  day_of_the_week_started_on,
  day_of_the_week_numerical
FROM trips_dated
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical
),

ride_hour_count AS (
SELECT
    day_of_the_week_started_on,
    day_of_the_week_numerical,
    EXTRACT(HOUR FROM time_started) AS ride_hour,
    member_casual,
    COUNT(*) AS ride_count
FROM trips_dated
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical, ride_hour, member_casual
)

SELECT
 dates_observed_count.day_of_the_week_started_on AS weekday,
 dates_observed_count.day_of_the_week_numerical AS day_number,
 day_occurrences,
 ride_hour AS start_hour,
 member_casual AS rider_type,
 ride_count,
 ride_count / day_occurrences AS avg_rides
FROM ride_hour_count INNER JOIN dates_observed_count ON ride_hour_count.day_of_the_week_started_on = dates_observed_count.day_of_the_week_started_on
ORDER BY day_number, start_hour, rider_type;


--- This interface displays only the final result when the script is run.
--- Run each query individually to inspect both results.


WITH dates_observed_count AS(
SELECT
  COUNT(DISTINCT(date_started)) AS day_occurrences,
  day_of_the_week_started_on,
  day_of_the_week_numerical
FROM trips_dated
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical
),

ride_hour_count AS (
SELECT
    day_of_the_week_started_on,
    day_of_the_week_numerical,
    EXTRACT(HOUR FROM time_started) AS ride_hour,
    member_casual,
    COUNT(*) AS ride_count
FROM trips_dated
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical, ride_hour, member_casual
)

SELECT
    COUNT(*) AS output_rows,
    SUM(ride_count) AS total_rides
FROM ride_hour_count
INNER JOIN dates_observed_count
    ON ride_hour_count.day_of_the_week_started_on =
       dates_observed_count.day_of_the_week_started_on;