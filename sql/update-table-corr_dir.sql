-- DELETE TABLE
DROP TABLE IF EXISTS prj_volume.corr_dir;
 
-- CREATE EMPTY TABLE
CREATE TABLE prj_volume.corr_dir(
	corridor_id bigserial primary key,
	linear_name_id int,
	linear_name text,
	linear_name_label text,
	dir text,
	start_id bigint);

-- POPULATE TABLE
INSERT INTO prj_volume.corr_dir (linear_name_id, linear_name, linear_name_label, dir)
SELECT 	s.linear_name_id,
	s.linear_name,
	s.linear_name_label,
	direction(degrees(st_azimuth(st_centroid(i.shape), st_centroid(j.shape)))) as dir
FROM	(SELECT linear_name_id, 
		linear_name, 
		linear_name_label, 
		count(centreline_id) as num_segs, 
		min(st_y(st_centroid(shape))) as min_y, 
		max(st_y(st_centroid(shape))) as max_y
	FROM prj_volume.centreline
	WHERE feature_code_desc NOT IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail')
	GROUP BY linear_name_id, linear_name, linear_name_label
	HAVING count(centreline_id) >= 50
	ORDER BY count(centreline_id) desc) AS s

INNER JOIN prj_volume.centreline as i on i.linear_name_id = s.linear_name_id AND s.min_y = st_y(st_centroid(i.shape))
INNER JOIN prj_volume.centreline as j on j.linear_name_id = s.linear_name_id AND s.max_y = st_y(st_centroid(j.shape))
ORDER BY s.num_segs desc;

-- UPDATE INDIVIDUAL CORRIDORS WITH DIRECTIONS
-- kingsway
UPDATE prj_volume.corr_dir cd
SET dir = 'N/S'
WHERE linear_name_id = 2601;

--vaughan
UPDATE prj_volume.corr_dir cd
SET dir = 'N/S'
WHERE linear_name_id = 930;

--trethewey
UPDATE prj_volume.corr_dir cd
SET dir = 'E/W'
WHERE linear_name_id = 917;

--danforth rd
UPDATE prj_volume.corr_dir cd
SET dir = 'N/S'
WHERE linear_name_id = 7707;

--chaplin
UPDATE prj_volume.corr_dir cd
SET dir = 'E/W'
WHERE linear_name_id = 3144;

--aylesworth
UPDATE prj_volume.corr_dir cd
SET dir = 'E/W'
WHERE linear_name_id = 7263;

--rexdale
UPDATE prj_volume.corr_dir cd
SET dir = 'E/W'
WHERE linear_name_id = 2361;

--albion
UPDATE prj_volume.corr_dir cd
SET dir = 'E/W'
WHERE linear_name_id = 1012;

--elmhurst
UPDATE prj_volume.corr_dir cd
SET dir = 'E/W'
WHERE linear_name_id = 1544;

--brookbanks
UPDATE prj_volume.corr_dir cd
SET dir = 'E/W'
WHERE linear_name_id = 5045;

UPDATE prj_volume.corr_dir cd
SET dir = 'EB'
WHERE cd.dir = 'E/W';

UPDATE prj_volume.corr_dir cd
SET dir = 'NB'
WHERE cd.dir = 'N/S';

INSERT INTO prj_volume.corr_dir (linear_name_id, linear_name, linear_name_label, dir)
SELECT	linear_name_id,
	linear_name,
	linear_name_label,
	'WB' AS dir
FROM prj_volume.corr_dir
WHERE dir = 'EB';

INSERT INTO prj_volume.corr_dir (linear_name_id, linear_name, linear_name_label, dir)
SELECT	linear_name_id,
	linear_name,
	linear_name_label,
	'SB' AS dir
FROM prj_volume.corr_dir
WHERE dir = 'NB';

UPDATE prj_volume.corr_dir cd
SET start_id = i.centreline_id
FROM prj_volume.centreline i
INNER JOIN ( 	SELECT linear_name_id, min(st_x(st_centroid(shape))) as min_x
		FROM prj_volume.centreline
		WHERE seg_dir(oneway_dir_code, 'EB', shape) IN ('BOTH','EB')
		GROUP BY linear_name_id) as sub ON sub.min_x = st_x(st_centroid(i.shape))
WHERE cd.dir = 'EB' AND cd.linear_name_id = i.linear_name_id AND cd.linear_name_id = sub.linear_name_id;

UPDATE prj_volume.corr_dir cd
SET start_id = i.centreline_id
FROM prj_volume.centreline i
INNER JOIN ( 	SELECT linear_name_id, min(st_y(st_centroid(shape))) as min_y
		FROM prj_volume.centreline
		WHERE seg_dir(oneway_dir_code, 'NB', shape) IN ('BOTH','NB')
		GROUP BY linear_name_id) as sub ON sub.min_y = st_y(st_centroid(i.shape))
WHERE cd.dir = 'NB' AND cd.linear_name_id = i.linear_name_id AND cd.linear_name_id = sub.linear_name_id;

UPDATE prj_volume.corr_dir cd
SET start_id = i.centreline_id
FROM prj_volume.centreline i
INNER JOIN ( 	SELECT linear_name_id, max(st_x(st_centroid(shape))) as max_x
		FROM prj_volume.centreline
		WHERE seg_dir(oneway_dir_code, 'WB', shape) IN ('BOTH','WB')
		GROUP BY linear_name_id) as sub ON sub.max_x = st_x(st_centroid(i.shape))
WHERE cd.dir = 'WB' AND cd.linear_name_id = i.linear_name_id AND cd.linear_name_id = sub.linear_name_id;

UPDATE prj_volume.corr_dir cd
SET start_id = i.centreline_id
FROM prj_volume.centreline i
INNER JOIN ( 	SELECT linear_name_id, max(st_y(st_centroid(shape))) as max_y
		FROM prj_volume.centreline
		WHERE seg_dir(oneway_dir_code, 'SB', shape) IN ('BOTH','SB')
		GROUP BY linear_name_id) as sub ON sub.max_y = st_y(st_centroid(i.shape))
WHERE cd.dir = 'SB' AND cd.linear_name_id = i.linear_name_id AND cd.linear_name_id = sub.linear_name_id;

-- Renforth Dr - Correct start_id for NB
UPDATE prj_volume.corr_dir
SET start_id = 11048510
WHERE linear_name_id = 2353 AND dir = 'NB';


