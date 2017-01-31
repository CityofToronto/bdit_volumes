DROP TABLE IF EXISTS prj_volume.count_summary_tmc;

CREATE TABLE prj_volume.count_summary_tmc(
	arterycode bigint,
	count_type character varying(10),
	loc character varying(65),
	count_date date,
	category_id smallint);

INSERT INTO prj_volume.count_summary_tmc
SELECT 	A.arterycode,
	A.count_type,
	A.location as loc,
	B.count_date, 
	B.category_id
	
FROM traffic.arterydata A
INNER JOIN traffic.countinfomics B USING (arterycode)
ORDER BY A.arterycode, B.count_date;