--- Confirm results.
--- Date boundaries: Dates starting at or after July 1st 2025 and before
--- July 1st 2026 at 00:00:00.
--- Expected row count for `trips_raw` remains: 5,932,349.
--- Expected Row count for `trips_dated`: 5,932,247.
--- 102 pre-period boundary rides were excluded.

CREATE OR REPLACE TABLE trips_dated AS(
    SELECT*,
    started_at::date AS date_started,
    started_at::time AS time_started,
    ended_at::date AS date_ended,
    ended_at::time AS time_ended
    FROM trips_raw
    WHERE started_at >= TIMESTAMP '2025-07-01 00:00:00'
    AND started_at < TIMESTAMP '2026-07-01 00:00:00'
);

--- This interface displays only the final result when the script is run.
--- Run each validation query individually to inspect both counts.

SELECT COUNT(*) AS row_count_raw
FROM trips_raw;


SELECT COUNT(*) AS row_count_dated
FROM trips_dated;