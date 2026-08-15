--- Clean trips from `trips_dated` where the duration is less than or equal to one minute,
--- as these rides were deemed non-representative of bike-use across the cohorts.
--- The final validation below confirms that no rides lasting one minute or
--- less remain; the deleted-row count should be recorded from the executed
--- cleaning run rather than inherited from an earlier table version.

DELETE FROM trips_dated
WHERE trip_duration_seconds <= 60;

--- Clean trips from `trips_dated` where duration is greater than 24 hours,
--- as these rides were deemed non-representative of bike-use across the cohorts.
--- The final validation below confirms that no rides lasting 2 over 24 hours
--- remain; the deleted-row count should be recorded from the executed cleaning
--- run rather than inherited from an earlier table version.

DELETE FROM trips_dated
WHERE trip_duration_seconds > 86400;

--- Confirm row count: 5,764,481
--- Confirm trips at or under a minute are: 0
--- Confirm trips over 24 hours are: 0

SELECT
    COUNT(*) AS row_count,
    COUNT(*) FILTER(trip_duration_seconds <= 60) AS minute_or_less,
    COUNT(*) FILTER(trip_duration_seconds > 86400) AS '24_hours_or_more'
FROM trips_dated;
