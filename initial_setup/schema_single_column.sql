CREATE OR REPLACE TABLE identifier($table_name) (
  data VARIANT
) AS
  SELECT 
  $1::VARIANT
  FROM @hep_data (PATTERN => '.*parquet');