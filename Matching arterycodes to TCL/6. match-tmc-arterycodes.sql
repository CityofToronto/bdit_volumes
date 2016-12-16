--0.1 excludes geoids from centreline table where either:  segment type is not a road segment
DROP TABLE IF EXISTS excluded_geoids;
CREATE TEMPORARY TABLE excluded_geoids(centreline_id bigint);

INSERT INTO excluded_geoids
SELECT centreline_id
FROM prj_volume.centreline
WHERE feature_code_desc IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail');

--0.2 generate a table of centreline nodes

DROP TABLE IF EXISTS centreline_nodes;
CREATE TEMPORARY TABLE centreline_nodes(node_id bigint primary key, shape geometry);

INSERT INTO centreline_nodes
SELECT from_intersection_id, ST_StartPoint(shape)
FROM prj_volume.centreline
ON CONFLICT ON CONSTRAINT centreline_nodes_pkey DO NOTHING;

INSERT INTO centreline_nodes
SELECT to_intersection_id, ST_EndPoint(shape)
FROM prj_volume.centreline
ON CONFLICT ON CONSTRAINT centreline_nodes_pkey DO NOTHING;

--0.3 generate a table of codes to be matched in this step
DROP TABLE IF EXISTS tmc_codes;
CREATE TEMPORARY TABLE tmc_codes(node_id bigint, loc geometry, arterycode bigint, found_in_tcl boolean);

INSERT INTO tmc_codes 
SELECT fnode_id as node_id, loc, arterycode, TRUE as found_in_tcl
FROM prj_volume.arteries 
WHERE tnode_id IS NULL and arterycode NOT IN (SELECT DISTINCT arterycode FROM prj_volume.artery_tcl) and EXISTS(SELECT 1 FROM prj_volume.centreline WHERE fnode_id = from_intersection_id or fnode_id = to_intersection_id);

INSERT INTO tmc_codes 
SELECT fnode_id as node_id, loc, arterycode, FALSE as found_in_tcl
FROM prj_volume.arteries 
WHERE tnode_id IS NULL and arterycode NOT IN (SELECT DISTINCT arterycode FROM prj_volume.artery_tcl) and NOT EXISTS(SELECT 1 FROM prj_volume.centreline WHERE fnode_id = from_intersection_id or fnode_id = to_intersection_id);

--0.4 snap node onto centreline nodes if node_id does not exist in centreline
UPDATE tmc_codes AS tc
SET node_id = sub.node_id
FROM 
	(SELECT DISTINCT ON (arterycode) arterycode, cn.node_id
	FROM (SELECT loc, arterycode FROM tmc_codes WHERE NOT found_in_tcl) an
		CROSS JOIN 
			centreline_nodes cn
	WHERE ST_DWithin(loc,shape,30)
	ORDER BY arterycode, ST_Distance(loc,shape)) as sub
WHERE tc.arterycode = sub.arterycode;

--1. match fnode and tnode
INSERT INTO prj_volume.artery_tcl
SELECT DISTINCT ON (arterycode, direction, sideofint)
	arterycode, centreline_id, direction, 
	(CASE direction 
		WHEN 'NS' THEN calc_side_ns(loc,shape)
		WHEN 'EW' THEN calc_side_ew(loc,shape)
	END) AS sideofint, 
	(CASE found_in_tcl 
		WHEN TRUE THEN 6
		ELSE 7
	END) AS match_on_case
FROM (SELECT arterycode, centreline_id, 
	(CASE 
		WHEN node_id = from_intersection_id THEN calc_dirc(shape)
		ELSE calc_dirc(ST_Reverse(shape))
	END) as direction, loc, 
	(CASE 
		WHEN node_id = from_intersection_id THEN shape
		ELSE ST_Reverse(shape)
	END) as shape, found_in_tcl
	FROM tmc_codes CROSS JOIN 
	     (SELECT shape, centreline_id, from_intersection_id, to_intersection_id FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc
	WHERE node_id = from_intersection_id or node_id = to_intersection_id) AS sub
ORDER BY arterycode, direction, sideofint, abs((ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape, 0.1)) + 0.292)-round((ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape, 0.1)) + 0.292)/(pi()/2))*(pi()/2))
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

--2. match spatially (not an intersection)
INSERT INTO prj_volume.artery_tcl as atc
SELECT DISTINCT ON (arterycode, direction, sideofint)
	arterycode, centreline_id, direction,
	(CASE direction 
		WHEN 'NS' THEN calc_side_ns(loc,shape)
		WHEN 'EW' THEN calc_side_ew(loc,shape)
	END) AS sideofint, 8 as match_on_case
FROM (
	SELECT arterycode, calc_dirc(shape) as direction, centreline_id, loc, shape
	FROM (SELECT loc, arterycode FROM prj_volume.arteries WHERE tnode_id is NULL and arterycode NOT IN (SELECT DISTINCT arterycode FROM prj_volume.artery_tcl)) ar
		CROSS JOIN 
	     (SELECT shape, centreline_id FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc 
	WHERE ST_DWithin(loc, shape, 15)
	ORDER BY arterycode, abs((ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape)) + 0.292)-round((ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape)) + 0.292)/(pi()/2))*(pi()/2))
	) AS sub
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

--3. insert failed instances (not within 30m to any intersection and not within 15m to any segment)
INSERT INTO prj_volume.artery_tcl(arterycode, sideofint, direction, match_on_case)
SELECT arterycode, sideofint, apprdir as direction, 9 as match_on_case
FROM prj_volume.arteries JOIN traffic.arterydata USING (arterycode)
WHERE arterycode NOT IN (SELECT DISTINCT arterycode FROM prj_volume.artery_tcl)
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET match_on_case = EXCLUDED.match_on_case;