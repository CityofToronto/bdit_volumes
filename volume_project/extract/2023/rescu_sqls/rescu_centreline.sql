-- Make a table that links RESCU detectors with the centreline from 2022-07-05
CREATE TABLE scannon.rescu_cent_20220705 AS (

-- get centreline segments
WITH cl_segs AS (
SELECT 
    cl.geo_id AS centreline_id,
    cl.lf_name AS cent_name,
    ST_SetSRID(cl.geom, 4326) AS cl_geom
FROM gis.centreline_20220705 AS cl
WHERE fcode_desc IN('Major Arterial', 'Expressway') -- these are the only types of roads we need
),

-- get RESCU detectors that pass the "good volume" tests
rescu_det AS (
SELECT DISTINCT 
    ev.detector_id, 
    ev.direction, 
    ev.gen_loc, 
    ST_SetSRID(ST_MAKEPOINT(ev.longitude, ev.latitude), 4326) AS rescu_geom
FROM scannon.rescu_enuf_vol_22 AS ev
),

-- spatially join buffered detectors and segments
buff_loc AS (
SELECT
    rd.*,
    cs.*
FROM rescu_det AS rd
LEFT JOIN cl_segs AS cs
    ON ST_INTERSECTS(cl_geom, ST_Buffer(rescu_geom, 0.001))
),

-- evaluate the join based on street names and directions
check_pls AS (
SELECT 
    *,
    CASE
        WHEN LEFT(UPPER(direction),1) = RIGHT(UPPER(cent_name),1) THEN 'good_dir'
        ELSE 'bad_dir'
    END AS check_dir,
    CASE
        WHEN cent_name LIKE 'Lake Shore Blvd%' THEN 'Lake Shore'
        WHEN cent_name LIKE '%Gardiner%' THEN 'Gardiner'
        WHEN cent_name LIKE 'Don Valley%' THEN 'DVP'
        WHEN cent_name LIKE 'Qew%' THEN 'QEW'
        ELSE 'bad_name'
    END AS check_name_cent,
    CASE
        WHEN LEFT(gen_loc, 3) = 'DON' THEN 'DVP'
        WHEN LEFT(gen_loc, 3) = 'QEW' THEN 'QEW'
        WHEN SUBSTRING(gen_loc, POSITION(' ' IN gen_loc) + 1, 4) = 'LAKE' THEN 'Lake Shore'
        WHEN SUBSTRING(gen_loc, POSITION(' ' IN gen_loc) + 1, 4) = 'GARD' THEN 'Gardiner'
        ELSE 'wut'
    END AS check_name_det
FROM buff_loc
),

-- select segments that pass the direction and name tests and that are the closest segments to the detectors
good_check AS (
    SELECT DISTINCT ON
        (detector_id)
        detector_id,
        gen_loc,
        rescu_geom,
        centreline_id,
        cent_name,
        cl_geom,
        ST_DISTANCE(rescu_geom, cl_geom) 
        AS dist
    FROM check_pls
    WHERE check_dir != 'bad_dir' AND check_name_cent = check_name_det
    ORDER BY detector_id, ST_DISTANCE(rescu_geom, cl_geom)
)

-- final selection!
SELECT
    rd.*,       
    gc.centreline_id,
    gc.cl_geom,
    gc.cent_name
FROM rescu_det AS rd
LEFT JOIN good_check AS gc USING (detector_id)
);

-- 19 records didn't match (mosty because of "Lake Shore Blvd E" or "Lake Shore Blvd W" issues :cry_cat: so I found them manually and updated them
UPDATE scannon.rescu_cent_20220705
SET centreline_id = 1145945
WHERE detector_id = 'DE0030DWL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 30021327
WHERE detector_id = 'DW0070DEL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 1147026
WHERE detector_id = 'DW0020DEL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 30016242
WHERE detector_id = 'DW0080DEL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 1146358
WHERE detector_id = 'DE0010DWL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 30021714
WHERE detector_id = 'DW0130DEL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 30134464
WHERE detector_id = 'DW0050DEL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 30087988
WHERE detector_id = 'DE0020DWL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 20043579
WHERE detector_id = 'DW0151DEG';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 30021784
WHERE detector_id = 'DE0050DWL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 913364
WHERE detector_id = 'DW0161DEG';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 30010427
WHERE detector_id = 'DW0126DWG';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 14189397
WHERE detector_id = 'DW0120DEL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 913354
WHERE detector_id = 'DW0161DWG';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 30007492
WHERE detector_id = 'DW0126DEG';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 1147201
WHERE detector_id = 'DW0040DEL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 30121301
WHERE detector_id = 'DW0110DEL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 30125351
WHERE detector_id = 'DW0060DEL';

UPDATE scannon.rescu_cent_20220705
SET centreline_id = 30036182
WHERE detector_id = 'DW0100DEL';
