SELECT *   
FROM (SELECT arterycode, count_date, feature_code_desc, linear_name_full, sum, centreline_id
	FROM (SELECT arterycode, count_date, feature_code, feature_code_desc, SUM(count), linear_name_full, centreline_id
		FROM prj_volume.cnt_det_clean JOIN traffic.countinfo USING (count_info_id) JOIN prj_volume.artery_tcl USING (arterycode) JOIN prj_volume.centreline USING (centreline_id)
		WHERE flag IS NULL
		GROUP BY arterycode, count_date, feature_code, feature_code_desc, linear_name_full, centreline_id) A ) B
	
	JOIN

	(SELECT arterycode, median(sum), avg(sum), stddev(sum), count(sum)
	FROM (SELECT arterycode, SUM(count)
		FROM prj_volume.cnt_det_clean JOIN traffic.countinfo USING (count_info_id)
		GROUP BY arterycode, count_date) C
	GROUP BY arterycode
	HAVING count(sum) > 10) D
	
	USING (arterycode)
	
	JOIN 

	(SELECT arterycode, location
	FROM traffic.arterydata) E

	USING (arterycode)
	
WHERE sum < (median - 2*stddev) or sum > (median + 2*stddev)
