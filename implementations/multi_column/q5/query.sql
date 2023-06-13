SELECT
  HistogramBin(pt, 0, 2000, 100) AS x,
  COUNT(*) AS y
FROM (
  SELECT ANY_VALUE(MET:pt) AS pt
  FROM 
    {input_table}
    , lateral flatten(input => Muon::array) AS m1
    , lateral flatten(input => Muon::array) AS m2
  WHERE 
    m1.index < m2.index 
    AND m1.value:charge != m2.value:charge
    AND SQRT(2 * m1.value:pt * m2.value:pt 
      * (COSH(m1.value:eta - m2.value:eta) 
        - COS(m1.value:phi - m2.value:phi))) BETWEEN 60 AND 120
  GROUP BY EVENT
)
GROUP BY x
ORDER BY x;