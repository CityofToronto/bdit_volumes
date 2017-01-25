TRUNCATE prj_volume.map_volumes;
TRUNCATE prj_volume.map_volumes_tmc;

INSERT INTO prj_volume.map_volumes
SELECT A.centreline_id, A.dir_bin, 
	A.dir_bin * dir_binary((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi()) AS opp_digitization, 
	SUM(A.volume)/COUNT(A.count_bin)*(CASE WHEN A.count_type = 1 THEN 96 ELSE 32 END)*1.0 AS daily_volume, 
	COUNT(DISTINCT A.count_bin::date) AS num_days, 
	A.count_type, A.centreline_id * A.dir_bin AS identifier
FROM prj_volume.centreline_volumes A
INNER JOIN prj_volume.centreline B USING (centreline_id)
WHERE A.count_bin >= '2010-01-01' AND A.count_bin < '2017-01-01' AND A.count_type = 1
GROUP BY A.centreline_id, A.dir_bin,  A.dir_bin * dir_binary((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi()), A.count_type
ORDER BY A.centreline_id, A.dir_bin;


INSERT INTO prj_volume.map_volumes_tmc
SELECT A.centreline_id, A.dir_bin, 
	A.dir_bin * dir_binary((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi()) AS opp_digitization, 
	SUM(A.volume)/COUNT(A.count_bin)*32*1.0 AS daily_volume, 
	COUNT(DISTINCT A.count_bin::date) AS num_days, 
	A.count_type, A.centreline_id * A.dir_bin AS identifier
FROM (SELECT centreline_id, dir_bin, count_bin, count_type, volume FROM prj_volume.centreline_volumes WHERE count_type = 2) A
INNER JOIN prj_volume.centreline B USING (centreline_id)
WHERE A.count_bin >= '2010-01-01' AND A.count_bin < '2017-01-01'
GROUP BY A.centreline_id, A.dir_bin, A.dir_bin * dir_binary((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi()), A.count_type
ORDER BY A.centreline_id, A.dir_bin;