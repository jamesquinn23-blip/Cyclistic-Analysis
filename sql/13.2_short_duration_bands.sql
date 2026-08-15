-- Purpose: compare short ride-duration distributions by weekday and rider type.
-- Grain: one row per weekday, rider type, and duration band.
-- Percentage denominator: all rides for the same weekday and rider type.
-- Expected rows: 112 (7 weekdays x 2 rider types x 8 duration bands).
-- Expected sum of ride_count: 5,764,481.
-- Tableau output: short_duration_bands_x_ridertype_x_weekday.csv.

with short_duration_bands AS (
  SELECT
    day_of_the_week_started_on,
    day_of_the_week_numerical,
    member_casual AS rider_type,
    CASE
      WHEN trip_duration_seconds < 300 THEN '01_to_05_min'
      WHEN trip_duration_seconds < 600 THEN '05_to_10_min'
      WHEN trip_duration_seconds < 900 THEN '10_to_15_min'
      WHEN trip_duration_seconds < 1200 THEN '15_to_20_min'
      WHEN trip_duration_seconds < 1800 THEN '20_to_30_min'
      WHEN trip_duration_seconds < 2700 THEN '30_to_45_min'
      WHEN trip_duration_seconds < 3600 THEN '45_to_60_min'
      ELSE '60+_min'
    END AS duration_band
    FROM trips_dated
),

short_duration_bands_counts AS (
  SELECT
    day_of_the_week_started_on,
    day_of_the_week_numerical,
    rider_type,
    duration_band,
    COUNT(*) AS ride_count
  FROM short_duration_bands
  GROUP BY day_of_the_week_started_on, day_of_the_week_numerical, rider_type, duration_band
),

dates_observed_count AS(
SELECT
  COUNT(DISTINCT(date_started)) AS day_occurrences,
  day_of_the_week_started_on,
  day_of_the_week_numerical
FROM trips_dated
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical
)

SELECT
  short_duration_bands_counts.day_of_the_week_started_on,
  short_duration_bands_counts.day_of_the_week_numerical,
  rider_type,
  duration_band,
  ride_count,
  ride_count / SUM(ride_count) OVER(
    PARTITION BY short_duration_bands_counts.day_of_the_week_started_on, rider_type) * 100
    AS duration_band_percent,
  ride_count / day_occurrences as avg_duration_rides_per_day
FROM short_duration_bands_counts INNER JOIN dates_observed_count ON short_duration_bands_counts.day_of_the_week_started_on = dates_observed_count.day_of_the_week_started_on
ORDER BY day_of_the_week_numerical
