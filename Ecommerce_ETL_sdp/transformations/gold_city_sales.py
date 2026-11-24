# from pyspark import pipelines as dp
from pyspark import pipelines as dp
from pyspark.sql.functions import col, sum, count, avg, round, dense_rank
from pyspark.sql.window import Window

@dp.materialized_view(
    name="gold_city_sales",
    comment="City-wise delivered orders and sales performance"
)
def gold_city_sales():
    delivered_df = spark.read.table("gold_delivered_orders")

    city_sales_df = (
        delivered_df
        .groupBy("city")
        .agg(
            count("*").alias("total_delivered_orders"),
            round(avg("unit_price"), 2).alias("average_order_value"),
            sum("unit_price").alias("total_revenue")
        )
    )

    ranking_window = Window.orderBy(col("total_revenue").desc())

    return city_sales_df.select(
        "*",
        dense_rank().over(ranking_window).alias("revenue_rank")
    )