SELECT *
FROM traffic.det
INNER JOIN traffic.countinfomics USING (count_info_id)
WHERE arterycode = 4709
ORDER BY count_date