SELECT (ST_Distance(a1.shape, a2.shape)/50)::int AS dist, sum(a1.volume-a2.volume)^2/2/count(*) AS semivariance, corr(a1.volume, a2.volume) as correlation, COUNT(*) as num_observations
FROM (prj_volume.aadt JOIN prj_volume.centreline_groups_geom USING (group_number)) a1 JOIN (prj_volume.aadt JOIN prj_volume.centreline_groups_geom USING (group_number)) a2 ON ST_DWithin(a1.shape, a2.shape, 5000)
WHERE a1.confidence = 1 AND a2.confidence = 1 AND a1.feature_code = $1 AND a2.feature_code = $1 AND a1.group_number > a2.group_number 
GROUP BY (ST_Distance(a1.shape, a2.shape)/50)::int
ORDER BY (ST_Distance(a1.shape, a2.shape)/50)::int