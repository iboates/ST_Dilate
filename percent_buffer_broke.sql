DROP FUNCTION st_percentbuffer(geometry,double precision,double precision,double precision);

CREATE OR REPLACE FUNCTION ST_PercentBuffer(
	in_geom GEOMETRY,
	scale_factor FLOAT,
	tol FLOAT DEFAULT 0.001,
	step FLOAT DEFAULT 100
)

RETURNS GEOMETRY AS

$$

DECLARE

	current_area FLOAT;
	desired_area FLOAT = ST_Area(ST_Buffer(in_geom, step))*scale_factor;
	dev FLOAT;
	old_dev FLOAT;
	safety_counter INTEGER = 0;
	
BEGIN

current_area = ST_Area(ST_Buffer(in_geom, step));
dev = (current_area-desired_area)/current_area;

RAISE NOTICE 'current_area: %', current_area;
RAISE NOTICE 'desired_area %', desired_area;
RAISE NOTICE 'dev (created polygon is % percent bigger/smaller than the desired polygon', dev*100;
dev = 1;
tol = 0;
WHILE ABS(dev) > tol OR safety_counter < 10 LOOP

	safety_counter = safety_counter + 1;

END LOOP;

RETURN ST_Buffer(in_geom, step);

END
$$
LANGUAGE plpgsql;

SELECT
	id AS id,
	ST_Area(geom) AS geom,
	ST_Area(ST_PercentBuffer(geom, 1.8)) AS pct_buff_geom
FROM
	public.shrinkpoly;