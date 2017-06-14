-- Flag 1: flag irregular timestamps where a regular 15min bin does not exist for the interval
UPDATE prj_volume.det_clean
SET flag = 1
WHERE id in (
	SELECT id
	FROM prj_volume.det_clean A
	WHERE (EXTRACT(second FROM count_time) != 0 or EXTRACT(minute FROM count_time)::int % 15 != 0));

-- Flag 3: flag duplicate time bins - some should be avg some should be sum. flag for now.			
UPDATE prj_volume.det_clean
SET flag = 3
WHERE (count_info_id, count_time::time) IN (
	SELECT count_info_id, count_time::time
	FROM prj_volume.det_clean
	GROUP BY count_info_id, count_time::time
	HAVING COUNT(*) > 1);
	
-- Flag 4: flag count times with volume that are break times and the count volume is 2 stddev away from median
UPDATE prj_volume.det_clean
SET flag = 4
WHERE id IN 
	(WITH temp AS
		(SELECT id, (COALESCE(n_cars_r,0) + COALESCE(n_cars_t,0) + COALESCE(n_cars_l,0) + COALESCE(s_cars_r,0) + COALESCE(s_cars_t,0) + COALESCE(s_cars_l,0) + COALESCE(e_cars_r,0) + COALESCE(e_cars_t,0) + COALESCE(e_cars_l,0) + COALESCE(w_cars_r,0) + COALESCE(w_cars_t,0) + COALESCE(w_cars_l,0)) AS total, count_time::time, count_info_id, time15
		FROM prj_volume.det_clean
		WHERE flag is NULL)
	(SELECT id
	FROM (SELECT count_info_id, STDDEV(total) , median(total)
		FROM temp
		GROUP BY count_info_id) A JOIN temp USING (count_info_id)
	WHERE NOT(total > median - 2*stddev AND total < median + 2*stddev) AND time15 IN (39,38,49,50,51,48,61,62,63,60)));

-- Flag 5: Flag hourly records (one entry for an hour, 0 volumes in other 15 min bins)
-- two count_info_ids, 832 and 631
UPDATE prj_volume.det_clean
SET flag = 5
WHERE count_info_id IN(
	WITH temp AS
		(SELECT id, (COALESCE(n_cars_r,0) + COALESCE(n_cars_t,0) + COALESCE(n_cars_l,0) + COALESCE(s_cars_r,0) + COALESCE(s_cars_t,0) + COALESCE(s_cars_l,0) + COALESCE(e_cars_r,0) + COALESCE(e_cars_t,0) + COALESCE(e_cars_l,0) + COALESCE(w_cars_r,0) + COALESCE(w_cars_t,0) + COALESCE(w_cars_l,0)) AS total, count_time::time, count_info_id, time15
		FROM prj_volume.det_clean
		WHERE flag IS NULL)
	(SELECT count_info_id
	FROM temp A
	GROUP BY count_info_id
	HAVING (SUM(CASE WHEN total <> 0 THEN 0 ELSE 1 END)/SUM(CASE WHEN total <> 0 THEN 1 ELSE 0 END))::int = 3 AND 
	(SELECT COUNT(distinct EXTRACT(hour from B.count_time)) FROM temp B WHERE B.count_info_id = A.count_info_id AND B.total <> 0) = SUM(CASE WHEN total = 0 THEN 0 ELSE 1 END)));
/*	
--(Not used) Flag 6: flag count times that are 2/3 stddev less than median depending on the relationship between median and stddev
UPDATE prj_volume.det_clean
SET flag = 6
WHERE id IN (
	WITH temp AS(SELECT id, (COALESCE(n_cars_r,0) + COALESCE(n_cars_t,0) + COALESCE(n_cars_l,0) + COALESCE(s_cars_r,0) + COALESCE(s_cars_t,0) + COALESCE(s_cars_l,0) + COALESCE(e_cars_r,0) + COALESCE(e_cars_t,0) + 
			COALESCE(e_cars_l,0) + COALESCE(w_cars_r,0) + COALESCE(w_cars_t,0) + COALESCE(w_cars_l,0)) AS total, 
		count_time::time, count_info_id, time15
		FROM prj_volume.det_clean
		WHERE flag IS NULL)
	(SELECT id
	FROM (SELECT count_info_id, STDDEV(total) , median(total)
		FROM temp
		GROUP BY count_info_id) A JOIN temp USING (count_info_id)
	WHERE (median < stddev*4 AND total < median - 2*stddev) OR (median>stddev*4 AND total < median-3*stddev) OR (total < 3 AND median > 15)));
*/
-- Flag 6: Find random breaks and anomalies based on 1st derivative
UPDATE prj_volume.det_clean
SET flag = 6
WHERE id IN (
	WITH temp AS(SELECT id, (COALESCE(n_cars_r,0) + COALESCE(n_cars_t,0) + COALESCE(n_cars_l,0) + COALESCE(s_cars_r,0) + COALESCE(s_cars_t,0) + COALESCE(s_cars_l,0) + COALESCE(e_cars_r,0) + COALESCE(e_cars_t,0) + 
				COALESCE(e_cars_l,0) + COALESCE(w_cars_r,0) + COALESCE(w_cars_t,0) + COALESCE(w_cars_l,0)) AS total, 
			count_time::time, count_info_id, time15
			FROM prj_volume.det_clean
			WHERE flag IS NULL)
	(SELECT t2.id
	FROM temp t1, temp t2, temp t3
	WHERE t1.count_info_id = t2.count_info_id AND t2.count_info_id = t3.count_info_id AND t1.time15 = t2.time15-1 AND t2.time15=t3.time15-1 AND 
		ABS(t3.total-t2.total) BETWEEN ABS(0.5*(t2.total-t1.total)) AND ABS(1.5*(t2.total-t1.total)) AND (t3.total+t1.total)/2 > 10 AND
		((ABS(t3.total-2*t2.total+t1.total) > (t3.total+t1.total)/2 AND (t3.total+t1.total)/2 > 100) OR (ABS(t3.total-2*t2.total+t1.total) > (t3.total+t1.total)/2*3 AND (t3.total+t1.total)/2 <= 100)))
	);	

UPDATE prj_volume.det_clean
SET flag = 6
WHERE id IN(
	WITH temp2 AS (
		WITH temp AS(SELECT id, (COALESCE(n_cars_r,0) + COALESCE(n_cars_t,0) + COALESCE(n_cars_l,0) + COALESCE(s_cars_r,0) + COALESCE(s_cars_t,0) + COALESCE(s_cars_l,0) + COALESCE(e_cars_r,0) + COALESCE(e_cars_t,0) + 
					COALESCE(e_cars_l,0) + COALESCE(w_cars_r,0) + COALESCE(w_cars_t,0) + COALESCE(w_cars_l,0)) AS total, 
				count_time::time, count_info_id, time15
				FROM prj_volume.det_clean
				WHERE flag IS NULL)
		(SELECT t1.count_info_id, t1.count_time::time, t1.time15, t1.total as vol1, t2.total as vol2, t2.total-t1.total AS d
		FROM temp t1, temp t2
		WHERE t1.count_info_id = t2.count_info_id AND t1.time15 = t2.time15-1))
	( SELECT id
	FROM  (SELECT t3.count_info_id, t3.time15 AS stime15e, t4.time15 AS etime15i
		FROM temp2 t3, temp2 t4
		WHERE t3.count_info_id = t4.count_info_id AND t3.time15 = t4.time15 - 2 AND 
			-- difference in derivative is as big as the actual volume and the change consists of a sharp drop and a sharp rise
			t4.d-t3.d > (t3.vol1+t4.vol2)/2 AND abs(t3.d) BETWEEN abs(0.5*t4.d) AND abs(1.5*t4.d) AND
			-- vol is bigger than 10
			(t3.vol1+t4.vol2)/2 > 10
		UNION 

		SELECT t3.count_info_id, t3.time15 AS stime15e, t4.time15 AS etime15i
		FROM temp2 t3, temp2 t4
		WHERE t3.count_info_id = t4.count_info_id AND t3.time15 = t4.time15 - 3 AND 
			-- difference in derivative is as big as the actual volume and the change consists of a sharp drop and a sharp rise
			t4.d-t3.d > (t3.vol1+t4.vol2)/2 AND abs(t3.d) BETWEEN abs(0.5*t4.d) AND abs(1.5*t4.d) AND
			-- vol is bigger than 10
			(t3.vol1+t4.vol2)/2 > 10 
		UNION

		SELECT t3.count_info_id, t3.time15 AS stime15e, t4.time15 AS etime15i
		FROM temp2 t3, temp2 t4
		WHERE t3.count_info_id = t4.count_info_id AND t3.time15 = t4.time15 - 4 AND 
			-- difference in derivative is as big as the actual volume and the change consists of a sharp drop and a sharp rise
			t4.d-t3.d > (t3.vol1+t4.vol2)/2 AND abs(t3.d) BETWEEN abs(0.5*t4.d) AND abs(1.5*t4.d) AND
			-- vol is bigger than 10
			(t3.vol1+t4.vol2)/2 > 10
		) A0

		JOIN 

		prj_volume.det_clean A USING (count_info_id)
	WHERE A.time15 > A0.stime15e AND A.time15 <= A0.etime15i
	))