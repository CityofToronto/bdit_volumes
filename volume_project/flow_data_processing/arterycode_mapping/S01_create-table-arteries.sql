TRUNCATE prj_volume.arteries;

INSERT INTO prj_volume.arteries (arterycode, fnode_id, tnode_id, fx, fy, tx, ty, source)
SELECT a.arterycode, a.fnode_id, a.tnode_id, fx, fy, tx, ty, 
	(CASE WHEN fx is not null or tx is not null THEN 'flow'
		ELSE NULL
		END) AS source
FROM
(SELECT arterycode, SUBSTRING(linkid,'([0-9]{1,20})@?')::bigint as fnode_id, SUBSTRING(linkid,'@([0-9]{1,20})')::bigint as tnode_id
FROM traffic.arterydata) a
LEFT JOIN (SELECT link_id::bigint AS fnode_id, x_coord as fx, y_coord as fy FROM traffic.node) f USING (fnode_id)
LEFT JOIN (SELECT link_id::bigint AS tnode_id, x_coord as tx, y_coord as ty FROM traffic.node) t USING (tnode_id);

-- FROM NODE, X and Y
UPDATE 	prj_volume.arteries a
SET 	fx = x, fy = y, source = 'tcl'
FROM 	gis.centreline_intersection c
WHERE 	a.fnode_id IS NOT NULL AND (a.fx IS NULL OR a.fy IS NULL) AND c.int_id = a.fnode_id;

-- TO NODE, X and Y
UPDATE prj_volume.arteries a
SET 	tx = x, ty = y, source = 'tcl'
FROM 	gis.centreline_intersection c 
WHERE 	a.tnode_id IS NOT NULL AND (a.tx IS NULL OR a.ty IS NULL) AND c.int_id = a.tnode_id;