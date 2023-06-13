WITH temp AS (
  SELECT
    data:event AS EVENT,
    j.index AS idx,
    ANY_VALUE(j.value:pt) AS pt,
    BOOLAND_AGG((m.value is NULL OR NOT (m.value:pt > 10 AND DeltaR(j.value, m.value) < 0.4))) AS m_pred,
    BOOLAND_AGG((e.value is NULL OR NOT (e.value:pt > 10 AND DeltaR(j.value, e.value) < 0.4))) AS e_pred
  FROM 
    {input_table}
    , lateral flatten(input => data:Jet) AS j
    , lateral flatten(input => data:Muon, OUTER => true) AS m 
    , lateral flatten(input => data:Electron, OUTER => true) AS e
  WHERE
    ARRAY_SIZE(data:Jet) > 0
    AND j.value:pt > 30
  GROUP BY 
    data:event,
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