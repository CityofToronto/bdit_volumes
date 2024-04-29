CREATE TABLE teps.rescu_enuf_vol_22 AS (
    WITH vol_asmt AS (
        SELECT 
            *,
            CASE
                WHEN det_group = 'DVP' AND day_type = 'Weekday' AND d_vol / lanes  >= 15000 THEN 'enough volume'
                WHEN det_group = 'DVP' AND day_type = 'Weekend' AND d_vol / lanes  >= 10000 THEN 'enough volume'
                WHEN det_group = 'Gardiner' AND d_vol / lanes  >= 10000 THEN 'enough volume'
                WHEN det_group = 'Lakeshore' AND d_vol / lanes  >= 2000 THEN 'enough volume'
                WHEN det_group = 'On-Ramp' THEN 'exclude'
                ELSE 'check volume'
            END AS vol_check
        FROM teps.rescu_dayvol_stats_22
    )

    SELECT 
        va.* 
    FROM vol_asmt AS va
    WHERE va.vol_check = 'enough volume'
);