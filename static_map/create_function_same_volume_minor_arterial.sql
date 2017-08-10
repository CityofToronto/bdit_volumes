DROP FUNCTION IF EXISTS prj_volume.same_volume_minor_arterial_group(g1 bigint, g2 bigint);

CREATE OR REPLACE FUNCTION prj_volume.same_volume_minor_arterial_group(g1 bigint, g2 bigint)
	RETURNS BOOLEAN AS $$
DECLARE
	NameNode boolean;
	common_node TEXT;
	fc bigint;
	result boolean;
	dir1 integer;
	dir2 integer;
	geom1 geometry;
	geom2 geometry;
BEGIN
	-- check if the two segments share a same node and road name and feature class
	SELECT (t1.feature_code = t2.feature_code AND t1.linear_name_full = t2.linear_name_full) AND (ARRAY[t1.from_intersection, t1.to_intersection] && ARRAY[t2.from_intersection, t2.to_intersection]) INTO NameNode
	FROM prj_volume.centreline_groups_geom t1, prj_volume.centreline_groups_geom t2
	WHERE t1.group_number = g1 AND t2.group_number = g2;
	
	SELECT dir_bin INTO dir1
	FROM prj_volume.centreline_groups
	WHERE group_number = g1;
	
	SELECT dir_bin INTO dir2
	FROM prj_volume.centreline_groups
	WHERE group_number = g2;

	SELECT shape INTO geom1
	FROM prj_volume.centreline_groups_geom
	WHERE group_number = g1;
	
	SELECT shape INTO geom2
	FROM prj_volume.centreline_groups_geom
	WHERE group_number = g2;

	IF dir1 != dir2 THEN 
		result := False;
	ELSIF NameNode THEN 
		-- Find the common node
		SELECT (CASE WHEN(t1.from_intersection=t2.from_intersection) THEN t1.from_intersection 
			WHEN (t1.from_intersection=t2.to_intersection) THEN t1.from_intersection 
			WHEN (t1.to_intersection=t2.from_intersection) THEN t1.to_intersection
			WHEN (t1.to_intersection=t2.to_intersection) THEN t1.to_intersection END) INTO common_node
		FROM prj_volume.centreline_groups_geom t1, prj_volume.centreline_groups_geom t2
		WHERE t1.group_number = g1 AND t2.group_number = g2;

		-- True if no Minor Arterial + (not Expressway) is intersecting at the intersection
		SELECT NOT EXISTS(SELECT centreline_id
				FROM prj_volume.centreline C JOIN prj_volume.centreline_groups G USING (centreline_id) 
				WHERE (ST_AsText(ST_StartPoint(C.shape)) = common_node OR ST_AsText(ST_EndPoint(C.shape)) = common_node) AND (feature_code < 201301 AND feature_code!=201100) AND (group_number not in (g1,g2)) AND NOT (prj_volume.angle_diff(C.shape, geom1) < 15 OR prj_volume.angle_diff(C.shape, geom2) < 15)) INTO result;
	ELSE
		result := False;
	END IF;
	
	RETURN result;
		
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;