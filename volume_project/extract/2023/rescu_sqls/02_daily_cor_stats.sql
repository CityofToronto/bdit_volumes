-- Make a table that compares daily volumes with the average daily volumes and z scores
CREATE TABLE teps.rescu_dayvol_stats_23 AS (

-- determine what day it is (weekday or weekend)    
    WITH day_jam AS (
        SELECT 
            di.detector_id,
            di.det_group,
            v.entity_location_uid,
            v.vdsconfig_uid,
            di.direction,
            vc.lanes,
            el.latitude,
            el.longitude,
            v.datetime_15min,
            v.count_15min,
            CASE
                WHEN EXTRACT(ISODOW FROM v.datetime_15min) IN (6, 7) THEN 'Weekend'
                ELSE 'Weekday'
            END AS day_type,
            UPPER(el.main_road_name) || ' and ' || UPPER(el.cross_road_name) AS gen_loc,
            date_trunc('day', v.datetime_15min)::date AS dt,
            TO_CHAR(v.datetime_15min, 'Day') AS dow
        FROM vds.counts_15min AS v
        LEFT JOIN vds.detector_inventory AS di ON di.uid = v.vdsconfig_uid 
        LEFT JOIN vds.vdsconfig AS vc ON vc.uid = v.vdsconfig_uid
        LEFT JOIN vds.entity_locations AS el ON el.uid = v.entity_location_uid
        WHERE 
            v.datetime_15min >= '2023-01-01'
            AND v.datetime_15min < '2024-01-01'
            AND di.det_type = 'RESCU Detectors'
    ),

    -- calculate daily volumes
    daily_vol AS (
        SELECT 
            dj.detector_id,
            dj.det_group,
            dj.entity_location_uid,
            dj.vdsconfig_uid,
            dj.direction,
            dj.lanes,
            dj.latitude,
            dj.longitude,
            dj.gen_loc,
            dj.dt,
            dj.day_type,
            SUM(dj.count_15min) AS d_vol
        FROM day_jam AS dj
        GROUP BY
            dj.detector_id,
            dj.det_group,
            dj.entity_location_uid,
            dj.vdsconfig_uid,
            dj.direction,
            dj.lanes,
            dj.latitude,
            dj.longitude,
            dj.gen_loc,
            dj.dt,
            dj.day_type
    ),

    -- calculate average and st dev volumes for weekdays and weekends
    ave_vol AS (
        SELECT 
            dv.detector_id,
            dv.det_group,
            dv.entity_location_uid,
            dv.vdsconfig_uid,
            dv.direction,
            dv.lanes,
            dv.latitude,
            dv.longitude,
            dv.gen_loc,
            dv.day_type,
            ROUND(AVG(dv.d_vol), 0) AS a_vol,
            ROUND(STDDEV_POP(dv.d_vol), 0) AS stdev_vol
        FROM daily_vol AS dv
        GROUP BY 
            dv.detector_id,
            dv.det_group,
            dv.entity_location_uid,
            dv.vdsconfig_uid,
            dv.direction,
            dv.lanes,
            dv.latitude,
            dv.longitude,
            dv.gen_loc,
            dv.day_type           
    )

    -- put the average and st dev volumes with the daily volumes
    SELECT
        av.detector_id,
        av.det_group,
        av.entity_location_uid,
        av.vdsconfig_uid,
        av.direction,
        av.lanes,
        av.latitude,
        av.longitude,
        av.gen_loc,
        av.day_type,
        dv.dt,
        dv.d_vol,
        av.a_vol,
        av.stdev_vol,
        ROUND(((dv.d_vol - av.a_vol) / av.stdev_vol), 0) AS zscore
    FROM daily_vol AS dv
    LEFT JOIN ave_vol AS av 
        ON av.detector_id = dv.detector_id 
        AND av.day_type = dv.day_type
    WHERE av.stdev_vol > 0
);