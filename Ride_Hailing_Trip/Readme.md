# Ride Hailing Trip Analytics Platform: Medallion Architecture with Lakeflow Spark Declarative Pipelines

An end-to-end ride-hailing analytics ETL pipeline built on  Databricks using Lakeflow Spark Declarative Pipelines (SQL) and the Medallion Architecture (Bronze → Silver → Gold).

## Table of Contents

- Business Problem
- Architecture
- Pipeline Lineage
- Tech Stack
- Dataset
- Repository Structure
- Layer Details
- Data Quality Rules
- Reconciliation
- How to Run
- Business Requirements Coverage
- Dashboard
- Key Learnings
- Future Improvements

## Business Problem

Ride-hailing companies generate thousands of trip records every month. Raw exports contain duplicates, inconsistent text formats, missing values, invalid distances, and negative rates.

**Goal:** Build a repeatable data engineering pipeline that transforms raw trip data into trusted analytics-ready tables and dashboards.

## Architecture

![Architecture](Images/Architecture.jpeg)


## Pipeline Lineage

| Object | Type | Description |
|---------|---------|-------------|
| bronze_ride_trips | Streaming Table | Raw ride trips |
| silver_trips_clean | Materialized View | Cleaned trip records |
| silver_trips_rejected | Materialized View | Invalid trip records |
| gold_monthly_trips | Materialized View | Monthly KPI summary |
| gold_city_summary | Materialized View | City-level analytics |
| gold_vehicle_summary | Materialized View | Vehicle performance analytics |
| gold_payment_summary | Materialized View | Payment method analytics |
| gold_data_quality | Materialized View | Data quality and reconciliation metrics |

## Tech Stack

- Lakeflow Spark Declarative Pipelines
- SQL
- Unity Catalog
- Delta Lake

## Dataset

Synthetic Ride-Hailing Dataset

- 1,214 rows
- 20 columns
- Cab trip records
- Data quality issues intentionally introduced

## Repository Structure

Ride_Hailing_Trip/
├── README.md
├── Data/
│   └── ride_trips_raw.csv
├── ETL-Pipeline/
│   ├── Bronze/
│   ├── Silver/
│   └── Gold/
├── Images/
│   ├── architecture.png
│   ├── lineage.png
│   └── dashboard.png

## Layer Details

### Bronze Layer

- Loads raw trip CSV
- Preserves source data
- Adds file metadata
- Adds ingestion timestamp

### Silver Layer

- Removes duplicate trip_id records
- Cleans city and vehicle names
- Replaces missing city values
- Recalculates missing fares
- Separates rejected records

### Gold Layer

#### gold_monthly_trips

- Trips
- Revenue
- Driver payout
- Platform earning

#### gold_city_summary

- Trips by city
- Revenue by city
- Average fare

#### gold_vehicle_summary

- Trips by vehicle
- Revenue by vehicle
- Average rating

#### gold_payment_summary

- Revenue by payment method
- Pending payments

#### gold_data_quality

- Duplicate count
- Missing values
- Invalid distance
- Invalid rate
- Reconciliation

## Data Quality Rules

| Rule | Treatment |
|--------|--------|
| Duplicate trip_id | Removed |
| Missing city | Unknown |
| Missing payment method | Unknown |
| Missing fare | Recalculated |
| Invalid distance | Rejected |
| Invalid rate | Rejected |

## Reconciliation

bronze_rows = clean_rows + rejected_rows + duplicate_rows

Ensures no records are lost during processing.

## Dashboard

### Page 1 – Overview

- Total Trips
- Total Revenue
- Platform Earnings
- Monthly Revenue Trend

### Page 2 – Vehicle & Payments

- Trips by Vehicle
- Revenue by Vehicle
- Average Rating
- Payment Method Analysis

### Page 3 – Data Quality

- Bronze Rows
- Clean Rows
- Rejected Rows
- Duplicate Rows
- Reconciliation Status

## How to Run

1. Upload dataset to Unity Catalog Volume.
2. Create Databricks pipeline.
3. Configure catalog and schema.
4. Run Bronze layer.
5. Run Silver layer.
6. Run Gold layer.
7. Validate reconciliation.
8. Build dashboard.

## Business Requirements Coverage

| Requirement | Solution |
|------------|------------|
| Monthly Trends | gold_monthly_trips |
| City Performance | gold_city_summary |
| Vehicle Performance | gold_vehicle_summary |
| Payment Analysis | gold_payment_summary |
| Data Quality | gold_data_quality |
| Reconciliation | gold_data_quality |

## Key Learnings

- Medallion Architecture
- Lakeflow Spark Declarative Pipelines
- Data Quality Validation
- Data Reconciliation
- SQL Transformations
- Databricks Pipeline Design

## Future Improvements

- Streaming ingestion
- Real-time trip analytics
- Driver performance analytics
- Surge pricing analysis
- Incremental pipeline refresh

## Author

Kanneganti Sravika Chowdary
