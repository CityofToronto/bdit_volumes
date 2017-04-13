DROP TABLE IF EXISTS artery_tcl_directions;

CREATE TEMPORARY TABLE artery_tcl_directions (
	centreline_id integer,
	arterycode integer,
	dir_bin smallint);

INSERT INTO artery_tcl_directions
SELECT	A.centreline_id,
	A.arterycode,
	(CASE 
	WHEN F.fnode_id = F.tnode_id THEN 1
	WHEN ST_GeometryType(F.loc) = 'ST_Point' THEN dir_binary_tmc((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(), gis.twochar_direction(E.apprdir))
	WHEN ST_GeometryType(F.loc) = 'ST_LineString' THEN dir_binary_rel((ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi(),(ST_Azimuth(ST_StartPoint(F.loc), ST_EndPoint(F.loc))+0.292)*180/pi())
	WHEN A.direction in ('Eastbound','Northbound') THEN 1
	WHEN A.direction in ('Westbound','Southbound') THEN -1
	END) AS dir_bin
FROM prj_volume.artery_tcl A
	INNER JOIN prj_volume.centreline B USING (centreline_id)
	INNER JOIN traffic.arterydata E USING (arterycode)
	INNER JOIN prj_volume.arteries F USING (arterycode)
WHERE A.artery_type = 1 
ORDER BY A.centreline_id, A.arterycode;

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

DROP TABLE IF EXISTS prj_volume.atr_volumes;

CREATE TABLE prj_volume.atr_volumes AS (
	SELECT count_info_id, arterycode, count_date, timecount::time, SUM(count) AS vol, dir_bin, centreline_id
	FROM prj_volume.cnt_det_clean JOIN traffic.countinfo USING (count_info_id) JOIN artery_tcl_directions USING (arterycode)
	WHERE flag IS NULL and EXTRACT(dow from count_date) NOT IN (0,6) 
	GROUP BY count_info_id, arterycode, count_date, timecount::time, dir_bin, centreline_id);
		
ALTER TABLE prj_volume.atr_volumes ADD COLUMN vol_weight double precision;
ALTER TABLE prj_volume.atr_volumes ADD COLUMN complete_day boolean;

DROP TABLE IF EXISTS sum_vol;

CREATE TEMPORARY TABLE sum_vol AS (	
	(SELECT count_info_id, SUM(vol) AS sumvol, (COUNT(*)=96) AS complete_day
	FROM prj_volume.atr_volumes
	GROUP BY count_info_id));
	
DROP TABLE IF EXISTS temp;

CREATE TEMPORARY TABLE temp AS (
	SELECT count_info_id, arterycode, count_date, timecount, vol, dir_bin, centreline_id, 
		(CASE sum_vol.complete_day
		WHEN TRUE THEN vol/sumvol 
		ELSE NULL 
		END) AS vol_weight, sum_vol.complete_day
	FROM prj_volume.atr_volumes JOIN sum_vol USING (count_info_id));

TRUNCATE TABLE prj_volume.atr_volumes;

INSERT INTO prj_volume.atr_volumes
SELECT *
FROM temp;

DROP TABLE temp;
DROP TABLE artery_tcl_directions;

CREATE INDEX atr_volumes_count_info_id_idx
  ON prj_volume.atr_volumes
  USING btree
  (count_info_id);
  
