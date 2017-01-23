SELECT *
FROM traffic.det
INNER JOIN traffic.countinfomics USING (count_info_id)
WHERE arterycode IN (4161)
ORDER BY arterycode, count_date