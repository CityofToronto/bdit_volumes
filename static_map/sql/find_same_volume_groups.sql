SELECT *
FROM (	SELECT r1.group_number, r2.group_number, prj_volume.same_volume_minor_arterial_group(r1.group_number, r2.group_number) AS same_volume
	FROM prj_volume.centreline_groups_geom r1 JOIN prj_volume.centreline_groups_geom r2 ON (r1.from_intersection = r2.from_intersection OR r1.from_intersection = r2.to_intersection OR r1.to_intersection = r2.from_intersection OR r1.to_intersection = r2.to_intersection)
	WHERE r1.group_number != r2.group_number and r1.feature_code % 100 = 0 and  r2.feature_code % 100 = 0) A
WHERE same_volume = True
