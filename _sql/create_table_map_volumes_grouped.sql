DROP TABLE prj_volume.map_volumes_grouped;
CREATE TABlE prj_volume.map_volumes_grouped AS 
(
SELECT identifier/centreline_id*group_number AS group_identifier, sum(num_days) AS num_days, avg(dir_bin) AS dir_bin, avg(count_type) AS count_type, avg(group_number) AS group_number
FROM prj_volume.map_volumes JOIN prj_volume.centreline_groups USING (centreline_id)
GROUP BY identifier/centreline_id*group_number
);