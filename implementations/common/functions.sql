CREATE OR REPLACE FUNCTION FMod(x float, y float) 
RETURNS float AS
$$
  x - FLOOR(x / y, 0) * y
$$;

CREATE OR REPLACE FUNCTION FMod2Pi(x float) 
RETURNS float AS 
$$
  FMod(x, 2 * PI())
$$;

CREATE OR REPLACE FUNCTION DeltaPhi(p1 VARIANT, p2 VARIANT) 
RETURNS float 
RETURNS NULL ON NULL INPUT AS
$$
  CASE
  WHEN FMod2Pi(p1:phi - p2:phi) < -PI() THEN FMod2Pi(p1:phi - p2:phi) + 2 * PI()
  WHEN FMod2Pi(p1:phi - p2:phi) >  PI() THEN FMod2Pi(p1:phi - p2:phi) - 2 * PI()
  ELSE FMod2Pi(p1:phi - p2:phi)
  END
$$;

CREATE OR REPLACE FUNCTION DeltaR(p1 VARIANT, p2 VARIANT)
RETURNS float 
RETURNS NULL ON NULL INPUT AS
$$
  SQRT(SQUARE(p1:eta - p2:eta) + SQUARE(DeltaPhi(p1, p2)))
$$;

CREATE OR REPLACE FUNCTION RhoZ2Eta(rho float, z float) 
RETURNS float 
RETURNS NULL ON NULL INPUT AS
$$
  LN(z / rho + SQRT(z / rho * z / rho + 1.0))
$$;

CREATE OR REPLACE FUNCTION PtEtaPhiM2PxPyPzE(pepm VARIANT) 
RETURNS OBJECT 
RETURNS NULL ON NULL INPUT AS
$$
  OBJECT_CONSTRUCT(
    'x', pepm:pt * COS(pepm:phi),
    'y', pepm:pt * SIN(pepm:phi),
    'z', pepm:pt * SINH(pepm:eta),
    'e', SQRT((pepm:pt * COSH(pepm:eta)) * (pepm:pt * COSH(pepm:eta)) + pepm:mass * pepm:mass)
  )
$$;

CREATE OR REPLACE FUNCTION PxPyPzE2PtEtaPhiM(xyzt VARIANT) 
RETURNS OBJECT 
RETURNS NULL ON NULL INPUT AS
$$
  OBJECT_CONSTRUCT(
    'pt', SQRT(xyzt:x * xyzt:x + xyzt:y * xyzt:y),
    'eta', RhoZ2Eta(sqrt(xyzt:x * xyzt:x + xyzt:y * xyzt:y), xyzt:z),
    'phi', IFF(xyzt:x = 0.0 AND xyzt:y = 0.0, 0, ATAN2(xyzt:y, xyzt:x)),
    'mass', SQRT(xyzt:e * xyzt:e - xyzt:x * xyzt:x - xyzt:y * xyzt:y - xyzt:z * xyzt:z)
  )
$$;

CREATE OR REPLACE FUNCTION AddPxPyPzE2(xyzt1 VARIANT, xyzt2 VARIANT)
RETURNS OBJECT 
RETURNS NULL ON NULL INPUT AS
$$
  OBJECT_CONSTRUCT(
    'x', xyzt1:x + xyzt2:x,
    'y', xyzt1:y + xyzt2:y,
    'z', xyzt1:z + xyzt2:z,
    'e', xyzt1:e + xyzt2:e
  )
$$;

CREATE OR REPLACE FUNCTION AddPxPyPzE3(
  xyzt1 VARIANT, 
  xyzt2 VARIANT, 
  xyzt3 VARIANT)
RETURNS OBJECT
RETURNS NULL ON NULL INPUT AS
$$
  OBJECT_CONSTRUCT(
    'x', xyzt1:x + xyzt2:x + xyzt3:x,
    'y', xyzt1:y + xyzt2:y + xyzt3:y,
    'z', xyzt1:z + xyzt2:z + xyzt3:z,
    'e', xyzt1:e + xyzt2:e + xyzt3:e
  )
$$;

CREATE OR REPLACE FUNCTION AddPtEtaPhiM2(pepm1 VARIANT, pepm2 VARIANT)
RETURNS OBJECT 
RETURNS NULL ON NULL INPUT AS
$$
  PxPyPzE2PtEtaPhiM(
     AddPxPyPzE2(
       PtEtaPhiM2PxPyPzE(pepm1),
       PtEtaPhiM2PxPyPzE(pepm2)))
$$;

CREATE OR REPLACE FUNCTION AddPtEtaPhiM3(
  pepm1 VARIANT,
  pepm2 VARIANT,
  pepm3 VARIANT) 
RETURNS OBJECT 
RETURNS NULL ON NULL INPUT AS
$$
  PxPyPzE2PtEtaPhiM(
     AddPxPyPzE3(
       PtEtaPhiM2PxPyPzE(pepm1),
       PtEtaPhiM2PxPyPzE(pepm2),
       PtEtaPhiM2PxPyPzE(pepm3)))
$$;

CREATE OR REPLACE FUNCTION HistogramBinHelper(
    value float, lo float, hi float, bin_width float)
RETURNS float 
RETURNS NULL ON NULL INPUT AS 
$$
  FLOOR((
    CASE
      WHEN value < lo THEN lo - bin_width / 4
      WHEN value > hi THEN hi + bin_width / 4
      ELSE value
    END - FMod(lo, bin_width)) / bin_width) * bin_width
      + bin_width / 2 + FMod(lo, bin_width)
$$;

CREATE OR REPLACE FUNCTION HistogramBin(
    value float, lo float, hi float, num_bins float) 
RETURNS float
RETURNS NULL ON NULL INPUT AS 
$$
  HistogramBinHelper(value, lo, hi, (hi - lo) / num_bins)
$$;
