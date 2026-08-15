--- Clean two Daylight saving time issues:
--- Nov 2nd 2025:
--- Rides ending before they started because of DST "fall-back" logic
--- Add an hour to their trip_duration, leave the original ended_at &
--- started_at columns unchanged.
--- Rows affected: 29

UPDATE trips_dated
SET trip_duration = trip_duration + INTERVAL '1 hour'
WHERE date_started = '2025-11-02'
AND ended_at < started_at
AND trip_duration < INTERVAL '0 hour';

--- March 8th 2026:
--- Rides with a duration 1 hour longer than elapsed ride time because of DST
--- "spring-forward" logic.
--- These would be trips that started before 2AM and ended at or after 3AM, 
--- crossing the DST transition, artificially increasing duration.
--- Rows affected: 40


UPDATE trips_dated
SET trip_duration = trip_duration - INTERVAL '1 hour'
WHERE date_started = '2026-03-08'
  AND started_at < '2026-03-08 02:00:00'
  AND ended_at >= '2026-03-08 03:00:00'
  AND ended_at < '2026-03-09 00:00:00'
  AND ended_at - started_at = trip_duration;


--- Confirm total row count remains 5,932,212
--- Confirm uncorrected records: 0
--- Confirm negative trips: 0
SELECT
  COUNT(*) AS row_count,
  COUNT(*) FILTER(WHERE date_started = '2026-03-08'
  AND started_at < '2026-03-08 02:00:00'
  AND ended_at >= '2026-03-08 03:00:00'
  AND ended_at < '2026-03-09 00:00:00'
  AND ended_at - started_at = trip_duration) AS uncorrected_crossings,
  COUNT(*) FILTER(trip_duration < INTERVAL '0 hour') AS negative_duration_rides
FROM trips_dated;