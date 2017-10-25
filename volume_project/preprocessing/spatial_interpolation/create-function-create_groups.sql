CREATE OR REPLACE FUNCTION prj_volume.create_groups() RETURNS VOID AS $$

DECLARE
	current_cl bigint;
	grouped_cls bigint[];
	grouped_cls_new bigint[];
	current_db smallint;
	group_id int;
	remaining boolean;
	group_loop boolean;
	total_unused int;
BEGIN
	group_id := 0;
	remaining := TRUE;

	WHILE remaining = TRUE LOOP
		group_id := group_id + 1;

		SELECT cl1, dir_bin INTO current_cl, current_db FROM prj_volume.centreline_volumes_truth WHERE unused = TRUE LIMIT 1;

		group_loop := TRUE;

		grouped_cls := NULL;
		grouped_cls := array_append(grouped_cls,current_cl);

		WHILE group_loop = TRUE LOOP
			grouped_cls_new := array(SELECT cl2 FROM prj_volume.centreline_volumes_truth WHERE dir_bin = current_db AND unused = TRUE and same_volume = TRUE AND cl1 = ANY(grouped_cls) AND cl2 != ANY(grouped_cls));

			IF (array_length(grouped_cls_new,1) < 1) THEN
				group_loop = FALSE;
			ELSE
				UPDATE prj_volume.centreline_volumes_truth SET unused = FALSE WHERE same_volume = TRUE AND cl1 = ANY(grouped_cls) AND dir_bin = current_db;
				grouped_cls := array_cat(grouped_cls, grouped_cls_new);
			END IF;

			UPDATE prj_volume.centreline_volumes_truth SET unused = FALSE WHERE (cl1 = ANY (grouped_cls) OR cl2 = ANY(grouped_cls)) AND dir_bin = current_db;
			INSERT INTO prj_volume.centreline_groups_test(centreline_id, dir_bin, group_number) SELECT unnest(grouped_cls) AS centreline_id, current_db as dir_bin, group_id as group_number;
		END LOOP;

		total_unused := (SELECT COUNT(*) FROM prj_volume.centreline_volumes_truth WHERE unused = TRUE LIMIT 1);

		IF (total_unused < 1) THEN
			remaining = FALSE;
		END IF;
	END LOOP;

END;
$$ LANGUAGE plpgsql;