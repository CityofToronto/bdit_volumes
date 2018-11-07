CREATE VIEW uoft_volume.major_intersections AS
WITH street_intersections_full AS (
	SELECT B.street_name, A.centreline_id, from_intersection_id, to_intersection_id
	FROM prj_volume.centreline A
	INNER JOIN uoft_volume.major_streets B ON B.street_name = trim((A.linear_name || ' ' || coalesce(A.linear_name_type,'')))
),
street_intersections AS (
	SELECT DISTINCT street_name, intersection_id
	FROM
	((SELECT street_name, from_intersection_id AS intersection_id
	FROM street_intersections_full)
	UNION ALL
	(SELECT street_name, to_intersection_id as intersection_id
	FROM street_intersections_full)) AS X
	ORDER BY street_name, intersection_id
),
street_intersections_cl AS (
	SELECT DISTINCT street_name, intersection_id, centreline_id
	FROM
	((SELECT A.street_name, A.intersection_id, B.centreline_id
	FROM street_intersections A
	INNER JOIN street_intersections_full B ON A.intersection_id = B.from_intersection_id AND A.street_name = B.street_name)
	UNION ALL
	(SELECT A.street_name, A.intersection_id, B.centreline_id
	FROM street_intersections A
	INNER JOIN street_intersections_full B ON A.intersection_id = B.to_intersection_id AND A.street_name = B.street_name)) AS X
	ORDER BY street_name, intersection_id, centreline_id
	
)

SELECT A.intersection_id, A.street_name AS street_main, B.street_name AS street_cross, C.centreline_id_1, D.centreline_id_2
FROM street_intersections A
INNER JOIN street_intersections B ON A.intersection_id = B.intersection_id AND A.street_name <> B.street_name
LEFT JOIN (SELECT street_name, intersection_id, MIN(centreline_id) AS centreline_id_1 FROM street_intersections_cl GROUP BY street_name, intersection_id) C ON A.street_name = C.street_name AND A.intersection_id = C.intersection_id
LEFT JOIN (SELECT street_name, intersection_id, MAX(centreline_id) AS centreline_id_2 FROM street_intersections_cl GROUP BY street_name, intersection_id) D ON C.street_name = D.street_name AND C.intersection_id = D.intersection_id AND C.centreline_id_1 != D.centreline_id_2
ORDER BY A.street_name, B.street_name