CREATE MATERIALIZED VIEW teps.speedvol_2023 AS (
    SELECT
        ac.centreline_id,
        CASE
            WHEN ac.direction = ANY (ARRAY['E'::text, 'N'::text]) THEN 1
            WHEN ac.direction = ANY (ARRAY['W'::text, 'S'::text]) THEN '-1'::integer
            ELSE NULL::integer
        END AS dir_bin,
        sv.timecount AS count_bin,
        sv.count AS volume,
        4 AS count_type,
        sc.speed_kph AS speed_class,
        NULL AS vehicle_class,
        sv.count_info_id AS volume_id
    FROM traffic.cnt_det AS sv
    LEFT JOIN traffic.countinfo AS ci USING(count_info_id)
    LEFT JOIN traffic.arteries_centreline AS ac USING(arterycode)
    LEFT JOIN prj_volume.speed_classes AS sc USING (speed_class)
    WHERE
        ci.count_date >= '2023-01-01'
        AND ci.count_date < '2024-01-01'
        AND sv.count > 0
        AND ci.category_id = 4
    ORDER BY
        centreline_id,
        count_bin,
        speed_class
);