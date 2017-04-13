DROP TABLE IF EXISTS prj_volume.vol_profile_tcl_summary;

CREATE TABLE prj_volume.vol_profile_tcl_summary AS (
	SELECT centreline_id, dir_bin, timecount, AVG(vol) as vol
	FROM prj_volume.atr_volumes
	WHERE count_date>='20100101'
	GROUP BY centreline_id, dir_bin, timecount);

ALTER TABLE prj_volume.vol_profile_tcl_summary ADD COLUMN vol_weight double precision;

DROP TABLE IF EXISTS sum_vol;

CREATE TEMPORARY TABLE sum_vol AS (
	SELECT centreline_id, dir_bin, SUM(vol)
	FROM prj_volume.vol_profile_tcl_summary B
	GROUP BY centreline_id, dir_bin
	HAVING SUM(vol)>24
	);
	
DROP  TABLE IF EXISTS temp_table;
CREATE TEMPORARY TABLE temp_table AS (
	SELECT centreline_id, dir_bin, timecount, vol, vol/sum AS vol_weight
	FROM prj_volume.vol_profile_tcl_summary JOIN sum_vol USING (centreline_id, dir_bin)
);

TRUNCATE TABLE prj_volume.vol_profile_tcl_summary;

INSERT INTO prj_volume.vol_profile_tcl_summary
SELECT *
FROM temp_table;

DROP TABLE temp_table;
DROP TABLE sum_vol;