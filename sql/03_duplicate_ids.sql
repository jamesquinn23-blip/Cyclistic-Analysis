WITH duplicate_ids AS (
    SELECT ride_id
    FROM trips_raw
    GROUP BY ride_id
    HAVING COUNT(ride_id) > 1
)

--- Confirm results.
--- 35 distinct duplicated `ride_id` values.
--- Each appears twice.
--- The inspection query therefore returns 70 rows.
--- This represents 35 excess records.


SELECT trips_raw.*
FROM trips_raw
INNER JOIN duplicate_ids
ON trips_raw.ride_id = duplicate_ids.ride_id
ORDER BY trips_raw.ride_id;