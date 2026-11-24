from pyspark import pipelines as dp
from pyspark.sql.functions import col, trim, regexp_replace, initcap, upper

def read_bronze():
    return spark.readStream.table(
        "ecommerce_sdp.default.bronze_orders_sdp" 
    )

def clean_string_columns(df):
    string_columns = [
        "order_id", "customer_id", "customer_name", "city",
        "product_name", "category", "payment_mode", "order_status"
    ]

    for column_name in string_columns:
        df = df.withColumn(
            column_name,
            regexp_replace(trim(col(column_name)), r"\\s+", " ")
        )
    return df

def standardize_columns(df):
    return (
        df
        .withColumn("customer_name", initcap(col("customer_name")))
        .withColumn("city", initcap(col("city")))
        .withColumn("product_name", initcap(col("product_name")))
        .withColumn("category", initcap(col("category")))
        .withColumn("payment_mode", upper(col("payment_mode")))
        .withColumn("order_status", initcap(col("order_status")))
    )

@dp.table(
    name="silver_orders_cleaned",
    comment="Cleaned and standardized e-commerce order records"
)
def silver_orders_cleaned():
    df = read_bronze()
    df = clean_string_columns(df)
    df = standardize_columns(df)
    return df
