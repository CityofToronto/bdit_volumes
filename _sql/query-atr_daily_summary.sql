SELECT centreline_id, dir_bin, count_bin::date, SUM(volume)
FROM prj_volume.centreline_volumes
WHERE count_type = 1 AND count_bin::date >= '2009-01-01'
GROUP BY centreline_id, dir_bin, count_bin::date
HAVING COUNT(*) IN (96,1344,1248)
ORDER BY centreline_id, dir_bin, count_bin::date;