DROP TABLE IF EXISTS prj_volume.map_clusters;

CREATE TABLE prj_volume.map_clusters(
	centreline_id bigint,
	dir_bin smallint,
	opp_digitization smallint, 
	cluster smallint,
	identifier bigint
);


INSERT INTO prj_volume.map_clusters
SELECT A.centreline_id, A.dir_bin, 
	(CASE B.oneway_dir_code 
	WHEN 0 THEN A.dir_bin * dir_binary((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi())
	ELSE B.oneway_dir_code
	END) AS opp_digitization,
	A.cluster,
	A.centreline_id * A.dir_bin AS identifier
FROM prj_volume.clusters A
INNER JOIN prj_volume.centreline B USING (centreline_id)
ORDER BY A.centreline_id, A.dir_bin;
