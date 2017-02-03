--*****BE CAREFUL, RUNNING THIS SCRIPT RESTARTS THE MATCHING PROCESS*******
TRUNCATE prj_volume.artery_tcl;

DROP TABLE IF EXISTS excluded_geoids;
CREATE TEMPORARY TABLE excluded_geoids(centreline_id bigint,reason int);

-- excludes geoids from centreline table where either: another segment shares identical fnode/tnode
INSERT INTO excluded_geoids
SELECT centreline_id, 0 as reason
FROM
(SELECT MAX(from_intersection_id) as from_intersection_id, MIN(to_intersection_id) as to_intersection_id
FROM prj_volume.centreline cl
WHERE feature_code_desc NOT IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail')
GROUP BY (CASE WHEN from_intersection_id < to_intersection_id THEN (from_intersection_id, to_intersection_id)
			ELSE (to_intersection_id,from_intersection_id) END)
HAVING COUNT(*) > 1) as f
INNER JOIN prj_volume.centreline cl ON ((cl.from_intersection_id = f.from_intersection_id AND cl.to_intersection_id = f.to_intersection_id)
										OR (cl.from_intersection_id = f.to_intersection_id AND cl.to_intersection_id = f.from_intersection_id));

-- excludes geoids from centreline table where either:  segment type is not a road segment
INSERT INTO excluded_geoids
SELECT centreline_id, 1 as reason
FROM prj_volume.centreline
WHERE feature_code_desc IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail');

-- STEP 1: INSERT centreline_ids based on fnode, tnode links
DROP TABLE IF EXISTS temp_match CASCADE;
CREATE TEMPORARY TABLE temp_match (arterycode bigint, cl_id1 bigint, cl_id2 bigint, dist1 double precision, dist2 double precision, direction character varying, sideofint character);

INSERT INTO temp_match
SELECT ad.arterycode, sc1.centreline_id as cl_id1, sc2.centreline_id as cl_id2, ST_HausdorffDistance(loc,sc1.shape) as dist1, ST_HausdorffDistance(loc,sc2.shape) as dist2, apprdir AS direction, sideofint
FROM traffic.arterydata ad
LEFT JOIN (SELECT * FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc1 ON SUBSTRING(ad.linkid,'([0-9]{1,20})@?')::bigint = sc1.from_intersection_id AND SUBSTRING(linkid,'@([0-9]{1,20})')::bigint = sc1.to_intersection_id
LEFT JOIN (SELECT * FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc2 ON SUBSTRING(ad.linkid,'([0-9]{1,20})@?')::bigint = sc2.to_intersection_id AND SUBSTRING(linkid,'@([0-9]{1,20})')::bigint = sc2.from_intersection_id
JOIN prj_volume.arteries USING (arterycode)
ORDER BY arterycode;
	
INSERT INTO prj_volume.artery_tcl
SELECT arterycode, COALESCE(sub.cl_id1, sub.cl_id2) as centreline_id, direction, sideofint, 1 as match_on_case, 1 as artery_type
FROM temp_match as sub
WHERE (sub.cl_id1 IS NOT NULL OR sub.cl_id2 IS NOT NULL) and (sub.cl_id1 IS NULL OR sub.cl_id2 IS NULL)
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

-- STEP 1.1: Segments with the same fnode, tnode combination (ramps are not well-matched, need to be picked out and corrected by hand)
INSERT INTO prj_volume.artery_tcl
SELECT DISTINCT ON (arterycode) arterycode, centreline_id, apprdir as direction, sideofint, 1 as match_on_case, 1 as artery_type
FROM (SELECT arterycode, levenshtein(UPPER(linear_name_full), CONCAT(street1,' ',street1type)) AS strscore, centreline_id,street1, linear_name_full, apprdir, sideofint
		FROM prj_volume.centreline JOIN (SELECT centreline_id FROM excluded_geoids WHERE reason = 0) ex USING (centreline_id) 
			JOIN prj_volume.arteries ON ((from_intersection_id = fnode_id AND to_intersection_id = tnode_id) OR (from_intersection_id = tnode_id AND to_intersection_id = fnode_id))
			JOIN traffic.arterydata USING (arterycode)) AS A
WHERE strscore = (SELECT MIN(levenshtein(UPPER(linear_name_full), CONCAT(street1,' ',street1type)))
					FROM prj_volume.centreline JOIN (SELECT centreline_id FROM excluded_geoids WHERE reason = 0) ex USING (centreline_id) 
							JOIN prj_volume.arteries ON ((from_intersection_id = fnode_id AND to_intersection_id = tnode_id) OR (from_intersection_id = tnode_id AND to_intersection_id = fnode_id))
							JOIN traffic.arterydata USING (arterycode)
					GROUP BY arterycode
					HAVING arterycode = A.arterycode)
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;
