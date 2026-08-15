-- Purpose: compare ride-duration distributions by weekday and rider type.
-- Grain: one row per weekday, rider type, and duration band.
-- Duration bands: under 1 hour, 1–<2 hours, 2–<3 hours, and 3+ hours.
-- The 3+ hour band ends below 24 hours because rides of 24+ hours were excluded.
-- Percentage denominator: all rides for the same weekday and rider type.
-- Expected rows: 56 (7 weekdays × 2 rider types × 4 duration bands).
-- Expected sum of ride_count: 5,764,481.
-- Expected duration_band_percent: sums to 100% within each weekday/rider-type group.
-- Weekdays are ordered using ISO weekday numbering, Monday = 1 through Sunday = 7.

--- Assign one duration band to every cleaned ride.

WITH rides_with_duration_bands AS (
SELECT
day_of_the_week_started_on,
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

--- Aggregate classified rides by weekday, rider type, and duratation band.

duration_band_counts AS (
SELECT
    day_of_the_week_started_on,
    day_of_the_week_numerical,
    member_casual,
    duration_band,
    COUNT(*) AS ride_count
FROM rides_with_duration_bands
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical, member_casual, duration_band
),

---  Calculate number of occurences of each weekday for denominator later

dates_observed_count AS(
SELECT
  COUNT(DISTINCT(date_started)) AS day_occurrences,
  day_of_the_week_started_on,
  day_of_the_week_numerical
FROM trips_dated
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical
)

--- Calculate each band's share of rides within its weekday and rider type.

SELECT
  duration_band_counts.day_of_the_week_started_on,
  duration_band_counts.day_of_the_week_numerical,
  member_casual,
  duration_band,
  ride_count,
  ride_count / SUM(ride_count) OVER(
  PARTITION BY duration_band_counts.day_of_the_week_started_on, member_casual) * 100 
  AS duration_band_percent,
  ride_count / day_occurrences as avg_rides_per_duration
FROM duration_band_counts INNER JOIN dates_observed_count ON duration_band_counts.day_of_the_week_started_on = dates_observed_count.day_of_the_week_started_on
ORDER BY day_of_the_week_numerical;






