-- Mark new and changed arterycodes
UPDATE prj_volume.new_arterydata
SET newcode = True
WHERE arterycode NOT IN (SELECT arterycode FROM prj_volume.arteries);

UPDATE prj_volume.new_arterydata
SET newcode = False
WHERE arterycode IN (SELECT arterycode FROM prj_volume.arteries);

INSERT INTO prj_volume.arteries (arterycode, fnode_id, tnode_id, fx, fy, tx, ty, source)
SELECT a.arterycode, a.fnode_id, a.tnode_id, fx, fy, tx, ty, 
	(CASE WHEN fx is not null or tx is not null THEN 'flow'
		ELSE NULL
		END) AS source
FROM
(SELECT arterycode, SUBSTRING(linkid,'([0-9]{1,20})@?')::bigint as fnode_id, SUBSTRING(linkid,'@([0-9]{1,20})')::bigint as tnode_id
FROM prj_volume.new_arterydata
WHERE newcode) a
LEFT JOIN (SELECT link_id::bigint AS fnode_id, x_coord as fx, y_coord as fy FROM traffic.node) f USING (fnode_id)
LEFT JOIN (SELECT link_id::bigint AS tnode_id, x_coord as tx, y_coord as ty FROM traffic.node) t USING (tnode_id);

UPDATE 	prj_volume.arteries a
SET 	fx = ST_X(ST_StartPoint(c.shape)), fy = ST_Y(ST_StartPoint(c.shape)), source = 'tcl'
FROM 	prj_volume.centreline c 
WHERE 	a.fnode_id IS NOT NULL AND (a.fx IS NULL OR a.fy IS NULL) AND c.from_intersection_id = a.fnode_id;

UPDATE prj_volume.arteries a
SET 	tx = ST_X(ST_EndPoint(c.shape)), ty = ST_Y(ST_EndPoint(c.shape)), source = 'tcl'
FROM 	prj_volume.centreline c 
WHERE 	a.tnode_id IS NOT NULL AND (a.tx IS NULL OR a.ty IS NULL) AND c.to_intersection_id = a.tnode_id;

UPDATE 	prj_volume.arteries a
SET 	fx = ST_X(ST_EndPoint(c.shape)), fy = ST_Y(ST_EndPoint(c.shape)), source = 'tcl'
FROM 	prj_volume.centreline c 
WHERE 	a.fnode_id IS NOT NULL AND (a.fx IS NULL OR a.fy IS NULL) AND c.to_intersection_id = a.fnode_id;

UPDATE 	prj_volume.arteries a
SET 	tx = ST_X(ST_StartPoint(c.shape)), ty = ST_Y(ST_StartPoint(c.shape)), source = 'tcl'
FROM 	prj_volume.centreline c 
WHERE 	a.tnode_id IS NOT NULL AND (a.tx IS NULL OR a.ty IS NULL) AND c.from_intersection_id = a.tnode_id;

UPDATE prj_volume.arteries
SET loc = ST_MakeLine(ST_SetSRID(ST_Point(fx, fy),82181)::geometry, ST_SetSRID(ST_Point(tx, ty),82181)::geometry)
WHERE fx IS NOT NULL AND tx IS NOT NULL AND loc IS NULL;

UPDATE prj_volume.arteries
SET loc = ST_SetSRID(ST_Point(fx, fy),82181)::geometry
WHERE fx IS NOT NULL AND tx IS NULL AND loc IS NULL;

-- Checkpoint: New arterycodes with no/incorrect geometry
SELECT *
FROM prj_volume.arteries JOIN prj_volume.new_arterydata USING (arterycode)
WHERE loc IS NULL OR (tnode_id IS NOT NULL AND tx IS NULL);