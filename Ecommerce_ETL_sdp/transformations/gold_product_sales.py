from pyspark import pipelines as dp
from pyspark.sql.functions import col, sum, count, dense_rank, round
from pyspark.sql.window import Window

@dp.materialized_view(
    name="gold_product_sales",
    comment="Product-wise delivered sales and product performance"
)
def gold_product_sales():
    delivered_df = spark.read.table("gold_delivered_orders")

    product_sales_df = (
        delivered_df
        .groupBy("product_name")
        .agg(
            count("*").alias("total_order_records"),
            sum("quantity").alias("total_units_sold"),
            # sum("amount").alias("total_revenue"),
            # round(
            #     sum("amount") / sum("quantity"), 2
            # ).alias("average_selling_price")
        )
    )

    ranking_window = Window.orderBy(col("total_order_records").desc())

    return product_sales_df.select(
        "*",
        dense_rank().over(ranking_window).alias("revenue_rank")
    )