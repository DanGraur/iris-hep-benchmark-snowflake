CREATE OR REPLACE TABLE identifier($table_name) (
  run NUMBER(38, 0),
  luminosityBlock NUMBER(38, 0),
  event NUMBER(38, 0),
  HLT  VARIANT,
  PV  VARIANT,
  MET VARIANT,
  Muon VARIANT,
  Electron VARIANT,
  Tau VARIANT,
  Photon VARIANT,
  Jet VARIANT
) AS
  SELECT 
  $1:run::NUMBER(38, 0),
  $1:luminosityBlock::NUMBER(38, 0),
  $1:event::NUMBER(38, 0),
  $1:HLT::VARIANT,
  $1:PV::VARIANT,
  $1:MET::VARIANT,
  $1:Muon::VARIANT,
  $1:Electron::VARIANT,
  $1:Tau::VARIANT,
  $1:Photon::VARIANT,
  $1:Jet::VARIANT
  FROM @hep_data (PATTERN => '.*parquet');