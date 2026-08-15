-- ARCHIVED: unfinished exploratory query; not part of the production workflow.

WITH rides_with_duration_bands AS (
SELECT
day_of_the_week_started_on,
EXTRACT(HOUR FROM time_started) AS ride_hour,
day_of_the_week_numerical,
member_casual,
CASE
    WHEN trip_duration_seconds < 3600 THEN 'under_one_hour'
    WHEN trip_duration_seconds < 7200 THEN 'one_to_two_hours'
    WHEN trip_duration_seconds < 10800 THEN 'two_to_three_hours'
    ELSE 'three_or_more_hours'
END AS duration_band
FROM trips_dated
),

ride_hour_count AS (
SELECT
    day_of_the_week_started_on,
    day_of_the_week_numerical,
    ride_hour,
    member_casual,
    COUNT(*) AS ride_count
FROM trips_dated
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical, ride_hour, member_casual
),

WITH dates_observed_count AS(
SELECT
  COUNT(DISTINCT(date_started)) AS day_occurrences,
  day_of_the_week_started_on,
  day_of_the_week_numerical
FROM trips_dated
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical
)

SELECT
    day_of_the_week_started_on,
    day_of_the_week_numerical,
    ride_hour,
    member_casual,
    ride_count,
    ride_hour,
    duration_band,
    day_occurrences,
FROM ride_hour_count INNER JOIN dates_observed_count ON ride_hour_count.day_of_the_week_started_on = dates_observed_count.day_of_the_week_started_on
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical,
