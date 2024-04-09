CREATE MATERIALIZED VIEW scannon.tmcs_to_atrs_20220705 AS (

-- Grab TMC volume from the long format table 
with vol_cent AS (
SELECT
    mlf.count_info_id,
    mlf.arterycode,
    mlf.traffic_column_name,
    mlf.datetime_bin,
    mlf.volume,
    mlf.traffic_classification,
    tt.tcl_from_segment,
    tt.tcl_to_segment,
    tt.from_dir,
    tt.to_dir
FROM traffic.tmc_miovision_long_format AS mlf
LEFT JOIN prj_volume.tmc_turns AS tt ON
    tt.arterycode = mlf.arterycode
    AND tt.movement = mlf.traffic_column_name
WHERE mlf.traffic_column_name NOT LIKE '%bike%'
    AND mlf.traffic_column_name NOT LIKE '%ped%'
    AND mlf.traffic_column_name NOT LIKE '%other%'
    AND mlf.datetime_bin >= '2022-01-01' AND mlf.datetime_bin < '2023-01-01'
    AND mlf.volume > 0
)

-- Format for TEPS; count entrances (the "froms") and exits (the "tos")
SELECT 
    tcl_from_segment AS centreline_id,
    CASE
        WHEN from_dir = ANY (ARRAY['EB'::text, 'NB'::text]) THEN 1
        WHEN from_dir = ANY (ARRAY['WB'::text, 'SB'::text]) THEN '-1'::integer
        ELSE NULL::integer
    END AS dir_bin,
    datetime_bin AS count_bin,
    volume,
    3 AS count_type,
    NULL AS speed_class,
    traffic_classification AS vehicle_class,
    count_info_id AS volume_id
FROM vol_cent
    
UNION ALL

SELECT 
    tcl_to_segment AS centreline_id,
    CASE
        WHEN to_dir = ANY (ARRAY['EB'::text, 'NB'::text]) THEN 1
        WHEN to_dir = ANY (ARRAY['WB'::text, 'SB'::text]) THEN '-1'::integer
        ELSE NULL::integer
    END AS dir_bin,
    datetime_bin AS count_bin,
    volume,
    3 AS count_type,
    NULL AS speed_class,
    traffic_classification AS vehicle_class,
    count_info_id AS volume_id
FROM vol_cent
WHERE vol_cent.tcl_to_segment IS NOT NULL
ORDER BY 1, 3, 7
);