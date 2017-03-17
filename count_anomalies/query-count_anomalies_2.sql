DROP TABLE IF EXISTS tod_check;

CREATE TEMPORARY TABLE tod_check (
	arterycode bigint,
	count_date date,
	bef8am bigint,
	aft8am bigint);

INSERT INTO tod_check
SELECT 	A.arterycode, 
	B.count_date, 
	SUM(CASE WHEN EXTRACT(HOUR FROM timecount) < 8 THEN count ELSE 0 END) as bef8am, 
	SUM(CASE WHEN EXTRACT(HOUR FROM timecount) >= 8 THEN count ELSE 0 END) as aft8am
FROM traffic.arterydata A
INNER JOIN traffic.countinfo B USING (arterycode)
INNER JOIN traffic.cnt_det C USING (count_info_id)
GROUP BY A.arterycode, B.count_date;

SELECT * FROM tod_check
WHERE bef8am > aft8am;