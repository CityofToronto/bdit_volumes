DROP TABLE IF EXISTS prj_volume.map_volumes;
DROP TABLE IF EXISTS prj_volume.map_volumes_tmc;

CREATE TABLE prj_volume.map_volumes(
	centreline_id bigint,
	dir_bin smallint,
	opp_digitization smallint, 
	daily_volume numeric,
	num_days numeric,
	count_type smallint
);

CREATE TABLE prj_volume.map_volumes_tmc(
	centreline_id bigint,
	dir_bin smallint,
	opp_digitization smallint, 
	daily_volume numeric,
	num_days numeric,
	count_type smallint
);