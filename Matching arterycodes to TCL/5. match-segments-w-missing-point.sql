--0. excludes geoids from centreline table where either:  segment type is not a road segment
DROP TABLE IF EXISTS excluded_geoids;
CREATE TEMPORARY TABLE excluded_geoids(centreline_id bigint);

INSERT INTO excluded_geoids
SELECT centreline_id
FROM prj_volume.centreline
WHERE feature_code_desc IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail');


--1. pick out the arterycodes that have 2 nodes and a point geometry
DROP TABLE IF EXISTS  mismatched;
CREATE TEMPORARY TABLE mismatched(arterycode bigint, loc geometry, fnode_id bigint, tnode_id bigint, fx double precision, fy double precision, tx double precision, ty double precision, sideofint character, apprdir character varying, location character varying);

INSERT INTO mismatched 
SELECT arterycode, loc, fnode_id, tnode_id, fx, fy, tx, ty, sideofint, apprdir, location
FROM prj_volume.arteries JOIN traffic.arterydata using (arterycode)
WHERE tnode_id is not null and fnode_id is not null and (fx is null or tx is null) and not(fx is null and tx is null); 

DROP TABLE IF EXISTS temp_match;
CREATE TEMPORARY TABLE temp_match(arterycode bigint primary key, centreline_id bigint, direction character varying, sideofint character varying, stringmatch boolean, match_on_case smallint);

--match segments except for midblock tcs
INSERT INTO temp_match(arterycode, centreline_id, direction, sideofint, match_on_case)
SELECT arterycode, centreline_id, apprdir as direction, sideofint, 3 as match_on_case
FROM mismatched CROSS JOIN (SELECT shape, centreline_id, from_intersection_id, to_intersection_id, linear_name_full FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc 
WHERE (fnode_id = from_intersection_id OR fnode_id = to_intersection_id OR tnode_id = from_intersection_id OR tnode_id = to_intersection_id)
	AND ((sideofint = 'E' and calc_side_ew(loc,shape) = 'E' and calc_dirc(shape,0.1) = 'EW') 
			OR (sideofint = 'W' and calc_side_ew(loc,shape) = 'W' and calc_dirc(shape,0.1) = 'EW') 
			OR (sideofint = 'N' and calc_side_ns(loc,shape) = 'N' and calc_dirc(shape,0.1) = 'NS')
			OR (sideofint = 'S' and calc_side_ns(loc,shape) = 'S' and calc_dirc(shape,0.1) = 'NS'))
	AND UPPER(SPLIT_PART(location, ' ', 1)) = UPPER(SPLIT_PART(linear_name_full, ' ', 1))
	AND location not like '%TCS%'
ON CONFLICT DO NOTHING;

-- do midblock tcs separately
INSERT INTO temp_match(arterycode, centreline_id, direction, sideofint, match_on_case)
SELECT arterycode, centreline_id, apprdir as direction, sideofint, 3 as match_on_case
FROM mismatched CROSS JOIN (SELECT shape, centreline_id, from_intersection_id, to_intersection_id, linear_name_full FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc 
WHERE (fnode_id = from_intersection_id OR fnode_id = to_intersection_id OR tnode_id = from_intersection_id OR tnode_id = to_intersection_id)
	AND ((sideofint = 'E' and calc_side_ew(loc,shape) = 'W' and calc_dirc(shape,0.1) = 'EW') 
			OR (sideofint = 'W' and calc_side_ew(loc,shape) = 'E' and calc_dirc(shape,0.1) = 'EW') 
			OR (sideofint = 'N' and calc_side_ns(loc,shape) = 'S' and calc_dirc(shape,0.1) = 'NS')
			OR (sideofint = 'S' and calc_side_ns(loc,shape) = 'N' and calc_dirc(shape,0.1) = 'NS'))
	AND UPPER(SPLIT_PART(location, ' ', 1)) = UPPER(SPLIT_PART(linear_name_full, ' ', 1))
	AND location like '%TCS%'
ON CONFLICT DO NOTHING;

--2. find the segments that the points lie on in the centreline file and tag the arterycode to the centreline segment

DELETE FROM mismatched
WHERE mismatched.arterycode IN (SELECT arterycode FROM temp_match);

INSERT INTO temp_match
SELECT DISTINCT ON (arterycode) arterycode, centreline_id, apprdir as direction, sideofint, 
	(CASE 
		WHEN location LIKE '%LN %' or location LIKE '%LANEWAY%' or location LIKE '%LNWY %' or location LIKE '%LANE %' THEN NULL 
		ELSE UPPER(SPLIT_PART(location, ' ', 1)) = UPPER(SPLIT_PART(linear_name_full, ' ', 1)) 
	END) AS stringmatch, 4 AS match_on_case
FROM mismatched CROSS JOIN (SELECT shape, centreline_id, linear_name_full FROM prj_volume.centreline WHERE centreline_id NOT IN (SELECT centreline_id FROM excluded_geoids)) sc 
WHERE ST_Dwithin(loc, shape, 15) AND ((sideofint = 'E' and calc_side_ew(loc,shape) = 'E') 
				OR (sideofint = 'W' and calc_side_ew(loc,shape) = 'W') 
				OR (sideofint = 'N' and calc_side_ns(loc,shape) = 'N')
				OR (sideofint = 'S' and calc_side_ns(loc,shape) = 'S')
				OR (location ~ '.*[0-9]+.*' and apprdir in ('Eastbound', 'Westbound') AND calc_dirc(shape,0.1) = 'EW')
				OR (location ~ '.*[0-9]+.*' and apprdir in ('Southbound', 'Northbound') AND calc_dirc(shape,0.1) = 'NS'))
ORDER BY arterycode, stringmatch DESC;

INSERT INTO prj_volume.artery_tcl 
SELECT arterycode, centreline_id, direction, sideofint, match_on_case, 1 as artery_type
FROM temp_match
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

--3. insert unmatched arterycodes (directional info does not match description)
INSERT INTO prj_volume.artery_tcl(arterycode, sideofint, direction, match_on_case, artery_type)
SELECT arterycode, sideofint, apprdir as direction, 9 as match_on_case, 1 as artery_type
FROM mismatched
WHERE mismatched.arterycode NOT IN (SELECT arterycode FROM temp_match)
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET match_on_case = EXCLUDED.match_on_case;


