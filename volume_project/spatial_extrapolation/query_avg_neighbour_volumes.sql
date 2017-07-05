-- Parameters: $1 - feature_codes

SELECT g1, dir_bin, AVG(neighbourvolume)::int
FROM (SELECT l1.group_number AS g1, l1.dir_bin AS dir_bin, l2.volume as neighbourvolume, row_number() OVER (PARTITION BY l1.group_number ORDER BY ST_Distance(l1.shape, l2.shape))
	FROM (SELECT group_number, dir_bin, shape
		FROM prj_volume.centreline_groups_geom JOIN prj_volume.centreline_groups USING (group_number)
		WHERE group_number NOT IN (SELECT group_number FROM prj_volume.aadt) AND feature_code = $1) l1 
	      JOIN 
	     (SELECT group_number, volume, shape FROM prj_volume.centreline_groups_geom JOIN prj_volume.aadt USING (group_number) WHERE aadt.confidence = 1 AND feature_code=$1) l2
		 ON (ST_DWithin(l1.shape, l2.shape, 500))) A 
WHERE row_number < 5
GROUP BY g1, dir_bin