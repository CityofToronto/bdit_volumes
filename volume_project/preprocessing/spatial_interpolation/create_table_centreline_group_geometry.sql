DROP TABLE IF EXISTS prj_volume.centreline_groups_geom;

CREATE TABLE prj_volume.centreline_groups_geom(group_number integer, shape geometry, feature_code bigint, feature_code_desc text);

INSERT INTO prj_volume.centreline_groups_geom(group_number, shape, feature_code, feature_code_desc)
SELECT group_number, ST_LineMerge(ST_Union(shape)) AS shape, AVG(feature_code), MAX(feature_code_desc)
FROM prj_volume.centreline_groups JOIN prj_volume.centreline USING (centreline_id)
WHERE from_intersection_id != to_intersection_id
GROUP BY group_number;

DROP TABLE IF EXISTS EndPoints;

CREATE TEMPORARY TABLE EndPoints AS 
(	SELECT group_number, point, NumConn, NumEnds
	FROM(	SELECT group_number, (ST_Dump(ST_Collect(p1,p2))).geom AS point, COUNT(*) AS NumConn, SUM(CASE WHEN COUNT(*)=1 THEN 1 ELSE 0 END) OVER (PARTITION BY group_number) AS NumEnds
		FROM (SELECT group_number, ST_StartPoint((ST_Dump(shape)).geom) AS p1, ST_EndPoint((ST_Dump(shape)).geom) AS p2
			FROM prj_volume.centreline_groups JOIN prj_volume.centreline USING (centreline_id) 
				JOIN 
				(SELECT group_number
				FROM prj_volume.centreline_groups_geom
				WHERE ST_GeometryType(shape) != 'ST_LineString') A USING (group_number)) A
		GROUP BY group_number, (ST_Dump(ST_Collect(p1,p2))).geom
		HAVING COUNT(*) != 2) B
	WHERE (NumEnds > 1 AND NumConn = 1) OR (NumConn % 2 = 1 AND NumEnds = 1)
	ORDER BY group_number);

DELETE FROM prj_volume.centreline_groups_geom
WHERE group_number IN (SELECT DISTINCT group_number FROM EndPoints); 

INSERT INTO prj_volume.centreline_groups_geom(group_number, shape, feature_code, feature_code_desc)
SELECT DISTINCT ON (group_number) group_number, (CASE WHEN dir_binary((ST_Azimuth(E1.point, E2.point)+0.292)*180/pi()) = dir_bin THEN ST_MakeLine(E1.point, E2.point) ELSE ST_MakeLine(E2.point, E1.point) END) AS shape, feature_code, feature_code_desc
FROM EndPoints E1 JOIN EndPoints E2 USING (group_number) JOIN prj_volume.centreline_groups USING (group_number) JOIN prj_volume.centreline USING (centreline_id)
WHERE ST_AsText(E1.point) != ST_AsText(E2.point)  
ORDER BY group_number, ST_Distance(E1.point, E2.point) DESC;

UPDATE prj_volume.centreline_groups_geom
SET shape = 
	(SELECT ST_LineMerge(ST_Union(shape))
	FROM prj_volume.centreline
	WHERE centreline_id in (10011118, 446577,446591,446601,30074319))
WHERE group_number = 11680;

UPDATE prj_volume.centreline_groups_geom
SET shape = 
	(SELECT ST_Reverse(ST_LineMerge(ST_Union(shape)))
	FROM prj_volume.centreline
	WHERE centreline_id in (10011118, 446577,446591,446601,30074319))
WHERE group_number = 13708;
