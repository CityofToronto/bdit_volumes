SELECT ST_X(ST_StartPoint(shape)), ST_Y(ST_StartPoint(shape)), ST_X(ST_EndPoint(shape)), ST_Y(ST_EndPoint(shape)), volume 
FROM (SELECT group_number, dir_bin, volume, (CASE WHEN dir_binary(ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape))) = dir_bin THEN shape ELSE ST_REVERSE(shape) END) AS shape 
	FROM (SELECT shape, group_number, dir_bin, AVG(volume)::int AS volume 
		FROM prj_volume.aadt JOIN prj_volume.centreline_groups_geom USING (group_number)
		WHERE feature_code=201200
		GROUP BY group_number, shape, dir_bin) A) B