CREATE OR REFRESH MATERIALIZED VIEW gold_monthly_trips
COMMENT 'Monthly trip, distance and revenue summary per month'
AS
SELECT DATE_TRUNC('MONTH', trip_date)                          AS trip_month,
       COUNT(*)                                                AS trips,
       SUM(distance_km)                                        AS total_km,
       SUM(fare_amount - discount_amount)                      AS net_revenue,
       SUM(driver_payout)                                      AS driver_payout,
       SUM(fare_amount - discount_amount) - SUM(driver_payout) AS platform_earnings
FROM silver_trips_clean
GROUP BY DATE_TRUNC('MONTH', trip_date);


CREATE OR REFRESH MATERIALIZED VIEW gold_city_summary
COMMENT 'Trip and net revenue summary per region and city'
AS
SELECT region,
       city,
       COUNT(*)                            AS trips,
       SUM(fare_amount - discount_amount)  AS net_revenue,
       AVG(fare_amount - discount_amount)  AS avg_fare_per_trip
FROM silver_trips_clean
GROUP BY ALL;


CREATE OR REFRESH MATERIALIZED VIEW gold_vehicle_summary
COMMENT 'Trip, distance, revenue and rating summary per vehicle type'
AS
SELECT vehicle_type,
       COUNT(*)                            AS trips,
       SUM(distance_km)                     AS total_km,
       SUM(fare_amount - discount_amount)  AS net_revenue,
       AVG(customer_rating)                 AS avg_rating
FROM silver_trips_clean
GROUP BY ALL;


CREATE OR REFRESH MATERIALIZED VIEW gold_payment_summary
COMMENT 'Trip, revenue and pending amount summary per payment method'
AS
SELECT payment_method,
       COUNT(*)                                                        AS trips,
       SUM(fare_amount - discount_amount)                              AS net_revenue,
       SUM(CASE WHEN payment_status = 'Pending'
               THEN fare_amount - discount_amount
               ELSE 0 END)                                            AS pending_amount
FROM silver_trips_clean
GROUP BY ALL;


CREATE OR REFRESH MATERIALIZED VIEW gold_data_quality
COMMENT 'Data quality and reconciliation metrics across bronze and silver layers'
AS
WITH bronze_stats AS (
  SELECT
    COUNT(*)                                                   AS bronze_rows,
    COUNT(*) - COUNT(DISTINCT trip_id)                         AS duplicate_rows,
    SUM(CASE WHEN distance_km <= 0 THEN 1 ELSE 0 END)         AS invalid_distance_rows,
    SUM(CASE WHEN rate_per_km < 0 THEN 1 ELSE 0 END)          AS negative_rate_rows,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END)            AS missing_city_rows,
    SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END)   AS missing_payment_rows,
    SUM(CASE WHEN fare_amount IS NULL THEN 1 ELSE 0 END)      AS missing_fare_rows,
    SUM(CASE WHEN customer_rating IS NULL THEN 1 ELSE 0 END)  AS missing_rating_rows
  FROM bronze_ride_trips
),
clean_stats AS (
  SELECT COUNT(*) AS clean_rows
  FROM silver_trips_clean
),
rejected_stats AS (
  SELECT COUNT(*) AS rejected_rows
  FROM silver_trips_rejected
)
SELECT bronze_rows,
       duplicate_rows,
       invalid_distance_rows,
       negative_rate_rows,
       missing_city_rows,
       missing_payment_rows,
       missing_fare_rows,
       missing_rating_rows,
       clean_rows,
       rejected_rows
FROM bronze_stats b
INNER JOIN clean_stats c ON TRUE
INNER JOIN rejected_stats r ON TRUE;
