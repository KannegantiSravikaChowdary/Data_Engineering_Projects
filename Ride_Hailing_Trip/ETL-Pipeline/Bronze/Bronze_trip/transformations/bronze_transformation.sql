CREATE OR REFRESH STREAMING TABLE bronze_ride_trips
COMMENT 'Raw ride-hailing trip CSVs ingested from the landing volume'
AS SELECT
  *,
  _metadata.file_name AS source_file,
  current_timestamp() AS loaded_at
FROM STREAM read_files(
  '/Volumes/ride_hailing_trip_sdp/default/ride_trips/',
  format => 'csv',
  header => true
);
