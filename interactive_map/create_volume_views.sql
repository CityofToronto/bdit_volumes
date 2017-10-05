CREATE VIEW prj_volume.centreline_hourly AS
SELECT centreline_id, year, time_15/4 as hh, SUM(vol_weight) * volume AS volume

FROM prj_volume.cluster_profiles 
INNER JOIN prj_volume.clusters USING (cluster)
INNER JOIN prj_volume.aadt USING (centreline_id, dir_bin)
GROUP BY centreline_id, year, hh, volume;


DROP VIEW prj_volume.centreline_hourly_group12;
CREATE OR REPLACE VIEW prj_volume.centreline_hourly_group12 AS
SELECT centreline_id, dir_bin, year, time_15/4 as hh, (SUM(vol_weight) * avg_vol)::INT AS volume

FROM prj_volume.cluster_profiles 
INNER JOIN prj_volume.clusters_group USING (cluster)
INNER JOIN prj_volume.centreline_groups_l2 ON l1_group_number = group_id
INNER JOIN prj_volume.aadt_l2 USING (l2_group_number, dir_bin)
INNER JOIN prj_volume.centreline_groups USING(dir_bin) 
WHERE group_number = group_id
GROUP BY centreline_id, dir_bin, year, hh, avg_vol;
--Test
SELECT * FROM prj_volume.centreline_hourly_group12
WHERE centreline_id IN (3154251, 
914785);


-- View: prj_volume.centreline_aadt_group12

-- DROP VIEW prj_volume.centreline_aadt_group12;

CREATE OR REPLACE VIEW prj_volume.centreline_aadt_group12 AS 
 SELECT centreline_groups.centreline_id,
    clusters_group.dir_bin,
    aadt_l2.year,
    aadt_l2.avg_vol::integer AS volume
   FROM prj_volume.clusters_group 
     JOIN prj_volume.centreline_groups_l2 ON centreline_groups_l2.l1_group_number::double precision = clusters_group.group_id
     JOIN prj_volume.aadt_l2 USING (l2_group_number, dir_bin)
     JOIN prj_volume.centreline_groups USING (dir_bin)
  WHERE centreline_groups.group_number::double precision = clusters_group.group_id;

ALTER TABLE prj_volume.centreline_aadt_group12
  OWNER TO prj_volume;
GRANT ALL ON TABLE prj_volume.centreline_aadt_group12 TO rds_superuser WITH GRANT OPTION;
GRANT ALL ON TABLE prj_volume.centreline_aadt_group12 TO prj_volume;
GRANT SELECT ON TABLE prj_volume.centreline_aadt_group12 TO bdit_humans WITH GRANT OPTION;
GRANT SELECT ON TABLE prj_volume.centreline_aadt_group12 TO tile_bot;


