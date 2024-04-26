-- make a table that contains stats by lane so that we can set volume minimums
CREATE TABLE scannon.rescu_lane_stats_22 AS (
    
    -- calculate daily volumes for days when detectors have data for every 15 minute bin 
    WITH daily_vol AS (
        SELECT
            di.detector_id,
            di.det_group,
            v.entity_location_uid,
            v.vdsconfig_uid,
            di.direction,
            vc.lanes,
            UPPER(el.main_road_name) || ' and ' || UPPER(el.cross_road_name) AS gen_loc,
            el.latitude,
            el.longitude,
            date_trunc('day', v.datetime_15min)::date AS dt,
            COUNT(v.datetime_15min) AS bin_ct,
            SUM(v.count_15min) AS daily_vol
        FROM vds.counts_15min AS v
        LEFT JOIN vds.detector_inventory AS di ON di.uid = v.vdsconfig_uid 
        LEFT JOIN vds.vdsconfig AS vc ON vc.uid = v.vdsconfig_uid
        LEFT JOIN vds.entity_locations AS el ON el.uid = v.entity_location_uid
        WHERE 
            v.datetime_15min >= '2022-01-01'
            AND v.datetime_15min < '2023-01-01'
            AND di.det_type = 'RESCU Detectors'
        GROUP BY
            di.detector_id,
            date_trunc('day', v.datetime_15min)::date,
            di.det_group,
            v.entity_location_uid,
            v.vdsconfig_uid,
            di.direction,
            vc.lanes,
            UPPER(el.main_road_name) || ' and ' || UPPER(el.cross_road_name),
            el.latitude,
            el.longitude
        HAVING COUNT(v.datetime_15min) >= 96
    ), 

    -- figure out if the day is a weekend or weekday; add in some more detector info
    day_jam AS (
        SELECT 
            dv.detector_id,
            dv.det_group,
            dv.entity_location_uid,
            dv.vdsconfig_uid,
            dv.direction,
            dv.lanes,
            dv.gen_loc,
            dv.latitude,
            dv.longitude,
            dv.bin_ct,
            dv.daily_vol,
            TO_CHAR(dv.dt, 'Day') AS dow,
            CASE
                WHEN EXTRACT(ISODOW FROM dv.dt) IN (6, 7) THEN 'Weekend'
                ELSE 'Weekday'
            END AS day_type
        FROM daily_vol AS dv
        WHERE 
            dv.gen_loc NOT LIKE '%RAMP%'
            AND dv.det_group NOT LIKE '%Ramp%'
    )

-- calculate stats - final table!
SELECT 
    dj.detector_id,
    dj.det_group,
    dj.entity_location_uid,
    dj.vdsconfig_uid,
    dj.direction,
    dj.lanes,
    dj.gen_loc,
    dj.latitude,
    dj.longitude,
    dj.day_type,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY dj.daily_vol) AS corr_med_vol,
    ROUND(AVG(dj.daily_vol), 0) AS corr_av_vol,
    ROUND(STDDEV_POP(dj.daily_vol), 0) AS corr_stdev_vol,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY dj.daily_vol) / dj.lanes AS lane_med_vol,
    ROUND(AVG(dj.daily_vol) / dj.lanes, 0) AS lane_av_vol,
    ROUND(STDDEV_POP(dj.daily_vol) / dj.lanes, 0) AS lane_stdev_vol
FROM day_jam AS dj
GROUP BY 
    dj.detector_id,
    dj.det_group,
    dj.entity_location_uid,
    dj.vdsconfig_uid,
    dj.direction,
    dj.lanes,
    dj.gen_loc,
    dj.latitude,
    dj.longitude,
    dj.day_type        
);