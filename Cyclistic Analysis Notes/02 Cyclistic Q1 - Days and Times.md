# Q1 — Days and times of the week

Navigation: [[00 Cyclistic Analysis Map|Analysis map]] · Source: [[Cyclistic Bike share scratchpad 1|Original scratchpad]]

> **Primary question:** Do `member` or `casual` appear to use bikes differently on days of the week?

## Do `member` or `casual` appear to use bikes differently on days of the week?

First, to answer this question in a meaningful day I have to think about the absolute scale at which both of these populations exist:
- `member` has many more rides than `casual`
- `casual` has many fewer rides than `member`
- To get analytically meaningful numbers from the question I'll need to inspect them individually and against the weekday subtotals first.

### How do `member` and `casual` ride totals differ by day of the week?
```postgresql
SELECT day_of_the_week_started_on,
day_of_the_week_numerical,
COUNT() FILTER(member_casual = 'member') AS member_rides,
COUNT() FILTER(member_casual = 'casual') AS casual_rides,
(member_rides) + (casual_rides) AS total_weekday_rides,
(member_rides) / (total_weekday_rides) * 100 AS member_percent,
(casual_rides) / (total_weekday_rides) * 100 AS casual_percent
FROM trips_dated
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical
ORDER BY day_of_the_week_numerical


| day_of_the_week_started_on | day_of_the_week_numerical | member_rides | casual_rides | total_weekday_rides | member_percent | casual_percent |
| -------------------------- | ------------------------- | ------------ | ------------ | ------------------- | -------------- | -------------- |
| Monday                     | 1                         | 588,417      | 271,740      | 860,157             | 68.41          | 31.59          |
| Tuesday                    | 2                         | 664,399      | 266,469      | 930,868             | 71.37          | 28.63          |
| Wednesday                  | 3                         | 637,606      | 251,418      | 889,024             | 71.72          | 28.28          |
| Thursday                   | 4                         | 653,292      | 290,854      | 944,146             | 69.19          | 30.81          |
| Friday                     | 5                         | 599,429      | 357,380      | 956,809             | 62.65          | 37.35          |
| Saturday                   | 6                         | 521,654      | 486,853      | 1,008,507           | 51.73          | 48.27          |
| Sunday                     | 7                         | 447,504      | 385,849      | 833,353             | 53.70          | 46.30          |
```
> Members account for the majority of rides each day
> The gap is smallest Saturday and Sunday
> Largest Tuesday and Wednesday
> > Mon - Thurs overall has a much bigger difference
> > > Friday catches back up by about 6 - 9% (I wonder if there's an evening surge after work?)
> Should investigate Mon - Fri ride timing to discover when rides are happening
> > Are Mon - Fri *mostly* commute trips?
> > Does Fri have a sneaky cohort of evening rides?

### Inspecting Friday - How do `member` and `casual` ride frequencies differ after 5:00pm?

```postgresql
SELECT
(EXTRACT(HOUR FROM time_started)) AS ride_hour,
day_of_the_week_started_on,
COUNT() FILTER(member_casual = 'member') AS member_rides,
COUNT() FILTER(member_casual = 'casual') AS casual_rides,
(member_rides) + (casual_rides) AS total_weekday_rides,
(member_rides) / (total_weekday_rides) * 100 AS member_percent,
(casual_rides) / (total_weekday_rides) * 100 AS casual_percent
FROM trips_dated
WHERE day_of_the_week_started_on = 'Friday' AND time_started > TIME '17:00:00'
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical, ride_hour
ORDER BY ride_hour

| ride_hour | day_of_the_week_started_on | member_rides | casual_rides | total_weekday_rides | member_percent     | casual_percent     |
| --------- | -------------------------- | ------------ | ------------ | ------------------- | ------------------ | ------------------ |
| 17        | Friday                     | 60996        | 35638        | 96634               | 63.12064076825962  | 36.87935923174038  |
| 18        | Friday                     | 49991        | 31385        | 81376               | 61.43211757766418  | 38.56788242233583  |
| 19        | Friday                     | 35732        | 23997        | 59729               | 59.823536305647174 | 40.176463694352826 |
| 20        | Friday                     | 24449        | 17139        | 41588               | 58.78859286332596  | 41.21140713667404  |
| 21        | Friday                     | 18660        | 14232        | 32892               | 56.731120029186435 | 43.26887997081357  |
| 22        | Friday                     | 16438        | 14185        | 30623               | 53.678607582535996 | 46.321392417464    |
| 23        | Friday                     | 12982        | 13093        | 26075               | 49.787152444870564 | 50.212847555129436 |

```
> We see that `member_percent` starts much higher than `casual_percent` and switches over the course of those 6 hour-bands, but only barely at the end.

### Inspecting all 24 hours of Friday, comparing `member` rides and `casual` rides.

```postgresql
SELECT
(EXTRACT(HOUR FROM time_started)) AS ride_hour,
day_of_the_week_started_on,
COUNT() FILTER(member_casual = 'member') AS member_rides,
COUNT() FILTER(member_casual = 'casual') AS casual_rides,
(member_rides) + (casual_rides) AS total_hourly_rides,
(member_rides) / (total_hourly_rides) * 100 AS member_percent,
(casual_rides) / (total_hourly_rides) * 100 AS casual_percent
FROM trips_dated
WHERE day_of_the_week_started_on = 'Friday'
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical, ride_hour
ORDER BY ride_hour

ride_hour	day_of_the_week_started_on	member_rides	casual_rides	total_hourly_rides	member_percent	casual_percent
0	Friday	5264	5990	11254	46.774480184823176	53.225519815176824
1	Friday	2916	3707	6623	44.028385927827266	55.97161407217273
2	Friday	1517	2158	3675	41.27891156462585	58.72108843537415
3	Friday	1088	1166	2254	48.26974267968057	51.73025732031943
4	Friday	1487	1192	2679	55.50578574094811	44.49421425905189
5	Friday	6449	2311	8760	73.61872146118722	26.381278538812786
6	Friday	17431	4850	22281	78.2325748395494	21.767425160450607
7	Friday	31417	8453	39870	78.79859543516429	21.201404564835716
8	Friday	38676	10798	49474	78.17439463152363	21.82560536847637
9	Friday	26250	10580	36830	71.27341840890578	28.72658159109422
10	Friday	21568	12326	33894	63.63368147754764	36.36631852245235
11	Friday	26953	16897	43850	61.46636259977195	38.53363740022805
12	Friday	32621	21179	53800	60.633828996282524	39.36617100371747
13	Friday	33371	22580	55951	59.64325928044182	40.35674071955819
14	Friday	33285	23195	56480	58.93236543909348	41.06763456090651
15	Friday	42673	27290	69963	60.99366808170033	39.00633191829967
16	Friday	57215	33039	90254	63.393312207769185	36.606687792230815
17	Friday	60996	35638	96634	63.12064076825962	36.87935923174038
18	Friday	49991	31385	81376	61.43211757766418	38.56788242233583
19	Friday	35732	23997	59729	59.823536305647174	40.176463694352826
20	Friday	24449	17139	41588	58.78859286332596	41.21140713667404
21	Friday	18660	14232	32892	56.731120029186435	43.26887997081357
22	Friday	16438	14185	30623	53.678607582535996	46.321392417464
23	Friday	12982	13093	26075	49.787152444870564	50.212847555129436

```
> We see commute-like patterns
> > An uptick in `total_hourly_rides` starting between 4-5, peaking between 8-9, dominated by `members`.
> > Another uptick around 15:00, peaking between 17:00-18:00, again dominated by members, but not *so* extremely as before.
> > > `member` peaks seem to correlate with commute-like behavior
> > > `casual` AM peaks seem to be later-than-normal-commute-like behavior, and PM absolute peaks also seem to be commute-like behavior
> > 
> Now I want to compare relative changes between other commute-days, Monday - Thursday

### Viz inspecting `member` vs `casual` ride-percent by hour during M-F

```postgresql
SELECT
day_of_the_week_started_on,
(EXTRACT(HOUR FROM time_started)) AS ride_hour,
COUNT() FILTER(member_casual = 'member') AS member_rides,
COUNT() FILTER(member_casual = 'casual') AS casual_rides,
(member_rides) + (casual_rides) AS total_hourly_rides,
(member_rides) / (total_hourly_rides) * 100 AS member_percent,
(casual_rides) / (total_hourly_rides) * 100 AS casual_percent
FROM trips_dated
WHERE day_of_the_week_numerical < 6
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical, ride_hour
ORDER BY ride_hour, day_of_the_week_numerical

day_of_the_week_started_on	ride_hour	member_rides	casual_rides	total_hourly_rides	member_percent	casual_percent
Monday	true	588417	271740	860157	68.40809294117237	31.591907058827633
Tuesday	true	664399	266469	930868	71.37413682713338	28.625863172866616
Wednesday	true	637606	251418	889024	71.71977359441365	28.28022640558635
Thursday	true	653292	290854	944146	69.19395940882025	30.806040591179755
Friday	true	599429	357380	956809	62.64876271021698	37.351237289783015
Saturday	true	521654	486853	1008507	51.7253722581995	48.2746277418005
Sunday	true	447504	385849	833353	53.69921269858031	46.30078730141969


```


![[casual share of hourly rides (%) viz.png]]
>  Yes, there's a difference in how `member` and `casual` use the bikes throughout the week, with a larger `casual` share use outside of peak commute-hours.

### Viz inspecting `member` vs `casual` ride-percent by hour all seven days of the week

```postgresql
SELECT
day_of_the_week_started_on,
(EXTRACT(HOUR FROM time_started)) AS ride_hour,
COUNT() FILTER(member_casual = 'member') AS member_rides,
COUNT() FILTER(member_casual = 'casual') AS casual_rides,
(member_rides) + (casual_rides) AS total_hourly_rides,
(member_rides) / (total_hourly_rides) * 100 AS member_percent,
(casual_rides) / (total_hourly_rides) * 100 AS casual_percent
FROM trips_dated
GROUP BY day_of_the_week_started_on, day_of_the_week_numerical, ride_hour
ORDER BY ride_hour, day_of_the_week_numerical
```

![[Pasted image 20260727102652.png]] There is near-parity between `members` and `casual` rides over the weekend


