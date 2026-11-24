from pyspark import pipelines as dp
from pyspark.sql.functions import col, when, trim, coalesce, expr

def handle_missing_values(df):
    columns_to_check = [
        "order_id", "order_date", "customer_id", "customer_name",
        "city", "product_name", "category", "quantity",
        "unit_price", "payment_mode", "order_status"
    ]

    for column_name in columns_to_check:
        df = df.withColumn(
            column_name,
            when(trim(col(column_name)) == "", None)
            .otherwise(col(column_name))
        )
    return df

def convert_data_types(df):
    df = df.withColumn(
        "order_date",
        coalesce(
            expr("try_to_timestamp(order_date, 'dd/MM/yyyy')"),
            expr("try_to_timestamp(order_date, 'yyyy-MM-dd')")
        ).cast("date")
    )

    df = df.withColumn(
        "quantity",
        expr("try_cast(quantity AS INT)")
    )

    df = df.withColumn(
        "unit_price",
        expr("try_cast(unit_price AS DECIMAL(12,2))")
    )

    df = df.withColumn(
        "order_amount",
        (
            col("quantity").cast("decimal(12,2)") *
            col("unit_price")
        ).cast("decimal(18,2)")
    )
    return df

@dp.table(
    name="silver_orders_typed",
    comment="Records with blank values normalized and data types converted"
)
def silver_orders_typed():
    df = spark.readStream.table(
        "ecommerce_sdp.default.silver_orders_cleaned"
    )
    df = handle_missing_values(df)
    df = convert_data_types(df)
    return df
