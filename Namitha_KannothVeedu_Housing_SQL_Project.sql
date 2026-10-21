-- Namitha_KannothVeedu_Housing_SQL_Project.sql
-- Project: Urban Housing Market Intelligence
-- Student name: Namitha Kannoth Veedu
-- Date:24 August 2026

USE housing_assignment;

/*Task 1: Validate the imported data
   Business Question: Did all tables load with the expected row counts and date ranges?*/
   
-- 1.1- Count rows in each imported table

SELECT COUNT(*) AS city_rows FROM dim_city;

SELECT COUNT(*) AS period_rows FROM dim_period;

SELECT COUNT(*) AS fact_rows FROM fact_housing_market;

SELECT COUNT(*) AS bridge_rows FROM bridge_city_focus_tags;

-- 1.2- Show the first 10 rows from the fact table.

SELECT * FROM fact_housing_market ORDER BY market_record_id LIMIT 10;

-- 1.3- Find the earliest and latest period in the fact table

SELECT
    MIN(p.period_start_date) AS earliest_year_month,
    MAX(p.period_start_date) AS latest_year_month
FROM fact_housing_market f
JOIN dim_period p
    ON f.period_id = p.period_id;
    
/* Task 2: Understand the dataset grain*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT city_id, period_id) AS unique_city_periods
FROM fact_housing_market;

-- 2.1-What does one row in `fact_housing_market` represent?
-- Each row in 'fact_housing_market' represents aggregate housing market activity 
-- for a single city during a specific month and year.

-- 2.2- Why does this matter before using `SUM(volume)` or `AVG(median_sale_price)`?
-- This matters because SUM(volume) adds volume across city-month records,
-- while AVG(median_sale_price) calculates the average across city-month records.
-- Understanding the grain helps avoid incorrect totals or averages caused by duplicate rows.

/* Task 3: Inspect unique values */

-- Use `DISTINCT` to list:

-- 3.1- All years in the fact table;
SELECT DISTINCT p.year 
FROM fact_housing_market f
JOIN dim_period p ON f.period_id = p.period_id
ORDER BY p.year ASC;

-- 3.2- All market size bands in `dim_city`;
SELECT DISTINCT market_size_band
FROM dim_city
ORDER BY market_size_band;

-- 3.3- all price bands in `dim_city`.
SELECT DISTINCT price_band
FROM dim_city
ORDER BY price_band;

/* Task 4: Data quality checks */

-- 4.1- Count missing values in the main housing measures
SELECT
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN volume IS NULL THEN 1 ELSE 0 END) AS missing_volume,
    SUM(CASE WHEN median_sale_price IS NULL THEN 1 ELSE 0 END) AS missing_median_sale_price,
    SUM(CASE WHEN listings IS NULL THEN 1 ELSE 0 END) AS missing_listings,
    SUM(CASE WHEN months_inventory IS NULL THEN 1 ELSE 0 END) AS missing_months_inventory
FROM fact_housing_market;

-- 4.2 - Sample 20 records where at least one field is missing
SELECT * 
FROM fact_housing_market
WHERE sales IS NULL 
   OR volume IS NULL 
   OR median_sale_price IS NULL 
   OR listings IS NULL 
   OR months_inventory IS NULL
LIMIT 20;

/* Task 5: Filtering and sorting */

-- 5.1 Which city-month records have sales above 1,000?

SELECT
    c.city_name,
    p.period_start_date,
    f.sales
FROM fact_housing_market f
JOIN dim_city c
    ON f.city_id = c.city_id
JOIN dim_period p
    ON f.period_id = p.period_id
WHERE f.sales > 1000
ORDER BY f.sales DESC;

-- 5.2- Which city-month records from 2014 have median sale price above 200,000?

SELECT
    c.city_name,
    p.period_start_date,
    f.median_sale_price
FROM fact_housing_market f
JOIN dim_city c
    ON f.city_id = c.city_id
JOIN dim_period p
    ON f.period_id = p.period_id
WHERE p.year = 2014
  AND f.median_sale_price > 200000
ORDER BY f.median_sale_price DESC;

-- 5.3- Which records are from selected cities such as `Austin`, `Dallas`, `Houston` and `San Antonio`?

SELECT
    c.city_name,
    p.period_start_date,
    f.sales,
    f.volume,
    f.median_sale_price
FROM fact_housing_market f
JOIN dim_city c
    ON f.city_id = c.city_id
JOIN dim_period p
    ON f.period_id = p.period_id
WHERE c.city_name IN ('Austin', 'Dallas', 'Houston', 'San Antonio')
ORDER BY c.city_name, p.period_start_date;

-- 5.4- Which cities contain the text pattern `San`?

SELECT city_name
FROM dim_city
WHERE city_name LIKE '%San%'
ORDER BY city_name;

/* Task 6: Overall KPI summary */
-- Calculate:
-- - total number of market records;
-- - total reported sales;
-- - total reported volume;
-- - average median sale price;
-- - average months of inventory.
-- Business question: What are the portfolio-wide baseline metrics?
SELECT 
    COUNT(*) AS total_market_records,
    SUM(sales) AS total_reported_sales,
    SUM(volume) AS total_reported_volume,
    AVG(median_sale_price) AS avg_median_sale_price,
    AVG(months_inventory) AS avg_months_inventory
FROM fact_housing_market;

/* Task 7: Time-based KPI analysis */

-- Join to `dim_period` and calculate yearly totals:
-- - record count;
-- - total sales;
-- - total volume;
-- - average median sale price.
-- Sort the result by year.
-- Business question: What are the yearly performance trends across the market?

SELECT
    p.year,
    COUNT(*) AS record_count,
    SUM(f.sales) AS total_sales,
    SUM(f.volume) AS total_volume,
    AVG(f.median_sale_price) AS avg_median_sale_price
FROM fact_housing_market f
JOIN dim_period p
    ON f.period_id = p.period_id
GROUP BY p.year
ORDER BY p.year;

/* Task 8: City-level performance analysis */
-- Join to `dim_city` and calculate city-level KPIs:
-- - number of city-month records;
-- - total sales;
-- - total volume;
-- - average median sale price;
-- - average inventory.
-- Show the top 10 cities by total volume.
-- Business question: What are the top 10 cities by total sales volume?

SELECT 
    c.city_name,
    COUNT(f.market_record_id) AS city_month_records,
    SUM(f.sales) AS total_sales,
    SUM(f.volume) AS total_volume,
    AVG(f.median_sale_price) AS avg_median_sale_price,
    AVG(f.months_inventory) AS avg_inventory
FROM fact_housing_market f
JOIN dim_city c ON f.city_id = c.city_id
GROUP BY c.city_name
ORDER BY total_volume DESC
LIMIT 10;

/* Task 9: Segment-level analysis */

-- Using `dim_city`, compare results by:
-- 1. `market_size_band`
-- 2. `price_band`
-- For each segment, calculate total sales, total volume and average median sale price.
-- Business question: How do performance metrics compare across segments?

-- 9.1 - By Market Size Band
SELECT 
    c.market_size_band,
    SUM(f.sales) AS total_sales,
    SUM(f.volume) AS total_volume,
    AVG(f.median_sale_price) AS avg_median_sale_price
FROM fact_housing_market f
JOIN dim_city c ON f.city_id = c.city_id
GROUP BY c.market_size_band
ORDER BY total_volume DESC;

-- 9.2 - By Price Band
SELECT 
    c.price_band,
    SUM(f.sales) AS total_sales,
    SUM(f.volume) AS total_volume,
    AVG(f.median_sale_price) AS avg_median_sale_price
FROM fact_housing_market f
JOIN dim_city c ON f.city_id = c.city_id
GROUP BY c.price_band
ORDER BY total_volume DESC;

/* Task 10: HAVING for management thresholds */

-- Find cities where total reported sales exceed 50,000 across the sample period. Use `GROUP BY` and `HAVING`.
-- Business question: Which cities exceeded 50,000 total sales?
SELECT c.city_name,
SUM(f.sales) AS total_sales
FROM fact_housing_market f
JOIN dim_city c ON f.city_id = c.city_id
GROUP BY c.city_name
HAVING SUM(f.sales) > 50000
ORDER BY total_sales DESC;

/* Task 11: LEFT JOIN gap check */

-- Use `dim_period` as the base table and `LEFT JOIN` to the fact table to identify periods in the period lookup table 
-- that have no matching market records in the 5,000-row sample.
-- Business question: Identify periods with missing market records.
SELECT
    p.period_id,
    p.period_start_date,
    p.year,
    p.month
FROM dim_period p
LEFT JOIN fact_housing_market f ON p.period_id = f.period_id
WHERE f.period_id IS NULL
ORDER BY p.period_start_date;

-- 11.2- Explain why a `LEFT JOIN` is appropriate here.

-- LEFT JOIN is appropriate because it keeps all periods from dim_period,
-- including periods that have no matching records in fact_housing_market.
-- NULL matches therefore identify the missing periods.

/* Task 12: Safe-join challenge */

-- Join city tags from `bridge_city_focus_tags`. 
-- Because one city can have multiple tags, a careless join can duplicate fact rows.
-- Business question: Prevent duplication from one-to-many tag relations.

-- 12.1- A query that shows why row counts increase after joining tags;

SELECT
    COUNT(*) AS rows_after_tag_join,
    COUNT(DISTINCT f.market_record_id) AS distinct_market_records
FROM fact_housing_market f
JOIN bridge_city_focus_tags b ON f.city_id = b.city_id;

-- 12.2- A correct query that counts distinct market records by tag;
SELECT 
    b.focus_tag,
    COUNT(DISTINCT f.market_record_id) AS distinct_market_records
FROM fact_housing_market f
JOIN bridge_city_focus_tags b ON f.city_id = b.city_id
GROUP BY b.focus_tag
ORDER BY distinct_market_records DESC;

-- 12.3- a short explanation of why `COUNT(*)` or `SUM(volume)` can be wrong after a one-to-many join.

-- A one-to-many join creates multiple rows per fact record whenever a city possesses multiple tags. 
-- Applying SUM(volume) or plain COUNT(*) on the resulting joined set inflates financial and volume totals.

/* Task 13: Final stakeholder summary table */

-- Create one final result table that a manager could read. It should include at least:
-- - city name;
-- - market size band;
-- - total sales;
-- - total volume;
-- - average median sale price;
-- - average months inventory;
-- - record count.
-- Sort by the most important KPI and limit to the top 15 rows.

SELECT
    c.city_name,
    c.market_size_band,
    SUM(f.sales) AS total_sales,
    SUM(f.volume) AS total_volume,
    AVG(f.median_sale_price) AS avg_median_sale_price,
    AVG(f.months_inventory) AS avg_months_inventory,
    COUNT(*) AS record_count
FROM fact_housing_market f
JOIN dim_city c ON f.city_id = c.city_id
GROUP BY
    c.city_name,
    c.market_size_band
ORDER BY total_volume DESC
LIMIT 15;

