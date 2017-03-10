DROP TABLE IF EXISTS prj_volume.centreline_dual;

CREATE TABLE prj_volume.centreline_dual (
	identifier bigint,
	shape geometry(LineString,82181),
	centreline_id bigint,
	width smallint);

INSERT INTO prj_volume.centreline_dual
SELECT 	centreline_id as identifier,
	shape,
	centreline_id,
	CASE 	WHEN feature_code IN (201100) THEN 10 --expressway
		WHEN feature_code IN (201200,201201) THEN 5 --major arterial
		WHEN feature_code IN (201300,201301) THEN 2 --minor arterial
		WHEN feature_code IN (201400,201401) THEN 1 --collector
		WHEN feature_code IN (201500) THEN 0.5 --local
		WHEN feature_code IN (201600,201601,201700,201800,201803) THEN 0.25 --laneway/other
	END AS width
FROM prj_volume.centreline
WHERE feature_code IN (201100, 201200, 201201, 201300, 201301, 201400, 201401, 201500, 201600, 210601, 201700, 201800, 201803);

INSERT INTO prj_volume.centreline_dual
SELECT 	-centreline_id as identifier,
	shape,
	centreline_id,
	CASE 	WHEN feature_code IN (201100) THEN 10 --expressway
		WHEN feature_code IN (201200,201201) THEN 5 --major arterial
		WHEN feature_code IN (201300,201301) THEN 2 --minor arterial
		WHEN feature_code IN (201400,201401) THEN 1 --collector
		WHEN feature_code IN (201500) THEN 0.5 --local
		WHEN feature_code IN (201600,201601,201700,201800,201803) THEN 0.25 --laneway/other
	END AS width
FROM prj_volume.centreline
WHERE feature_code IN (201100, 201200, 201201, 201300, 201301, 201400, 201401, 201500, 201600, 210601, 201700, 201800, 201803);