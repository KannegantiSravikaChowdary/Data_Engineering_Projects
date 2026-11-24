from pyspark import pipelines as dp
from pyspark.sql.functions import current_timestamp, col

SOURCE_PATH = "/Volumes/ecommerce_sdp/ecommerce_data/landing"

@dp.table(
    name="bronze_orders_sdp",
    comment="Raw e-commerce order data ingested using Auto Loader"
)
def bronze_orders_sdp():

    raw_df = (
        spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "csv")
        .option("header", "true")
        .option("cloudFiles.inferColumnTypes", "false")
        .load(SOURCE_PATH)
    )

    bronze_df = (
        raw_df
        .withColumn("ingestion_timestamp", current_timestamp())
        .withColumn("source_file_name", col("_metadata.file_path"))
    )

    return bronze_df

