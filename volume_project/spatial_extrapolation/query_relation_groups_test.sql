-- Parameters: $1 - feature_code

SELECT g1, dir_bin, array_agg(v ORDER BY parallel, row_number)
FROM(
	SELECT g1, C.dir_bin, g2, parallel, dist, row_number() OVER (PARTITION BY g1, parallel ORDER BY dist, feature_code), E.volume::int as v
	FROM (
		SELECT g1, g2, (CASE WHEN diff BETWEEN 45 AND 135 OR diff BETWEEN 225 AND 315 THEN FALSE ELSE TRUE END) AS parallel, dist, feature_code
		FROM (SELECT t1.group_number AS g1, t2.group_number AS g2, ST_Distance(t1.shape, t2.shape) AS dist, t2.feature_code, 
				ABS((ST_Azimuth(ST_StartPoint(t1.shape), ST_EndPoint(t1.shape)) - ST_Azimuth(ST_StartPoint(t2.shape), ST_EndPoint(t2.shape))))/pi()*180 AS diff
			FROM prj_volume.centreline_groups_geom t1 JOIN prj_volume.centreline_groups_geom t2 ON (ST_Dwithin(t1.shape, t2.shape,500)) 
			WHERE t1.feature_code=$1 AND t1.group_number != t2.group_number AND t2.group_number IN (SELECT DISTINCT group_number FROM prj_volume.aadt) AND t1.group_number NOT IN (SELECT DISTINCT group_number FROM prj_volume.aadt)) A
		WHERE feature_code=$1 OR diff BETWEEN 45 AND 135 OR diff BETWEEN 225 AND 315) B

	JOIN (SELECT DISTINCT group_number, dir_bin
		FROM prj_volume.centreline_groups) C
		ON (g1 = C.group_number)
	JOIN (SELECT DISTINCT group_number, dir_bin
		FROM prj_volume.centreline_groups) D
		ON (g2 = D.group_number)
	JOIN (SELECT group_number, AVG(volume) AS volume FROM prj_volume.aadt GROUP BY group_number) E ON (E.group_number = g2)
	WHERE not parallel OR C.dir_bin = D.dir_bin) G

WHERE row_number < 3 
GROUP BY g1, dir_bin
