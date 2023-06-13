WITH temp AS (
  SELECT
    EVENT,
    j.index AS idx,
    ANY_VALUE(j.value:pt) AS pt,
    BOOLAND_AGG((m.value is NULL OR NOT (m.value:pt > 10 AND DeltaR(j.value, m.value) < 0.4))) AS m_pred,
    BOOLAND_AGG((e.value is NULL OR NOT (e.value:pt > 10 AND DeltaR(j.value, e.value) < 0.4))) AS e_pred
  FROM 
    {input_table}
    , lateral flatten(input => Jet) AS j
    , lateral flatten(input => Muon, OUTER => true) AS m 
    , lateral flatten(input => Electron, OUTER => true) AS e
  WHERE
    ARRAY_SIZE(Jet) > 0
    AND j.value:pt > 30
  GROUP BY 
    EVENT,
    idx 
)
SELECT
  HistogramBin(pt, 15, 200, 100) AS x,
  COUNT(*) AS y
FROM (
  SELECT 
    EVENT, 
    SUM(pt) AS pt
  FROM 
    temp
  WHERE 
    m_pred = TRUE
    AND e_pred = TRUE
  GROUP BY 
    EVENT
)
GROUP BY x
ORDER BY x;