DROP TABLE IF EXISTS prj_volume.corr_dir;

CREATE TABLE prj_volume.corr_dir(
	linear_name_id int,
	linear_name text,
	linear_name_label text,
	dir text,
	start_id bigint);

INSERT INTO prj_volume.corr_dir
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
	HAVING count(centreline_id) >= 20
	ORDER BY count(centreline_id) desc) AS s

INNER JOIN prj_volume.centreline as i on i.linear_name_id = s.linear_name_id AND s.min_y = st_y(st_centroid(i.shape))
INNER JOIN prj_volume.centreline as j on j.linear_name_id = s.linear_name_id AND s.max_y = st_y(st_centroid(j.shape))
ORDER BY s.num_segs desc;

UPDATE prj_volume.corr_dir cd
SET start_id = i.centreline_id
FROM prj_volume.centreline i
INNER JOIN ( 	SELECT linear_name_id, min(st_x(st_centroid(shape))) as min_x
		FROM prj_volume.centreline
		GROUP BY linear_name_id) as sub ON sub.min_x = st_x(st_centroid(i.shape))
WHERE cd.dir = 'E/W' AND cd.linear_name_id = i.linear_name_id;

UPDATE prj_volume.corr_dir cd
SET start_id = i.centreline_id
FROM prj_volume.centreline i
INNER JOIN ( 	SELECT linear_name_id, min(st_y(st_centroid(shape))) as min_y
		FROM prj_volume.centreline
		GROUP BY linear_name_id) as sub ON sub.min_y = st_y(st_centroid(i.shape))
WHERE cd.dir != 'E/W' AND cd.linear_name_id = i.linear_name_id;