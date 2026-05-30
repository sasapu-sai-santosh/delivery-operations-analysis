-- =========================================================
-- Delivery Operations Analytics SQL Queries
-- Project: Last-Mile Delivery Performance & Slow-Delivery Analysis
-- Database Name: delivery_operations_db
-- Database Type: Relational Database
-- SQL Dialect: PostgreSQL
-- =========================================================
--
-- Database setup note:
-- Create a PostgreSQL database named delivery_operations_db before running these queries.
--
-- In pgAdmin:
-- 1. Create/select the database: delivery_operations_db
-- 2. Open the Query Tool inside that database
-- 3. Run the queries below
--
-- In psql terminal, connect using:
-- \c delivery_operations_db
--
-- Important:
-- PostgreSQL does not use MySQL-style USE database_name;
-- So do not write: USE delivery_operations_db;
--
-- CSV import note:
-- Import delivery_cleaned.csv as delivery_cleaned.
-- Import delivery_cleaned_for_analysis.csv as delivery_cleaned_for_analysis.
--
-- Expected input tables:
-- 1. delivery_cleaned
--    - Full cleaned delivery dataset
--    - Includes all records and data quality flags
--
-- 2. delivery_cleaned_for_analysis
--    - Clean distance-analysis dataset
--    - Excludes suspicious distance records
--
-- Important project notes:
-- slow_delivery_flag is a proxy based on the top 25% delivery-time threshold.
-- It is not an actual company-defined SLA delay.
--
-- distance_km is straight-line Haversine distance, not actual road distance.
-- distance_issue_flag marks suspicious distance records excluded from distance-based analysis.
--
-- Use delivery_cleaned for overall KPIs, traffic, vehicle, weather, category, and rating analysis.
-- Use delivery_cleaned_for_analysis for distance-based analysis.


-- 1. Overall Delivery KPI Summary
SELECT
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_time,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY delivery_time)::numeric, 2) AS median_delivery_time,
    ROUND(AVG(pickup_delay_mins)::numeric, 2) AS avg_pickup_delay_mins,
    ROUND(AVG(slow_delivery_flag)::numeric * 100, 2) AS slow_delivery_rate,
    SUM(distance_issue_flag) AS distance_issue_records
FROM delivery_cleaned;


-- 2. Traffic-Level Delivery Performance
SELECT
    traffic,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_time,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY delivery_time)::numeric, 2) AS median_delivery_time,
    ROUND(AVG(slow_delivery_flag)::numeric * 100, 2) AS slow_delivery_rate
FROM delivery_cleaned
GROUP BY traffic
ORDER BY avg_delivery_time DESC;


-- 3. Distance Category Delivery Performance
-- Uses delivery_cleaned_for_analysis to avoid suspicious distance records.
SELECT
    distance_category,
    COUNT(*) AS total_orders,
    ROUND(AVG(distance_km)::numeric, 2) AS avg_distance_km,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_time,
    ROUND(AVG(slow_delivery_flag)::numeric * 100, 2) AS slow_delivery_rate
FROM delivery_cleaned_for_analysis
GROUP BY distance_category
ORDER BY avg_distance_km;


-- 4. Traffic and Distance Risk Check
SELECT
    traffic,
    distance_category,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_time,
    ROUND(AVG(slow_delivery_flag)::numeric * 100, 2) AS slow_delivery_rate
FROM delivery_cleaned_for_analysis
GROUP BY traffic, distance_category
HAVING COUNT(*) >= 50
ORDER BY slow_delivery_rate DESC;


-- 5. Peak-Hour Delivery Performance
SELECT
    peak_hour_flag,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_time,
    ROUND(AVG(slow_delivery_flag)::numeric * 100, 2) AS slow_delivery_rate
FROM delivery_cleaned
GROUP BY peak_hour_flag
ORDER BY avg_delivery_time DESC;


-- 6. Hourly Order Volume and Delivery Performance
SELECT
    order_hour,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_time,
    ROUND(AVG(slow_delivery_flag)::numeric * 100, 2) AS slow_delivery_rate
FROM delivery_cleaned
GROUP BY order_hour
ORDER BY order_hour;


-- 7. Vehicle-Level Delivery Performance
SELECT
    vehicle,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_time,
    ROUND(AVG(slow_delivery_flag)::numeric * 100, 2) AS slow_delivery_rate
FROM delivery_cleaned
GROUP BY vehicle
ORDER BY avg_delivery_time DESC;


-- 8. Small Vehicle Group Check
-- Helps avoid over-interpreting vehicle groups with very low record counts.
SELECT
    vehicle,
    COUNT(*) AS total_orders
FROM delivery_cleaned
GROUP BY vehicle
HAVING COUNT(*) < 50
ORDER BY total_orders;


-- 9. Agent Rating Group Performance
SELECT
    rating_group,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_time,
    ROUND(AVG(slow_delivery_flag)::numeric * 100, 2) AS slow_delivery_rate
FROM delivery_cleaned
GROUP BY rating_group
ORDER BY slow_delivery_rate DESC;


-- 10. Area-Level Slow-Delivery Ranking
WITH area_summary AS (
    SELECT
        area,
        COUNT(*) AS total_orders,
        ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_time,
        ROUND(AVG(slow_delivery_flag)::numeric * 100, 2) AS slow_delivery_rate
    FROM delivery_cleaned
    GROUP BY area
)
SELECT
    area,
    total_orders,
    avg_delivery_time,
    slow_delivery_rate,
    RANK() OVER (ORDER BY slow_delivery_rate DESC) AS slow_risk_rank
FROM area_summary
ORDER BY slow_risk_rank;


-- 11. Weather-Level Delivery Performance
SELECT
    weather,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_time,
    ROUND(AVG(slow_delivery_flag)::numeric * 100, 2) AS slow_delivery_rate
FROM delivery_cleaned
GROUP BY weather
ORDER BY slow_delivery_rate DESC;


-- 12. Product Category Delivery Performance
SELECT
    category,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_time,
    ROUND(AVG(slow_delivery_flag)::numeric * 100, 2) AS slow_delivery_rate
FROM delivery_cleaned
GROUP BY category
ORDER BY slow_delivery_rate DESC;


-- 13. Data Quality Check
SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN pickup_delay_mins IS NULL THEN 1 ELSE 0 END) AS missing_pickup_delay_records,
    SUM(CASE WHEN order_hour IS NULL THEN 1 ELSE 0 END) AS missing_order_hour_records,
    SUM(CASE WHEN distance_issue_flag = 1 THEN 1 ELSE 0 END) AS distance_issue_records,
    SUM(CASE WHEN distance_category = 'Distance Issue' THEN 1 ELSE 0 END) AS distance_issue_category_records
FROM delivery_cleaned;


-- 14. Slow-Delivery Flag Validation
-- Checks whether slow_delivery_flag contains only expected values.
SELECT
    slow_delivery_flag,
    COUNT(*) AS total_records,
    ROUND(COUNT(*)::numeric / SUM(COUNT(*)) OVER () * 100, 2) AS record_percentage
FROM delivery_cleaned
GROUP BY slow_delivery_flag
ORDER BY slow_delivery_flag;


-- 15. Distance Issue Percentage Check
-- Checks how many records were excluded from distance-based analysis.
SELECT
    COUNT(*) AS total_records,
    SUM(distance_issue_flag) AS distance_issue_records,
    ROUND(SUM(distance_issue_flag)::numeric / COUNT(*) * 100, 2) AS distance_issue_percentage
FROM delivery_cleaned;
