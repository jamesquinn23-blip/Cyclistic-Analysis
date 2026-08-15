# Cyclistic analysis map

> [!note] Source preservation
> These notes were split from [[Cyclistic Bike share scratchpad 1|Original scratchpad]]. The source remains the chronological record; the notes below reorganize the same work by analytical purpose.

## Project framing

1. How do annual members and casual riders use Cyclistic bikes differently?
	1. What data do I have to answer these questions?
		1. `ride_id` - unique rides
		2. `rideable_type`
			1. `classic_bike`
			2. `electric_bike`
			3. Do member types use one more than the other?
			4. Is there evidence this is preference? Or prevalence based?
		3. `started_at` & `ended_at`
			1. Do member types use bikes for different ride lengths?
			2. Do member types use bikes at a different time of day?
			3. Do member types use bikes on different days of the week?
		4. `start_station_name` & `start_station_id`
			1. Do member types start at different locations?
		5. `end_station_name` & `end_station_id`
			1. Do member types end at different locations?
		6. `start_lat` & `start_lng` 
			1. Do member types start at different locations?
		7. `end_lat` & `end_lng`
			1. Do member types start at different locations?
		8. `member_casual`
			1. Seems to be an oddly named `member_type`
				1. member & casual
		9. `filename`
			1. filename contains the month of the `ride_id` hidden in there.

| Hours | Seconds | Hours | Seconds |
| ----- | ------- | ----- | ------- |
| 1     | 3600    | 13    | 46800   |
| 2     | 7200    | 14    | 50400   |
| 3     | 10800   | 15    | 54000   |
| 4     | 14400   | 16    | 57600   |
| 5     | 18000   | 17    | 61200   |
| 6     | 21600   | 18    | 64800   |
| 7     | 25200   | 19    | 68400   |
| 8     | 28800   | 20    | 72000   |
| 9     | 32400   | 21    | 75600   |
| 10    | 36000   | 22    | 79200   |
| 11    | 39600   | 23    | 82800   |
| 12    | 43200   | 24    | 86400   |


Maybe something checking `member_casual` and a derived `day_of_week` to see if members vs casual use more during the workweek for commute options?

## Working notes

| Note | Purpose | State at time of split |
| --- | --- | --- |
| [[01 Cyclistic Data Cleaning Log]] | Cleaning rules, transformations, validation, and row-impact decisions | Documented through short- and long-ride removal |
| [[02 Cyclistic Q1 - Days and Times]] | Differences by weekday and hour | Substantial exploration and Tableau work |
| [[03 Cyclistic Q2 - Ride Duration]] | Differences in ride length overall and by day | Duration cohorts established; further day/time work remains |
| [[04 Cyclistic Q3 - Start Stations]] | Differences in where rides begin | Overall, under-one-hour, and one-to-two-hour comparisons begun |
| [[05 Cyclistic Q4 - End Stations]] | Differences in where rides end | Not yet analyzed in the source |
| [[06 Cyclistic Supplemental - Bike Types]] | Differences in bike type | Proposed, but not yet analyzed in the source |

## Structural boundary used for the split

- Cleaning logic stays in the cleaning log even when it concerns duration.
- Weekday and hour-of-day comparisons stay with Question 1.
- Duration-band comparisons stay with Question 2.
- Station-distribution comparisons stay with Question 3, including the station work that grew out of the one-to-two-hour cohort.
- Unstarted questions receive placeholders so the project map shows both completed and missing work.

