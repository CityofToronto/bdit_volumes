DROP TABLE IF EXISTS prj_volume.cl_attr;

CREATE TABLE prj_volume.cl_attr
(
  centerline character varying,
  linear_n_1 character varying,
  linear_n_2 character varying,
  from_inter bigint,
  to_inter bigint,
  road_type character varying,
  fx double precision,
  fy double precision,
  tx double precision,
  ty double precision
)
WITH (
  OIDS=FALSE
);
ALTER TABLE prj_volume.cl_attr
  OWNER TO aharpal;
GRANT ALL ON TABLE prj_volume.cl_attr TO aharpal;
GRANT SELECT ON TABLE prj_volume.cl_attr TO public;