-- The function takes two centreline_ids and return a boolean value indicating whether they should be merged.
DROP FUNCTION IF EXISTS prj_volume.same_volume(c1 bigint, c2 bigint);
CREATE OR REPLACE FUNCTION prj_volume.same_volume(c1 bigint, c2 bigint)
	RETURNS BOOLEAN AS $$
DECLARE
	NameNode boolean;
	common_node bigint;
	result boolean;
BEGIN
	-- check if the two segments share a same node and road name and feature class
	SELECT (t1.feature_code = t2.feature_code AND t1.linear_name_full = t2.linear_name_full) AND (ARRAY[t1.from_intersection_id, t1.to_intersection_id] && ARRAY[t2.from_intersection_id, t2.to_intersection_id]) INTO NameNode
	FROM prj_volume.centreline t1, prj_volume.centreline t2
	WHERE t1.centreline_id = c1 AND t2.centreline_id = c2;
	
	-- continue checking if there's a common node (two segments are connected)
	IF NameNode THEN
		
		-- find the common_node
		SELECT (t1.from_intersection_id=t2.from_intersection_id)::int*t1.from_intersection_id +
				(t1.from_intersection_id=t2.to_intersection_id)::int*t1.from_intersection_id +
				(t1.to_intersection_id=t2.from_intersection_id)::int*t1.to_intersection_id +
				(t1.to_intersection_id=t2.to_intersection_id)::int*t1.to_intersection_id INTO common_node
		FROM prj_volume.centreline t1, prj_volume.centreline t2
		WHERE t1.centreline_id = c1 AND t2.centreline_id = c2;
		
		-- check if a collector and above segment also intersects at the common node. yes->return false; no->return true.
		SELECT NOT EXISTS(SELECT centreline_id
				FROM prj_volume.centreline
				WHERE (from_intersection_id = common_node OR to_intersection_id = common_node) AND (feature_code < 201401) AND (centreline_id not in (c1,c2))) INTO result;
				
	-- return false if the segments do not share a common node
	ELSE
		result := False;
	END IF;
	
	RETURN result;
		
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;