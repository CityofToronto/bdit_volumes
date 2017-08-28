SELECT arterycode, location, loc, centreline_id, B.direction, B.sideofint, artery_type, match_on_case
FROM prj_volume.new_arterydata A JOIN prj_volume.artery_tcl B USING (arterycode) JOIN prj_volume.arteries C USING (arterycode)
