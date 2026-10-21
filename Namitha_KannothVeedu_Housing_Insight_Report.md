# Urban Housing Market Intelligence Report

**Student name:** Namitha Kannoth Veedu  
**Submission date:** 24 August 2026 
**Database tool used:**  MySQL Workbench

## 1. Executive Summary

This report looks at the housing market data to understand how sales, transaction volume, median sale prices and inventory vary across different cities, years and market sizes. The aim of the analysis is to identify the main patterns in the data and highlight the areas that may be most important for management to consider.

The analysis shows that Houston was one of the strongest markets in the dataset, with the highest total sales and transaction volume among the cities analysed. When looking at the data by year, 2014 had the highest total transaction volume, although total sales were slightly higher in 2006. There was also a clear difference between market-size groups. Large markets had much higher sales and transaction volumes than mid-sized and small markets, and they also had a higher average median sale price.

While carrying out the analysis, I also found some missing values in the dataset. The largest number of missing values was found in the listings and months of inventory fields. This means that inventory-related results should be interpreted with some caution. Based on the overall findings, high-activity and large markets should be an important area of focus, while changes in prices, inventory levels and data completeness should continue to be monitored.

## 2. Business Question

The purpose of this analysis is to get a better understanding of the housing market data and see how the results differ across cities, years and market sizes. I wanted to find out which cities had the highest level of activity, which years performed better, and how sales, prices and inventory changed across the different market groups. I also checked the data for missing values and other issues that could affect the results.

## 3. Dataset and Method

**Dataset used:**The analysis was carried out using a housing market dataset containing 5,000 records. The main table used for the analysis was fact_housing_market, which contains information such as sales, transaction volume, median sale price, listings and months of inventory.

**Fact table grain:** Each row in `fact_housing_market` represents the aggregate monthly performance of a single city for a specific month and year.

**Tables joined:** Other tables were joined to the main table to provide additional information. dim_city was used to get details about the cities and their market categories, while dim_period provided the year and month information. The bridge_city_focus_tags table was also used to analyse different focus tags assigned to cities.

**SQL methods used:** I used SQL to explore and analyse the data. This included checking the number of records, looking for missing values, filtering and sorting the data, calculating totals and averages, grouping the results by city, year and market segment, and joining related tables together. I also used GROUP BY, HAVING and COUNT(DISTINCT) where needed. I checked the joins carefully to make sure duplicate rows did not lead to incorrect results.


## 4. KPI Definitions

| KPI                       | Definition                                               | SQL calculation used  |
|---------------------------|----------------------------------------------------------|-----------------------|
| Record count              |Number of housing market records included in the analysis |COUNT(*)               |
| Total sales               |Total number of reported property sales                   |SUM(sales)             |
| Total volume              |Total value of reported housing transactions              |SUM(volume)            |
| Average median sale price |Average of the median sale prices in the selected records |AVG(median_sale_price) |
| Average months inventory  |Average number of months of housing inventory available   |AVG(months_inventory)  |

## 5. Key Findings

### Finding 1
Housing market activity changed across the years, with 2014 recording the highest transaction volume in the dataset.

Evidence from SQL: The yearly analysis showed that 2014 had a total transaction volume of approximately 84.76 billion. However, 2006 had slightly higher total sales, with 347,733 compared with 345,720 in 2014.

### Finding 2
Houston had the highest overall sales and transaction volume among the cities in the dataset.

Evidence from SQL: The city-level analysis showed Houston with 636,995 total sales and a total transaction volume of approximately 139.60 billion.

### Finding 3
Large housing markets performed much more strongly than mid-sized and small markets.

Evidence from SQL: Large markets recorded 1,664,997 total sales and approximately 375.06 billion in total transaction volume. They also had the highest average median sale price at around 178,665.

## 6. Data Quality and Caveats

While checking the dataset, I found some missing values, mainly in the listings and months of inventory columns. Because of this, results involving inventory may not give a complete picture of the market.

I also noticed that the January 2015 data is only partially available, so it should not be directly compared with years that contain complete data. These limitations should be kept in mind when interpreting the results.

## 7. Join Accuracy Note

Joining housing records to city focus tags can duplicate records because a city may have multiple tags. I used COUNT(DISTINCT f.market_record_id) to count unique market records. This corrects record counts only; it does not correct duplicated financial sums. Sales and transaction-volume totals were calculated without joining the tag bridge.

## 8. Recommendations

1. Management should pay particular attention to high-activity markets such as Houston, as these cities contribute a large share of overall sales and transaction volume.

2. Large markets should remain an important area of focus because they showed higher sales, transaction volumes and average median sale prices than the other market-size groups.

3. Changes in sales and transaction volume should be monitored over time, as the yearly analysis showed differences in market performance from one year to another.

4. Data quality should also be improved, especially for listings and months of inventory, as missing values in these fields may affect the accuracy of inventory-related analysis.
