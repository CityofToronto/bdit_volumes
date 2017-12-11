INSERT INTO traffic.arterydata(arterycode, geomcode, street1, street1type, street1dir, street2, street2type, street2dir, street3, street3type, street3dir, stat_code, count_type, location, apprdir, sideofint, linkid, seq_order, geo_id)
SELECT arterycode, geomcode, street1, street1type, street1dir, street2, street2type, street2dir, street3, street3type, street3dir, stat_code, count_type, location, apprdir, sideofint, linkid, seq_order, geo_id
FROM prj_volume.new_arterydata
ON CONFLICT (arterycode) 
DO UPDATE SET (geomcode, street1, street1type, street1dir, street2, street2type, street2dir, street3, street3type, street3dir, stat_code, count_type, location, apprdir, sideofint, linkid, seq_order, geo_id)
= (EXCLUDED.geomcode, EXCLUDED.street1, EXCLUDED.street1type, EXCLUDED.street1dir, EXCLUDED.street2, EXCLUDED.street2type, EXCLUDED.street2dir, EXCLUDED.street3, EXCLUDED.street3type, EXCLUDED.street3dir, EXCLUDED.stat_code, EXCLUDED.count_type, EXCLUDED.location, EXCLUDED.apprdir, EXCLUDED.sideofint, EXCLUDED.linkid, EXCLUDED.seq_order, EXCLUDED.geo_id);

INSERT INTO traffic.countinfo(count_info_id, arterycode, count_date, day_no, comment_, file_name, source1, source2, load_date, speed_info_id, category_id)
SELECT count_info_id, arterycode, count_date, day_no, comment_, file_name, source1, source2, load_date, speed_info_id, category_id
FROM prj_volume.new_countinfo
ON CONFLICT (count_info_id)
DO UPDATE SET (arterycode, count_date, day_no, comment_, file_name, source1, source2, load_date, speed_info_id, category_id)
= (EXCLUDED.arterycode, EXCLUDED.count_date, EXCLUDED.day_no, EXCLUDED.comment_, EXCLUDED.file_name, EXCLUDED.source1, EXCLUDED.source2, EXCLUDED.load_date, EXCLUDED.speed_info_id, EXCLUDED.category_id);

INSERT INTO traffic.countinfomics(count_info_id, arterycode, count_type, count_date, day_no, comment_, file_name, load_date, transfer_rec, category_id)
SELECT count_info_id, arterycode, count_type, count_date, day_no, comment_, file_name, load_date, transfer_rec, category_id
FROM prj_volume.new_countinfomics
ON CONFLICT (count_info_id)
DO UPDATE SET (arterycode, count_type, count_date, day_no, comment_, file_name, load_date, transfer_rec, category_id)
= (EXCLUDED.arterycode, EXCLUDED.count_type, EXCLUDED.count_date, EXCLUDED.day_no, EXCLUDED.comment_, EXCLUDED.file_name, EXCLUDED.load_date, EXCLUDED.transfer_rec, EXCLUDED.category_id);

INSERT INTO traffic.cnt_det(id, count_info_id, count, timecount, speed_class)
SELECT id, count_info_id, count, timecount, speed_class
FROM prj_volume.new_cnt_det
ON CONFLICT (id)
DO UPDATE SET (count_info_id, count, timecount, speed_class)
= (EXCLUDED.count_info_id, EXCLUDED.count, EXCLUDED.timecount, EXCLUDED.speed_class);

INSERT INTO traffic.det(id, count_info_id, count_time, n_cars_r,n_cars_t,n_cars_l,s_cars_r,s_cars_t,s_cars_l,e_cars_r,e_cars_t,e_cars_l,w_cars_r,w_cars_t,w_cars_l,
n_truck_r,n_truck_t,n_truck_l,s_truck_r,s_truck_t,s_truck_l,e_truck_r,e_truck_t,e_truck_l,w_truck_r,w_truck_t,w_truck_l,
n_bus_r,n_bus_t,n_bus_l,s_bus_r,s_bus_t,s_bus_l,e_bus_r,e_bus_t,e_bus_l,w_bus_r,w_bus_t,w_bus_l,
n_peds,s_peds,e_peds,w_peds,
n_bike,s_bike,e_bike,w_bike,
n_other,s_other,e_other,w_other)
SELECT id, count_info_id, count_time, n_cars_r,n_cars_t,n_cars_l,s_cars_r,s_cars_t,s_cars_l,e_cars_r,e_cars_t,e_cars_l,w_cars_r,w_cars_t,w_cars_l,
n_truck_r,n_truck_t,n_truck_l,s_truck_r,s_truck_t,s_truck_l,e_truck_r,e_truck_t,e_truck_l,w_truck_r,w_truck_t,w_truck_l,
n_bus_r,n_bus_t,n_bus_l,s_bus_r,s_bus_t,s_bus_l,e_bus_r,e_bus_t,e_bus_l,w_bus_r,w_bus_t,w_bus_l,
n_peds,s_peds,e_peds,w_peds,
n_bike,s_bike,e_bike,w_bike,
n_other,s_other,e_other,w_other
FROM prj_volume.new_det
ON CONFLICT (id)
DO UPDATE SET (count_info_id, count_time, n_cars_r,n_cars_t,n_cars_l,s_cars_r,s_cars_t,s_cars_l,e_cars_r,e_cars_t,e_cars_l,w_cars_r,w_cars_t,w_cars_l,
n_truck_r,n_truck_t,n_truck_l,s_truck_r,s_truck_t,s_truck_l,e_truck_r,e_truck_t,e_truck_l,w_truck_r,w_truck_t,w_truck_l,
n_bus_r,n_bus_t,n_bus_l,s_bus_r,s_bus_t,s_bus_l,e_bus_r,e_bus_t,e_bus_l,w_bus_r,w_bus_t,w_bus_l,
n_peds,s_peds,e_peds,w_peds,
n_bike,s_bike,e_bike,w_bike,
n_other,s_other,e_other,w_other)
= (EXCLUDED.count_info_id, EXCLUDED.count_time, EXCLUDED.n_cars_r, EXCLUDED.n_cars_t, EXCLUDED.n_cars_l, EXCLUDED.s_cars_r, EXCLUDED.s_cars_t, EXCLUDED.s_cars_l, EXCLUDED.e_cars_r, EXCLUDED.e_cars_t, EXCLUDED.e_cars_l, EXCLUDED.w_cars_r, EXCLUDED.w_cars_t, EXCLUDED.w_cars_l, 
EXCLUDED.n_truck_r, EXCLUDED.n_truck_t, EXCLUDED.n_truck_l, EXCLUDED.s_truck_r, EXCLUDED.s_truck_t, EXCLUDED.s_truck_l, EXCLUDED.e_truck_r, EXCLUDED.e_truck_t, EXCLUDED.e_truck_l, EXCLUDED.w_truck_r, EXCLUDED.w_truck_t, EXCLUDED.w_truck_l, 
EXCLUDED.n_bus_r, EXCLUDED.n_bus_t, EXCLUDED.n_bus_l, EXCLUDED.s_bus_r, EXCLUDED.s_bus_t, EXCLUDED.s_bus_l, EXCLUDED.e_bus_r, EXCLUDED.e_bus_t, EXCLUDED.e_bus_l, EXCLUDED.w_bus_r, EXCLUDED.w_bus_t, EXCLUDED.w_bus_l, 
EXCLUDED.n_peds, EXCLUDED.s_peds, EXCLUDED.e_peds, EXCLUDED.w_peds, 
EXCLUDED.n_bike, EXCLUDED.s_bike, EXCLUDED.e_bike, EXCLUDED.w_bike, 
EXCLUDED.n_other, EXCLUDED.s_other, EXCLUDED.e_other, EXCLUDED.w_other);