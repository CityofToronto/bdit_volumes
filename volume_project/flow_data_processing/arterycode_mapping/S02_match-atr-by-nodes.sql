--*****BE CAREFUL, RUNNING THIS SCRIPT RESTARTS THE MATCHING PROCESS*******
TRUNCATE prj_volume.artery_tcl;

-- TEMPORARY TABLE: Centreline IDs that shouldn't be included in the match process
DROP TABLE IF EXISTS excluded_geoids;
CREATE TEMPORARY TABLE excluded_geoids(centreline_id bigint, reason int);

-- REASON 0: excludes geoids from centreline table where either: another segment shares identical fnode/tnode
INSERT INTO excluded_geoids
SELECT geo_id AS centreline_id, 0 as reason
FROM	(	
		SELECT 		MAX(fnode) as fnode,
				MIN(tnode) as tnode
		FROM 		gis.centreline cl
		WHERE 		fcode_desc NOT IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail')
		GROUP BY 	(CASE 	WHEN fnode < tnode THEN (fnode, tnode)
							ELSE (tnode, fnode) 
					END)
		HAVING 	COUNT(1) > 1
		) as f
INNER JOIN gis.centreline cl ON (	(cl.fnode = f.fnode AND cl.tnode = f.tnode)
					OR (cl.fnode = f.tnode AND cl.tnode = f.fnode)
				);

-- REASON 1: excludes geoids from centreline table where either:  segment type is not a road segment
INSERT INTO excluded_geoids
SELECT geo_id AS centreline_id, 1 as reason
FROM gis.centreline
WHERE fcode_desc IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail');

-- STEP 1: INSERT centreline_ids based on fnode, tnode links
DROP TABLE IF EXISTS temp_match CASCADE;
CREATE TEMPORARY TABLE temp_match (arterycode bigint, cl_id1 bigint, cl_id2 bigint, dist1 double precision, dist2 double precision, direction character varying, sideofint character);

INSERT INTO temp_match
SELECT ad.arterycode, sc1.geo_id as cl_id1, sc2.geo_id as cl_id2, ST_HausdorffDistance(loc,sc1.geom) as dist1, ST_HausdorffDistance(loc,sc2.geom) as dist2, apprdir AS direction, sideofint
FROM traffic.arterydata ad
LEFT JOIN (SELECT * FROM gis.centreline WHERE geo_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc1 ON SUBSTRING(ad.linkid,'([0-9]{1,20})@?')::bigint = sc1.fnode AND SUBSTRING(linkid,'@([0-9]{1,20})')::bigint = sc1.tnode
LEFT JOIN (SELECT * FROM gis.centreline WHERE geo_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc2 ON SUBSTRING(ad.linkid,'([0-9]{1,20})@?')::bigint = sc2.tnode AND SUBSTRING(linkid,'@([0-9]{1,20})')::bigint = sc2.fnode
INNER JOIN prj_volume.arteries USING (arterycode)
ORDER BY arterycode;
	
INSERT INTO prj_volume.artery_tcl
SELECT 	arterycode, 
		COALESCE(sub.cl_id1, sub.cl_id2) as centreline_id,
		direction,
		sideofint,
		1 as match_on_case,
		1 as artery_type
FROM 	temp_match as sub
WHERE 	sub.cl_id1 IS NOT NULL OR 
		sub.cl_id2 IS NOT NULL
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

-- STEP 1.1: For segments with the same fnode, tnode combination, pick out the one with the closest text match using Levenshtein
INSERT INTO prj_volume.artery_tcl
SELECT DISTINCT ON (arterycode) arterycode, centreline_id, apprdir as direction, sideofint, 1 as match_on_case, 1 as artery_type
FROM (SELECT arterycode, levenshtein(UPPER(lf_name), CONCAT(street1,' ',street1type)) AS strscore, A.geo_id AS centreline_id, street1, lf_name, apprdir, sideofint
		FROM 		gis.centreline A
		INNER JOIN 	(SELECT centreline_id AS geo_id FROM excluded_geoids WHERE reason = 0) B USING (geo_id) 
		INNER JOIN 	prj_volume.arteries C ON ((A.fnode = C.fnode_id AND A.tnode = C.tnode_id) OR (A.fnode = C.tnode_id AND A.tnode = C.fnode_id))
		INNER JOIN traffic.arterydata D USING (arterycode)
	) AS X
WHERE strscore = (	SELECT 		MIN(levenshtein(UPPER(lf_name), CONCAT(street1,' ',street1type)))
					FROM 		gis.centreline A
					INNER JOIN 	(SELECT centreline_id AS geo_id FROM excluded_geoids WHERE reason = 0) B USING (geo_id) 
					INNER JOIN 	prj_volume.arteries C ON ((A.fnode = C.fnode_id AND A.tnode = C.tnode_id) OR (A.fnode = C.tnode_id AND A.tnode = C.fnode_id))
					INNER JOIN 	traffic.arterydata D USING (arterycode)
					GROUP BY arterycode
					HAVING arterycode = X.arterycode)
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;
