DROP VIEW uoft_volume.street_charts;
CREATE VIEW uoft_volume.street_charts AS
WITH streets AS(
	SELECT unnest(ARRAY['Yonge St','Bathurst St','Bayview Ave','Jane St','Keele St'])::text AS linear_name_full
	),
streets_char AS (
	
	SELECT 	linear_name_full,
		ABS((MIN(ST_X(ST_StartPoint(shape))) - MAX(ST_X(ST_EndPoint(shape))))) AS x_diff,
		ABS((MIN(ST_Y(ST_StartPoint(shape))) - MAX(ST_Y(ST_EndPoint(shape))))) as y_diff,
		SUM(ST_Length(shape)) AS length
	FROM prj_volume.centreline
	INNER JOIN streets USING (linear_name_full)
	GROUP BY linear_name_full
	),
links_all AS (
	SELECT linear_name_full,centreline_id,
	SUM(ST_Length(shape)) OVER (PARTITION BY linear_name_full ORDER BY ST_Y(ST_StartPoint(shape))) - ST_Length(shape) AS start_m,
	SUM(ST_Length(shape)) OVER (PARTITION BY linear_name_full ORDER BY ST_Y(ST_StartPoint(shape))) AS end_m
	FROM prj_volume.centreline
	INNER JOIN streets_char USING (linear_name_full)
	-- ORDER BY ST_Y(ST_StartPoint(shape))
	
)
SELECT linear_name_full, CASE WHEN dir_bin = 1 THEN 'NB/EB' ELSE 'SB/WB' END AS dir, start_m, end_m, aadt FROM links_all
INNER JOIN uoft_volume.map_aadt_2013 USING (linear_name_full, centreline_id)
