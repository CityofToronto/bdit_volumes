DROP TABLE l2_aadt_2015;

create table USERSCHEMA.l2_aadt_2015 as
(
	select
	cgl2.l2_group_number,
	cgg.linear_name_full,
	cgg.feature_code_desc fcode_desc,
	a.dir_bin,
	a.year,
	round(avg(a.volume),0) avg_vol
	, geoml2.geom
	from prj_volume.aadt a
	inner join prj_volume.centreline_groups_l2 cgl2 on (a.group_number = cgl2.l1_group_number)
	inner join prj_volume.centreline_groups_geom cgg using (group_number)
	inner join prj_volume.centreline_groups_l2_geom geoml2 using (l2_group_number)
	group by cgl2.l2_group_number, cgg.linear_name_full, cgg.feature_code_desc, a.dir_bin, a.year, geoml2.geom
	order by l2_group_number
);