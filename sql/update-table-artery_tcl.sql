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
TRUNCATE prj_volume.artery_tcl;

-- create records
INSERT INTO prj_volume.artery_tcl(arterycode, direction)
SELECT ad.arterycode, ad.apprdir
FROM traffic.arterydata ad
ORDER BY ad.arterycode;

-- STEP 1: INSERT centreline_ids based on fnode, tnode links
UPDATE prj_volume.artery_tcl AS atc
SET centreline_id = COALESCE(sub.cl_id1, sub.cl_id2)

FROM (
	SELECT ad.arterycode, sc1.centreline_id as cl_id1, sc2.centreline_id as cl_id2
	FROM traffic.arterydata ad
	LEFT JOIN (SELECT * FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc1 ON SUBSTRING(ad.linkid,'([0-9]{1,20})@?')::bigint = sc1.from_intersection_id AND SUBSTRING(linkid,'@([0-9]{1,20})')::bigint = sc1.to_intersection_id
	LEFT JOIN (SELECT * FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc2 ON SUBSTRING(ad.linkid,'([0-9]{1,20})@?')::bigint = sc2.to_intersection_id AND SUBSTRING(linkid,'@([0-9]{1,20})')::bigint = sc2.from_intersection_id
	ORDER BY arterycode
	) AS sub

WHERE (sub.cl_id1 IS NOT NULL OR sub.cl_id2 IS NOT NULL) AND sub.arterycode = atc.arterycode;

-- STEP 2: INSERT centreline_ids based on spatial match to closest segment

-- STEP 3: text-based match