CREATE OR REFRESH MATERIALIZED VIEW silver_trips_clean (
  CONSTRAINT valid_distance EXPECT (distance_km > 0) ON VIOLATION DROP ROW,
  CONSTRAINT valid_rate EXPECT (rate_per_km >= 0) ON VIOLATION DROP ROW
)
COMMENT 'Clean ride-hailing trips: deduplicated, standardized text fields, fares backfilled from distance x rate'
AS
SELECT DISTINCT
  trip_id,
  customer_id,
  driver_id,
  trip_date,
  pickup_hour,
  COALESCE(INITCAP(TRIM(city)), 'Unknown') AS city,
  pickup_zone,
  region,
  INITCAP(TRIM(vehicle_type)) AS vehicle_type,
  INITCAP(TRIM(booking_channel)) AS booking_channel,
  distance_km,
  duration_min,
  rate_per_km,
  COALESCE(fare_amount, distance_km * rate_per_km) AS fare_amount,
  discount_amount,
  COALESCE(payment_method, 'Unknown') AS payment_method,
  payment_status,
  driver_payout,
  customer_rating,
  trip_type
FROM bronze_ride_trips;

CREATE OR REFRESH MATERIALIZED VIEW silver_trips_rejected
COMMENT 'Trips rejected by silver quality rules, with the reason for rejection'
AS
SELECT
  *,
  CASE
    WHEN NOT (distance_km > 0) THEN 'Distance is zero, negative, or missing'
    ELSE 'Rate per km is negative'
  END AS reject_reason
FROM bronze_ride_trips
WHERE NOT (distance_km > 0 AND rate_per_km >= 0);
