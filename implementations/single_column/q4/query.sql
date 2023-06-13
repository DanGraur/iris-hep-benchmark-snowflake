SELECT
  HistogramBin(pt, 0, 2000, 100) AS x,
  COUNT(*) AS y
FROM (
  SELECT ANY_VALUE(data:MET:pt) as pt
  FROM
    {input_table}
    , lateral flatten(input => data:Jet::array) AS t
  WHERE t.value:pt > 40
  GROUP BY data:event
  HAVING COUNT(*) > 1
)
GROUP BY x
ORDER BY x;