DROP TABLE IF EXISTS prj_volume.tmc_turns;

CREATE TEMPORARY TABLE tmc_turns_temp (
	turn_id serial NOT NULL,
	arterycode int not null,
	movement text,
	tcl_from_segment int,
	tcl_to_segment int,
	from_dir text,
	to_dir text
	);


CREATE TABLE prj_volume.tmc_turns (
	turn_id serial NOT NULL,
	arterycode int not null,
	movement text,
	tcl_from_segment int,
	tcl_to_segment int,
	from_dir text,
	to_dir text
	);

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	'n_cars_r' AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'SB' AS from_dir,
	'WB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'N' AND A.direction = 'Southbound' AND B.sideofint = 'W' AND B.direction = 'Westbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	'n_cars_t' AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'SB' AS from_dir,
	'SB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'N' AND A.direction = 'Southbound' AND B.sideofint = 'S' AND B.direction = 'Southbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	'n_cars_l' AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'SB' AS from_dir,
	'EB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'N' AND A.direction = 'Southbound' AND B.sideofint = 'E' AND B.direction = 'Eastbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	's_cars_r' AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'NB' AS from_dir,
	'EB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'S' AND A.direction = 'Northbound' AND B.sideofint = 'E' AND B.direction = 'Eastbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	's_cars_t' AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'NB' AS from_dir,
	'NB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'S' AND A.direction = 'Northbound' AND B.sideofint = 'N' AND B.direction = 'Northbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	's_cars_l' AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'NB' AS from_dir,
	'WB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'S' AND A.direction = 'Northbound' AND B.sideofint = 'W' AND B.direction = 'Westbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	'e_cars_r' AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'WB' AS from_dir,
	'NB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'E' AND A.direction = 'Westbound' AND B.sideofint = 'N' AND B.direction = 'Northbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	'e_cars_t' AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'WB' AS from_dir,
	'WB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'E' AND A.direction = 'Westbound' AND B.sideofint = 'W' AND B.direction = 'Westbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	'e_cars_l' AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'WB' AS from_dir,
	'SB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'E' AND A.direction = 'Westbound' AND B.sideofint = 'S' AND B.direction = 'Southbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	'w_cars_r' AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'EB' AS from_dir,
	'SB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'W' AND A.direction = 'Eastbound' AND B.sideofint = 'S' AND B.direction = 'Southbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	'w_cars_t' AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'EB' AS from_dir,
	'EB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'W' AND A.direction = 'Eastbound' AND B.sideofint = 'E' AND B.direction = 'Eastbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	'w_cars_l' AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'EB' AS from_dir,
	'NB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'W' AND A.direction = 'Eastbound' AND B.sideofint = 'N' AND B.direction = 'Northbound';


INSERT INTO prj_volume.tmc_turns(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT A.arterycode, A.movement, A.tcl_from_segment, A.tcl_to_segment, A.from_dir, A.to_dir
FROM tmc_turns_temp A
ORDER BY 	arterycode, 
		CASE 	WHEN LEFT(A.movement,1) = 'n' THEN 1
			WHEN LEFT(A.movement,1) = 's' THEN 2
			WHEN LEFT(A.movement,1) = 'e' THEN 3
			WHEN LEFT(A.movement,1) = 'w' THEN 4
		END,
		CASE 	WHEN RIGHT(A.movement,1) = 'r' THEN 1
			WHEN RIGHT(A.movement,1) = 't' THEN 2
			WHEN RIGHT(A.movement,1) = 'l' THEN 3
		END;

DROP TABLE tmc_turns_temp;

