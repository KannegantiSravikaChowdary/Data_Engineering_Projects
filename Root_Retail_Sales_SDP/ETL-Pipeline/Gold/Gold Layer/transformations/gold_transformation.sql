CREATE OR REFRESH MATERIALIZED VIEW gold_data_quality_summary
COMMENT 'Data quality summary: row counts across pipeline layers'
AS

SELECT
  'Bronze (raw)' AS layer,
  'Raw records from CSV' AS description,
  COUNT(*) AS row_count
FROM cs_bronze_sales

UNION ALL

SELECT
  'Silver (clean)' AS layer,
  'Valid, deduplicated records' AS description,
  COUNT(*) AS row_count
FROM cs_silver_sales;

CREATE OR REFRESH MATERIALIZED VIEW gold_monthly_sales_trends
COMMENT 'Gold layer: Monthly sales and profit trends over time'
AS
SELECT
  YEAR(order_date) AS order_year,
  MONTH(order_date) AS order_month,
  COUNT(*) AS order_count,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  AVG(sales) AS avg_sales,
  SUM(quantity) AS total_quantity
FROM cs_silver_sales
GROUP BY ALL;

CREATE OR REFRESH MATERIALIZED VIEW gold_product_performance
COMMENT 'Gold layer: Individual product performance metrics'
AS
SELECT
  product_id,
  product_name,
  product_category,
  product_sub_category,
  COUNT(*) AS order_count,
  SUM(quantity) AS total_quantity_sold,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  AVG(sales) AS avg_sales_per_order,
  AVG(customer_rating) AS avg_customer_rating,
  ROUND(
    SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2
  ) AS profit_margin_pct
FROM cs_silver_sales
GROUP BY ALL;

CREATE OR REFRESH MATERIALIZED VIEW gold_sales_by_category
COMMENT 'Gold layer: Sales and profit by category and sub-category'
AS
SELECT
  product_category,
  product_sub_category,
  COUNT(*) AS order_count,
  SUM(quantity) AS total_quantity,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  AVG(sales) AS avg_sales,
  AVG(profit) AS avg_profit,
  ROUND(
    SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2
  ) AS profit_margin_pct
FROM cs_silver_sales
GROUP BY ALL;


CREATE OR REFRESH MATERIALIZED VIEW gold_sales_by_region
COMMENT 'Gold layer: Sales performance by region and state'
AS
SELECT
  region,
  state,
  COUNT(*) AS order_count,
  COUNT(DISTINCT customer_id) AS unique_customers,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  AVG(sales) AS avg_sales,
  ROUND(
    SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2
  ) AS profit_margin_pct
FROM cs_silver_sales
GROUP BY ALL;


CREATE OR REFRESH MATERIALIZED VIEW gold_top_products
COMMENT 'Gold layer: Top products ranked by sales and profit'
AS
SELECT
  product_id,
  product_name,
  product_category,
  product_sub_category,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  SUM(quantity) AS total_quantity_sold,
  COUNT(*) AS order_count,
  RANK() OVER (
    ORDER BY SUM(sales) DESC
  ) AS sales_rank,
  RANK() OVER (
    ORDER BY SUM(profit) DESC
  ) AS profit_rank
FROM cs_silver_sales
GROUP BY ALL;



