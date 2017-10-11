SELECT l2_group_number, linear_name_full, fcode_desc, dir_bin, year, avg_vol, st_transform(geom,26917) as geom
        FROM qchen.l2_aadt_2015
        WHERE year = {year} 
        AND (fcode_desc IN ('Expressway','Major Arterial','Minor Arterial')
        OR linear_name_full IN ('Finch Ave E','Old Finch Ave','McNicoll Ave','Neilson Rd','Morningside Ave','Staines Rd','Sewell''s Rd','Meadowvale Rd','Plug Hat Rd','Beare Rd','Reesor Rd'))