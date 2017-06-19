DROP TABLE IF EXISTS atr_summary;
DROP TABLE IF EXISTS tmc_summary;
DROP TABLE IF EXISTS perm_stations;
DROP TABLE IF EXISTS shifted_bins;


CREATE TEMPORARY TABLE shifted_bins (
	arterycode bigint,
	count_date date,
	category_id bigint);

CREATE TEMPORARY TABLE atr_summary (
	arterycode bigint,
	count_date date,
	category_id bigint,
	num_records bigint);

CREATE TEMPORARY TABLE tmc_summary (
	arterycode bigint,
	count_date date,
	category_id bigint,
	num_records bigint);

CREATE TEMPORARY TABLE perm_stations (
	arterycode bigint);

INSERT INTO atr_summary
SELECT A.arterycode, B.count_date, B.category_id, COUNT(C.id) AS num_records
FROM traffic.arterydata A
INNER JOIN traffic.countinfo B USING (arterycode)
INNER JOIN traffic.cnt_det C USING (count_info_id)
GROUP BY A.arterycode, B.count_date, B.category_id;

INSERT INTO tmc_summary
SELECT A.arterycode, B.count_date, B.category_id, COUNT(C.id) AS num_records
FROM traffic.arterydata A
INNER JOIN traffic.countinfomics B USING (arterycode)
INNER JOIN traffic.det C USING (count_info_id)
GROUP BY A.arterycode, B.count_date, B.category_id;

INSERT INTO shifted_bins
SELECT A.arterycode, B.count_date, B.category_id
FROM traffic.arterydata A
INNER JOIN traffic.countinfo B USING (arterycode)
INNER JOIN traffic.cnt_det C USING (count_info_id)
WHERE EXTRACT(second FROM C.timecount) = 59 OR EXTRACT(minute FROM C.timecount) = 59;

INSERT INTO perm_stations
SELECT arterycode
FROM atr_summary
GROUP BY arterycode
HAVING COUNT(*) >= 100;


SELECT R.arterycode, REPLACE(S.location, ';','') as location, R.count_date, R.category_id, R.category_name, R.num_records, R.error_code
FROM
((SELECT A.arterycode, A.count_date, A.category_id, A.num_records, B.category_name, 1 as error_code
FROM atr_summary A
INNER JOIN traffic.category B USING (category_id)
WHERE	((category_id IN (1,2,6,7) AND num_records <> 96)
  OR	(category_id IN (3,4) AND num_records NOT IN (1248,1344))
  OR	category_id NOT IN (1,2,3,4,6,7))
  AND	arterycode NOT IN (SELECT arterycode FROM perm_stations)
ORDER BY num_records)
UNION ALL
(SELECT A.arterycode, A.count_date, A.category_id, NULL::bigint as num_records, B.category_name, 2 as error_code
FROM shifted_bins A
INNER JOIN traffic.category B USING (category_id)
ORDER BY arterycode, count_date)
UNION ALL
(SELECT A.arterycode, A.count_date, A.category_id, A.num_records, B.category_name, 3 as error_code
FROM tmc_summary A
INNER JOIN traffic.category B USING (category_id)
WHERE	(category_id IN (5) AND num_records <> 32)
ORDER BY num_records)
UNION ALL
(SELECT A.arterycode, A.count_date, A.category_id, A.num_records, B.category_name, 4 as error_code
FROM tmc_summary A
INNER JOIN traffic.category B USING (category_id)
WHERE	(category_id NOT IN (5))
ORDER BY num_records)) R
INNER JOIN traffic.arterydata S USING (arterycode);