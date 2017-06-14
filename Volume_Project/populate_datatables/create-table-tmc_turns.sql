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
	unnest(array['n_cars_r','n_truck_r','n_bus_r']) AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'SB' AS from_dir,
	'WB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'N' AND A.direction = 'Southbound' AND B.sideofint = 'W' AND B.direction = 'Westbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['n_cars_t','n_truck_t','n_bus_t']) AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'SB' AS from_dir,
	'SB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'N' AND A.direction = 'Southbound' AND B.sideofint = 'S' AND B.direction = 'Southbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['n_cars_l','n_truck_l','n_bus_l']) AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'SB' AS from_dir,
	'EB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'N' AND A.direction = 'Southbound' AND B.sideofint = 'E' AND B.direction = 'Eastbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['s_cars_r','s_truck_r','s_bus_r']) AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'NB' AS from_dir,
	'EB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'S' AND A.direction = 'Northbound' AND B.sideofint = 'E' AND B.direction = 'Eastbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['s_cars_t','s_truck_t','s_bus_t']) AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'NB' AS from_dir,
	'NB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'S' AND A.direction = 'Northbound' AND B.sideofint = 'N' AND B.direction = 'Northbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['s_cars_l','s_truck_l','s_bus_l']) AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'NB' AS from_dir,
	'WB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'S' AND A.direction = 'Northbound' AND B.sideofint = 'W' AND B.direction = 'Westbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['e_cars_r','e_truck_r','e_bus_r']) AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'WB' AS from_dir,
	'NB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'E' AND A.direction = 'Westbound' AND B.sideofint = 'N' AND B.direction = 'Northbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['e_cars_t','e_truck_t','e_bus_t']) AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'WB' AS from_dir,
	'WB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'E' AND A.direction = 'Westbound' AND B.sideofint = 'W' AND B.direction = 'Westbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['e_cars_l','e_truck_l','e_bus_l']) AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'WB' AS from_dir,
	'SB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'E' AND A.direction = 'Westbound' AND B.sideofint = 'S' AND B.direction = 'Southbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['w_cars_r','w_truck_r','w_bus_r']) AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'EB' AS from_dir,
	'SB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'W' AND A.direction = 'Eastbound' AND B.sideofint = 'S' AND B.direction = 'Southbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['w_cars_t','w_truck_t','w_bus_t']) AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'EB' AS from_dir,
	'EB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'W' AND A.direction = 'Eastbound' AND B.sideofint = 'E' AND B.direction = 'Eastbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['w_cars_l','w_truck_l','w_bus_l']) AS movement,
	A.centreline_id AS tcl_from_segment,
	B.centreline_id AS tcl_to_segment,
	'EB' AS from_dir,
	'NB' AS to_dir
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.artery_tcl B USING (arterycode)
WHERE A.sideofint = 'W' AND A.direction = 'Eastbound' AND B.sideofint = 'N' AND B.direction = 'Northbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['n_peds','n_bike']) AS movement,
	A.centreline_id AS tcl_from_segment,
	NULL AS tcl_to_segment,
	'N' AS from_dir,
	NULL AS to_dir
FROM prj_volume.artery_tcl A
WHERE A.sideofint = 'N' and A.direction = 'Northbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['s_peds','s_bike']) AS movement,
	A.centreline_id AS tcl_from_segment,
	NULL AS tcl_to_segment,
	'S' AS from_dir,
	NULL AS to_dir
FROM prj_volume.artery_tcl A
WHERE A.sideofint = 'S' and A.direction = 'Southbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['w_peds','w_bike']) AS movement,
	A.centreline_id AS tcl_from_segment,
	NULL AS tcl_to_segment,
	'W' AS from_dir,
	NULL AS to_dir
FROM prj_volume.artery_tcl A
WHERE A.sideofint = 'W' and A.direction = 'Westbound';

INSERT INTO tmc_turns_temp(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
SELECT	A.arterycode,
	unnest(array['e_peds','e_bike']) AS movement,
	A.centreline_id AS tcl_from_segment,
	NULL AS tcl_to_segment,
	'E' AS from_dir,
	NULL AS to_dir
FROM prj_volume.artery_tcl A
WHERE A.sideofint = 'E' and A.direction = 'Eastbound';


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
			ELSE 4
		END;

DROP TABLE tmc_turns_temp;

