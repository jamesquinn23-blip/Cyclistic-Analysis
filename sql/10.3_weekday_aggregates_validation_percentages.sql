--- Purpose: summarize ride counts by weekday and calculate each rider type's share of that weekday's rides.
--- Grain: one row per weekday.
--- Ordering: ISO weekday order, Monday = 1, Sunday = 7.
--- Daily composition denominator: `total_weekday_rides`
--- Expected rows: 7.
--- Expected sum of total_weekday_rides: 5,764,481.
--- Expected `daily_member_percent` + `daily_casual_percent`: 100% for every row.
--- Expected dates_observed: 52 for every weekday except Tuesday; 53 for Tuesday.
--- Expect `day_share_member_rides` to sum to 100% across seven rows.
--- Expect `day_share_casual_rides` to sum to 100% across seven rows.
--- Expect `weekday_percent_of_rides` to sum to 100% across seven rows.

WITH weekday_aggregates AS (
    SELECT
    day_of_the_week_started_on,
    day_of_the_week_numerical,
    COUNT(DISTINCT(date_started)) AS dates_observed,
    COUNT() FILTER(member_casual = 'member') AS member_rides,
    COUNT() FILTER(member_casual = 'casual') AS casual_rides,
    member_rides + casual_rides AS total_weekday_rides
FROM trips_dated
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical
),

output AS (
    SELECT
    day_of_the_week_started_on,
    day_of_the_week_numerical,
    dates_observed,
    member_rides,
    casual_rides,
    total_weekday_rides,
    member_rides / total_weekday_rides * 100 AS daily_member_percent,
    casual_rides / total_weekday_rides * 100 AS daily_casual_percent,
    member_rides / SUM(member_rides) OVER() * 100 AS day_share_member_rides,
    casual_rides / SUM(casual_rides) OVER() * 100 AS day_share_casual_rides,
    total_weekday_rides / SUM(total_weekday_rides) OVER() * 100 AS weekday_percent_of_rides
FROM weekday_aggregates
ORDER BY day_of_the_week_numerical
)

SELECT
    SUM(CASE
            WHEN ABS(
                daily_member_percent + daily_casual_percent - 100
            ) > 0.000001
            THEN 1
            ELSE 0
        END
    ) AS daily_composition_failures,

    CASE
        WHEN ABS(SUM(day_share_member_rides) - 100) > 0.000001
        THEN 1
        ELSE 0
    END AS member_share_total_failures,

    CASE
        WHEN ABS(SUM(day_share_casual_rides) - 100) > 0.000001
        THEN 1
        ELSE 0
    END AS casual_share_total_failures,

    CASE
        WHEN ABS(SUM(weekday_percent_of_rides) - 100) > 0.000001
        THEN 1
        ELSE 0
    END AS weekday_share_total_failures
FROM output;