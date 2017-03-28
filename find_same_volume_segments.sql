DROP TABLE IF EXISTS roads;

CREATE TEMPORARY TABLE roads (centreline_id bigint, shape geometry, from_intersection_id bigint, to_intersection_id bigint);

INSERT INTO roads
SELECT centreline_id, shape,from_intersection_id, to_intersection_id
FROM prj_volume.centreline
WHERE feature_code<202000;

SELECT r1.centreline_id, r2.centreline_id, same_volume(r1.centreline_id, r2.centreline_id) AS same_volume
FROM roads r1 JOIN roads r2 ON (r1.from_intersection_id = r2.from_intersection_id OR r1.from_intersection_id = r2.to_intersection_id OR r1.to_intersection_id = r2.from_intersection_id OR r1.to_intersection_id = r2.to_intersection_id)
WHERE r1.centreline_id != r2.centreline_id 