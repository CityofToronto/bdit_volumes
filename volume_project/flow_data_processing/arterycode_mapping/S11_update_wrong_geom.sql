UPDATE prj_volume.arteries
SET loc = ST_Reverse(loc)
WHERE arterycode IN (
SELECT arterycode
	FROM (SELECT arterycode, loc, (ST_Azimuth(ST_StartPoint(loc), ST_EndPoint(loc))+0.292)*180/pi() AS locangle, 
	dir_binary(text) AS textdirbin, 
	dir_binary((ST_Azimuth(ST_StartPoint(loc), ST_EndPoint(loc))+0.292)*180/pi()) AS locdirbin,
	oneway_dir_code * dir_binary((ST_Azimuth(ST_StartPoint(shape),ST_EndPoint(shape))+0.292)*180/pi()) AS tcldirbin 
		FROM (SELECT loc, arterycode, (CASE direction WHEN 'Eastbound' THEN 90 WHEN 'Southbound' THEN 180 WHEN 'Westbound' THEN 270 WHEN 'Northbound' THEN 0 END) AS text, oneway_dir_code, shape
			FROM prj_volume.arteries JOIN prj_volume.artery_tcl USING (arterycode) JOIN prj_volume.centreline USING (centreline_id)
			WHERE ST_GeometryType(loc) = 'ST_LineString') A
		WHERE (ABS((ST_Azimuth(ST_StartPoint(loc), ST_EndPoint(loc))+0.292)*180/pi() - text) BETWEEN 135 AND 225) ) B
	WHERE tcldirbin = 0 OR tcldirbin = textdirbin);
	
UPDATE prj_volume.artery_tcl
SET direction = (CASE direction WHEN 'Eastbound' THEN 'Westbound' WHEN 'Southbound' THEN 'Northbound' WHEN 'Westbound' THEN 'Eastbound' WHEN 'Northbound' THEN 'Southbound' END)
WHERE arterycode IN (
	SELECT arterycode
		FROM (SELECT arterycode, loc, (ST_Azimuth(ST_StartPoint(loc), ST_EndPoint(loc))+0.292)*180/pi() AS locangle, 
		dir_binary(text) AS textdirbin, 
		dir_binary((ST_Azimuth(ST_StartPoint(loc), ST_EndPoint(loc))+0.292)*180/pi()) AS locdirbin,
		oneway_dir_code * dir_binary((ST_Azimuth(ST_StartPoint(shape),ST_EndPoint(shape))+0.292)*180/pi()) AS tcldirbin
			FROM (SELECT loc, arterycode, (CASE direction WHEN 'Eastbound' THEN 90 WHEN 'Southbound' THEN 180 WHEN 'Westbound' THEN 270 WHEN 'Northbound' THEN 0 END) AS text, oneway_dir_code, shape
				FROM prj_volume.arteries JOIN prj_volume.artery_tcl USING (arterycode) JOIN prj_volume.centreline USING (centreline_id)
				WHERE ST_GeometryType(loc) = 'ST_LineString') A
			WHERE (ABS((ST_Azimuth(ST_StartPoint(loc), ST_EndPoint(loc))+0.292)*180/pi() - text) BETWEEN 135 AND 225) ) B
		WHERE tcldirbin = locdirbin);