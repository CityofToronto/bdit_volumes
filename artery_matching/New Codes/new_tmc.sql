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
FROM prj_volume.arteries JOIN prj_volume.new_arterydata USING (arterycode)
WHERE newcode AND count_type IN ('R','P') and arterycode NOT IN (SELECT DISTINCT arterycode FROM prj_volume.artery_tcl) and EXISTS(SELECT 1 FROM prj_volume.centreline WHERE fnode_id = from_intersection_id or fnode_id = to_intersection_id);

INSERT INTO tmc_codes 
SELECT fnode_id as node_id, loc, arterycode, FALSE as found_in_tcl
FROM prj_volume.arteries JOIN prj_volume.new_arterydata USING (arterycode)
WHERE newcode AND count_type IN ('R','P') and arterycode NOT IN (SELECT DISTINCT arterycode FROM prj_volume.artery_tcl) and NOT EXISTS(SELECT 1 FROM prj_volume.centreline WHERE fnode_id = from_intersection_id or fnode_id = to_intersection_id);

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

--1.1 find all tcl segments attached to intersection and assign direction if it's a major corridor
DROP TABLE IF EXISTS temp_match CASCADE;
CREATE TEMPORARY TABLE temp_match(arterycode bigint, centreline_id bigint, loc geometry, dir text, shape geometry, found_in_tcl boolean, linear_name_label text);

INSERT INTO temp_match
SELECT arterycode, centreline_id, loc, 
	NULL as dir,
	(CASE 
		WHEN node_id = from_intersection_id THEN shape
		ELSE ST_Reverse(shape)
	END) as shape, found_in_tcl, linear_name_label
FROM tmc_codes CROSS JOIN 
	     (SELECT shape, centreline_id, from_intersection_id, to_intersection_id, linear_name_label FROM prj_volume.centreline WHERE feature_code <=201800) sc
WHERE node_id = from_intersection_id or node_id = to_intersection_id;

UPDATE temp_match 
SET dir = 
	(CASE 
		WHEN (left(linear_name_label, -1) in (SELECT left(linear_name_label, -1) FROM prj_volume.corr_dir WHERE dir in ('NB','SB'))) and not (((ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape, 0.1)) + 0.292) BETWEEN pi()*0.4 and 0.6*pi()) OR ((ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape, 0.1)) + 0.292)  BETWEEN 1.4*pi() and 1.6*pi())) THEN 'NS'
		WHEN (left(linear_name_label, -1) in (SELECT left(linear_name_label, -1) FROM prj_volume.corr_dir WHERE dir in ('EB','WB'))) and not (((ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape, 0.1)) + 0.292) <0.1*pi()) OR ((ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape, 0.1)) + 0.292)  BETWEEN 0.9*pi() and 1.1*pi()) OR ((ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape, 0.1)) + 0.292) > 1.9*pi())) THEN 'EW'
		ELSE NULL
	END);

CREATE VIEW ns_corr AS
SELECT arterycode, count(*) AS num
FROM temp_match
WHERE dir = 'NS'
GROUP BY arterycode;

CREATE VIEW ew_corr AS
SELECT arterycode, count(*) AS num
FROM temp_match
WHERE dir  = 'EW'
GROUP BY arterycode;

--1.2 assign direction to arterycode containing major corridors
UPDATE temp_match 
SET dir = 'NS'
WHERE dir is null and (SELECT num FROM ew_corr WHERE temp_match.arterycode = ew_corr.arterycode) = 2;

UPDATE temp_match 
SET dir = 'EW'
WHERE dir is null and (SELECT num FROM ns_corr WHERE temp_match.arterycode = ns_corr.arterycode) = 2;

-- reset direction if two major corridors of the same direction meet
UPDATE temp_match
SET dir = NULL
WHERE arterycode in ((SELECT arterycode FROM ew_corr WHERE num > 2) UNION (SELECT arterycode FROM ns_corr WHERE num > 2));

--1.3 assign direction to arterycode not containing major corridors
UPDATE temp_match
SET dir = calc_dirc(shape,0.1)
WHERE dir is NULL; --(arterycode not in (SELECT arterycode FROM ns_corr) and arterycode not in (SELECT arterycode FROM ew_corr));

--1.4 assign sideofint and insert
INSERT INTO prj_volume.artery_tcl(arterycode, centreline_id, direction, sideofint, match_on_case, artery_type)
SELECT DISTINCT ON (arterycode, dir, sideofint)
	arterycode, centreline_id, 
	(CASE dir	
		WHEN 'NS' THEN 'Northbound'
		WHEN 'EW' THEN 'Eastbound'
	END) AS direction,
	(CASE dir 
		WHEN 'NS' THEN calc_side_ns(loc,shape)
		WHEN 'EW' THEN calc_side_ew(loc,shape)
	END) AS sideofint, 
	(CASE found_in_tcl 
		WHEN TRUE THEN 6
		ELSE 7
	END) AS match_on_case,
	2 as artery_type
FROM temp_match 
ORDER BY arterycode, dir, sideofint, abs((ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape, 0.1)) + 0.292)-round((ST_Azimuth(ST_StartPoint(shape), ST_LineInterpolatePoint(shape, 0.1)) + 0.292)/(pi()/2))*(pi()/2))
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

-- Insert the other direction (SB/WB)
INSERT INTO prj_volume.artery_tcl(arterycode, centreline_id, direction, sideofint, match_on_case, artery_type)
SELECT arterycode, centreline_id, 
		(CASE direction 
			WHEN 'Northbound' THEN 'Southbound'
			WHEN 'Eastbound' THEN 'Westbound'
		END) as direction, artery_tcl.sideofint, match_on_case, artery_type
FROM prj_volume.artery_tcl JOIN prj_volume.new_arterydata USING (arterycode)
WHERE newcode AND match_on_case in (6,7)
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id;

-- Correct for RAMP TMC
DELETE FROM prj_volume.artery_tcl
WHERE arterycode in (38082,38083,38084,38085);

INSERT INTO prj_volume.artery_tcl(arterycode, centreline_id, direction, sideofint, match_on_case, artery_type) VALUES
(38082,30079400,'Westbound','W',10,2),(38083,30054171,'Eastbound','E',10,2),(38084,12334089,'Southbound','S',10,2), (38085, 12334091, 'Westbound','W',10,2);

-- Checkpoint: check if there's any RAMP TMC and if anything is not matched.
SELECT *
FROM prj_volume.new_arterydata
WHERE count_type in ('R','P') AND NOT EXISTS (SELECT 1 FROM prj_volume.artery_tcl WHERE new_arterydata.arterycode=artery_tcl.arterycode);