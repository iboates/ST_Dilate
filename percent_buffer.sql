DROP FUNCTION st_percentbuffer(geometry,double precision,double precision);

CREATE OR REPLACE FUNCTION ST_PercentBuffer(
	in_geom GEOMETRY,
	in_buff_pct FLOAT,
	in_step FLOAT DEFAULT 100
)

RETURNS GEOMETRY AS

$$
DECLARE step FLOAT;
BEGIN

RETURN ST_Buffer(in_geom, 10);

END
$$
LANGUAGE plpgsql;

SELECT
	id AS id,
	ST_Area(geom) AS geom,
	ST_Area(ST_PercentBuffer(geom, 1.0, 1.0)) AS pct_buff_geom
FROM
	public.shrinkpoly;