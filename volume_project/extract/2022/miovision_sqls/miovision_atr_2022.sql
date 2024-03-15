CREATE MATERIALIZED VIEW scannon.mio_atr_centreline_20220705 AS

WITH mio_data AS (
    SELECT 
        volumes.volume_15min_uid,
        volumes.intersection_uid,
        volumes.datetime_bin,
        volumes.classification_uid,
        volumes.leg,
        volumes.volume,
        CASE 
            WHEN volumes.leg IN ('E', 'N') THEN 1
            WHEN volumes.leg IN ('W', 'S') THEN -1
        END AS dir_bin -- following suit with other prj_volumes jams

    FROM miovision_api.volumes_15min AS volumes
    WHERE volumes.datetime_bin >= '2022-01-01'
        AND volumes.datetime_bin < '2023-01-01' -- only 2022 data
        AND volumes.classification_uid NOT IN (2,6,10) --exclude bikes and peds because this is about emissions
)

SELECT
    cm.centreline_id,
    md.dir_bin,
    md.datetime_bin AS count_bin,
    md.volume,
    3 AS count_type, -- max of count_type in prj_volume.centreline_volumes and it was 2, so I picked 3
    NULL AS speed_class, -- no speed, so null to preserve the table format
    md.classification_uid AS vehicle_class,
    md.volume_15min_uid AS volume_id
FROM mio_data AS md
LEFT JOIN scannon.centreline_miovision_20220705 AS cm ON md.intersection_uid = cm.intersection_uid AND md.leg = cm.leg