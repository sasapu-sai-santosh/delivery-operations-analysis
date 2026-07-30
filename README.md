# Delivery Operations Analytics: Last-Mile Delivery Performance & Slow-Delivery Analysis

## Project Overview

This project analyzes last-mile delivery operations data to understand delivery time patterns, slow-delivery risk groups, and operational factors that may affect delivery performance.

The main goal of this project is not to build an advanced machine learning model.
The focus is on practical data analyst work such as data cleaning, KPI creation, exploratory analysis, SQL validation, Excel checks, and Power BI dashboard preparation.

This project is suitable for understanding how traffic, distance, pickup delay, vehicle type, weather, area, and agent rating groups relate to delivery performance.

---

## Business Problem

Delivery teams need to monitor where delivery time increases and which operational groups show higher slow-delivery risk.

In this project, I tried to answer questions such as:

* What is the average delivery time?
* How many deliveries fall into slow-delivery risk?
* Does traffic affect delivery performance?
* How does delivery distance relate to delivery time?
* Are there small vehicle groups that should not be over-interpreted?
* Which records should be excluded from distance-based analysis?
* How can the cleaned data be prepared for dashboard reporting?

---

## Dataset Summary

The dataset contains delivery order-level records with information such as order time, pickup time, traffic, weather, vehicle type, area, category, agent rating, store location, drop location, and delivery time.

### Key Metrics

| Metric                           |          Value |
| -------------------------------- | -------------: |
| Total Orders                     |         43,739 |
| Average Delivery Time            | 124.91 minutes |
| Median Delivery Time             |    125 minutes |
| Average Distance - Clean Records |        9.73 km |
| Average Pickup Delay             |   9.96 minutes |
| Slow-Delivery Threshold          |    160 minutes |
| Slow-Delivery Rate               |         23.05% |
| Distance Issue Records           |            188 |

---

## Tools Used

* Python
* Pandas
* NumPy
* Matplotlib
* Seaborn
* PostgreSQL
* Excel
* Power BI

---

## Project Workflow

### 1. Data Understanding

I first reviewed the dataset structure, column names, data types, missing values, duplicate records, and basic summary statistics.

This helped me understand which fields needed cleaning before analysis.

---

### 2. Data Cleaning

The cleaning process included:

* standardizing column names
* cleaning text columns such as traffic, weather, vehicle, area, and category
* converting numeric fields into proper formats
* handling invalid agent ratings
* checking duplicate rows
* identifying missing or invalid pickup delay values

I avoided unnecessary deletion of records unless they were clearly unsuitable for a specific analysis.

---

### 3. Feature Engineering

I created additional features to make the data more useful for operations analysis:

* `order_hour`
* `order_day`
* `is_weekend`
* `pickup_delay_mins`
* `distance_km`
* `distance_issue_flag`
* `distance_category`
* `peak_hour_flag`
* `rating_group`
* `slow_delivery_flag`

The distance was calculated using the Haversine formula based on store and drop coordinates.

---

## Important Assumptions

The dataset does not include promised delivery time or official SLA target.

Because of that, `slow_delivery_flag` is created as a proxy metric.
Orders above the 75th percentile of delivery time are treated as slow-delivery cases.

The slow-delivery threshold used in this project is:

```text
160 minutes
```

This should not be treated as an actual company-defined delay metric.

Also, `distance_km` is straight-line distance calculated from latitude and longitude. It is not actual road distance.

Records with suspicious distance values were flagged using `distance_issue_flag`.
A total of 188 records were marked as distance issue records and excluded from distance-based analysis.

---

## Analysis Performed

The project includes analysis on:

* delivery time distribution
* traffic-level delivery performance
* distance category performance
* traffic and distance slow-delivery risk
* pickup delay relationship with delivery time
* hourly order volume
* peak-hour vs non-peak-hour performance
* vehicle-level performance
* rating-group performance
* data quality checks
* SQL validation checks
* Excel KPI validation
* Power BI dashboard summary

---

## Key Insights

1. The dataset contains 43,739 delivery records, with an average delivery time of 124.91 minutes.

2. The median delivery time is 125 minutes, which is close to the average delivery time.

3. Around 23.05% of orders were marked as slow-delivery cases using the proxy threshold of 160 minutes.

4. The average pickup delay is 9.96 minutes, so pickup delay is useful as a supporting operational metric.

5. After excluding suspicious distance records, the average delivery distance is 9.73 km.

6. 188 records were flagged as distance issue records and excluded from distance-based analysis.

7. Traffic and distance-based analysis can help identify operational groups with higher slow-delivery risk.

8. Vehicle groups with very low record counts should not be over-interpreted.

---

## Recommendations

1. Monitor high-traffic and longer-distance delivery groups separately because these groups may have higher slow-delivery risk.

2. Track slow-delivery rate along with average delivery time instead of relying only on one metric.

3. Keep distance issue records flagged separately so that distance-based analysis remains transparent.

4. Use pickup delay as a supporting metric, but avoid treating it as the only reason for longer delivery times.

5. Review small vehicle groups carefully before making conclusions because low record counts can give misleading results.

6. Use the dashboard summary output for regular monitoring of traffic, distance, vehicle, area, and rating-level performance.

---

## SQL Validation

PostgreSQL queries were added to validate the analysis from a database point of view.

The SQL file includes checks for:

* overall delivery KPIs
* traffic performance
* distance category performance
* peak-hour performance
* vehicle performance
* rating group performance
* area-level ranking
* weather and category performance
* slow-delivery flag validation
* distance issue percentage check

This helps confirm that the Python analysis can also be checked using SQL.

---

## Excel Validation

An Excel validation workbook was prepared to cross-check important KPIs and summary outputs.

The Excel file includes:

* sample data
* KPI summary
* traffic summary
* distance summary
* peak-hour summary
* vehicle summary
* rating summary
* notes on assumptions

This was added to show that the analysis was not only done in Python, but also validated in a simple business-friendly format.

---

---

## Project Limitations

* The dataset does not include actual promised delivery time or SLA.
* Slow delivery is based on a proxy threshold, not an official delay label.
* Distance is calculated using straight-line Haversine distance, not road distance.
* Pickup delay may have missing values because full pickup date information is not available.
* Some vehicle groups have low record counts, so they should not be over-interpreted.
* The baseline model is only used as a supporting check, not as the main objective.

---

## Final Outcome

This project shows practical data analyst skills using Python, SQL, Excel, and Power BI.

It covers data cleaning, feature engineering, KPI creation, exploratory analysis, validation checks, dashboard preparation, and business recommendations.

The project is designed to be realistic for a fresher-level Data Analyst or BI Analyst portfolio.
