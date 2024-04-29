CREATE TABLE teps.rescu_spdvol_centreline_2023 AS (
    SELECT 
        art.centreline_id, 
        CASE
            WHEN ev.direction = ANY (ARRAY['Eastbound'::text, 'Northbound'::text]) THEN 1
            WHEN ev.direction = ANY (ARRAY['Westbound'::text, 'Southbound'::text]) THEN '-1'::integer
            ELSE NULL::integer
        END AS dir_bin,
        v.datetime_15min AS count_bin,
        v.count AS volume,
        4 AS count_type,
        v.speed_5kph AS speed_class,
        NULL AS vehicle_class,
        uid AS volume_id
    FROM teps.rescu_enuf_vol_23 AS ev
    LEFT JOIN teps.rescu_cent_20220705 AS art USING (detector_id)
    LEFT JOIN vds.veh_speeds_15min AS v 
            ON ev.entity_location_uid = v.entity_location_uid
                AND ev.dt = v.datetime_15min::date
    WHERE v.count IS NOT NULL
    AND detector_id NOT IN ('DW0070DEG', 'DW0120DEG') -- these detectors had fewer days of data than another detector on the same centreline_id
);