# High-energy Physics Analysis Queries in Snowflake

This repository contains implementations of High-energy Physics (HEP) analysis queries from [the IRIS HEP benchmark](https://github.com/iris-hep/adl-benchmarks-index) written in [SQL](https://en.wikipedia.org/wiki/SQL) to be run in [Snowflake](https://www.snowflake.com/en/).

## Motivation

The purpose of this repository is to study the suitability of SQL for HEP analyses and to serve as a use case for improving database technologies. While SQL has often been considered unsuited for HEP analyses, we believe that the support for arrays and structured types introduced in SQL:1999 make SQL actually a rather good fit. As a high-level declarative language, it has the potential to bring many of its benefits to HEP including transparent query optimization, transparent caching, and a separation of the logical level (in the form of data model and query) from the physical level (in the form of storage formats and performance optimizations).

## Prerequisites

Make sure you have [`python3`](https://www.python.org/downloads/) and [`snowsql`](https://docs.snowflake.com/en/user-guide/snowsql-install-config) and [`awscli`](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed on your machine. Once you have set these up, please follow [`initial_setup/README.md`](initial_setup/README.md). During the setup, you may have to install some `python` packages.  

## Running Queries

Queries are run through [`test_queries.py`](/test_queries.py). Run the following command to see its options:

```
$ python test_queries.py --help
usage: test_queries.py [options] [file_or_dir] [file_or_dir] [...]

...
custom options:
  -Q QUERY_ID, --query-id=QUERY_ID
                        Of the form "qX", where X is the id of the query.
  -I INPUT_TABLE, --input-table=INPUT_TABLE
                        The input table name.
  -C CONFIG, --config=CONFIG
                        Path to the config file for establishing a connection. This should be similar to the ~/.snowsql/config file.
  -N CONNECTION, --connection=CONNECTION
                        The connection name to be used for the query. Should be located in the config file.
  -T QUERY_VERSION, --query-version=QUERY_VERSION
                        Either "multi_column" or "single_column". Refers to the source data version.
```

For example, the following command runs query `q5` on the `xsmall` connection, the `adl` table (where the `adl` table has 1000 rows in the `xsmall` connection) with `multi_column` setup, using the default `snowsql` config file:

```
python test_queries.py \
            --query-id q5 \
            --connection xsmall \
            --input-table adl \
            --config ~/.snowsql/config \
            --query-version multi_column
```