WITH rel_cnt AS
(SELECT place_holder_identifier_name, dir_bin, count_date, count_time, count_type, class, AVG(volume) AS volume
FROM (SELECT group_number, centreline_id, dir_bin, count_bin::date as count_date, count_bin::time as count_time, SUM(volume) AS volume, 
	(CASE WHEN EXTRACT(YEAR FROM count_bin::date) = place_holder_year THEN 1
	ELSE 2
	END) AS class, count_type
	FROM prj_volume.centreline_volumes JOIN prj_volume.centreline_groups USING (centreline_id, dir_bin) 
	WHERE EXTRACT(DOW FROM count_bin) NOT IN (0,6) AND group_number = (SELECT group_number FROM prj_volume.centreline_groups WHERE place_holder_identifier_name = place_holder_identifier_value AND dir_bin = place_holder_dir_bin LIMIT 1)
	GROUP BY group_number, centreline_id, dir_bin, count_bin::date, count_bin::time, count_type) A
GROUP BY place_holder_identifier_name, dir_bin, count_date, count_time, count_type, class)	
	
SELECT place_holder_identifier_name, dir_bin, count_date, count_time, count_type, volume
FROM rel_cnt
WHERE class = (SELECT MIN(class) FROM rel_cnt)