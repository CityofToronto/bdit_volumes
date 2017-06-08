DROP TABLE IF EXISTS artery_tcl_directions;

CREATE TEMPORARY TABLE artery_tcl_directions (
	centreline_id integer,
	arterycode integer,
	dir_bin smallint,
	shape geometry,
	oneway_dir_code smallint);

INSERT INTO artery_tcl_directions
SELECT	A.centreline_id,
	A.arterycode,
	(CASE 
	WHEN F.fnode_id = F.tnode_id THEN -1
	WHEN ST_GeometryType(F.loc) = 'ST_Point' THEN dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(), gis.twochar_direction(E.apprdir))
	WHEN ST_GeometryType(F.loc) = 'ST_LineString' THEN dir_binary_rel((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),(ST_Azimuth(ST_StartPoint(F.loc), ST_EndPoint(F.loc))+0.292)*180/pi())
	-- if no condition is met, exception needs to be raised about added special situation
	END) AS dir_bin,
	B.shape, B.oneway_dir_code
FROM prj_volume.artery_tcl A
	INNER JOIN prj_volume.centreline B USING (centreline_id)
	INNER JOIN traffic.arterydata E USING (arterycode)
	INNER JOIN prj_volume.arteries F USING (arterycode)
WHERE A.artery_type = 1 AND B.feature_code <= 201500
ORDER BY A.centreline_id, A.arterycode) A;

UPDATE artery_tcl_directions
SET dir_bin = 1
WHERE (centreline_id = 108379 and arterycode = 3526) or (centreline_id = 14063455 and arterycode = 27469) or (centreline_id = 14307786 and arterycode = 33159)
or (centreline_id = 20051038 and arterycode = 29562) or (centreline_id = 20051039 and arterycode = 29557) or (centreline_id = 20059734 and arterycode = 30546) 
or (centreline_id = 20089656 and arterycode = 36190) or (centreline_id = 30002424 and arterycode = 24782) or (centreline_id = 30011544 and arterycode = 3285)
or (centreline_id = 30028880 and arterycode = 27172) or (centreline_id = 30039432 and arterycode = 35537) or (centreline_id = 30064524 and arterycode = 35346)
or (centreline_id = 30073636 and arterycode = 34008) or (centreline_id = 30074130 and arterycode = 33025) or (centreline_id = 910701 and arterycode = 23140); 

UPDATE artery_tcl_directions
SET dir_bin = -1
WHERE (centreline_id = 14063455 and arterycode = 27468) or (centreline_id = 14307786 and arterycode = 33160) or (centreline_id = 20059734 and arterycode = 30547) 
or (centreline_id = 20089656 and arterycode = 36191) or (centreline_id = 30002424 and arterycode = 24781) or (centreline_id = 30028880 and arterycode = 27171) 
or (centreline_id = 30039432 and arterycode = 35538) or (centreline_id = 30065648 and arterycode = 35347) or (centreline_id = 30073636 and arterycode = 34009)
or (centreline_id = 30074130 and arterycode = 33024);

DELETE FROM artery_tcl_directions
WHERE oneway_dir_code != 0 AND oneway_dir_code * dir_binary((ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape))+0.292)*180/pi()) != dir_bin;

DELETE FROM prj_volume.centreline_volumes WHERE count_type = 1;

INSERT INTO prj_volume.centreline_volumes(centreline_id, dir_bin, count_bin, volume, count_type, speed_class, vehicle_class)
SELECT	A.centreline_id,
	A.dir_bin,
	(C.timecount::time + B.count_date) AS count_bin,
	C.count as volume,
	1 as count_type,
	(CASE WHEN C.category_id = 4 THEN C.speed_class ELSE NULL END) AS speed_class,
	(CASE WHEN C.category_id = 3 THEN C.speed_class ELSE NULL END) AS vehicle_class
FROM artery_tcl_directions A
INNER JOIN traffic.countinfo B USING (arterycode)
INNER JOIN prj_volume.cnt_det_clean C USING (count_info_id)
WHERE A.dir_bin IN (1,-1)
ORDER BY A.centreline_id, A.arterycode;

DROP TABLE artery_tcl_directions;

