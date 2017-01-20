DROP TABLE IF EXISTS artery_tcl_directions;

CREATE TEMPORARY TABLE artery_tcl_directions (
	centreline_id integer,
	arterycode integer,
	dir_bin smallint);

INSERT INTO artery_tcl_directions
SELECT	A.centreline_id,
	A.arterycode,
	dir_binary_rel((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),(ST_Azimuth(ST_StartPoint(F.loc), ST_EndPoint(F.loc))+0.292)*180/pi()) AS dir_bin
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.centreline B USING (centreline_id)
INNER JOIN traffic.arterydata E USING (arterycode)
INNER JOIN prj_volume.arteries F USING (arterycode)
WHERE A.artery_type = 1
ORDER BY A.centreline_id, A.arterycode;

TRUNCATE prj_volume.centreline_volumes;

INSERT INTO prj_volume.centreline_volumes(centreline_id, dir_bin, count_bin, volume, count_type)
SELECT	A.centreline_id,
	A.dir_bin,
	C.timecount AS count_bin,
	C.count as volume,
	1 as count_type
FROM artery_tcl_directions A
INNER JOIN traffic.countinfo B USING (arterycode)
INNER JOIN traffic.cnt_det C USING (count_info_id)
WHERE A.dir_bin IN (1,-1)
ORDER BY A.centreline_id, A.arterycode;

DROP TABLE artery_tcl_directions;
