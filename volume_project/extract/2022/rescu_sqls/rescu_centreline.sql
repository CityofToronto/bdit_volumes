-- WIP
with cl_segs AS (
SELECT 
    cl.geo_id AS centreline_id,
    cl.lf_name AS cent_name,
    ST_SetSRID(cl.geom, 4326) AS cl_geom
FROM gis.centreline_20220705 AS cl
WHERE fcode_desc IN('Major Arterial', 'Expressway')
),

rescu_det AS (
SELECT DISTINCT 
    ev.detector_id, 
    ev.direction, 
    ev.gen_loc, 
    ST_SetSRID(ST_MAKEPOINT(ev.longitude, ev.latitude), 4326) AS rescu_geom
FROM scannon.rescu_enuf_vol_22 AS ev
),

buff_loc AS (
SELECT
    rd.*,
    cs.*
FROM rescu_det AS rd
LEFT JOIN cl_segs AS cs
    ON ST_INTERSECTS(cl_geom, ST_Buffer(rescu_geom, 0.001))
),

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
        ELSE 'bad_name'
    END AS check_name
FROM buff_loc
),
--only 93 of the 98 detectors have good directions and names; need to find the missing 5 and do a length jam to find the closest centreline to the detector.
SELECT
rd.detector_id AS det_og,
rd.gen_loc,
cp.detector_id AS det_w_loc
FROM rescu_det AS rd
JOIN check_pls AS cp USING (detector_id)
