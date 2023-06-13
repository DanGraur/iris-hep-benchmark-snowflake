SELECT
  HistogramBin(t.value:pt, 15, 60, 100) AS x,
  COUNT(*) AS y
FROM 
  {input_table}
  , lateral flatten(input => Jet::array) AS t
WHERE ABS(t.value:eta) < 1
GROUP BY x
ORDER BY x;