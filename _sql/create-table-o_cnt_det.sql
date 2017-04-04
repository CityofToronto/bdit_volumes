DROP FOREIGN TABLE IF EXISTS o_cnt_det;
CREATE FOREIGN TABLE o_cnt_det
(
  id bigint NOT NULL,
  count_info_id bigint,
  count bigint DEFAULT 0,
  timecount timestamp without time zone,
  speed_class integer) SERVER oradb OPTIONS (table 'CNT_DET');