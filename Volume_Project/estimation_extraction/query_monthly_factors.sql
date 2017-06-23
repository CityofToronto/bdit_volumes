SELECT place_holder_identifier_name, dir_bin, y, array_agg(month_weight ORDER BY m) AS month_weight 
FROM( 
	SELECT place_holder_identifier_name, dir_bin, y, m, avg_daily_volume/SUM(avg_daily_volume) OVER (PARTITION BY place_holder_identifier_name, dir_bin, y) AS month_weight 
	FROM(
		SELECT place_holder_identifier_name, dir_bin, y, m, AVG(daily_volume) AS avg_daily_volume, COUNT(*) AS num_counts 
		FROM (
			SELECT place_holder_identifier_name, dir_bin, EXTRACT(YEAR FROM count_bin::date) AS y, EXTRACT(MONTH FROM count_bin::date) AS m, SUM(volume) AS daily_volume 
			FROM (SELECT place_holder_identifier_name, dir_bin, count_bin, AVG(volume) AS volume
					FROM (SELECT centreline_id, dir_bin, count_bin, SUM(volume) AS volume, group_number
							FROM prj_volume.centreline_volumes JOIN prj_volume.centreline_groups USING (centreline_id, dir_bin)
							WHERE count_type = 1 
							GROUP BY group_number, centreline_id, dir_bin, count_bin) Z 
					GROUP BY place_holder_identifier_name, dir_bin, count_bin) Y
			GROUP BY place_holder_identifier_name, dir_bin, count_bin::date 
			HAVING count(*) = 96) A 
		GROUP BY place_holder_identifier_name, dir_bin, y, m 
		ORDER BY place_holder_identifier_name, dir_bin, y, m) B 
	WHERE num_counts > 5) C 
GROUP BY place_holder_identifier_name, dir_bin, y 
HAVING COUNT(DISTINCT m) = 12;