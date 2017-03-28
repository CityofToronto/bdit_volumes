-- Create new instance of table for operations
--Query returned successfully: 111875806 rows affected, 07:34 minutes execution time.

TRUNCATE traffic.cnt_det_clean;

INSERT INTO traffic.cnt_det_clean
SELECT *
FROM traffic.cnt_det;


-- Fix shifted time bins
--Query returned successfully: 41030103 rows affected, 01:07:3604 hours execution time.

DROP TABLE IF EXISTS shifted_time;

CREATE TEMPORARY TABLE shifted_time(count_info_id bigint);

INSERT INTO shifted_time
SELECT count_info_id
FROM traffic.cnt_det_clean
WHERE EXTRACT(second FROM timecount) = 59 OR EXTRACT(minute FROM timecount) = 59;

UPDATE traffic.cnt_det_clean cdc
SET timecount = sub.timecount
FROM	(SELECT (CASE 
		WHEN EXTRACT(SECOND FROM timecount) = 59 THEN timecount - INTERVAL '14 minutes 59 seconds'
		WHEN EXTRACT(MINUTE FROM timecount) = 59 THEN timecount - INTERVAL '14 minutes'
		ELSE timecount - INTERVAL '15 minutes'
		END) AS timecount, id
	FROM traffic.cnt_det_clean
	WHERE count_info_id IN (SELECT count_info_id FROM shifted_time)) AS sub
WHERE cdc.id = sub.id;

-- Delete entries where there's no volume at all in one count_info_id
-- 412 count_info_id
-- Query returned successfully: 338204 rows affected, 06:48 minutes execution time.

DELETE FROM traffic.cnt_det_clean
WHERE count_info_id IN (SELECT count_info_id
			FROM traffic.cnt_det_clean
			GROUP BY count_info_id
			HAVING SUM(count) = 0);


-- Remove Duplicate Entries (same volume, same time, same location for the entire day)
-- 649 count_info_id
DROP TABLE IF EXISTS duplicate;
 
CREATE TEMPORARY TABLE duplicate(id bigint, count_info_id bigint, count bigint, timecount timestamp without time zone, speed_class int);

INSERT INTO duplicate
SELECT DISTINCT ON (arterycode, count_date, timecount::time) id, count_info_id, count, timecount, speed_class
FROM traffic.countinfo JOIN traffic.cnt_det_clean USING (count_info_id)
WHERE (arterycode, count_date) IN
	(SELECT arterycode, count_date
	FROM (SELECT arterycode,count_date,timecount::time
		 FROM traffic.countinfo JOIN traffic.cnt_det_clean USING (count_info_id)
		 GROUP BY arterycode, count_date, timecount::time
		 HAVING AVG(count) = MAX(count) AND COUNT(count)>1) AS A
	GROUP BY arterycode, count_date
	HAVING count(*) = (SELECT COUNT(DISTINCT timecount::time) FROM traffic.cnt_det_clean B JOIN traffic.countinfo C USING (count_info_id) WHERE C.arterycode = A.arterycode AND C.count_date = A.count_date))
ORDER BY arterycode, count_date, timecount::time, count_info_id;

DELETE FROM traffic.cnt_det_clean 
WHERE (count_info_id) IN (SELECT count_info_id FROM (SELECT arterycode, count_date FROM duplicate JOIN traffic.countinfo USING (count_info_id)) A JOIN traffic.countinfo USING (arterycode, count_date));

INSERT INTO traffic.cnt_det_clean
SELECT *
FROM duplicate;

-- Remove Entries where volume between 8am and 12am is 0
-- AND (whole day count is present OR less than 8h count)
-- 41577 rows affected
DELETE FROM traffic.cnt_det_clean
WHERE (count_info_id) IN 
	(SELECT count_info_id
	FROM traffic.countinfo B INNER JOIN traffic.cnt_det_clean C USING (count_info_id)
	GROUP BY count_info_id
	HAVING SUM(CASE WHEN EXTRACT(HOUR FROM timecount) >= 8 THEN count ELSE 0 END) = 0 AND (MOD(COUNT(*),96) = 0 OR COUNT(*) < 32))