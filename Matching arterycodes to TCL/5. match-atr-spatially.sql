-- STEP 2: INSERT centreline_ids based on spatial match to closest segment
DROP TABLE IF EXISTS unmatched_linestrings;

CREATE TABLE unmatched_linestrings(arterycode bigint, loc geometry, direction character varying, sideofint character varying, fnode_id bigint, tnode_id bigint);

INSERT INTO unmatched_linestrings
SELECT arterycode, loc, apprdir AS direction, arterydata.sideofint, fnode_id, tnode_id
FROM prj_volume.arteries LEFT JOIN prj_volume.artery_tcl USING (arterycode) JOIN traffic.arterydata USING (arterycode)
WHERE centreline_id IS NULL and ST_GeometryType(loc) = 'ST_LineString';

-- take out segments that are obviously outside of tcl boundary
INSERT INTO prj_volume.artery_tcl
SELECT arterycode, null as centreline_id, direction, unmatched_linestrings.sideofint, 11 as match_on_case, 1 as artery_type
FROM unmatched_linestrings JOIN traffic.arterydata USING (arterycode)
WHERE location LIKE '%N OF STEELES%' or loc LIKE '%W OF ETOBICOKE CREEK%'
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

DELETE FROM unmatched_linestrings
WHERE arterycode in (SELECT arterycode FROM prj_volume.artery_tcl WHERE match_on_case = 11);

-- 2-1: if one node coincides with nodes in centreline
DROP TABLE IF EXISTS temp_match;
CREATE TEMPORARY TABLE temp_match(arterycode bigint, centreline_id bigint, direction character varying, sideofint character varying, match_on_case smallint, shape geometry);

INSERT INTO temp_match(arterycode, centreline_id, direction, sideofint, match_on_case, shape)
SELECT arterycode, centreline_id, direction, sideofint, 2 as match_on_case, shape
FROM unmatched_linestrings CROSS JOIN (SELECT shape, centreline_id, from_intersection_id, to_intersection_id, linear_name_full FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc 
WHERE (fnode_id = from_intersection_id AND abs(ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape,0.1))-ST_Azimuth(ST_StartPoint(loc),ST_LineInterpolatePoint(loc, 0.1))) < (pi()/9))
	or (fnode_id = to_intersection_id AND abs(ST_Azimuth(ST_EndPoint(shape), ST_LineInterpolatePoint(shape,0.9))-ST_Azimuth(ST_StartPoint(loc),ST_LineInterpolatePoint(loc, 0.1))) < (pi()/9))
	or (tnode_id = from_intersection_id AND abs(ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape,0.1))-ST_Azimuth(ST_EndPoint(loc),ST_LineInterpolatePoint(loc, 0.9))) < (pi()/9))
	or (tnode_id = to_intersection_id AND abs(ST_Azimuth(ST_EndPoint(shape), ST_LineInterpolatePoint(shape,0.9))-ST_Azimuth(ST_EndPoint(loc),ST_LineInterpolatePoint(loc, 0.9))) < (pi()/9))
ORDER BY arterycode;
--choose the longer segment in case >1 segment overlaps with arterycode

INSERT INTO prj_volume.artery_tcl 
SELECT DISTINCT ON (arterycode) arterycode, centreline_id, direction, sideofint, match_on_case, 1 as artery_type
FROM temp_match
ORDER BY arterycode, ST_Length(shape) DESC
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

DELETE FROM unmatched_linestrings 
WHERE unmatched_linestrings.arterycode IN (SELECT arterycode FROM temp_match);

-- 2-2: no node coincides with centreline nodes -> spatial match
INSERT INTO prj_volume.artery_tcl
SELECT arterycode,centreline_id, direction, sideofint, 12 as match_on_case, 1 as artery_type
FROM (
	SELECT DISTINCT ON (ar.arterycode) ar.arterycode, cl.centreline_id, ar.direction, ar.sideofint
	FROM unmatched_linestrings ar CROSS JOIN (SELECT * FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids WHERE reason=1)) cl
	-- only exclude segments that do no represent roads, keep the ones with duplicate fnode,tnode
	WHERE (ST_DWithin(loc,shape,20) 
		and (abs(ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape))-ST_Azimuth(ST_StartPoint(loc),ST_EndPoint(loc))) < (pi()/4)
			or abs(ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape))-ST_Azimuth(ST_EndPoint(loc),ST_StartPoint(loc))) < (pi()/4)))
		-- spatial proximity + direction match
		or (ST_DWithin(loc,shape,0.5) and abs(ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape))-ST_Azimuth(ST_StartPoint(shape),ST_LineInterpolatePoint(shape,0.1))) > (pi()/4))
		-- very close segments(0.5) and the centreline segment curves
	ORDER BY ar.arterycode, ST_HausdorffDistance(loc,shape)
	) AS sub
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

--3. insert unmatched arterycodes

DELETE FROM unmatched_linestrings 
WHERE unmatched_linestrings.arterycode IN (SELECT arterycode FROM prj_volume.artery_tcl);

INSERT INTO prj_volume.artery_tcl(arterycode, sideofint, direction, match_on_case, artery_type)
SELECT arterycode, sideofint, direction, 9 as match_on_case, 1 as artery_type
FROM unmatched_linestrings
WHERE unmatched_linestrings.arterycode NOT IN (SELECT arterycode FROM prj_volume.artery_tcl)
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET match_on_case = EXCLUDED.match_on_case;
