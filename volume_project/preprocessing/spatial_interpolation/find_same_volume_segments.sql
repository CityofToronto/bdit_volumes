﻿DROP TABLE IF EXISTS roads;
DROP TABLE IF EXISTS prj_volume.centreline_volumes_truth;

CREATE TEMPORARY TABLE roads (centreline_id bigint, shape geometry, intersection_id bigint, dir_bin smallint);
CREATE TABLE prj_volume.centreline_volumes_truth (cl1 bigint, cl2 bigint, dir_bin smallint, same_volume boolean, unused boolean);

INSERT INTO roads
SELECT	centreline_id,
	shape,
	UNNEST(ARRAY[from_intersection_id, to_intersection_id]) as intersection_id,
	dir_bin
FROM
	(SELECT centreline_id,
		shape,
		from_intersection_id,
		to_intersection_id,
		(CASE oneway_dir_code
		WHEN 0 THEN UNNEST(ARRAY[1,-1])
		ELSE oneway_dir_code * dir_binary((ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape))+0.292)*180/pi()) END) AS dir_bin
	FROM prj_volume.centreline
	WHERE feature_code<202000) A;

INSERT INTO prj_volume.centreline_volumes_truth
SELECT r1.centreline_id, r2.centreline_id, r1.dir_bin, prj_volume.same_volume(r1.centreline_id, r2.centreline_id) AS same_volume, TRUE as unused
FROM roads r1 
INNER JOIN roads r2 USING (intersection_id)
WHERE r1.centreline_id != r2.centreline_id AND r1.dir_bin = r2.dir_bin
GROUP BY r1.centreline_id, r2.centreline_id, r1.dir_bin;