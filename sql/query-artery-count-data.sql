SELECT *
FROM traffic.det
INNER JOIN traffic.countinfomics USING (count_info_id)
WHERE arterycode = 5614
ORDER BY count_date