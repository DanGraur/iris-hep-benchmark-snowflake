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

## Reference Results

You will notice the existence of files titled `ref-1000.csv` in each query file. These are the reference outputs for the queries when running on the 1000 event subsample.

## Data sample

A json file containing 1000 data samples is available in `Run2012B_SingleMu_restructured_1000.json`. Each row / object is an event / 'row' in the dataset. Below we provide a single formatted example of an object (note that this is a big object, please scroll down to the end of the document for details on query modifications).

```json
{
  "run": 194711,
  "luminosityBlock": 299,
  "event": 263142897,
  "MET": {
    "pt": 22.1770324707,
    "phi": 0.533716619,
    "sumet": 556.7757568359,
    "significance": 2.3655102253,
    "CovXX": 160.5729064941,
    "CovXY": 61.2005462646,
    "CovYY": 191.6288909912
  },
  "HLT": {
    "IsoMu24_eta2p1": false,
    "IsoMu24": false,
    "IsoMu17_eta2p1_LooseIsoPFTau20": false
  },
  "PV": {
    "npvs": 9,
    "x": 0.0726952404,
    "y": 0.0632376149,
    "z": -3.1561815739
  },
  "Muon": [
    {
      "pt": 12.7770967484,
      "eta": -0.6230234504,
      "phi": 0.6473218203,
      "mass": 0.1056583673,
      "charge": -1,
      "pfRelIso03_all": 1.4582817554,
      "pfRelIso04_all": 1.5519471169,
      "tightId": true,
      "softId": true,
      "dxy": 0.0139893312,
      "dxyErr": 0.0017925985,
      "dz": 0.0318274945,
      "dzErr": 0.0024212187,
      "jetIdx": -1,
      "genPartIdx": -1
    }
  ],
  "Electron": [],
  "Photon": [
    {
      "pt": 48.1147994995,
      "eta": -1.5827258825,
      "phi": -2.2322263718,
      "mass": 0.000002336,
      "charge": 0,
      "pfRelIso03_all": 0.052749984,
      "jetIdx": -1,
      "genPartIdx": -1
    }
  ],
  "Jet": [
    {
      "pt": 71.742477417,
      "eta": -1.6034725904,
      "phi": -2.2516970634,
      "mass": 12.7169504166,
      "puId": true,
      "btag": 0.0153531581
    },
    {
      "pt": 27.8205337524,
      "eta": -0.7512971759,
      "phi": 0.5696190596,
      "mass": 7.453250885,
      "puId": true,
      "btag": 0.440434128
    }
  ],
  "Tau": [
    {
      "pt": 36.9196853638,
      "eta": -1.5682779551,
      "phi": -2.234171629,
      "mass": 1.1496301889,
      "charge": 1,
      "decayMode": 1,
      "relIso_all": 1.0643558502,
      "jetIdx": -1,
      "genPartIdx": -1,
      "idDecayMode": true,
      "idIsoRaw": 33.0146713257,
      "idIsoVLoose": false,
      "idIsoLoose": false,
      "idIsoMedium": false,
      "idIsoTight": false,
      "idAntiEleLoose": true,
      "idAntiEleMedium": false,
      "idAntiEleTight": false,
      "idAntiMuLoose": true,
      "idAntiMuMedium": true,
      "idAntiMuTight": true
    }
  ]
}

``` 


## Changes to the de-facto ADL Queries 

Below you will find a list of changes:

* Q1: No significant differences.
* Q2: No significant differences.
* Q3: No significant differences.
* Q4: Unrolled the `$event.Jet[]` into its own separate `for` loop, then moved the syntactic sugar expression `[$$.pt > 40]` to its own dedicated `where` clause. This helps eliminate some tuples more eagerly.
* Q5: Removed the additional level of nesting cause by the `exists` function. This makes the query more similar to the reference SQL implementation. Also moved two predicates (originally applied through two `where` clauses) into one.
* Q6: No significant changes, although the query might seem more verbose due to function inlining (see explanation below).
* Q7: The original query generates the full set of leptons (i.e. concatenation of electrons with muons), before generating all possible pairs with jets. After all pairs are created, each undergoes filtering. This formulation is inefficient, as it causes a combinatorial explosion due to unnesting and renesting. We formulate this more efficiently, by first pairing half of the leptons (i.e. the muons) with all the jets, filtering the unused pairs, then repeating the process with the other half of the leptons (.i.e. the electrons). This helps, as after each `exists` function call, there are less tuples to process. This formulation is more similar to the SQL version.
* Q8: No significant changes, although the query might seem more verbose due to function inlining (see explanation below).  

Besides these changes, if you compare the queries in this repository with the standard versions, you will notice that these versions are more verbose. This is because we do not yet support value-functions (i.e. functions that return a single scalar value per tuple e.g. `hep:compute-invariant-mass`); we only support functions which return entire Snowflake tables (e.g `hep:histogram`). As a consequence, we inline the function code into the main query body which makes the queries seem verbose. Implementing support for value-function refers purely to engineering effort and would not have any additional research contribution, which is why we have postponed introducing support for such functions. We are planning to add support for value-functions soon as well.  


## Experiment scripts

See the `experiment-scripts` folder for more details. 