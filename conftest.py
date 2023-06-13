import glob
from os.path import dirname, join

def pytest_addoption(parser):
  parser.addoption('-Q', '--query-id', action='append', default=[],
                   help='Of the form "qX", where X is the id of the query.')
  parser.addoption('-I', '--input-table', action='store', default="adl",
                   help='The input table name.')    
  parser.addoption('-C', '--config', action='store', 
                   default="~/.snowsql/config", help='Path to the config file '
                   'for establishing a connection. This should be similar to '
                   'the ~/.snowsql/config file.')    
  parser.addoption('-N', '--connection', action='store', default="xsmall",
                   help='The connection name to be used for the query. Should '
                   'be located in the config file.') 
  parser.addoption('-T', '--query-version', action='store', 
                   default="multi_column", help='Either "multi_column" or '
                   '"single_column". Refers to the source data version.') 


def find_queries(single_column_version=False):
  basedir = join(dirname(__file__), 'implementations')
  version = "single_column" if single_column_version else "multi_column"
  queryfiles = glob.glob(join(basedir, '**', version, '**/query.sql'), 
      recursive=True)
  return sorted([s[len(basedir)+1:-len('/query.sql')] for s in queryfiles])


def pytest_generate_tests(metafunc):
  if 'query_id' in metafunc.fixturenames:
    connection = metafunc.config.getoption('connection')
    query_version = metafunc.config.getoption('query_version')
    single_column_version = query_version != "multi_column"
    queries = metafunc.config.getoption('query_id')
    if queries:
      version = "single_column" if single_column_version else "multi_column"
      queries = [join(version, x) for x in queries]
    else:
      queries = find_queries(single_column_version)
    metafunc.parametrize('query_id', queries)
