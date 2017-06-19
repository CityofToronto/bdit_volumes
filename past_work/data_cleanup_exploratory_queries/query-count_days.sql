DROP TABLE IF EXISTS count_days;

CREATE TEMPORARY TABLE count_days (
	arterycode bigint,
	count_date date,
	min_time time without time zone,
	max_time time without time zone);

INSERT INTO count_days
SELECT A.arterycode, B.count_date, MIN(pg_catalog.time(C.timecount)) as min_time, MAX(pg_catalog.time(C.timecount)) as max_time
FROM traffic.arterydata A
INNER JOIN traffic.countinfo B USING (arterycode)
INNER JOIN traffic.cnt_det C USING (count_info_id)
GROUP BY A.arterycode, B.count_date;

SELECT EXTRACT(year FROM count_date) AS yr, min_time, max_time, COUNT(*)
FROM count_days
GROUP BY EXTRACT(year FROM count_date), min_time, max_time