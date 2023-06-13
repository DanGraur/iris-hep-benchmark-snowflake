from abc import ABC, abstractmethod
import io
import json
import logging
from os.path import dirname, join
import subprocess
import sys
import time
import warnings

import pandas as pd
import pytest
import requests


class SnowflakeProxy(ABC):
  @abstractmethod
  def run(self, query_file):
    pass


class SnowflakeCliProxy(SnowflakeProxy):
  def __init__(self, connection_name, config_path):
    self.connection_name = connection_name
    self.config = config_path

  def run(self, query):
    command = [
      'snowsql', 
      '-o output_format=csv',
      '-o friendly=false',
      '-o timing=false',
      '-o header=false',
      f'--config {self.config}',
      f'-c {self.connection_name}',
      f'-q "{query}"',
    ]

    return subprocess.run(' '.join(command), check=True, shell=True, 
      stdout=subprocess.PIPE).stdout


@pytest.fixture
def snowflake(pytestconfig):
  connection_name = pytestconfig.getoption('connection')
  config_path = pytestconfig.getoption('config')
  return SnowflakeCliProxy(connection_name, config_path)


def test_query(query_id, pytestconfig, snowflake):
  root_dir = join(dirname(__file__))
  query_dir = join(root_dir, 'implementations', query_id)
  ref_file = join(query_dir, 'ref-1000.csv')
  query_file = join(query_dir, 'query.sql')

  # Get the input table name
  input_table = pytestconfig.getoption('input_table')

  with open(query_file, 'r') as f:
      query = f.read()
  query = query.format(
      input_table=input_table,
  )

  # Run query and read result
  start_timestamp = time.time()
  df = snowflake.run(query)
  end_timestamp = time.time()

  running_time = end_timestamp - start_timestamp
  logging.info('Running time: {:.2f}s'.format(running_time))

  df_ref = pd.read_csv(ref_file, sep=',')

  # Normalize result
  df = pd.read_csv(io.StringIO(df.decode('utf-8')), sep=',', names=['x', 'y'], 
    dtype={'x': 'float64', 'y': 'int64'})
  df = df[df.y > 0]
  df = df[['x', 'y']]
  df.x = df.x.astype(float).round(6)
  df.reset_index(drop=True, inplace=True)

  # Read and normalize references result
  df_ref = pd.read_csv(ref_file, sep=',')

  df_ref = df_ref[df_ref.y > 0]
  df_ref = df_ref[['x', 'y']]
  df_ref.x = df_ref.x.astype(float).round(6)
  df_ref.reset_index(drop=True, inplace=True)

  # Assert correct result
  pd.testing.assert_frame_equal(df_ref, df)


if __name__ == '__main__':
  pytest.main(sys.argv)
