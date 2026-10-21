USE housing_assignment;
-- Stretch 1: Use a CTE
-- Rewrite your final stakeholder table using a `WITH` clause.

WITH city_summary AS (
    SELECT
        c.city_name,
        c.market_size_band,
        SUM(f.sales) AS total_sales,
        SUM(f.volume) AS total_volume,
        AVG(f.median_sale_price) AS avg_median_sale_price,
        AVG(f.months_inventory) AS avg_months_inventory,
        COUNT(*) AS record_count
    FROM fact_housing_market f
    JOIN dim_city c
        ON f.city_id = c.city_id
    GROUP BY
        c.city_name,
        c.market_size_band
)

SELECT *
FROM city_summary
ORDER BY total_volume DESC
LIMIT 15;

-- Stretch 2: Use a window function
-- Rank cities by total volume within each market size band.

WITH city_totals AS (
    SELECT
        c.city_name,
        c.market_size_band,
        SUM(f.volume) AS total_volume
    FROM fact_housing_market f
    JOIN dim_city c
        ON f.city_id = c.city_id
    GROUP BY
        c.city_name,
        c.market_size_band
)

SELECT
    city_name,
    market_size_band,
    total_volume,
    RANK() OVER (
        PARTITION BY market_size_band
        ORDER BY total_volume DESC
    ) AS city_rank
FROM city_totals
ORDER BY
    market_size_band,
    city_rank;
    
-- Stretch 3: Create a dashboard mock-up
-- Create a simple dashboard in Excel, Power BI, Tableau or Google Sheets showing:
-- - total sales by year;
-- - top 10 cities by volume;
-- - average median sale price by price band;
-- - inventory pressure by market size band.    

SELECT
    c.city_name,
    SUM(f.volume) AS total_volume
FROM fact_housing_market f
JOIN dim_city c
    ON f.city_id = c.city_id
GROUP BY c.city_name
ORDER BY total_volume DESC
LIMIT 10;
    
SELECT
    p.year,
    SUM(f.volume) AS total_volume
FROM fact_housing_market f
JOIN dim_period p
    ON f.period_id = p.period_id
GROUP BY p.year
ORDER BY p.year;
    
    
    
    