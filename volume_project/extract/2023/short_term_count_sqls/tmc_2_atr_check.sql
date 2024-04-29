-- The mat view for TMCs converted to ATRs is based on this code, but this code includes a check!

-- An important distinction between this code and the mat view code is that the mat view code 
-- excludes data for which there is no centreline_id (like mall entrances). Since there may
-- be counts on these driveways, if you run the 2x check on the mat view you may not have an
-- exact doubling of the ATRs over TMCs.

-- Grab the TMC volume data from the long format table
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
    WHERE
        mlf.traffic_column_name NOT LIKE '%bike%'
        AND mlf.traffic_column_name NOT LIKE '%ped%'
        AND mlf.traffic_column_name NOT LIKE '%other%'
        AND mlf.datetime_bin >= '2023-01-01' AND mlf.datetime_bin < '2024-01-01'
        AND mlf.volume > 0
),

-- Format it for TEPS; grab the "from" info and union it to the "to" info
teps AS (
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
), 

-- Add up the total volume counted in the TMC counts (TMCs count one vehicle once as it enters and moves through an intersection)
tmc_vol AS (
    SELECT
        count_info_id AS volume_id,
        SUM(vc.volume) AS tmc_ct
    FROM vol_cent AS vc
    GROUP BY volume_id
),

--Add up the total volume counted in the ATR counts (ATRs count one vehicle twice: once as it enters an intersection and a second time when it exits an intersection)
atr_vol AS (
    SELECT    
        volume_id,
        SUM(te.volume) AS atr_ct
    FROM teps AS te
    GROUP BY volume_id
)

SELECT 
    *, 
    (atr_ct / tmc_ct)::float AS please_be_two -- this should be two since ATRs count cars twice and TMCs count cars once
FROM tmc_vol 
LEFT JOIN atr_vol USING(volume_id)
ORDER BY (atr_ct / tmc_ct)::float;

-- I also checked that the higher functional class road had more volume for a few cases...
-- Forest Hill and Lonsdale
SELECT centreline_id, lf_name, fcode_desc, sum(volume)
FROM teps.tmcs_to_atrs_2023
LEFT JOIN gis.centreline_20220705 ON centreline_id = geo_id
WHERE centreline_id IN (1139211, 1139232, 1139355, 7254137)
GROUP BY centreline_id, lf_name, fcode_desc;

-- Morningside and Warnsworth
SELECT centreline_id, lf_name, fcode_desc, sum(volume)
FROM teps.tmcs_to_atrs_2023
LEFT JOIN gis.centreline_20220705 ON centreline_id = geo_id
WHERE centreline_id IN (107586, 107621, 107724)
GROUP BY centreline_id, lf_name, fcode_desc;

-- St. Leonard's and Mildenhall
SELECT centreline_id, lf_name, fcode_desc, sum(volume)
FROM teps.tmcs_to_atrs_2023
LEFT JOIN gis.centreline_20220705 ON centreline_id = geo_id
WHERE centreline_id IN (444286, 444372, 444285, 444387)
GROUP BY centreline_id, lf_name, fcode_desc;

-- Kipling and St. Andrews
SELECT centreline_id, lf_name, fcode_desc, sum(volume)
FROM teps.tmcs_to_atrs_2023
LEFT JOIN gis.centreline_20220705 ON centreline_id = geo_id
WHERE centreline_id IN (908458, 908511, 9980271)
GROUP BY centreline_id, lf_name, fcode_desc;

-- Blythwood and Strathgowan
SELECT centreline_id, lf_name, fcode_desc, sum(volume)
FROM teps.tmcs_to_atrs_2023
LEFT JOIN gis.centreline_20220705 ON centreline_id = geo_id
WHERE centreline_id IN (7754013, 30057003, 1137956)
GROUP BY centreline_id, lf_name, fcode_desc;
-- These all checked out so I stopped.