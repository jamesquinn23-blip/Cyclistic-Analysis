# Cyclistic SQL workflow

  

This directory contains the SQL used to import, clean, validate, and analyze

12 months of Cyclistic/Divvy trip data from July 1, 2025 through June 30, 2026.

  

The final cleaned table contains **5,764,481 rides**. Analytical query outputs

were exported as CSV files for use in Tableau.

  

## Tools and environment

  

- Database: DuckDB, running locally

- SQL interface: DuckDB Local UI in Google Chrome

- Tableau input format: CSV

- Working directory: project root, so paths such as `data/*.csv` resolve

  correctly

- DuckDB version: v1.5.5

  

## How to reproduce the SQL workflow

  

1. Place the 12 monthly Divvy CSV files in `data/`.

2. Connect DuckDB to the intended project database.

3. Run scripts `01` through `09` in numerical order. These scripts create and

   mutate the working tables.

4. Run the analytical scripts (`10` onward) after cleaning is complete.

5. Export each production query result to the CSV listed in the output map

   below.

6. Run validation queries separately where noted.

  

The SQL interface displays only the final result produced by a script. When a

file contains multiple validation statements, run each statement separately to

inspect every result.

  

## Data-cleaning workflow

  

| Order | Script | Role in the workflow | Main result or check |

| --- | --- | --- | --- |

| 01 | `01_inventory.sql` | Confirms the connected database and inventories the monthly CSV files | 12 input CSV files |

| 02 | `02_trips_raw.sql` | Imports the monthly files into one persistent raw table | `trips_raw`: 5,932,349 rows |

| 03 | `03_duplicate_ids.sql` | Inspects duplicated `ride_id` values before cleaning | 35 duplicated IDs / 70 affected rows |

| 04 | `04_trips_dated.sql` | Applies the analysis-period boundary and derives date/time fields | `trips_dated`: 5,932,247 rows |

| 05 | `05_clean_duplicates.sql` | Removes the redundant copies of duplicated rides | 5,932,212 distinct rides |

| 06 | `06_add_columns.sql` | Adds weekday and ride-duration fields | Derived columns populated for every row |

| 07 | `07_clean_DST.sql` | Corrects durations affected by the fall and spring daylight-saving transitions | Row count unchanged; no remaining negative or uncorrected durations |

| 08 | `08_update_columns_trip_duration_seconds.sql` | Converts corrected intervals to duration in seconds | No null or mismatched duration values |

| 09 | `09_clean_trips_under_60s.sql` | Removes rides at or below 60 seconds and above 24 hours | Final cleaned table: 5,764,481 rides |

  

### Cleaning decisions

  

Briefly explain the reasoning behind the important exclusions. One or two

sentences per decision is enough.

  

- **Analysis-period boundary:** The analysis includes rides starting on or after midnight on July 1, 2025 and before midnight on July 1, 2026, producing a complete 12-month analysis period.

- **Duplicate IDs:** Thirty-five rides beginning April 30, 2026 and ending May 1 appeared in both monthly source files. Because the records were otherwise identical, I retained the copy whose starting month matched the month represented by its source filename.

- **Daylight-saving corrections:** Because the source timestamps did not record time-zone offsets, the November 2025 and March 2026 daylight-saving transitions distorted some calculated ride durations. On November 2, 2025, 29 rides had an `ended_at` timestamp earlier than `started_at`; one hour was added to their derived durations. On March 8, 2026 40 rides crossing the spring-forward transition had durations inflated by one hour, so one hour was subtracted. The original timestamps were retained for source preservation; only the derived duration fields were corrected.

- **Rides lasting 60 seconds or less:**  Rides lasting 60 seconds or less were excluded because they were unlikely to represent substantive bike-share trips. The same duration-based rule was applied to both rider types.

- **Rides lasting 24 hours or more:** Rides lasting 24 hours or more were excluded as extreme-duration observations unlikely to represent ordinary bike-share use. The data did not establish the cause of these durations, and the same threshold was applied to both rider types.



## Analytical queries and Tableau outputs



### Question 1 — Days and times

  

| Script | Purpose | Exported Tableau CSV |

| --- | --- | --- |

| `10_weekday_aggregates.sql` | Compares weekday ride counts, rider-type composition, and each weekday's share of annual rides | `output/01_days_and_times/weekday_aggregates.csv` |

| `12_hourly_timing.sql` | Compares average ride volume by weekday, start hour, and rider type | `output/02_ride_duration/hourly_ride_volume.csv` |

  

Daily averages were used for hourly comparisons to normalize for the unequal number of weekday occurrences in the dataset: Tuesday appears 53 times, while every other weekday appears 52 times.
  

### Question 2 — Ride duration

  

| Script | Purpose | Exported Tableau CSV |

| --- | --- | --- |

| `13_duration_bands.sql` | Compares broad duration distributions by weekday and rider type | `output/02_ride_duration/duration_band_volume_by_weekday.csv` |

| `13.2_short_duration_bands.sql` | Examines the under-one-hour distribution in narrower duration bands | `output/02_ride_duration/short_duration_bands_x_ridertype_x_weekday.csv` |

  

Associated validation files:

  

- `13_duration_bands_validation_totals.sql`

- `13_duration_bands_validation_percentages.sql`

- `13_duration_bands_validation_day_occurrences.sql`

  

Narrower duration bands were introduced because the broad under-one-hour category contained approximately 93% of casual rides and more than 99% of member rides, concealing differences
within that range. The finer bands showed a consistent divergence around 15 minutes: on every weekday, rides lasting 15 minutes or longer represented a larger share of casual rides than member
rides. Therefore, 15 minutes was selected as the summary boundary in Tableau.

### Question 3 — Start and end station concentration

  

| Script | Purpose | Exported Tableau CSV |

| --- | --- | --- |

| `endpoint_roles.sql` | Identifies the named, mappable stations contributing to approximately 10% of starts or ends within each rider-type/endpoint group | `output/03_endpoint_roles/endpoint_roles.csv` |

| `null_start_stations.sql` | Diagnoses missing start-station names overall and by rider type | Diagnostic only; no production Tableau export |

  

Only named, mappable stations were used because station names provided a consistent identifier for grouping rides, while recorded coordinates sometimes varied within the same station. Average coordinates were calculated for each named station, and records without a station name or usable coordinates were excluded. Because missing station names affected approximately one-fifth of rides, the resulting concentration findings describe only named, mappable activity—not the complete geographic distribution of either rider type. If station information is missing non-randomly, the excluded rides may have a different geographic pattern.

### Question 4 — Directed station pairs

  

All directed-pair percentages use rides with non-null start and end station

names as their rider-type denominator. Start-to-end and end-to-start pairs are

treated as different routes.

  

| Script | Purpose | Exported Tableau CSV |

| --- | --- | --- |

| `14.1_qualifying_directed_pair_shares.sql` | Compares both rider types across the union of pairs contributing to either rider type's first 10% of named-endpoint rides | `output/05_directed_pairs/qualifying_directed_pair_shares_by_rider_type.csv` |

| `14.2_directed_pair_count_to_10_percent.sql` | Counts the highest-ranked pairs required to reach 10% within each rider type | `output/05_directed_pairs/directed_pair_rider_type_share.csv` |

| `14.3_ranked_directed_pairs_by_rider_type.sql` | Produces ranks 1–650 and cumulative ride share for the concentration curve | `output/05_directed_pairs/directed_pairs_ranked_by_ride_type.csv` |

| `14.4_top_ten_directed_pairs_by_rider_type.sql` | Compares both rider types across the combined set of their top-ten pairs | `output/05_directed_pairs/top_ten_directed_pairs_by_rider_type.csv` |

| `14.5_same_station_ride_share.sql` | Compares the within-cohort prevalence of rides beginning and ending at the same named station | `output/05_directed_pairs/same_station_rides_share.csv` |

  

Associated `14.1_validation_*.sql` files test:

  

- one row per directed pair and rider type;

- coverage of both rider types for every selected pair; and

- 761 unique directed pairs in the qualifying-pair output.


Trips were represented as directed station pairs for the analysis because the data only contains the recorded start and end station and coordinates, not higher-resolution data like GPS traces of the paths riders followed. Further, direction was preserved because travel from Station A to Station B may or may not represent distinct behavior from Station B to Station A. Additionally, the 10% threshold provided a consistent benchmark for comparing how concentrated each rider type's activity was among its busiest directed pairs without attempting to display every pair in the dataset. Finally, rides beginning and ending at the same named station were described as **same-station rides** , not round trips, because matching endpoints do not reveal the route taken or prove the rider completed a circuit.
  

## Validation approach

  

The analytical files document expected output grain, row counts, denominators,

and total ride counts where applicable. Separate validation scripts are used

when the SQL interface cannot display the production output and its validation

results together.

  

Before the CSVs were used in Tableau each export was validated according to its intended grain. Checks included expected row-counts, percentage totals within the appropriate rider-type or weekday groups, reconciliation of ride counts with the source tables, absence of prohibited null station names, and uniqueness of the expected key combinations. Station names and directed pairs were also reviewed for valid values and complete rider-type coverage where required.

  

## Important definitions and limitations

  

- A **ride** is one retained `ride_id`; the data does not identify unique

  people.

- `member` and `casual` describe ride records, not demographic groups.

- Commute-like timing patterns do not prove that a ride was a commute.

- Station and route analyses exclude records missing the station names required

  for that analysis.

- A **same-station ride** starts and ends at the same named station; its actual

  path and whether it was a round trip are unknown.

- A **directed pair** is an ordered combination of recorded start and end stations, such as Station A → Station B. Station B → Station A is treated as a distinct pair because its origin, destination, and direction of movement differ, representing different observed ride behavior. The dataset does not reveal the street-level path taken or the rider’s purpose.

- The dataset contains no rider information beyond whether each ride was classified as `member` or `casual`. Interpretations involving commuting, education, leisure, or tourism are therefore contextual inferences rather than directly observed trip purposes.

- The analysis covers one 12-month period. Its findings describe rides recorded during that period and should not automatically be generalized to other years or assumed to represent permanent rider behavior.

  

## Directory conventions

  

- Numbered `.sql` files are part of the working production sequence.

- Files containing `validation` return diagnostic results rather than Tableau

  datasets.

- `_archive/` contains unfinished or superseded exploratory SQL and is not part

  of the reproducible workflow.

- Numbering reflects the order in which the analysis developed, so not every

  integer is present.