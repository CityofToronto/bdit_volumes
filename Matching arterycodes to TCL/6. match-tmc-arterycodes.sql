--0. excludes geoids from centreline table where either:  segment type is not a road segment
DROP TABLE IF EXISTS excluded_geoids;
CREATE TEMPORARY TABLE excluded_geoids(centreline_id bigint);

INSERT INTO excluded_geoids
SELECT centreline_id
FROM prj_volume.centreline
WHERE feature_code_desc IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail');

--1. match fnode and tnode

INSERT INTO prj_volume.artery_tcl as atc
SELECT arterycode, centreline_id, direction, 
	(CASE direction 
		WHEN 'NS' THEN calc_side_ns(loc,shape)
		WHEN 'EW' THEN calc_side_ew(loc,shape)
	END) AS sideofint
FROM (SELECT arterycode, centreline_id, 
	(CASE 
		WHEN fnode_id = from_intersection_id THEN calc_dirc(shape)
		ELSE calc_dirc(ST_Reverse(shape))
	END) as direction, loc, shape
	FROM (SELECT loc, fnode_id, arterycode FROM aharpal.arteries WHERE tnode_id IS NULL) ar 
		CROSS JOIN 
	     (SELECT shape, centreline_id, from_intersection_id, to_intersection_id FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc
	WHERE fnode_id = from_intersection_id or fnode_id = to_intersection_id
	ORDER BY arterycode) AS sub
ON CONFLICT DO NOTHING;

--2. match spatially
INSERT INTO prj_volume.artery_tcl as atc
SELECT arterycode, centreline_id, direction, 
	(CASE direction 
		WHEN 'NS' THEN calc_side_ns(loc,shape)
		WHEN 'EW' THEN calc_side_ew(loc,shape)
	END) AS sideofint
FROM (
	SELECT arterycode, calc_dirc(shape) as direction, centreline_id, loc, shape
	FROM (SELECT loc, arterycode FROM aharpal.arteries WHERE tnode_id is NULL and arterycode NOT IN (SELECT DISTINCT arterycode FROM prj_volume.artery_tcl)) ar --and arterycode IN (SELECT DISTINCT arterycode FROM traffic.countinfomics)) ar
		CROSS JOIN 
	     (SELECT shape, centreline_id FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc 
	WHERE ST_DWithin(loc, shape, 8) 
	ORDER BY arterycode, abs((ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape)) + 0.292)-round((ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape)) + 0.292)/(pi()/2))*(pi()/2))
	) AS sub
ON CONFLICT DO NOTHING