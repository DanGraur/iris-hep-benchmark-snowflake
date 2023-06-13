# Initial Setup

## Creating a Snowflake account

If you do not have one, create a Snowflake trial account [here](https://signup.snowflake.com/).

## Initial Snowflake setup

You will need to use the Snowflake Web UI and input the commands:

```SQL
-- Create warehouses
CREATE WAREHOUSE XSMALL WITH WAREHOUSE_SIZE='XSMALL';
CREATE WAREHOUSE LARGE WITH WAREHOUSE_SIZE='LARGE';

-- Create a database where the different schemas can be stored
CREATE DATABASE ADL;
```

Then make sure to create two connections in your `~/.snowsql/config` of the type:

```
[connections.xsmall]

accountname = <your-account-id>.<your-snowflake-region>
username = <your-username>
password = <your-password>

dbname = ADL
schemaname = ADL_1000
warehousename = XSMALL

[connections.large]

accountname = <your-account-id>.<your-snowflake-region>
username = <your-username>
password = <your-password>

dbname = ADL
schemaname = ADL
warehousename = LARGE
```

Finally, if you intend to use our upload scripts, make sure to create an integration between S3 and Snowflake for uploading and storing the data internally in Snowflake. If you intend to upload your data manually, you can skip this stage. To create an integration, follow [this guide](https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration.html). When creating the Snowflake-side storage integration make sure you use the following SQL command:

```SQL
CREATE OR REPLACE STORAGE INTEGRATION s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = '<your-AWS-role-ARN>' -- or your equivalent AWS ROLE
  STORAGE_ALLOWED_LOCATIONS = ('s3://hep-adl-ethz/hep-parquet/native/');
```

## Upload your data

In order to create an internal table using our scripts:

1. Use the `upload.sh`, passing the right parameters in order to ensure the table gets uploaded to the right DB, schema, etc.
  * Use: `./upload.sh internal adl s3://hep-adl-ethz/hep-parquet/native/Run2012B_SingleMu-1000.parquet XSMALL adl_1000` to upload the 1000 row reference dataset. Note that this will by default stage the data into multiple columns (as opposed to a single column of [VARIANT](https://docs.snowflake.com/en/sql-reference/data-types-semistructured#variant) type). 

For larger data sizes you will have to set up your own data. Similarly, if you want to stage the parquet data manually, see [this guide](https://docs.snowflake.com/en/user-guide/script-data-load-transform-parquet) and the `Run2012B_SingleMu-1000.parquet` file located in this folder. For potential schemas see the `schema_multiple_columns.sql` and `schema_single_column.sql` located in this folder.

## Functions for ADL Queries

Our hand-written ADL queries require a set of SQL functions to be stored ahead of time the Snowflake such that they work correctly. To make this happen, first make sure to have `snowsql` installed [using this guide](https://docs.snowflake.com/en/user-guide/snowsql-install-config#installing-snowsql-on-linux-using-the-installer). Then, run the following commands:

```
snowsql -c xsmall -f ../implementations/common/functions.sql
snowsql -c large -f ../implementations/common/functions.sql
```  

Alternatively you can copy paste the code of the `functions.sql` script into a Snowflake worksheet and execute it there.