DROP TABLE IF EXISTS excluded_geoids;
CREATE TEMPORARY TABLE excluded_geoids(centreline_id bigint,reason int);

-- excludes geoids from centreline table where either: another segment shares identical fnode/tnode
INSERT INTO excluded_geoids
SELECT centreline_id, 0 as reason
FROM
(SELECT from_intersection_id, to_intersection_id, count(*)
FROM prj_volume.centreline cl
WHERE feature_code_desc NOT IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail')
GROUP BY from_intersection_id, to_intersection_id
HAVING COUNT(*) > 1) as f
INNER JOIN prj_volume.centreline cl ON cl.from_intersection_id = f.from_intersection_id AND cl.to_intersection_id = f.to_intersection_id;

-- excludes geoids from centreline table where either:  segment type is not a road segment
INSERT INTO excluded_geoids
SELECT centreline_id, 1 as reason
FROM prj_volume.centreline
WHERE feature_code_desc IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail');

-- STEP 1: INSERT centreline_ids based on fnode, tnode links
DROP TABLE IF EXISTS temp_match;
CREATE TEMPORARY TABLE temp_match (arterycode bigint, cl_id1 bigint, cl_id2 bigint, dist1 double precision, dist2 double precision, direction character varying, sideofint character);

INSERT INTO temp_match
SELECT ad.arterycode, sc1.centreline_id as cl_id1, sc2.centreline_id as cl_id2, ST_HausdorffDistance(loc,sc1.shape) as dist1, ST_HausdorffDistance(loc,sc2.shape) as dist2, apprdir AS direction, sideofint
FROM traffic.arterydata ad
LEFT JOIN (SELECT * FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc1 ON SUBSTRING(ad.linkid,'([0-9]{1,20})@?')::bigint = sc1.from_intersection_id AND SUBSTRING(linkid,'@([0-9]{1,20})')::bigint = sc1.to_intersection_id
LEFT JOIN (SELECT * FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc2 ON SUBSTRING(ad.linkid,'([0-9]{1,20})@?')::bigint = sc2.to_intersection_id AND SUBSTRING(linkid,'@([0-9]{1,20})')::bigint = sc2.from_intersection_id
JOIN prj_volume.arteries USING (arterycode)
ORDER BY arterycode;
	
-- links that match multiple centrelines
INSERT INTO prj_volume.artery_tcl
SELECT DISTINCT ON (arterycode) arterycode, (CASE WHEN dist1>dist2 THEN cl_id2 ELSE cl_id1 END) AS centreline_id, direction, sideofint, 1 as match_on_case
FROM temp_match as sub
WHERE (sub.cl_id1 IS NOT NULL AND sub.cl_id2 IS NOT NULL)
ORDER BY arterycode, LEAST(dist1, dist2)
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

-- links that only match one centreline
INSERT INTO prj_volume.artery_tcl
SELECT arterycode, COALESCE(sub.cl_id1, sub.cl_id2) as centreline_id, direction, sideofint, 1 as match_on_case
FROM temp_match as sub
WHERE (sub.cl_id1 IS NOT NULL OR sub.cl_id2 IS NOT NULL) and (sub.cl_id1 IS NULL OR sub.cl_id2 IS NULL)
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;


-- STEP 2: INSERT centreline_ids based on spatial match to closest segment
DROP TABLE IF EXISTS unmatched_linestrings;

CREATE TABLE unmatched_linestrings(arterycode bigint, loc geometry, direction character varying, sideofint character varying, fnode_id bigint, tnode_id bigint);

INSERT INTO unmatched_linestrings
SELECT arterycode, loc, apprdir AS direction, arterydata.sideofint, fnode_id, tnode_id
FROM prj_volume.arteries LEFT JOIN prj_volume.artery_tcl USING (arterycode) JOIN traffic.arterydata USING (arterycode)
WHERE centreline_id IS NULL and ST_GeometryType(loc) = 'ST_LineString';

-- take out segments that are obviously outside of tcl boundary
INSERT INTO prj_volume.artery_tcl
SELECT arterycode, null as centreline_id, direction, unmatched_linestrings.sideofint, 11 as match_on_case
FROM unmatched_linestrings JOIN traffic.arterydata USING (arterycode)
WHERE location LIKE '%N OF STEELES%' or loc LIKE '%W OF ETOBICOKE CREEK'
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
SELECT DISTINCT ON (arterycode) arterycode, centreline_id, direction, sideofint, match_on_case
FROM temp_match
ORDER BY arterycode, ST_Length(shape) DESC
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

DELETE FROM unmatched_linestrings 
WHERE unmatched_linestrings.arterycode IN (SELECT arterycode FROM temp_match);

-- 2-2: no node coincides with centreline nodes -> spatial match
INSERT INTO prj_volume.artery_tcl
SELECT arterycode,centreline_id, direction, sideofint, 12 as match_on_case
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
