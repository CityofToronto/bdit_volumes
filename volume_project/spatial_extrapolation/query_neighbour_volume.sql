-- Parameters: $1 - feature_code, $2 - number of neighbours

SELECT g1, dir_bin, place_holder_time_var, array_agg(v ORDER BY row_number) AS neigh_vols
FROM(
	SELECT g1, dir_bin, g2, dist, place_holder_time_var, row_number() OVER (PARTITION BY g1, place_holder_time_var ORDER BY dist), E.volume::int as v
	FROM (SELECT t1.group_number AS g1, t2.group_number AS g2, ST_Distance(t1.shape, t2.shape) AS dist
			FROM prj_volume.centreline_groups_geom t1 JOIN prj_volume.centreline_groups_geom t2 ON (ST_Dwithin(t1.shape, t2.shape,300)) 
			WHERE t1.feature_code=$1 AND t2.feature_code = $1 AND t1.group_number != t2.group_number 
					AND t2.group_number IN (SELECT DISTINCT group_number FROM prj_volume.place_holder_table_name) 
					AND t1.group_number NOT IN (SELECT DISTINCT group_number FROM prj_volume.place_holder_table_name)) A
	JOIN prj_volume.centreline_groups B ON (g1 = B.group_number)
	JOIN 
		(SELECT group_number, place_holder_time_var, AVG(volume) AS volume 
		FROM prj_volume.place_holder_table_name 
		GROUP BY group_number, place_holder_time_var) E 
	ON (E.group_number = g2)) G
WHERE row_number <= $2 
GROUP BY g1, dir_bin, place_holder_time_var
HAVING count(v) = $2