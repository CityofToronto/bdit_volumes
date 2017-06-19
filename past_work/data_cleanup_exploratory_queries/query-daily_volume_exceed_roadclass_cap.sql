SELECT *   
FROM (SELECT arterycode, count_date, feature_code_desc, linear_name_full, sum, centreline_id
	FROM (SELECT arterycode, count_date, feature_code, feature_code_desc, SUM(count), linear_name_full, centreline_id,
			(CASE feature_code_desc
				WHEN 'Expressway' THEN 120000
				WHEN 'Expressway Ramp' THEN 61050
				WHEN 'Major Arterial' THEN 70000
				WHEN 'Major Arterial Ramp' THEN 25000
				WHEN 'Minor Arterial' THEN 22750
				WHEN 'Collector' THEN 20000
				WHEN 'Local' THEN 9000
				WHEN 'Laneway' THEN 600
			END) AS cap
		FROM prj_volume.cnt_det_clean JOIN traffic.countinfo USING (count_info_id) JOIN prj_volume.artery_tcl USING (arterycode) JOIN prj_volume.centreline USING (centreline_id)
		WHERE flag IS NULL
		GROUP BY arterycode, count_date, feature_code, feature_code_desc, linear_name_full, centreline_id) A 
	WHERE sum > cap) B
	
	JOIN

	(SELECT arterycode, median(sum), avg(sum), stddev(sum), count(sum)
	FROM (SELECT arterycode, SUM(count)
		FROM prj_volume.cnt_det_clean JOIN traffic.countinfo USING (count_info_id)
		GROUP BY arterycode, count_date) C
	GROUP BY arterycode) D
	
	USING (arterycode)
	
	JOIN 

	(SELECT arterycode, location
	FROM traffic.arterydata) E
 
	USING (arterycode)  