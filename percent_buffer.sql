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

WHILE ABS(dev) > tol AND safety_counter < 100 LOOP

	IF dev < 0 THEN /* current area is smaller than desired area, increase the step */
		step = step + step;
	ELSE /* current area is larger than desired area, decrease the step */
		step = step - step;
	END IF;

	old_dev = dev;

	dev = (desired_area-current_area)/desired_area;

	IF dev * old_dev < 0 THEN /* negative value indicates difference of sign, need to do a halving & directional reversal */
		step = step*-0.5;
	END IF;

	current_area = ST_Area(ST_Buffer(in_geom, step));

	safety_counter = safety_counter + 1;
	RAISE NOTICE 'safety_counter: %', safety_counter;

	RAISE NOTICE 'current_area: %', current_area;
	RAISE NOTICE 'desired_area %', desired_area;
	RAISE NOTICE 'dev (created polygon is % percent bigger/smaller than the desired polygon', dev*100;

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