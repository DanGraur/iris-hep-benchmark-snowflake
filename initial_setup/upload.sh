#!/usr/bin/env bash

type=${1:-'internal'}  # Can be 'internal' or 'external' 
table_name=${2:-'adl'}
data_path=${3:-'s3://hep-adl-ethz/hep-parquet/native/Run2012B_SingleMu-1000.parquet'}
warehouse_name=${4:-'XSMALL'}
schema_name=${5:-'adl_1000'}  # 'adl'
database_name=${6:-'adl'}
upload_type=${6:-'multiple'}  # Can be 'single' or 'multiple'; this refers to the number of columns of the uploaded table

if [ "${type}" == "external" ]; then
  target="upload_external.sql"
elif [ "${type}" == "internal" ]; then 
  cat "upload.sql" > "upload_temp_a.sql"
  if [ "${upload_type}" == "single" ]; then
    schema_script="schema_single_column.sql"
  elif [ "${upload_type}" == "multiple" ]; then
    schema_script="schema_multiple_columns.sql"
  else
    echo "Supplied parameter 'upload_type=${upload_type}' is not supported!"
    exit 1
  fi
  echo "" >> "upload_temp_a.sql" && cat ${schema_script} >> "upload_temp_a.sql"
  target="upload_temp_a.sql"
else
  echo "The other option can only be 'internal' data upload!"
  exit 1
fi

sed "s/'TEST_WAREHOUSE'/'$warehouse_name'/" ${target} \
| sed "s/'TEST'/'$database_name'/" \
| sed "s/'ADL'/'$schema_name'/" \
| sed "s/'adl'/'$table_name'/" \
| sed "s,<PATH>,'$data_path',g" \
> upload_temp.sql

snowsql -c xsmall -o log_level=DEBUG -f upload_temp.sql

rm -f upload_temp_a.sql 