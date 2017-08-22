CREATE TABLE dolejarz.volume_map_grouped_l2 AS (
SELECT AVG(volume) as avg_vol, year, dir_bin, fcode_desc, l2_group_number, geom
FROM(
SELECT aadt.dir_bin, aadt.year, aadt.volume, aadt.group_number, centreline_groups.centreline_id, centreline_groups_geom.feature_code_desc as fcode_desc, centreline_groups_l2.l2_group_number, grouped_segments.geom
        FROM prj_volume.aadt
	INNER JOIN prj_volume.centreline_groups_l2 ON group_number = l1_group_number
	INNER JOIN prj_volume.centreline_groups_geom USING (group_number)
        INNER JOIN prj_volume.centreline_groups USING (group_number)
        INNER JOIN dolejarz.grouped_segments USING (l2_group_number)) as a
GROUP BY l2_group_number, year, dir_bin, fcode_desc, geom)