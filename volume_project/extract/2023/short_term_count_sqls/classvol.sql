CREATE MATERIALIZED VIEW teps.classvol_2023 AS (
    SELECT
        ac.centreline_id,
        CASE
            WHEN ac.direction = ANY (ARRAY['E'::text, 'N'::text]) THEN 1
            WHEN ac.direction = ANY (ARRAY['W'::text, 'S'::text]) THEN '-1'::integer
            ELSE NULL::integer
        END AS dir_bin,
        sv.timecount AS count_bin,
        sv.count AS volume,
        3 AS count_type,
        NULL AS speed_class,
        sc.class_desc AS vehicle_class,
        sv.count_info_id AS volume_id
    FROM traffic.cnt_det AS sv
    LEFT JOIN traffic.countinfo AS ci USING (count_info_id)
    LEFT JOIN traffic.arteries_centreline AS ac USING (arterycode)
    LEFT JOIN scannon.oti_class AS sc
        ON speed_class = class_id
    WHERE
        ci.count_date >= '2023-01-01'
        AND ci.count_date < '2024-01-01'
        AND sv.count > 0
        AND ci.category_id = 3
    ORDER BY
        centreline_id,
        count_bin,
        speed_class
);