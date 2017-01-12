DROP TABLE IF EXISTS prj_volume.centreline_volumes;

CREATE TABLE prj_volume.centreline_volumes (
	volume_id serial NOT NULL,
	centreline_id int NOT NULL,
	dir bit NOT NULL, --0 for "NE", 1 for "SW"
	count_bin timestamp without time zone,
	volume smallint,
	count_type smallint
	);

INSERT INTO prj_volume.centreline_volumes( centreline_id, dir, count_bin, volume, count_type)
SELECT	A.centreline_id

FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.centreline B USING (centreline_id)



