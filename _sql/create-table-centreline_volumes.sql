DROP TABLE IF EXISTS prj_volume.centreline_volumes;

CREATE TABLE prj_volume.centreline_volumes (
	volume_id serial NOT NULL,
	centreline_id int NOT NULL,
	dir_bin smallint NOT NULL, -- 1 for "NE", -1 for "SW"
	count_bin timestamp without time zone,
	volume smallint,
	count_type smallint
	);




