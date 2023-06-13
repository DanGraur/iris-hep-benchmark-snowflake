-- This SQL script is used to upload the ADL data to into Snowflake
-- Somewhat based on: https://docs.snowflake.com/en/user-guide/script-data-load-transform-parquet.html
-- Note that you need a integration called `s3_integration` if you intend to upload data from cloud storage
  -- For s3 follow this guide: https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration.html
-- run this within `snowsql` using: `!source /path/to/upload.sql`
-- run this using `snowsql` using: `$ snowsql -c <connection_name> -f /path/to/upload.sql`
SET warehouse_name = 'TEST_WAREHOUSE';
SET database_name = 'TEST';
SET schema_name = 'ADL';
SET table_name = 'adl';

SET data_path = <PATH>;

CREATE DATABASE IF NOT EXISTS identifier($database_name);
USE DATABASE identifier($database_name);

CREATE SCHEMA IF NOT EXISTS identifier($schema_name);
USE SCHEMA identifier($schema_name);

USE WAREHOUSE identifier($warehouse_name);

-- We add the parquet data to Snowflake
-- Step 1) Create temporary external stage
CREATE OR REPLACE TEMPORARY STAGE hep_data
storage_integration = s3_integration 
URL = <PATH>
FILE_FORMAT = (TYPE = 'PARQUET');


-- Step 2) Create a table and populate it with the staged data