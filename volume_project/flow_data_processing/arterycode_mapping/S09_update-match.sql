--***TRUNCATE AND IMPORT to prj_volume.artery_tcl_manual_corr BEFORE RUNNING THIS SCRIPT***

--1. update centreline_mapping in prj_volume.artery_tcl
DELETE FROM prj_volume.artery_tcl
WHERE arterycode in (SELECT DISTINCT arterycode FROM prj_volume.artery_tcl_manual_corr);

INSERT INTO prj_volume.artery_tcl
SELECT arterycode, 
	(CASE a.centreline_id
	WHEN 0 THEN NULL
	ELSE a.centreline_id
	END) AS centreline_id, a.direction, a.sideofint, a.match_on_case, artery_type
FROM 		prj_volume.artery_tcl_manual_corr a 
INNER JOIN 	traffic.arterydata d USING (arterycode)
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

--2. update geometry and node_ids in prj_volume.arteries
UPDATE 	prj_volume.arteries ar
SET 	fnode_id = sub.from_intersection_id, 
		tnode_id = sub.to_intersection_id,
		loc = shape
FROM 	(	SELECT arterycode, B.fnode AS from_intersection_id, B.tnode AS to_intersection_id, geom AS shape
			FROM prj_volume.artery_tcl_manual_corr A
			INNER JOIN gis.centreline B ON A.centreline_id = B.geo_id
			WHERE was_match_on_case = 1 and match_on_case = 10
	) AS sub
WHERE ar.arterycode = sub.arterycode;