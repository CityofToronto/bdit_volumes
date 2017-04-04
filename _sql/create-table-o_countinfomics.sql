DROP FOREIGN TABLE IF EXISTS o_countinfomics;
CREATE FOREIGN TABLE o_countinfomics
(
  count_info_id bigint NOT NULL,
  arterycode bigint,
  count_type character varying(1),
  count_date timestamp without time zone,
  day_no bigint,
  comment_ character varying(250),
  file_name character varying(100),
  load_date timestamp without time zone,
  transfer_rec smallint,
  category_id bigint) SERVER oradb OPTIONS (table 'COUNTINFOMICS');