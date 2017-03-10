TRUNCATE aharpal.arteries;

INSERT INTO aharpal.arteries (arterycode, fnode_id, tnode_id, fx, fy, tx, ty)
SELECT a.arterycode, a.fnode_id, a.tnode_id, fx, fy, tx, ty
FROM
(SELECT arterycode, SUBSTRING(linkid,'([0-9]{1,20})@?')::bigint as fnode_id, SUBSTRING(linkid,'@([0-9]{1,20})')::bigint as tnode_id
FROM traffic.arterydata) a
LEFT JOIN (SELECT link_id::bigint AS fnode_id, x_coord as fx, y_coord as fy FROM traffic.node) f USING (fnode_id)
LEFT JOIN (SELECT link_id::bigint AS tnode_id, x_coord as tx, y_coord as ty FROM traffic.node) t USING (tnode_id);

UPDATE 	aharpal.arteries a
SET 	fx = c.fx, fy = c.fy
FROM 	aharpal.cl_attr c 
WHERE 	a.fnode_id IS NOT NULL AND (a.fx IS NULL OR a.fy IS NULL) AND c.from_inter = a.fnode_id;

UPDATE aharpal.arteries a
SET 	tx = c.tx, ty = c.ty
FROM 	aharpal.cl_attr c 
WHERE 	a.tnode_id IS NOT NULL AND (a.tx IS NULL OR a.ty IS NULL) AND c.to_inter = a.tnode_id;

UPDATE 	aharpal.arteries a
SET 	fx = c.tx, fy = c.ty
FROM 	aharpal.cl_attr c 
WHERE 	a.fnode_id IS NOT NULL AND (a.fx IS NULL OR a.fy IS NULL) AND c.to_inter = a.fnode_id;

UPDATE 	aharpal.arteries a
SET 	tx = c.fx, ty = c.fy
FROM 	aharpal.cl_attr c 
WHERE 	a.tnode_id IS NOT NULL AND (a.tx IS NULL OR a.ty IS NULL) AND c.from_inter = a.tnode_id;