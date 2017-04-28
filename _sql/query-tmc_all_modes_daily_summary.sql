DROP TABLE IF EXISTS tmc_det_norm;

CREATE TEMPORARY TABLE tmc_det_norm(
	count_info_id bigint,
	count_time timestamp without time zone,
	movement text,
	volume bigint,
	vehicle text);


INSERT INTO tmc_det_norm
SELECT 	count_info_id, 
	count_time,
	unnest(array['n_cars_r','n_cars_t','n_cars_l','s_cars_r','s_cars_t','s_cars_l','e_cars_r','e_cars_t','e_cars_l','w_cars_r','w_cars_t','w_cars_l','n_truck_r','n_truck_t','n_truck_l','s_truck_r','s_truck_t','s_truck_l','e_truck_r','e_truck_t','e_truck_l','w_truck_r','w_truck_t','w_truck_l','n_bus_r','n_bus_t','n_bus_l','s_bus_r','s_bus_t','s_bus_l','e_bus_r','e_bus_t','e_bus_l','w_bus_r','w_bus_t','w_bus_l','n_peds','s_peds','e_peds','w_peds','n_bike','s_bike','e_bike','w_bike']) as movement,
	unnest(array[n_cars_r,n_cars_t,n_cars_l,s_cars_r,s_cars_t,s_cars_l,e_cars_r,e_cars_t,e_cars_l,w_cars_r,w_cars_t,w_cars_l,n_truck_r,n_truck_t,n_truck_l,s_truck_r,s_truck_t,s_truck_l,e_truck_r,e_truck_t,e_truck_l,w_truck_r,w_truck_t,w_truck_l,n_bus_r,n_bus_t,n_bus_l,s_bus_r,s_bus_t,s_bus_l,e_bus_r,e_bus_t,e_bus_l,w_bus_r,w_bus_t,w_bus_l,n_peds,s_peds,e_peds,w_peds,n_bike,s_bike,e_bike,w_bike]) as volume,
	unnest(array['cars','cars','cars','cars','cars','cars','cars','cars','cars','cars','cars','cars','truck','truck','truck','truck','truck','truck','truck','truck','truck','truck','truck','truck','bus','bus','bus','bus','bus','bus','bus','bus','bus','bus','bus','bus','peds','peds','peds','peds','bike','bike','bike','bike']) as vehicle
FROM prj_volume.det_clean
WHERE flag IS NULL;

TRUNCATE prj_volume.tmc_daily_summary;

INSERT INTO prj_volume.tmc_daily_summary (arterycode, centreline_id, dir_bin, count_bin, cars, truck, bus, peds, bike)
SELECT *
FROM 
(SELECT arterycode, centreline_id, dir_bin, count_bin, cars, truck, bus, NULL as peds, NULL as bike
FROM	crosstab('SELECT array[arterycode,centreline_id,dir_bin,count_bin::date - date ''1900-01-01''] AS row_name, arterycode, centreline_id, dir_bin, count_bin::date, vehicle, SUM(volume) as volume
	FROM (
		SELECT	C.arterycode, B.centreline_id,
			dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.from_dir) AS dir_bin,
			pg_catalog.date(C.count_date)+pg_catalog.time(D.count_time) AS count_bin,
			SUM(D.volume) AS volume,
			D.vehicle
		FROM prj_volume.tmc_turns A
			INNER JOIN prj_volume.centreline B ON A.tcl_from_segment = B.centreline_id
			INNER JOIN traffic.countinfomics C USING (arterycode)
			INNER JOIN tmc_det_norm D USING (count_info_id, movement)
		WHERE (oneway_dir_code = 0 OR dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.from_dir) = dir_binary((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi())*oneway_dir_code) AND D.vehicle IN (''cars'',''truck'',''bus'')
		GROUP BY C.arterycode, B.centreline_id,dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.from_dir),pg_catalog.date(C.count_date)+pg_catalog.time(count_time), D.vehicle
		
		UNION
		
		SELECT	C.arterycode, B.centreline_id,
			dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.to_dir) AS dir_bin,
			pg_catalog.date(C.count_date)+pg_catalog.time(D.count_time) AS count_bin,
			SUM(D.volume) AS volume,
			D.vehicle
		FROM prj_volume.tmc_turns A
			INNER JOIN prj_volume.centreline B ON A.tcl_to_segment = B.centreline_id
			INNER JOIN traffic.countinfomics C USING (arterycode)
			INNER JOIN tmc_det_norm D USING (count_info_id, movement)
		WHERE (oneway_dir_code = 0 OR dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.to_dir) = dir_binary((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi())*oneway_dir_code) AND D.vehicle IN (''cars'',''truck'',''bus'')
		GROUP BY C.arterycode, B.centreline_id,dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.to_dir),pg_catalog.date(C.count_date)+pg_catalog.time(count_time), D.vehicle) C  
	WHERE (EXTRACT(HOUR FROM count_bin) * 4 + (EXTRACT(MINUTE FROM count_bin) / 15))::int IN (30,31,32,33,34,35,36,37,40,41,42,43,44,45,46,47,52,53,54,55,56,57,58,59,64,65,66,67,68,69,70,71)     
	GROUP BY arterycode, centreline_id, dir_bin, count_bin::date, vehicle
	HAVING COUNT(*) = 32',

	$$VALUES ('cars'),('truck'),('bus')$$)
AS ct(row_name bigint[], arterycode bigint, centreline_id bigint, dir_bin smallint, count_bin date, cars int, truck int, bus int)
UNION
SELECT arterycode, centreline_id, dir_bin, count_bin, NULL AS cars, NULL AS truck, NULL AS bus, peds, bike
FROM	crosstab('SELECT array[arterycode,centreline_id,dir_bin,count_bin::date - date ''1900-01-01''] AS row_name, arterycode, centreline_id, dir_bin, count_bin::date, vehicle, SUM(volume) as volume
	FROM (
		SELECT	C.arterycode, B.centreline_id,
			dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.from_dir) AS dir_bin,
			pg_catalog.date(C.count_date)+pg_catalog.time(D.count_time) AS count_bin,
			SUM(D.volume) AS volume,
			D.vehicle
		FROM prj_volume.tmc_turns A
			INNER JOIN prj_volume.centreline B ON A.tcl_from_segment = B.centreline_id
			INNER JOIN traffic.countinfomics C USING (arterycode)
			INNER JOIN tmc_det_norm D USING (count_info_id, movement)
		WHERE (oneway_dir_code = 0 OR dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.from_dir) = dir_binary((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi())*oneway_dir_code) AND D.vehicle IN (''peds'',''bike'')
		GROUP BY C.arterycode, B.centreline_id,dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.from_dir),pg_catalog.date(C.count_date)+pg_catalog.time(count_time), D.vehicle
		
		UNION
		
		SELECT	C.arterycode, B.centreline_id,
			dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.to_dir) AS dir_bin,
			pg_catalog.date(C.count_date)+pg_catalog.time(D.count_time) AS count_bin,
			SUM(D.volume) AS volume,
			D.vehicle
		FROM prj_volume.tmc_turns A
			INNER JOIN prj_volume.centreline B ON A.tcl_to_segment = B.centreline_id
			INNER JOIN traffic.countinfomics C USING (arterycode)
			INNER JOIN tmc_det_norm D USING (count_info_id, movement)
		WHERE (oneway_dir_code = 0 OR dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.to_dir) = dir_binary((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi())*oneway_dir_code) AND D.vehicle IN (''peds'',''bike'')
		GROUP BY C.arterycode, B.centreline_id,dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),A.to_dir),pg_catalog.date(C.count_date)+pg_catalog.time(count_time), D.vehicle) C  
	WHERE (EXTRACT(HOUR FROM count_bin) * 4 + (EXTRACT(MINUTE FROM count_bin) / 15))::int IN (30,31,32,33,34,35,36,37,40,41,42,43,44,45,46,47,52,53,54,55,56,57,58,59,64,65,66,67,68,69,70,71)     
	GROUP BY arterycode, centreline_id, dir_bin, count_bin::date, vehicle
	HAVING COUNT(*) = 32',

	$$VALUES ('peds'),('bike')$$)
AS ct(row_name bigint[], arterycode bigint, centreline_id bigint, dir_bin smallint, count_bin date, peds int, bike int)) A;

DELETE FROM prj_volume.tmc_daily_summary
WHERE arterycode IN (
	SELECT DISTINCT arterycode
	FROM prj_volume.tmc_daily_summary
	WHERE cars = 0);
