SELECT	A.centreline_id,
	--D.timecount AS count_bin,
	--D.count as volume,
	1 as count_type,
	A.arterycode,
	E.apprdir,
	(ST_Azimuth(ST_StartPoint(B.shape), ST_EndPoint(B.shape))+0.292)*180/pi() AS deg,
	B.linear_name,
	E.location
		
FROM prj_volume.artery_tcl A
INNER JOIN prj_volume.centreline B USING (centreline_id)
--INNER JOIN traffic.countinfo C USING (arterycode)
--INNER JOIN traffic.cnt_det D USING (count_info_id)
INNER JOIN traffic.arterydata E USING (arterycode)

WHERE A.artery_type = 1
ORDER BY A.centreline_id, A.arterycode
