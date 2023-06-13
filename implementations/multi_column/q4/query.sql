SELECT
  HistogramBin(pt, 0, 2000, 100) AS x,
  COUNT(*) AS y
FROM (
  SELECT ANY_VALUE(MET:pt) as pt
  FROM
    {input_table}
    , lateral flatten(input => Jet::array) AS t
  WHERE t.value:pt > 40
  GROUP BY EVENT
  HAVING COUNT(*) > 1
)
GROUP BY x
ORDER BY x;