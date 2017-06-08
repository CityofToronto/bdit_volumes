TRUNCATE prj_volume.new_arterydata;

INSERT INTO prj_volume.new_arterydata
SELECT arterycode,geomcode,street1,street1type,street1dir,street2,street2type,street2dir,street3,street3type,street3dir,stat_code,count_type,location,apprdir,sideofint,linkid,seq_order,geo_id
FROM traffic.arterydata 
WHERE arterycode NOT IN (SELECT arterycode FROM prj_volume.artery_tcl);