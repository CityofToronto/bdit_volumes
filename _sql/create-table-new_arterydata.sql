DROP TABLE IF EXISTS prj_volume.new_arterydata;
CREATE TABLE prj_volume.new_arterydata
(
  arterycode bigint NOT NULL,
  geomcode bigint,
  street1 character varying(30),
  street1type character varying(10),
  street1dir character varying(5),
  street2 character varying(30),
  street2type character varying(10),
  street2dir character varying(5),
  street3 character varying(30),
  street3type character varying(5),
  street3dir character varying(5),
  stat_code character varying(20),
  count_type character varying(10),
  location character varying(65),
  apprdir character varying(10),
  sideofint character varying(1),
  linkid character varying(50),
  seq_order character varying(7),
  geo_id bigint);