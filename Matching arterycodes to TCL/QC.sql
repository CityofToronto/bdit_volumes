--QC1-1 2-1. Calculate Distance Between matched segments

SELECT arterycode, loc, shape, centreline_id, location, ST_HausdorffDistance(shape, loc)
FROM prj_volume.artery_tcl JOIN prj_volume.arteries USING (arterycode) JOIN prj_volume.centreline USING (centreline_id) JOIN traffic.arterydata USING (arterycode)
WHERE match_on_case = 2
ORDER BY ST_HausdorffDistance(shape, loc) DESC
LIMIT 100


--QC3-3. Segments involving midblock TCS
SELECT arterycode, loc, shape, centreline_id, location
FROM prj_volume.artery_tcl JOIN prj_volume.arteries USING (arterycode) JOIN prj_volume.centreline USING (centreline_id) JOIN traffic.arterydata USING (arterycode)
WHERE match_on_case = 3 and location LIKE '%TCS%'
