DROP TABLE IF EXISTS excluded_geoids;
CREATE TEMPORARY TABLE excluded_geoids(centreline_id bigint);

-- excludes geoids from centreline table where either: another segment shares identical fnode/tnode
INSERT INTO excluded_geoids
SELECT centreline_id
FROM
(SELECT from_intersection_id, to_intersection_id, count(*)
FROM prj_volume.centreline cl
WHERE feature_code_desc NOT IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail')
GROUP BY from_intersection_id, to_intersection_id
HAVING COUNT(*) > 1) as f
INNER JOIN prj_volume.centreline cl ON cl.from_intersection_id = f.from_intersection_id AND cl.to_intersection_id = f.to_intersection_id;

-- excludes geoids from centreline table where either:  segment type is not a road segment
INSERT INTO excluded_geoids
SELECT centreline_id
FROM prj_volume.centreline
WHERE feature_code_desc IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail');

-- truncate link table
/*TRUNCATE prj_volume.artery_tcl;

-- create records
INSERT INTO prj_volume.artery_tcl(arterycode, direction, sideofint)
SELECT ad.arterycode, ad.apprdir, ad.sideofint
FROM traffic.arterydata ad
ORDER BY ad.arterycode;
*/
-- STEP 1: INSERT centreline_ids based on fnode, tnode links
--UPDATE prj_volume.artery_tcl AS atc
--SET centreline_id = COALESCE(sub.cl_id1, sub.cl_id2)
INSERT INTO prj_volume.artery_tcl
SELECT arterycode, COALESCE(sub.cl_id1, sub.cl_id2) as centreline_id, direction, sideofint
FROM (
	SELECT ad.arterycode, sc1.centreline_id as cl_id1, sc2.centreline_id as cl_id2, apprdir AS direction, sideofint
	FROM traffic.arterydata ad
	LEFT JOIN (SELECT * FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc1 ON SUBSTRING(ad.linkid,'([0-9]{1,20})@?')::bigint = sc1.from_intersection_id AND SUBSTRING(linkid,'@([0-9]{1,20})')::bigint = sc1.to_intersection_id
	LEFT JOIN (SELECT * FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc2 ON SUBSTRING(ad.linkid,'([0-9]{1,20})@?')::bigint = sc2.to_intersection_id AND SUBSTRING(linkid,'@([0-9]{1,20})')::bigint = sc2.from_intersection_id
	ORDER BY arterycode
	) AS sub

WHERE (sub.cl_id1 IS NOT NULL OR sub.cl_id2 IS NOT NULL)-- AND sub.arterycode = atc.arterycode;
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id;

-- STEP 2: INSERT centreline_ids based on spatial match to closest segment
DROP TABLE IF EXISTS unmatched_linestrings;

CREATE TABLE unmatched_linestrings(arterycode bigint, loc geometry, direction character varying, sideofint character varying);

INSERT INTO unmatched_linestrings
SELECT arterycode, loc, apprdir AS direction, arterydata.sideofint
FROM aharpal.arteries LEFT JOIN prj_volume.artery_tcl USING (arterycode) JOIN traffic.arterydata USING (arterycode)
WHERE centreline_id IS NULL and ST_GeometryType(loc) = 'ST_LineString';

--UPDATE prj_volume.artery_tcl AS atc
--SET centreline_id = sub.centreline_id
INSERT INTO prj_volume.artery_tcl
SELECT arterycode,centreline_id, direction, sideofint
FROM (
	SELECT DISTINCT ON (ar.arterycode) ar.arterycode, cl.centreline_id, ar.direction, ar.sideofint
	FROM unmatched_linestrings ar CROSS JOIN prj_volume.centreline cl
	WHERE ST_DWithin(loc,shape,500)
	ORDER BY ar.arterycode, ST_HausdorffDistance(loc,shape)
	) AS sub
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id
--WHERE sub.arterycode = atc.arterycode;


-- STEP 3: text-based match