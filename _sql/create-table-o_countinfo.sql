DROP FOREIGN TABLE IF EXISTS o_countinfo;
CREATE FOREIGN TABLE o_countinfo
(
  count_info_id bigint NOT NULL,
  arterycode bigint DEFAULT 0,
  count_date date,
  day_no bigint DEFAULT 0,
  comment_ character varying(250),
  file_name character varying(100),
  source1 character varying(50),
  source2 character varying(50),
  load_date timestamp without time zone,
  speed_info_id bigint DEFAULT 0,
  category_id bigint) SERVER oradb OPTIONS (table 'COUNTINFO');