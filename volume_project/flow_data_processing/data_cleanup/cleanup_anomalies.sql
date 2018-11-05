-- Create new instance of table for operations
-- Query returned successfully: 111875806 rows affected, 07:34 minutes execution time.

DROP TABLE IF EXISTS temp_cnt_det;
CREATE TEMPORARY TABLE temp_cnt_det (LIKE prj_volume.cnt_det_clean);

INSERT INTO temp_cnt_det
SELECT id, count_info_id, count, timecount, speed_class, NULL AS flag
FROM traffic.cnt_det
WHERE count_info_id NOT IN (SELECT DISTINCT count_info_id FROM prj_volume.cnt_det_clean);

CREATE INDEX temp_cnt_det_count_info_id_idx
  ON temp_cnt_det
  USING btree
  (count_info_id);

-- Delete NULL values (time bin exists but count is NULL)
-- Query returned successfully: 15352 rows affected

DELETE FROM temp_cnt_det
WHERE count IS NULL;

-- Fix shifted time bins
-- Query returned successfully: 41030103 rows affected, 01:07:3604 hours execution time.

DROP TABLE IF EXISTS shifted_time;

CREATE TEMPORARY TABLE shifted_time(count_info_id bigint);

INSERT INTO shifted_time
SELECT count_info_id
FROM temp_cnt_det
WHERE EXTRACT(second FROM timecount) = 59 OR EXTRACT(minute FROM timecount) = 59;

UPDATE temp_cnt_det cdc
SET timecount = sub.timecount
FROM	(SELECT (CASE 
		WHEN EXTRACT(SECOND FROM timecount) = 59 THEN timecount - INTERVAL '14 minutes 59 seconds'
		WHEN EXTRACT(MINUTE FROM timecount) = 59 THEN timecount - INTERVAL '14 minutes'
		ELSE timecount - INTERVAL '15 minutes'
		END) AS timecount, id
	FROM temp_cnt_det
	WHERE count_info_id IN (SELECT count_info_id FROM shifted_time)) AS sub
WHERE cdc.id = sub.id;

-- Delete entries where there's no volume at all in one count_info_id
-- 412 count_info_id
-- Query returned successfully: 338204 rows affected, 06:48 minutes execution time.

DELETE FROM temp_cnt_det
WHERE count_info_id IN (SELECT count_info_id
			FROM temp_cnt_det
			GROUP BY count_info_id
			HAVING SUM(count) = 0);

-- Fix redundant speed_class
-- SET speed_class to NULL when it is not a speed count. (some counts have speed_class 0 that gets picked up by group by later)
-- Query returned successfully: 14026175 rows affected

UPDATE temp_cnt_det
SET speed_class = NULL
WHERE (count_info_id, timecount::time) IN 
	(SELECT count_info_id, timecount::time
	FROM temp_cnt_det
	GROUP BY count_info_id, timecount::time
	HAVING SUM(speed_class) = 0);
	
-- Remove Duplicate Entries (same volume, same time, same location for the entire day)
-- This query removes entries where one single profile exists (within a single count_info_id or in two different count_info_ids)
-- Does not deal with multiple loading with different profiles and one is duplicated
-- Ex. arterycode 848 and date 20011212 - loaded 3 times, 2 of them the same, 1 different -> not dealt with here
-- 649 count_info_id

DROP TABLE IF EXISTS duplicate;
 
CREATE TEMPORARY TABLE duplicate(id bigint, count_info_id bigint, count bigint, timecount timestamp without time zone, speed_class int);

INSERT INTO duplicate
SELECT DISTINCT ON (arterycode, count_date, timecount::time) id, count_info_id, count, timecount, speed_class
FROM traffic.countinfo JOIN temp_cnt_det USING (count_info_id)
WHERE (arterycode, count_date) IN
	(SELECT arterycode, count_date
	FROM (SELECT arterycode,count_date,timecount::time
		 FROM traffic.countinfo JOIN temp_cnt_det USING (count_info_id)
		 GROUP BY arterycode, count_date, timecount::time
		 HAVING AVG(count) = MAX(count) AND COUNT(count)>1) AS A
	GROUP BY arterycode, count_date
	HAVING count(*) = (SELECT COUNT(DISTINCT timecount::time) FROM temp_cnt_det B JOIN traffic.countinfo C USING (count_info_id) WHERE C.arterycode = A.arterycode AND C.count_date = A.count_date))
ORDER BY arterycode, count_date, timecount::time, count_info_id;

DELETE FROM temp_cnt_det 
WHERE (count_info_id) IN (SELECT count_info_id FROM (SELECT arterycode, count_date FROM duplicate JOIN traffic.countinfo USING (count_info_id)) A JOIN traffic.countinfo USING (arterycode, count_date));

INSERT INTO temp_cnt_det
SELECT *
FROM duplicate;


-- Delete manually, three cases exists: 1. shifted profile, cannot delete a random one 2. identical profile, delete a random one 3. wrong counts discovered from other processing.
-- 672 rows deleted

DELETE FROM temp_cnt_det
WHERE count_info_id IN (136298, 298873, 179128, 136297, 719350, 719364, 721374, 301314, 301318, 301320, 301322, 301289, 301291, 301295, 301297, 301275);

-- Remove Entries where volume between 8am and 12am is 0
-- AND (whole day count is present OR less than 8h count)
-- 41577 rows affected

DELETE FROM temp_cnt_det
WHERE (count_info_id) IN 
	(SELECT count_info_id
	FROM traffic.countinfo B INNER JOIN temp_cnt_det C USING (count_info_id)
	GROUP BY count_info_id
	HAVING SUM(CASE WHEN EXTRACT(HOUR FROM timecount) >= 8 THEN count ELSE 0 END) = 0 AND (MOD(COUNT(*),96) = 0 OR COUNT(*) < 32));
	
INSERT INTO prj_volume.cnt_det_clean
SELECT *
FROM temp_cnt_det;