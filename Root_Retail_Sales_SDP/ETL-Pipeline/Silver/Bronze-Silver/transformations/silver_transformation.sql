create or refresh materialized view cs_silver_sales
(
    -- critical keys: drop rows that cannot be identified
    constraint valid_order_id expect (order_id is not null) on violation drop row,
    constraint valid_product_id expect (product_id is not null) on violation drop row,
    constraint valid_order_date expect (order_date is not null) on violation drop row,
    -- business rules: drop rows with impossible values
    constraint valid_quantity expect (quantity > 0) on violation drop row,
    constraint valid_sales expect (sales >= 0) on violation drop row,
    -- monitor only: keep rows, report metrics
    constraint valid_ship_date expect (ship_date is not null),
    constraint valid_discount expect (discount_percent between 0 and 100),
    constraint valid_rating expect (customer_rating between 1 and 5)
)
comment 'Silver Layer:- Data Transformation (snake_case renames, typed casts, trimmed strings, deduplicated by order_id + product_id)'
as
select
    -- order identifiers
    trim(OrderID)                      as order_id,
    OrderDate                          as order_date,
    ShipDate                           as ship_date,
    trim(ShipMode)                     as ship_mode,
    OrderStatus                        as order_status,

    -- customer
    trim(CustomerID)                   as customer_id,
    trim(CustomerName)                 as customer_name,
    trim(CustomerSegment)              as customer_segment,

    -- geography
    trim(Country)                      as country,
    trim(Region)                       as region,
    trim(State)                        as state,
    trim(City)                         as city,
    cast(PostalCode as string)         as postal_code,

    -- product
    trim(ProductID)                    as product_id,
    trim(ProductName)                  as product_name,
    trim(ProductCategory)              as product_category,
    trim(ProductSubCategory)           as product_sub_category,
    trim(Brand)                        as brand,
    trim(Supplier)                     as supplier,

    -- measures
    cast(Quantity as int)              as quantity,
    cast(UnitPrice as decimal(12,2))   as unit_price,
    cast(DiscountPercent as decimal(5,2)) as discount_percent,
    cast(DiscountAmount as decimal(12,2)) as discount_amount,
    cast(Sales as decimal(12,2))       as sales,
    cast(UnitCost as decimal(12,2))    as unit_cost,
    cast(TotalCost as decimal(12,2))   as total_cost,
    cast(Profit as decimal(12,2))      as profit,

    -- transaction details
    trim(PaymentMethod)                as payment_method,
    trim(SalesChannel)                as sales_channel,
    trim(SalesRep)                    as sales_rep,
    Returned                          as returned,
    CustomerRating                    as customer_rating,
    trim(Currency)                     as currency,

    -- lineage
    souce_file                         as source_file,
    ingested_at                        as ingested_at

from retail_sales_sdp.default.cs_bronze_sales

-- keep only the latest record per order line
qualify row_number() over (partition by OrderID, ProductID order by ingested_at desc) = 1