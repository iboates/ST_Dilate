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

WHILE ABS(dev) > tol OR safety_counter < 1 LOOP

	IF dev < 0 THEN /* deviation is negative, we are overestimating the area, decrease the step */
		step = step - step;
	ELSE /* deviation is positive, we are underestimating the area, increase the step */
		step = step + step;
	END IF;

	current_area = ST_Area(ST_Buffer(in_geom, step));

	old_dev = dev;

	dev = (desired_area-current_area)/desired_area;

	IF dev * old_dev < 0 THEN /* negative value indicates difference of sign, need to do a halving & directional reversal */
		step = step*-0.5;
	END IF;

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