from pyspark import pipelines as dp
from pyspark.sql.functions import col

def read_silver():
    return spark.readStream.table(
        "ecommerce_sdp.default.silver_orders_cleaned"

    )

def get_delivered_orders(df):
    return df.filter(col("order_status") == "Delivered")

@dp.table(
    name="gold_delivered_orders",
    comment="Delivered e-commerce orders prepared for Gold analytics"
)
def gold_delivered_orders():
    silver_df = read_silver()
    delivered_df = get_delivered_orders(silver_df)
    return delivered_df