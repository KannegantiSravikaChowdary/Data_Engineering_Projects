-- Bronze Layer :- Raw data Ingestion
Create or refresh streaming table cs_bronze_sales
(
    constraint data_loaded expect (orderid is not null)
)
comment 'Bronze layer: Retail sales Data Ingestion'
AS 
select *,
    _metadata.file_path as souce_file,
    current_timestamp() as ingested_at
From stream read_files("/Volumes/retail_sales_sdp/default/sales_volume",
format => 'CSV',
header =>'true'
);