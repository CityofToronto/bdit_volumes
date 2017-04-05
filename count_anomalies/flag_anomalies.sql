-- Flag timestamps that share multiple counts
-- 1445051 rows affected, 10:10 minutes execution time.
UPDATE prj_volume.cnt_det_clean
SET flag = 2
WHERE count_info_id IN 
	(SELECT count_info_id
	FROM traffic.countinfo
	WHERE (arterycode, count_date) IN
		(SELECT DISTINCT arterycode, count_date
		FROM traffic.countinfo JOIN prj_volume.cnt_det_clean USING (count_info_id)
		GROUP BY arterycode, count_date, timecount::time, speed_class
		HAVING COUNT(count)>1))
		
-- Flag records that have <8h data
-- 1833 rows affected
UPDATE prj_volume.cnt_det_clean
SET flag = 1
WHERE count_info_id IN
	(SELECT arterycode, count_date
	FROM prj_volume.cnt_det_clean JOIN traffic.countinfo USING (count_info_id)
	GROUP BY count_info_id, speed_class
	HAVING COUNT(*) < 32)

-- Flag hourly records (one entry for an hour, 0 volumes in other 15 min bins)
-- 13248 rows affected
UPDATE prj_volume.cnt_det_clean
SET flag = 3
WHERE count_info_id IN 
	(SELECT count_info_id
	FROM prj_volume.cnt_det_clean A JOIN traffic.countinfo B USING (count_info_id) 
	WHERE category_id NOT IN (3,4) 
	GROUP BY arterycode, count_date, count_info_id
	HAVING (SUM(CASE WHEN count = 0 THEN 1 ELSE 0 END)/SUM(CASE WHEN count = 0 THEN 0 ELSE 1 END))::int = 3 AND 
		(SELECT COUNT(distinct EXTRACT(hour from timecount)) FROM prj_volume.cnt_det_clean JOIN traffic.countinfo USING (count_info_id) WHERE arterycode = B.arterycode AND count_date = B.count_date AND count <> 0) =  SUM(CASE WHEN count = 0 THEN 0 ELSE 1 END))
		
-- Flag daily volumes (exceeds specified cap for the road class)
-- 39440 rows affected
UPDATE prj_volume.cnt_det_clean
SET flag = 4
WHERE count_info_id IN 
	(SELECT count_info_id
	FROM (SELECT count_info_id, feature_code, feature_code_desc, SUM(count), linear_name_full, centreline_id,
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
		GROUP BY count_info_id, feature_code, feature_code_desc, linear_name_full, centreline_id) A 
	WHERE sum > cap) 
	
-- Flag abnormal daily volumes (+/- 2 stdevs from median)
-- 3869643 rows affected, 16:53 minutes execution time.
UPDATE prj_volume.cnt_det_clean
SET flag = 5
WHERE count_info_id IN 
	(SELECT count_info_id   
	FROM (SELECT arterycode, count_info_id, SUM(count)
		FROM prj_volume.cnt_det_clean JOIN traffic.countinfo USING (count_info_id) 
		WHERE flag IS NULL
		GROUP BY count_info_id, arterycode) A 
		
		JOIN

		(SELECT arterycode, median(sum), stddev(sum)
		FROM (SELECT count_info_id, arterycode, SUM(count)
			FROM prj_volume.cnt_det_clean JOIN traffic.countinfo USING (count_info_id)
			GROUP BY count_info_id, arterycode) C
		GROUP BY arterycode
		HAVING count(sum) > 10) D
		
		USING (arterycode)

	WHERE sum < (median - 2*stddev) OR sum > (median + 2*stddev))
