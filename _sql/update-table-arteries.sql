UPDATE aharpal.arteries
SET loc = ST_MakeLine(ST_SetSRID(ST_Point(fx, fy),2019)::geometry, ST_SetSRID(ST_Point(tx, ty),2019)::geometry)
WHERE fx IS NOT NULL AND tx IS NOT NULL;

UPDATE aharpal.arteries
SET loc = ST_SetSRID(ST_Point(fx, fy),2019)::geometry
WHERE fx IS NOT NULL AND tx IS NULL;

UPDATE aharpal.arteries
SET loc = ST_SetSRID(ST_Point(tx, ty),2019)::geometry
WHERE fx IS NULL AND tx IS NOT NULL;