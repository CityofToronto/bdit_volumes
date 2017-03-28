-- Flag timestamps that share multiple counts
UPDATE traffic.cnt_det_clean
SET flag = 2
WHERE count_info_id IN 
	(SELECT count_info_id
	FROM traffic.countinfo JOIN traffic.cnt_det_clean USING (count_info_id)
	GROUP BY count_info_id, timecount::time, speed_class
	HAVING COUNT(count)>1);

-- Flag records that have <8h data
UPDATE traffic.cnt_det_clean
SET flag = 1
WHERE count_info_id IN
	(SELECT arterycode, count_date
	FROM traffic.cnt_det_clean JOIN traffic.countinfo USING (count_info_id)
	GROUP BY count_info_id, speed_class
	HAVING COUNT(*) < 32)

-- Flag hourly records (one entry for an hour, 0 volumes in other 15 min bins)
-- 13248 rows affected
UPDATE traffic.cnt_det_clean
SET flag = 3
WHERE count_info_id IN 
	(SELECT count_info_id
	FROM traffic.cnt_det_clean A JOIN traffic.countinfo B USING (count_info_id) 
	WHERE category_id NOT IN (3,4) 
	GROUP BY arterycode, count_date, count_info_id
	HAVING (SUM(CASE WHEN count = 0 THEN 1 ELSE 0 END)/SUM(CASE WHEN count = 0 THEN 0 ELSE 1 END))::int = 3 AND 
		(SELECT COUNT(distinct EXTRACT(hour from timecount)) FROM traffic.cnt_det_clean JOIN traffic.countinfo USING (count_info_id) WHERE arterycode = B.arterycode AND count_date = B.count_date AND count <> 0) =  SUM(CASE WHEN count = 0 THEN 0 ELSE 1 END))