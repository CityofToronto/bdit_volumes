DROP TABLE IF EXISTS prj_volume.count_summary;

CREATE TABLE prj_volume.count_summary(
	arterycode bigint,
	count_type character varying(10),
	loc character varying(65),
	count_date date,
	source character varying(50),
	category_id smallint);

INSERT INTO prj_volume.count_summary
SELECT 	A.arterycode,
	A.count_type,
	A.location as loc,
	B.count_date, 
	B.source1 as source,
	B.category_id
	
FROM traffic.arterydata A
INNER JOIN traffic.countinfo B USING (arterycode)
ORDER BY A.arterycode, B.count_date;