-- match based on node_ids
INSERT INTO prj_volume.artery_tcl(arterycode, centreline_id, direction, sideofint, match_on_case, artery_type)
SELECT arterycode, centreline_id, apprdir, sideofint, 1, 1
FROM prj_volume.new_arterydata JOIN prj_volume.arteries USING (arterycode) JOIN prj_volume.centreline ON (fnode_id = from_intersection_id and tnode_id = to_intersection_id or fnode_id = to_intersection_id and tnode_id = from_intersection_id)
WHERE newcode;

INSERT INTO prj_volume.artery_tcl(arterycode, centreline_id, direction, sideofint, match_on_case, artery_type)
SELECT DISTINCT ON (arterycode) arterycode, centreline_id, direction, sideofint, 2 as match_on_case, 1 AS artery_type
FROM (SELECT arterycode, loc, apprdir AS direction, sideofint, fnode_id, tnode_id
	FROM prj_volume.new_arterydata A JOIN prj_volume.arteries USING (arterycode)
	WHERE newcode AND NOT EXISTS (SELECT * FROM prj_volume.artery_tcl B WHERE B.arterycode = A.arterycode) AND ST_GeometryType(loc) = 'ST_LineString') C	
     CROSS JOIN 
	(SELECT shape, centreline_id, from_intersection_id, to_intersection_id, linear_name_full FROM prj_volume.centreline WHERE feature_code<=201800) sc 
WHERE (fnode_id = from_intersection_id AND abs(ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape,0.1))-ST_Azimuth(ST_StartPoint(loc),ST_LineInterpolatePoint(loc, 0.1))) < (pi()/9))
	or (fnode_id = to_intersection_id AND abs(ST_Azimuth(ST_EndPoint(shape), ST_LineInterpolatePoint(shape,0.9))-ST_Azimuth(ST_StartPoint(loc),ST_LineInterpolatePoint(loc, 0.1))) < (pi()/9))
	or (tnode_id = from_intersection_id AND abs(ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape,0.1))-ST_Azimuth(ST_EndPoint(loc),ST_LineInterpolatePoint(loc, 0.9))) < (pi()/9))
	or (tnode_id = to_intersection_id AND abs(ST_Azimuth(ST_EndPoint(shape), ST_LineInterpolatePoint(shape,0.9))-ST_Azimuth(ST_EndPoint(loc),ST_LineInterpolatePoint(loc, 0.9))) < (pi()/9))
ORDER BY arterycode, ST_Length(shape);

-- Checkpoint: check if all new LINESTRING arterycodes are matched

SELECT *
FROM prj_volume.new_arterydata
WHERE count_type NOT IN ('R','P') AND NOT EXISTS (SELECT 1 FROM prj_volume.artery_tcl WHERE new_arterydata.arterycode=artery_tcl.arterycode);