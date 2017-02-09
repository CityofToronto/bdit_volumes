DROP TABLE IF EXISTS count_disc;
DROP TABLE IF EXISTS count_disc2;
DROP TABLE IF EXISTS prj_volume.vol_profiles;

CREATE TEMPORARY TABLE count_disc (
	arterycode bigint,
	count_date date,
	category_id smallint,
	records bigint,
	daily_vol bigint);

CREATE TEMPORARY TABLE count_disc2 (
	arterycode bigint,
	count_date date,
	category_id smallint,
	daily_vol bigint);

CREATE TABLE prj_volume.vol_profiles (
	arterycode bigint,
	count_date date,
	category_id smallint,
	time_bin time without time zone,
	vol_weight numeric);

INSERT INTO count_disc
SELECT A.arterycode, B.count_date, D.category_id, COUNT(*) as records, SUM(C.count) as daily_vol
FROM traffic.arterydata A
INNER JOIN traffic.countinfo B USING (arterycode)
INNER JOIN traffic.cnt_det C USING (count_info_id)
INNER JOIN traffic.category D USING (category_id)
WHERE C.count IS NOT NULL
GROUP BY A.arterycode, B.count_date, D.category_id
ORDER BY A.arterycode, B.count_date, D.category_id;

INSERT INTO count_disc2
SELECT arterycode, count_date, category_id, daily_vol
FROM count_disc
WHERE ((category_id IN (1,2,6,7) AND records = 96) OR (category_id = 3 AND records IN (1248, 1344)) OR (category_id = 4 AND records = 1344)) AND daily_vol > 0;

INSERT INTO prj_volume.vol_profiles
SELECT A.arterycode, A.count_date, A.category_id, pg_catalog.time(C.timecount) AS time_bin, SUM(C.count)*1.0/A.daily_vol AS vol_weight
FROM count_disc2 A
INNER JOIN traffic.countinfo B USING (arterycode, count_date, category_id)
INNER JOIN traffic.cnt_det C USING (count_info_id)
GROUP BY A.arterycode, A.count_date, A.category_id, pg_catalog.time(C.timecount), A.daily_vol