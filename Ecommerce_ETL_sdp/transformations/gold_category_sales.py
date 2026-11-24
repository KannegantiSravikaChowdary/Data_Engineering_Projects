from pyspark import pipelines as dp
# from databricks import pipelines as dp
from pyspark.sql.functions import col, sum, count, avg, round, dense_rank
from pyspark.sql.window import Window

@dp.materialized_view(
    name="gold_category_sales",
    comment="Category-wise delivered sales and product performance"
)
def gold_category_sales():
    delivered_df = spark.read.table("gold_delivered_orders")

    category_sales_df = (
        delivered_df
        .groupBy("category")
        .agg(
            count("*").alias("total_delivered_orders"),
            sum("quantity").alias("total_units_sold"),
            sum("order_id").alias("total_revenue"),
            round(avg("order_id"), 2).alias("average_order_value")
        )
    )

    ranking_window = Window.orderBy(col("total_revenue").desc())

    return category_sales_df.select(
        "*",
        dense_rank().over(ranking_window).alias("revenue_rank")
    )