CREATE MATERIALIZED VIEW IF NOT EXISTS teps.mio_atr_centreline_2023
TABLESPACE pg_default
AS
WITH mio_data AS (
    SELECT
        volumes.volume_15min_uid,
        volumes.intersection_uid,
        volumes.datetime_bin,
        volumes.classification_uid,
        volumes.leg,
        volumes.volume,
            CASE
                WHEN volumes.leg = ANY (ARRAY['E'::text, 'N'::text]) THEN 1
                WHEN volumes.leg = ANY (ARRAY['W'::text, 'S'::text]) THEN '-1'::integer
                ELSE NULL::integer
            END AS dir_bin,
        array_agg(ar.notes ORDER BY ar.range_start, ar.uid) FILTER (WHERE ar.uid IS NOT NULL)
        AS anomalous_range_caveats,
        array_agg(ar.uid ORDER BY ar.range_start, ar.uid) FILTER (WHERE ar.uid IS NOT NULL)
        AS anomalous_range_uids
    FROM miovision_api.volumes_15min volumes
    LEFT JOIN miovision_api.anomalous_ranges AS ar
        ON (
            ar.intersection_uid = volumes.intersection_uid
            OR ar.intersection_uid IS NULL
        ) AND (
            ar.classification_uid = volumes.classification_uid
            OR ar.classification_uid IS NULL
        )
        AND volumes.datetime_bin >= ar.range_start
        AND (
            volumes.datetime_bin < ar.range_end
            OR ar.range_end IS NULL
        )
    WHERE
        volumes.datetime_bin >= '2023-01-01 00:00:00'::timestamp without time zone
        AND volumes.datetime_bin < '2024-01-01 00:00:00'::timestamp without time zone 
        AND (volumes.classification_uid <> ALL (ARRAY[2, 6, 10]))
    GROUP BY 
        volumes.volume_15min_uid,
        volumes.intersection_uid,
        volumes.datetime_bin,
        volumes.classification_uid,
        volumes.leg,
        volumes.volume
    HAVING NOT (array_agg(ar.problem_level) && ARRAY['do-not-use', 'questionable'])
)

SELECT
    cm.centreline_id,
    md.dir_bin,
    md.datetime_bin AS count_bin,
    md.volume,
    3 AS count_type,
    NULL::text AS speed_class,
    md.classification_uid AS vehicle_class,
    md.volume_15min_uid AS volume_id,
    md.anomalous_range_caveats
FROM mio_data md
LEFT JOIN teps.centreline_miovision_20220705 cm
    ON md.intersection_uid = cm.intersection_uid
    AND md.leg = cm.leg
WITH DATA;

ALTER TABLE IF EXISTS teps.mio_atr_centreline_2023
OWNER TO teps_admins;

GRANT SELECT ON TABLE teps.mio_atr_centreline_2023 TO bdit_humans;
GRANT ALL ON TABLE teps.mio_atr_centreline_2023 TO teps_admins;