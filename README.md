# Cyclistic Analysis

Cyclistic Analysis/

├── README.md

├── sql/                 # Cleaning, analysis, validation, and SQL documentation

├── output/              # Tableau-ready CSV outputs

├── tableau/             # Tableau workbook and supporting files

├── data/                # Raw Divvy files; not included in the repository

└── database/            # Local DuckDB files; not included in the repository

## Project Overview

In this analysis for the fictional company Cyclistic, I use 12 months of the real company Divvy's ride data to analyze and find differences between Member and Casual ride behavior in order to help inform digital media spending to convert Casual riders to annual Members.

### Tableau Visualization

[Visualizations](https://public.tableau.com/app/profile/james.quinn1414/viz/CyclisticPresentationWorkbookextracteddata/Question1)

## Data source and analysis period

From Divvy's tripdata at
[Divvy Data](https://divvy-tripdata.s3.amazonaws.com/index.html)

July 1st 2025 - June 30th 2026

## Tools and environment

- Database: DuckDB, running locally

- SQL interface: DuckDB Local UI in Google Chrome

- Tableau input format: CSV

- Working directory: project root, so paths such as `data/*.csv` resolve correctly

- DuckDB version: v1.5.5

## Data Preparation

In order to provide insights into rides I analyzed 12 months of contiguous ride data from "Cyclistic", starting 00:00:00 July 1st 2025 ending 11:59:59 June 30th 2026, 5,932,349 rides before cleaning.

5,764,481 rides remain after removing duplicate rides, rides determined to be non-representative of real bike-ride behavior; rides 60 seconds or less and rides over 24 hours, as well as applying the analysis-period boundary, removing the rides that ended on July 1st 2025 but began on June 30th 2025.

Additionally, because the source timestamps did not record time-zone offsets, the November 2025 and March 2026 daylight-saving transitions distorted some calculated ride durations. On November 2, 2025, 29 rides had an `ended_at` timestamp earlier than `started_at`; one hour was added to their derived durations. On March 8, 2026 40 rides crossing the spring-forward transition had durations inflated by one hour, so one hour was subtracted. The original timestamps were retained for source preservation; only the derived duration fields were corrected.


## Questions and key findings
The business question at hand is this: How does annual Member rider behavior differ from Casual, non-Member rider behavior?

In order to dig into this question, I further broke it down:

  1. How do Member and Casual rides differ by weekday?
  2. How do Member and Casual rides differ by ride duration?
  3. How do Member and Casual rides differ by start- and end-station?
  4. How do Member and Casual rides differ by directed pair?

In answering these questions, I believe I have uncovered some genuine differences in behavior by rider type.

### **Question 1** - How do Member and Casual rides differ by weekday?

Member rides have their highest concentration Monday-Friday, reaching daily peaks in the 17:00 hour each weekday, while Casual rides have their highest concentration of frequency on Saturday and Sunday, with ride starts peaking in the 15:00 hour.

Further, during weekdays Members have another, relatively smaller peak of rides starting at 08:00 Monday-Friday. Because of these two Member-peaks, I suspect that a significant portion of Member rides are commute related, as the time-bands of these rides correspond with commute-like behavior, though the data cannot directly support that.

### **Question 2** - How do Member and Casual rides differ by ride duration?

Member and Casual rides have predominantly similar ride duration patterns: The majority of all rides taken, more than 95.5% for Casual and 99.3% for Member, are less than one hour.

However, within that less-than-one-hour duration band, I found that Casual rides had a greater within-rider-type proportion of rides lasting 15+ minutes when compared with Member rides.

From this we can conclude the Member rides tend to be shorter than 15 minutes more often than Casual rides. Does this imply Casual rides are more leisurely? We don't know.

### **Question 3** - How do Member and Casual rides differ by start- and end-station?

Perhaps the most useful question in the analysis, I found that Casual rides had start- and end-stations occurring with much greater concentration than that of Member rides; for Casual starts and ends separately, just 6 and 7 stations account for approximately 10% of named, mappable activity, compared with 17 Member stations for both starts and ends.

Additionally, while Member start- and end-stations were predominantly found in downtown locations, or locations adjacent to public transport or education, Casual ride start- and end-stations were concentrated around the Chicago waterfront and other areas related to leisure, recreation or tourism. While these data alone cannot conclude the reason for the trips, the data provide evidence that there is a difference in location pattern between Member and Casual rides, supporting differing interpretations of trip context.

### **Question 4** - How do Member and Casual rides differ by directed pair?

First, a definition. 

The term "*directed pair*" was chosen because "*route*"  is too precise for what the data had to offer and "*trip*" is inaccurate here because a directed pair is an aggregation of multiple trips. Directionality was preserved (i.e a trip from Navy Pier to Millennium Park vs a trip from Millennium Park to Navy Pier being differentiated) because each direction potentially represents distinct rider behavior, and the purpose of the analysis was to find differences between Member and Casual rider behavior.

Again, we find meaningful difference in the concentration of directed pairs just like we did with unique start- and end-stations: It took Casual riders 166 directed pairs to make up approximately 10% of Casual rides, where Members took 650, equaling 3.9 times as many directed pairs when compared with Casual riders.

In the directed pair analysis, we again find that the most common directed pairs for Casual riders involve the Chicago waterfront, while Members directed pairs are spread closer to downtown centers of business, education and transportation, as well as urban living.

Additionally, the data show us a distinctive finding: Member-leading pairs receive meaningful Casual use (i.e. the busiest Member directed pair had .12% of Member rides with both station names intact, and .08% of Casual rides with both station names intact while the busiest Casual directed pair had .64% of Casual rides with both station names intact and .03% of Member rides with both station names intact), while Casual-leading pairs receive comparatively little Member use.

Further, within the directed pair analysis, I looked at same-station rides, or rides with the same start- and end-station name, and found that, again, Casual riders have a greater concentration of activity within this behavioral band; 7.9% of mappable rides with start- and end-station name matching for Casual riders while only 2.2% of mappable, named station-rides were same-station rides for Members.

## Recommendations

From these data, I recommend we begin a measured pilot using geotargeted campaigns and digital out-of-home advertising as well as station signage (where available) where casual ride activity is concentrated that detail the benefits of an annual Membership.

Further, to increase the return-on-investment of these types of campaigns, we should expand ride data to include information such as:
1. A privacy-preserving persistent rider identifier
2. Casual pass type
3. Local versus visitor status
4. Repeat-use frequency
5. Promotion exposure
6. Membership conversion outcome

Ideally, we would measure campaign exposure or treatment

## Limitations

 - Rides cannot be linked to unique people.
 - Repeat casual use and later conversion cannot be measured.
 - Trip purpose and intent are unknown.
 - Directed pairs do not reveal the path traveled.
 - Same-station rides are not proven round trips.
 - Station analyses exclude rides missing the required station names.
 - Geographic interpretations rely on the named, mappable subset.
 - The analysis is descriptive and does not establish causation.
