-- Show all rows and columns
SELECT *
FROM deliveries;
-- Q1. how many orders, which dates, and are any order ids repeated
select count(*) as total_orders,
       count(distinct Order_ID) as unique_orders,
       min(Order_Date) as first_date,
       max(Order_Date) as last_date
from deliveries;

-- Q2. quick check of the cleaned table (problems should be 0, wrong locations are kept on purpose)
select sum(case when distance_km is null then 1 else 0 end) as wrong_location,
       sum(case when Agent_Rating > 5 then 1 else 0 end) as rating_above_5,
       sum(case when Agent_Age < 18 then 1 else 0 end) as agents_under_18,
       sum(case when Traffic is null or Weather is null then 1 else 0 end) as missing_traffic_weather,
       min(Delivery_Time) as fastest,
       max(Delivery_Time) as slowest
from deliveries;

-- Q3. average delivery time for each category (Grocery stands out)
select Category,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes
from deliveries
group by Category
order by avg_minutes;


-- Q4. orders, average time and percent of late orders
select count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes,
       round(100.0 * sum(case when Delivery_Time > 150 then 1 else 0 end) / count(*), 1) as pct_late,
       round(avg(wait_min), 1) as avg_prep_wait
from deliveries
where Category <> 'Grocery';

-- Q5. traffic
select Traffic,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes,
       round(100.0 * sum(case when Delivery_Time > 150 then 1 else 0 end) / count(*), 1) as pct_late
from deliveries
where Category <> 'Grocery'
group by Traffic
order by avg_minutes;

-- Q6. weather
select Weather,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes,
       round(100.0 * sum(case when Delivery_Time > 150 then 1 else 0 end) / count(*), 1) as pct_late
from deliveries
where Category <> 'Grocery'
group by Weather
order by avg_minutes;

-- Q7. slowest traffic and weather combinations (having removes groups with few orders)
select Traffic, Weather,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes
from deliveries
where Category <> 'Grocery'
group by Traffic, Weather
having count(*) >= 100
order by avg_minutes desc
limit 5;

-- Q8. which traffic levels happen at which time of day
-- (Jam only shows up in the evening, so traffic and hour are mixed together)
select case when order_hour between 8 and 11 then '1 morning (8-11)'
            when order_hour between 12 and 16 then '2 midday (12-16)'
            else '3 evening and night (17-24)' end as time_of_day,
       Traffic,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes
from deliveries
where Category <> 'Grocery'
group by time_of_day, Traffic
order by time_of_day, Traffic;

-- Q9. each order hour: orders, average time, and rank (1 = slowest hour)
select order_hour,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes,
       rank() over (order by avg(Delivery_Time) desc) as slowest_rank
from deliveries
where Category <> 'Grocery'
group by order_hour
order by order_hour;

-- Q10. area (Semi-Urban has very few orders, so do not trust it)
select Area,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes
from deliveries
where Category <> 'Grocery'
group by Area
order by avg_minutes;

-- Q11. vehicle
select Vehicle,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes
from deliveries
where Category <> 'Grocery'
group by Vehicle
order by avg_minutes;

-- Q12. distance groups (only orders with a correct location)
select case when distance_km < 5 then '1) 0-5 km'
            when distance_km < 10 then '2) 5-10 km'
            when distance_km < 15 then '3) 10-15 km'
            else '4) 15 km or more' end as distance_group,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes,
       round(100.0 * sum(case when Delivery_Time > 150 then 1 else 0 end) / count(*), 1) as pct_late
from deliveries
where Category <> 'Grocery' and distance_km is not null
group by distance_group
order by distance_group;

-- Q13. agent rating groups
select case when Agent_Rating <= 4.0 then '1) 4.0 or less'
            when Agent_Rating <= 4.5 then '2) 4.1 to 4.5'
            when Agent_Rating <= 4.7 then '3) 4.6 to 4.7'
            when Agent_Rating <= 4.9 then '4) 4.8 to 4.9'
            else '5) 5.0' end as rating_group,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes,
       round(100.0 * sum(case when Delivery_Time > 150 then 1 else 0 end) / count(*), 1) as pct_late
from deliveries
where Category <> 'Grocery'
group by rating_group
order by rating_group;

-- Q14. agent age groups
select case when Agent_Age <= 25 then '1) 20-25'
            when Agent_Age <= 30 then '2) 26-30'
            when Agent_Age <= 35 then '3) 31-35'
            else '4) 36-39' end as age_group,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes
from deliveries
where Category <> 'Grocery'
group by age_group
order by age_group;

-- Q15. day of the week
select weekday,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes
from deliveries
where Category <> 'Grocery'
group by weekday
order by avg_minutes;


-- Q16. morning vs evening, only in Low traffic (Low is the only level found in both)
select case when order_hour between 8 and 11 then 'morning (8-11)'
            else 'evening and night' end as time_of_day,
       count(*) as orders,
       round(avg(Delivery_Time), 1) as avg_minutes
from deliveries
where Category <> 'Grocery'
  and Traffic = 'Low'
  and (order_hour between 8 and 11 or order_hour >= 17 or order_hour = 0)
group by time_of_day;


-- Q17. do low rated agents get longer trips?
select case when Agent_Rating <= 4.0 then '1) 4.0 or less'
            when Agent_Rating <= 4.5 then '2) 4.1 to 4.5'
            else '3) above 4.5' end as rating_group,
       count(*) as orders,
       round(avg(distance_km), 1) as avg_distance_km,
       round(avg(Delivery_Time), 1) as avg_minutes
from deliveries
where Category <> 'Grocery' and distance_km is not null
group by rating_group
order by rating_group;

-- Q18. Grocery vs other categories in each traffic level
select Traffic,
       round(avg(case when Category = 'Grocery' then Delivery_Time end), 1) as grocery_avg,
       round(avg(case when Category <> 'Grocery' then Delivery_Time end), 1) as other_avg
from deliveries
group by Traffic
order by other_avg;