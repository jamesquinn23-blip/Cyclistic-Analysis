# Cyclistic data cleaning log

Navigation: [[00 Cyclistic Analysis Map|Analysis map]] · Source: [[Cyclistic Bike share scratchpad 1|Original scratchpad]]

> [!info] Scope
> This note preserves the cleaning, feature-engineering, validation, and row-impact record from the chronological scratchpad.

## Cleaning projects

1. Nulls
	- [ ] There appear to be quite a few `null` values in `end_station_name` and `end_station_id`.
	- [ ] In the end, null values in `end_station_name` and `end_station_id` can be handled according to each question
2. Columns
	- [x] The columns `started_at` and `ended_at` could be split into `date_started`, `date_ended` and `time_started` and `time_ended`
	- [x] Add `day_of_the_week_started_on` column with dayname(date_started)
	- [x] Add `trip_duration` column (`ended_at` - `started_at`)
	- [x] Add day_of_the_week_numerical
3. Unrealistic/impossible values
	1. Proposed cut offs before analysis
		- [x] Rides less than 1 minute
		- [x] Rides longer than 24 hours
	2. Discovered boundary issues:
		1. November 2nd DST "fall-backward": `started_at` > `ended_at1`
			- [x] Clean the derived `trip_duration` by adding an hour
		2. March 8th DST "spring forward":  `ended_at` inflated by 1 hour for trips whose duration crosses the 02:00:00 boundary on March 8th.
			- [x] Clean the derived `trip_duration` by subtracting an hour
4. Rides with duplicate `ride_id`s
	- [x] Remove redundant copies of exact duplicates
	- [x] Investigate repeated IDs that contain complementary or conflicting information
	- [x] If ambiguous `ride_id`s are rare, exclude every record associated with those IDs rather than subjectively choosing the "less outlandish" one.
	- [x]  If they are common, investigate the underlying cause before discarding them.

### Original table state

```postgresql
SELECT *
FROM trips_raw
```
```
Rows: 6,611,253
Columns: 14
`ride_id`
`rideable_type`
`started_at`
`ended_at`
`start_station_name`
`start_station_id`
`end_station_name`
`end_station_id`
`start_lat`
`start_lng`
`end_lat`
`end_lng`
`member_casual`
`filename`
```

### Discover duplicate `ride_id`s

```postgresql
WITH duplicate_ids as (
SELECT ride_id
FROM trips_raw
GROUP BY ride_id
HAVING COUNT(ride_id) > 1
)
SELECT trips_raw.*
FROM trips_raw
INNER JOIN duplicate_ids
ON trips_raw.ride_id = duplicate_ids.ride_id
ORDER BY trips_raw.ride_id
```


There are 35 duplicate `ride_id`s affecting 70 records.

It appears that all 35 duplicates appear `started_at` at some time on 2026-04-30 and `ended_at` some time on 2026-05-01. Other than the filename differing they are exact matches.

One ride should contribute one observation. 

**Rule Adopted:** Assign a ride to its starting month and retain one record per `ride_id`.

### Cleaning up `started_at` and `ended_at`
#### CREATE TABLE `trips_dated`

```postgresql
CREATE TABLE trips_dated AS (
SELECT *,
started_at::date AS date_started,
started_at::time AS time_started,
ended_at::date AS date_ended,
ended_at::time AS time_ended
FROM trips_raw
)
```
```postgresql
Rows: 6,611,253
Columns: 18
```

### DELETE FROM `ride_id`s from trips_dated

```postgresql
DELETE FROM trips_dated
WHERE filename = 'data\202605-divvy-tripdata.csv' AND date_started = '2026-04-30'
RETURNING ride_id
```

#### row_count check
```postgresql
SELECT *
FROM trips_dated

rows: 6,611,218
columns: 18

```

#### duplicate `ride_id`s check after cleaning

```postgresql
WITH may_duplicates AS (
SELECT *
FROM trips_dated
WHERE filename = 'data\202605-divvy-tripdata.csv' AND date_started = '2026-04-30'
)
SELECT trips_dated.*
FROM trips_dated
INNER JOIN may_duplicates
ON trips_dated.ride_id = may_duplicates.ride_id
ORDER BY trips_dated.ride_id

0 rows returned
```

### ALTER TABLE `trips_dated` ADD COLUMN
```postgresql
ALTER TABLE trips_dated
ADD COLUMN day_of_the_week_started_on VARCHAR;

UPDATE trips_dated
SET day_of_the_week_on = dayname(date_started)
WHERE day_of_the_week_started_on IS NULL;

rows: 6,611,218
```
```postgresql
SELECT DISTINCT(day_of_the_week_started_on)
FROM trips_dated


|     | `day_of_the_week_started_on` |
| --- | ---------------------------- |
| 1   | Monday                       |
| 2   | Tuesday                      |
| 3   | Wednesday<br>                |
| 4   | Thursday                     |
| 5   | Friday                       |
| 6   | Saturday                     |
|     | Sunday                       |

```

### ALTER TABLE `trips_dated` ADD COLUMN

```postgresql
ALTER TABLE trips_dated
ADD COLUMN day_of_the_week_numerical INTEGER;

UPDATE trips_dated
SET day_of_the_week_numerical = isodow(date_started)
WHERE day_of_the_week_numerical IS NULL;

rows: 6,611,218


```

```postgresql
SELECT *
FROM trips_dated

day_of_the_week_started_on : Thursday
day_of_the_week_numerical : 4
```

```postgresql
SELECT COUNT(DISTINCT(day_of_the_week_numerical))
FROM trips_dated

count: 7
```

```postgresql
SELECT *
FROM trips_dated
WHERE day_of_the_week_numerical IS NULL

rows: 0
```

### ALTER `trips_dated` ADD COLUMN

```postgresql
ALTER TABLE trips_dated
ADD COLUMN trip_duration INTERVAL;

UPDATE trips_dated
SET trip_duration = ((ended_at) - (started_at))
WHERE trip_duration IS NULL

rows: 6,611,218
```

```postgresql
SELECT *
FROM trips_dated
WHERE trip_duration IS NULL

rows: 0
```

### Check for impossible ride lengths

```postgresql
SELECT *
FROM trips_dated
WHERE ended_at < started_at

rows: 29

```
> An interesting occurrence! All 29 rows are dated for November 2, 2025, meaning they have a length that is an hour shorter than the real ride was because of daylight-savings.
> This makes me realize that I need to check for daylight-savings in spring, as well. March 8 2026

```postgresql
SELECT *
FROM trips_dated
WHERE (started_at < '2026-03-08 01:59:59') AND (ended_at > '2026-03-08 03:00:00')

rows: 40
```
> Additionally, discovered a potential maximum for ride length: 25 hours.

```postgresql
SELECT *
FROM trips_dated
WHERE trip_duration > INTERVAL '24:00:00'
ORDER BY trip_duration DESC

max: 1 day 02:14:54.011

```

####  Cleaning DST-affected negative durations on November 2nd

```postgresql
UPDATE trips_dated  
SET trip_duration = trip_duration + INTERVAL '1 hour'  
WHERE ended_at < started_at AND trip_duration < INTERVAL '0 hour'

rows affected: 29
```

```postgresql
SELECT *
FROM trips_dated
WHERE ended_at < started_at AND trip_duration < INTERVAL '0 hour'

rows returned: 0

```

```postgresql
SELECT *
FROM trips_dated
WHERE trip_duration < INTERVAL '0 hour'

rows returned: 0
```

#### Cleaning the DST-affected durations on March 8th

```postgresql
SELECT *
FROM trips_dated
WHERE (started_at < '2026-03-08 02:00:00') AND (ended_at >= '2026-03-08 03:00:00') AND ((ended_at - started_at) = trip_duration)

rows returned: 40
```

```postgresql
UPDATE trips_dated
SET trip_duration = trip_duration - INTERVAL '1 hour'
WHERE (started_at < '2026-03-08 02:00:00') AND (ended_at >= '2026-03-08 03:00:00') AND ((ended_at - started_at) = trip_duration)

rows affected: 40
```

##### Checking the cleaning logic

```postgresql
SELECT *
FROM trips_dated
WHERE (started_at < '2026-03-08 02:00:00') AND (ended_at >= '2026-03-08 03:00:00') AND ((ended_at - started_at) = trip_duration)

rows returned: 0
```

### Explore trip_durations for cleaning
> Because `trip_duration` is an INTERVAL, I will ALTER TABLE and ADD COLUMN

```postgresql
ALTER TABLE trips_dated
ADD COLUMN trip_duration_seconds DOUBLE;

UPDATE trips_dated
SET trip_duration_seconds = EPOCH(trip_duration)
WHERE trip_duration_seconds IS NULL

row count: 6,611,218

```


**Explore `trip_duration_seconds` mathematically:

```postgresql
SUMMARIZE SELECT trip_duration_seconds
FROM trips_dated

| column_name           | column_type | min   | max       | approx_unique | avg               | std               | q25               | q50              | q75               | count   | null_percent |
| --------------------- | ----------- | ----- | --------- | ------------- | ----------------- | ----------------- | ----------------- | ---------------- | ----------------- | ------- | ------------ |
| trip_duration_seconds | DOUBLE      | 0.046 | 94494.011 | 1942423       | 962.1380758686166 | 3280.686985972049 | 324.7435518871911 | 569.871799007703 | 1001.410194658252 | 6611218 | 0.00         |
|                       |             |       |           |               |                   |                   |                   |                  |                   |         |              |

```


**Explore `trip_duration_seconds` under or equal to 60 seconds

```postgresql
SELECT *
FROM trips_dated
WHERE trip_duration_seconds <= 60
ORDER BY trip_duration_seconds ASC

row count: 181,840

```

**Explore `trip_duration_seconds` under and equal to 1 second, 1 - 10-inclusive seconds, 10 - 30-inclusive seconds and 30 - 60-inclusive seconds

```postgresql
SELECT
COUNT() FILTER(trip_duration_seconds <= 1) AS count_under_one,
COUNT() FILTER(1 < trip_duration_seconds AND trip_duration_seconds <= 10) AS count_one_to_ten,
COUNT() FILTER(10 < trip_duration_seconds AND trip_duration_seconds <= 30) AS count_ten_to_thirty,
COUNT() FILTER(30 < trip_duration_seconds AND trip_duration_seconds <= 60) AS count_thirty_to_sixty
FROM trips_dated

| count_under_one | count_one_to_ten | count_ten_to_thirty | count_thirty_to_sixty | total_one_minute_and_less |
| --------------- | ---------------- | ------------------- | --------------------- | ------------------------- |
| 2046            | 41424            | 86819               | 51551                 | 181840                    |

```

### Cleaning decision: remove all rows where trip_duration_seconds is <= 60

> Rides lasting one minute or less were considered non-representative of meaningful bike use.
> The rule below exclused 181840 rides, or 2.75% of overall rides.
> It exclused 3.85% of total casual rides and 2.12% of member rides.
> The difference was measure and accepted because the same behavior-based rule applies to both groups.

```postgresql
DELETE FROM trips_dated
WHERE trip_duration_seconds <= 60
returning ride_id


rows affected: 181840
rows remaining: 6429378
```


### Long trip_duration cleaning exploration

1 hour = 3600
6 hours = 21600 seconds
12 hours = 43200 seconds
18 hours = 64800 seconds
24 hours = 86400 seconds
25 hours = 90000 seconds
26 hours = 93600 seconds

```postgresql
SELECT
member_casual,
COUNT() FILTER(trip_duration_seconds <= 21600) AS under_six_hours,
COUNT() FILTER(21600 < trip_duration_seconds AND trip_duration_seconds <= 43200) AS count_six_to_twelve_hours,
COUNT() FILTER(43200 < trip_duration_seconds AND trip_duration_seconds <= 64800) AS count_twelve_to_eighteen_hours,
COUNT() FILTER(64800 < trip_duration_seconds AND trip_duration_seconds <= 86400) AS count_eighteen_to_twentyfour_hours,
COUNT() FILTER(86400 < trip_duration_seconds AND trip_duration_seconds <= 90000) AS count_twentyfour_to_twentyfive_hours,
COUNT() FILTER(90000 < trip_duration_seconds AND trip_duration_seconds <= 93600) AS count_twentyfive_to_twentysix_hours,
COUNT() FILTER(93600 < trip_duration_seconds) AS count_above_twentysix,
count_six_to_twelve_hours + count_twelve_to_eighteen_hours + count_eighteen_to_twentyfour_hours + count_twentyfour_to_twentyfive_hours + count_twentyfive_to_twentysix_hours + count_above_twentysix as total_trips_above_six_hours
FROM trips_dated
GROUP BY member_casual
ORDER BY member_casual ASC

| `member_casual` | under 6hr | 6-12hr | 12-18hr | 18-24hr | 24-25hr | 25-26hr | above 26hr | total above 6hr |
| --------------- | --------- | ------ | ------- | ------- | ------- | ------- | ---------- | ------------- |
| casual          | 2307431   | 1412   | 969     | 751     | 5401    | 2       | 1          | 8536          |
| member          | 4110821   | 782    | 603     | 395     | 1110    | 0       | 0          | 2890          |

```

**The concentration of rides above 24 hours are qualitatively different from an ordinary tapering duration distribution. It suggests some operational boundary or recording process, although the data alone cannot prove the cause**

```postgresql
SELECT
member_casual,
COUNT() FILTER(trip_duration_seconds > 86400) AS rides_above_24hr,
COUNT(*) AS all_rides,
rides_above_24hr / all_rides * 100 AS proposed_removal_percentage
FROM trips_dated
GROUP BY member_casual
ORDER BY member_casual ASC 

| `member_casual` | number of rides above 24hr | all rides | proposed removal percentage |
| --------------- | -------------------------- | --------- | --------------------------- |
| casual          | 5404                       | 2315967   | .2333%                      |
| member          | 1110                       | 4113411   | .0268%                      |

```

**Adopted rule and validation targets:**
> Exclude rides lasting more than 24 hours.
> Expected removal: 6,514 rows
> Expected remaining table: 6,422,864 rows
> Validate that zero records remain with duration over 86,400 seconds


```postgresql
DELETE FROM trips_dated
WHERE trip_duration_seconds > 86400


rows affected: 6,514
rows remaining: 6,422,864
```

