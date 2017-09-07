--Create zoom levels table
SELECT *

INTO gis.streets_zoomlevels 
FROM ( VALUES  ('Collector'::TEXT, 16 ),
('Collector Ramp'::TEXT, 16 ),
('Expressway'::TEXT, 8 ),
('Expressway Ramp'::TEXT, 11 ),
('Local'::TEXT, 14 ),
('Major Arterial'::TEXT, 9  ),
('Major Arterial Ramp'::TEXT, 12 ),
('Minor Arterial'::TEXT, 13 ),
('Minor Arterial Ramp'::TEXT, 15 ),
('Pending'::TEXT, 16 ) 
) zooms(fcode_desc, min_zoom);

--Create view with zoom levels and change srid
CREATE OR REPLACE VIEW gis.streets_tiled AS 
 SELECT fcode_desc,
    street_centreline.gid,
    street_centreline.geo_id,
    street_centreline.lfn_id,
    street_centreline.lf_name,
    street_centreline.address_l,
    street_centreline.address_r,
    street_centreline.oe_flag_l,
    street_centreline.oe_flag_r,
    street_centreline.lonuml,
    street_centreline.hinuml,
    street_centreline.lonumr,
    street_centreline.hinumr,
    street_centreline.fnode,
    street_centreline.tnode,
    street_centreline.fcode,
    street_centreline.juris_code,
    street_centreline.objectid,
    ST_Transform(street_centreline.geom, 3857) AS geom,
    streets_zoomlevels.min_zoom
   FROM gis.street_centreline
     JOIN gis.streets_zoomlevels USING (fcode_desc);