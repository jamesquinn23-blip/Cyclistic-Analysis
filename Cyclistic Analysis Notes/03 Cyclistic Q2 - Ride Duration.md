# Q2 — Ride duration

Navigation: [[00 Cyclistic Analysis Map|Analysis map]] · Source: [[Cyclistic Bike share scratchpad 1|Original scratchpad]]

> **Primary question:** Do `member` and `casual` appear to use bikes for different lengths of time overall? On specific days?

> [!note] Boundary
> Duration cleaning rules remain in [[01 Cyclistic Data Cleaning Log]]. This note begins with analytical comparisons of duration cohorts.

### Viz inspecting rider-percent all seven days of the week, by hour grouping.

```postgresql
SELECT
day_of_the_week_started_on,
COUNT() FILTER(member_casual = 'member') AS member_rides,
COUNT() FILTER(member_casual = 'casual') AS casual_rides,
COUNT() FILTER(trip_duration_seconds < 3600 AND member_casual = 'member') AS members_under_one_hour,
COUNT() FILTER(trip_duration_seconds < 3600 AND member_casual = 'casual') AS casuals_under_one_hour,
COUNT() FILTER(trip_duration_seconds >= 3600 AND trip_duration_seconds < 7200 AND member_casual = 'member') AS members_one_two,
COUNT() FILTER(trip_duration_seconds >= 3600 AND trip_duration_seconds < 7200 AND member_casual = 'casual') AS casuals_one_two,
COUNT() FILTER(trip_duration_seconds >= 7200 AND trip_duration_seconds < 10800 AND member_casual = 'member') AS members_two_three,
COUNT() FILTER(trip_duration_seconds >= 7200 AND trip_duration_seconds < 10800 AND member_casual = 'casual') AS casuals_two_three,
members_under_one_hour / member_rides * 100 AS m_one_perc,
casuals_under_one_hour / casual_rides * 100 AS c_one_perc,
members_one_two / member_rides * 100 AS m_one_two_perc,
casuals_one_two / casual_rides * 100 AS c_one_two_perc,
members_two_three / member_rides * 100 AS m_two_three_perc,
casuals_two_three / casual_rides * 100 AS c_two_three_perc
FROM trips_dated
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical
ORDER BY day_of_the_week_numerical ASC

day_of_the_week_started_on	member_rides	casual_rides	members_under_one_hour	casuals_under_one_hour	members_one_two	casuals_one_two	members_two_three	casuals_two_three	m_one_perc	c_one_perc	m_one_two_perc	c_one_two_perc	m_two_three_perc	c_two_three_perc
Monday	588417	271740	584623	258142	2651	10848	457	1901	99.35521917279753	94.99595201295355	0.450530831026296	3.9920512254360787	0.07766600896982921	0.6995657613895635
Tuesday	664399	266469	660950	256957	2285	7520	449	1300	99.48088422770053	96.43035399990242	0.3439198433471453	2.8220918756027906	0.06757987293779792	0.4878616274313335
Wednesday	637606	251418	634489	243864	2059	5995	394	966	99.51114010846824	96.99544185380522	0.3229266976785037	2.3844752563460054	0.06179364686028676	0.38422070018853066
Thursday	653292	290854	649774	280859	2392	7818	453	1409	99.4614965436589	96.56356797568539	0.3661456132939023	2.687946529874095	0.06934112158116126	0.48443548997091324
Friday	599429	357380	595285	342252	2945	11900	454	1996	99.30867542277736	95.76697073143433	0.49130088801175786	3.32978902009066	0.07573874470537795	0.5585091499244502
Saturday	521654	486853	516660	459490	3820	21586	531	3852	99.04266046076519	94.37961766693437	0.7322861513570298	4.4337818602329655	0.10179160899753477	0.7912039157610202
Sunday	447504	385849	442777	361735	3659	18892	502	3566	98.94369659265615	93.75040495115965	0.8176463227144338	4.896215877195483	0.11217776824341236	0.9241957346008414

```
![[Pasted image 20260727162534.png]]

## Open continuation from the source

### How do ride lengths differ by weekday and start time?

![[Pasted image 20260729115223.png]]

| Day   | `member` start hour peak | `member` percent peak | `casual`  start hour peak | percent peak |
| ----- | ------------------------ | --------------------- | ------------------------- | ------------ |
| Mon   | 17                       | 12.60%                | 17                        | 10.82%       |
| Tues  | 17                       | 12.54%                | 17                        | 11.41        |
| Wed   | 17                       | 12.25%                | 17                        | 11.67%       |
| Thurs | 17                       | 11.80%                | 17                        | 11.28%       |
| Fri   | 17                       | 10.18%                | 17                        | 9.97%        |
| Sat   | 15 / 16                  | 7.63%                 | 15                        | 8.64%        |
| Sun   | 15                       | 8.18%                 | 15                        | 8.93%        |
