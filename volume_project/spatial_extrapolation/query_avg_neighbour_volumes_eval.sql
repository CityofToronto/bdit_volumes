-- Parameters: $1 - feature_code; $2 - sample size

WITH segments AS (
	SELECT group_number, AVG(volume) AS volume, shape, feature_code
	FROM prj_volume.aadt JOIN prj_volume.centreline_groups_geom USING (group_number)
	GROUP BY group_number, feature_code, shape)

SELECT g1, AVG(neighbourvolume)::int, volume::int
FROM (SELECT l1.group_number AS g1, l1.volume as volume, l2.volume as neighbourvolume, row_number() OVER (PARTITION BY l1.group_number,l1.volume ORDER BY ST_Distance(l1.shape, l2.shape))
	FROM segments l1, segments l2
	WHERE ST_DWithin(l1.shape, l2.shape, 500) AND l1.group_number != l2.group_number AND l1.feature_code=$1 AND l2.feature_code=$1) A 
WHERE row_number < 5
GROUP BY g1, volume
ORDER BY random()
LIMIT (SELECT COUNT(*) FROM segments WHERE feature_code=$1)*$2/100