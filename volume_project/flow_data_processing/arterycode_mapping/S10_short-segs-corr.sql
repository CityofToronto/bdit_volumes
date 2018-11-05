DROP TABLE IF EXISTS short_segs;
CREATE TEMPORARY TABLE short_segs (arterycode bigint, buffloc geometry);

INSERT INTO short_segs
SELECT arterycode, buffloc
FROM 
	(SELECT DISTINCT	A.arterycode, A.buffloc, COUNT(DISTINCT D.centreline_id) as nleg

	FROM		(	SELECT AR.arterycode, AR.buffloc
					FROM 	(	SELECT arterycode, ST_Buffer(loc,25) as buffloc 
								FROM prj_volume.arteries WHERE tx IS NULL and ty IS NULL AND tnode_id IS NULL ORDER BY arterycode
							) AR
					INNER JOIN 	gis.centreline CL ON ST_Intersects(CL.geom, AR.buffloc)
					WHERE 		CL.fcode_desc NOT IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail')
					GROUP BY AR.arterycode, AR.buffloc
					HAVING COUNT(AR.arterycode) = 5 AND MIN(ST_Length(ST_Transform(CL.geom,82181))) < 25
				) A
	INNER JOIN	prj_volume.artery_tcl D USING (arterycode)
	WHERE		arterycode NOT IN 
			(	SELECT AR.arterycode
				FROM (SELECT arterycode, ST_Buffer(loc,25) as buffloc FROM prj_volume.arteries WHERE tx IS NULL and ty IS NULL AND tnode_id IS NULL ORDER BY arterycode) AR
				INNER JOIN gis.centreline CL ON ST_Intersects(CL.geom, AR.buffloc)
				WHERE CL.fcode_desc IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail')
				GROUP BY AR.arterycode
			)
	GROUP BY A.arterycode, A.buffloc
	) AA 

INNER JOIN 

	(	SELECT arterycode, N+S+E+W AS nvc
		FROM 	(	SELECT 	arterycode, 
							(CASE WHEN sum(n_cars_l)+ sum(n_cars_r)>0 THEN 1 ELSE 0 END) N, 
							(CASE WHEN sum(s_cars_r)+sum(s_cars_l)>0 THEN 1 ELSE 0 END) S, 
							(CASE WHEN sum(e_cars_l)+sum(e_cars_r)>0 THEN 1 ELSE 0 END) E, 
							(CASE WHEN sum(w_cars_l)+sum(w_cars_r)>0 THEN 1 ELSE 0 END) W
					FROM traffic.countinfomics 
					INNER JOIN traffic.det USING (count_info_id)
					GROUP BY arterycode) BB
	) CC USING (arterycode)

WHERE CC.nvc > AA.nleg
ORDER BY arterycode;

DROP TABLE IF EXISTS temp_match CASCADE;
CREATE TEMPORARY TABLE temp_match(arterycode bigint, centreline_id bigint, direction text, sideofint char, loc geometry, shape geometry);

INSERT INTO temp_match
SELECT arterycode, centreline_id, (CASE WHEN direction IS NULL THEN calc_dirc(shape,0.1) ELSE direction END), sideofint, loc, 
	(CASE 
		WHEN fnode_id = to_intersection_id THEN ST_Reverse(shape)
		WHEN fnode_id = from_intersection_id THEN shape
		WHEN ST_Distance(ST_StartPoint(shape), loc) > ST_Distance(ST_EndPoint(shape), loc) THEN shape
		WHEN ST_Distance(ST_StartPoint(shape), loc) < ST_Distance(ST_EndPoint(shape), loc) THEN ST_Reverse(shape) 
	END) AS shape
FROM short_segs SS 
	INNER JOIN (SELECT geo_id AS centreline_id, geom AS shape, fnode AS from_intersection_id, tnode AS to_intersection_id 
				FROM gis.centreline
				WHERE fcode_desc NOT IN ('Geostatistical line', 'Hydro Line','Creek/Tributary','Major Railway','Major Shoreline','Minor Shoreline (Land locked)','Busway','River','Walkway','Ferry Route','Trail')
				) CL ON ST_Intersects(CL.shape, SS.buffloc) 
	LEFT JOIN prj_volume.artery_tcl ACL USING (arterycode, centreline_id) 
	INNER JOIN prj_volume.arteries AR USING (arterycode)
 WHERE ST_Length(ST_Transform(CL.shape,82181)) > 25;

UPDATE temp_match
SET direction = (CASE direction	
		WHEN 'NS' THEN 'Northbound'
		WHEN 'EW' THEN 'Eastbound'
		ELSE direction
	END);
	
INSERT INTO temp_match
SELECT arterycode, centreline_id, 
		(CASE direction 
			WHEN 'Northbound' THEN 'Southbound'
			WHEN 'Eastbound' THEN 'Westbound'
		END) as direction, sideofint, loc, shape
FROM temp_match
WHERE sideofint IS NULL;


UPDATE temp_match
SET sideofint = (CASE direction 
		WHEN 'Northbound' THEN calc_side_ns(loc,shape)
		WHEN 'Southbound' THEN calc_side_ns(loc,shape)
		WHEN 'Eastbound' THEN calc_side_ew(loc,shape)
		WHEN 'Westbound' THEN calc_side_ew(loc,shape)
	END)
WHERE sideofint IS NULL;

INSERT INTO prj_volume.artery_tcl
SELECT arterycode, centreline_id, direction, sideofint, 10 as match_on_case, 2 as artery_type
FROM temp_match
WHERE arterycode IN
	(SELECT arterycode
	FROM (SELECT arterycode, COUNT(DISTINCT sideofint)
	FROM temp_match
	GROUP BY arterycode
	HAVING COUNT(DISTINCT sideofint) = 4) AS A)
ORDER BY arterycode
ON CONFLICT ON CONSTRAINT artery_tcl_pkey DO
UPDATE SET centreline_id = EXCLUDED.centreline_id, match_on_case = EXCLUDED.match_on_case;

--print out to screen ones that need to be manually corrected (already did, 31129 IS CORRECT)

SELECT DISTINCT arterycode
FROM temp_match
WHERE arterycode NOT IN
	(SELECT arterycode
	FROM (SELECT arterycode, COUNT(DISTINCT sideofint)
	FROM temp_match
	GROUP BY arterycode
	HAVING COUNT(DISTINCT sideofint) = 4) AS A)
ORDER BY arterycode;
