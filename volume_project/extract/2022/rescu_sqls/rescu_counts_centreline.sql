CREATE TABLE scannon.rescu_count_centreline_20220705 AS (
SELECT 
    art.centreline_id, 
    CASE
        WHEN ev.direction = ANY (ARRAY['Eastbound'::text, 'Northbound'::text]) THEN 1
        WHEN ev.direction = ANY (ARRAY['Westbound'::text, 'Southbound'::text]) THEN '-1'::integer
        ELSE NULL::integer
    END AS dir_bin,
    v.datetime_15min AS count_bin,
    v.count_15min AS volume,
    1 AS count_type,
    NULL AS speed_class,
    NULL AS vehicle_class,
    volumeuid AS volume_id
FROM scannon.rescu_enuf_vol_22 AS ev
LEFT JOIN scannon.rescu_cent_20220705 AS art USING (detector_id)
LEFT JOIN vds.counts_15min AS v 
        ON ev.entity_location_uid = v.entity_location_uid
            AND ev.dt = v.datetime_15min::date
WHERE detector_id NOT IN ('DW0070DEG', 'DW0120DEG') -- these detectors had fewer days of data than another detector on the same centreline_id
    AND v.count_15min > 0
);