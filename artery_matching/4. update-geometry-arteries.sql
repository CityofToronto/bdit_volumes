UPDATE prj_volume.arteries
SET loc = ST_MakeLine(ST_SetSRID(ST_Point(fx, fy),82181)::geometry, ST_SetSRID(ST_Point(tx, ty),82181)::geometry)
WHERE fx IS NOT NULL AND tx IS NOT NULL AND source NOT LIKE 'geo';

UPDATE prj_volume.arteries
SET loc = ST_SetSRID(ST_Point(fx, fy),82181)::geometry
WHERE fx IS NOT NULL AND tx IS NULL AND source NOT LIKE 'geo';

UPDATE prj_volume.arteries
SET loc = ST_SetSRID(ST_Point(tx, ty),82181)::geometry
WHERE fx IS NULL AND tx IS NOT NULL AND source NOT LIKE 'geo';

UPDATE prj_volume.arteries
SET loc = (CASE WHEN ST_SRID(loc) = 82181 THEN ST_SetSRID(ST_Point(fx, fy), 82181)::geometry
		ELSE ST_SetSRID(ST_Point(fx, fy), 4326)::geometry
		END)
WHERE source LIKE 'geo';

UPDATE prj_volume.arteries
SET loc = ST_Transform(loc, 82181)
WHERE source LIKE 'geo' and NOT ST_SRID(loc) = 82181;

UPDATE prj_volume.arteries
SET fx = ST_X(loc), fy = ST_Y(loc)
WHERE source LIKE 'geo'