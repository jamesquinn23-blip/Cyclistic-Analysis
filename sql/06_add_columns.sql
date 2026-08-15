--- Added column with day name of the day of the week the trip started on to make it easier to understand
--- when rides were happening.

ALTER TABLE trips_dated
ADD COLUMN day_of_the_week_started_on VARCHAR;

--- `day_of_the_week_numerical` uses ISO ordering.
ALTER TABLE trips_dated
ADD COLUMN day_of_the_week_numerical INTEGER;

--- Is initially calculated from the two timestamps.
ALTER TABLE trips_dated
ADD COLUMN trip_duration INTERVAL;

--- Will be populated after the DST correction so it reflects the corrected duration.
ALTER TABLE trips_dated
ADD COLUMN trip_duration_seconds DOUBLE;


UPDATE trips_dated
SET day_of_the_week_started_on = dayname(date_started),
day_of_the_week_numerical = isodow(date_started),
trip_duration = (ended_at) - (started_at);


--- Confirmation:
--- Expected unchanged row count: 5,932,212
SELECT
    COUNT(*) as row_count
FROM trips_dated;
