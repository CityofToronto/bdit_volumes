DROP TABLE IF EXISTS prj_volume.vol_profiles_last;

CREATE TABLE prj_volume.vol_profiles_last (
	arterycode bigint,
	count_date date,
	category_id smallint,
	time_bin time without time zone,
	vol_weight numeric);

INSERT INTO prj_volume.vol_profiles_last
SELECT B.*
FROM	(SELECT arterycode, MAX(count_date) AS count_date
	FROM prj_volume.vol_profiles
	WHERE EXTRACT(dow FROM count_date) IN (1,2,3,4,5)
	GROUP BY arterycode) A
INNER JOIN prj_volume.vol_profiles B USING (arterycode, count_date)
ORDER BY B.arterycode, B.time_bin;

DELETE FROM prj_volume.vol_profiles_last
WHERE arterycode IN (SELECT arterycode FROM prj_volume.vol_profiles_last WHERE vol_weight > 0.1);