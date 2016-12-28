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

CREATE TABLE unmatched_linestrings(arterycode bigint, loc geometry, direction character varying, sideofint character varying);

INSERT INTO unmatched_linestrings
SELECT arterycode, loc, apprdir AS direction, arterydata.sideofint
FROM prj_volume.arteries LEFT JOIN prj_volume.artery_tcl USING (arterycode) JOIN traffic.arterydata USING (arterycode)
WHERE centreline_id IS NULL and ST_GeometryType(loc) = 'ST_LineString';

INSERT INTO prj_volume.artery_tcl
SELECT arterycode,centreline_id, direction, sideofint, 2 as match_on_case
FROM (
	SELECT DISTINCT ON (ar.arterycode) ar.arterycode, cl.centreline_id, ar.direction, ar.sideofint
	FROM unmatched_linestrings ar CROSS JOIN (SELECT * FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids WHERE reason=1)) cl
	-- only exlude segments that do no represent roads, keep the ones with duplicate fnode,tnode
	WHERE ST_DWithin(loc,shape,200) 
		and (abs(ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape))-ST_Azimuth(ST_StartPoint(loc),ST_EndPoint(loc))) < (pi()/4)
			or abs(ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape))-ST_Azimuth(ST_EndPoint(loc),ST_StartPoint(loc))) < (pi()/4))
		-- proximity of direction of the two segments
	ORDER BY ar.arterycode, ST_HausdorffDistance(loc,shape)
	) AS sub
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
