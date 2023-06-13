WITH Leptons AS (
  SELECT EVENT, ANY_VALUE(Met) AS Met, ARRAY_AGG(Lepton) AS Lepton 
  FROM (
    SELECT
      EVENT,
      Met,
      OBJECT_CONSTRUCT(
        'pt', e.value:pt, 
        'eta', e.value:eta, 
        'phi', e.value:phi, 
        'mass', e.value:mass, 
        'charge', e.value:charge, 
        'type', 'e'
      ) as Lepton
    FROM  
      {input_table}
      , lateral flatten(INPUT => Electron) AS e
    UNION ALL
    SELECT
      EVENT,
      Met,
      OBJECT_CONSTRUCT(
        'pt', m.value:pt, 
        'eta', m.value:eta, 
        'phi', m.value:phi, 
        'mass', m.value:mass, 
        'charge', m.value:charge, 
        'type', 'm'
      ) as Lepton
    FROM  
      {input_table}
      , lateral flatten(INPUT => Muon) AS m
  )
  GROUP BY 
    EVENT
),
TriLeptons AS (
  SELECT 
    EVENT,
    Met,
    l1.index AS l1_idx,
    l2.index AS l2_idx,
    l1.value AS l1,
    l2.value AS l2,
    l3.value AS l3
  FROM
    Leptons
    , lateral flatten(INPUT => Lepton) AS l1
    , lateral flatten(INPUT => Lepton) AS l2
    , lateral flatten(INPUT => Lepton) AS l3
  WHERE
    l1.index < l2.index 
    AND l1.index != l3.index
    AND l2.index != l3.index
    AND l1.value:charge = -l2.value:charge
    AND l1.value:type   =  l2.value:type
),
TriLeptonsGrouped AS (
  SELECT 
    EVENT,
    l1_idx,
    l2_idx,
    ANY_VALUE(Met) AS Met,
    ANY_VALUE(l1) AS l1,
    ANY_VALUE(l2) AS l2,
    GET(ARRAY_AGG(l3) WITHIN GROUP (ORDER BY l3:pt DESC), 0) l3,
    ANY_VALUE(AddPtEtaPhiM2(l1, l2)) AS Dilepton
  FROM
    TriLeptons
  GROUP BY  
    EVENT,
    l1_idx,
    l2_idx   
),
MainTriLeptons AS (
  SELECT
    EVENT,
    ANY_VALUE(Met) AS Met,
    GET(ARRAY_AGG(l3) WITHIN GROUP (ORDER BY ABS(Dilepton:mass - 91.2) ASC), 0) AS l3
  FROM 
    TriLeptonsGrouped
  GROUP BY 
    EVENT
),
WithMass AS (
  SELECT
    EVENT,
    SQRT(2 * Met:pt * l3:pt * (1.0 - COS(DeltaPhi(Met, l3)))) AS transverseMass
  FROM 
    MainTriLeptons
)
SELECT 
  HistogramBin(transverseMass, 15, 250, 100) AS x,
  COUNT(*) AS y 
FROM
  WithMass
GROUP BY x
ORDER BY x;
