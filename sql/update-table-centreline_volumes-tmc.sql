DROP TABLE IF EXISTS tmc_det_norm;

CREATE TEMPORARY TABLE tmc_det_norm(
	count_info_id bigint,
	count_time timestamp without time zone,
	movement text,
	volume bigint);


INSERT INTO tmc_det_norm
SELECT 	count_info_id, 
	count_time,
	unnest(array['n_cars_r','n_cars_t','n_cars_l','s_cars_r','s_cars_t','s_cars_l','e_cars_r','e_cars_t','e_cars_l','w_cars_r','w_cars_t','w_cars_l']) as movement,
	unnest(array[n_cars_r,n_cars_t,n_cars_l,s_cars_r,s_cars_t,s_cars_l,e_cars_r,e_cars_t,e_cars_l,w_cars_r,w_cars_t,w_cars_l]) as volume
FROM traffic.det;

DELETE FROM prj_volume.centreline_volumes WHERE count_type = 2;

INSERT INTO prj_volume.centreline_volumes(centreline_id, dir_bin, count_bin, volume, count_type)
SELECT	B.centreline_id,
	dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.from_dir) AS dir_bin,
	pg_catalog.date(C.count_date)+pg_catalog.time(D.count_time) AS count_bin,
	SUM(D.volume) AS volume,
	2 AS count_type
FROM prj_volume.tmc_turns A
INNER JOIN prj_volume.centreline B ON A.tcl_from_segment = B.centreline_id
INNER JOIN traffic.countinfomics C USING (arterycode)
INNER JOIN tmc_det_norm D USING (count_info_id, movement)
GROUP BY B.centreline_id,dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.from_dir),pg_catalog.date(C.count_date)+pg_catalog.time(count_time);

INSERT INTO prj_volume.centreline_volumes(centreline_id, dir_bin, count_bin, volume, count_type)
SELECT	B.centreline_id,
	dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.to_dir) AS dir_bin,
	pg_catalog.date(C.count_date)+pg_catalog.time(D.count_time) AS count_bin,
	SUM(D.volume) AS volume,
	2 AS count_type
FROM prj_volume.tmc_turns A
INNER JOIN prj_volume.centreline B ON A.tcl_to_segment = B.centreline_id
INNER JOIN traffic.countinfomics C USING (arterycode)
INNER JOIN tmc_det_norm D USING (count_info_id, movement)
GROUP BY B.centreline_id,dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.to_dir),pg_catalog.date(C.count_date)+pg_catalog.time(count_time);