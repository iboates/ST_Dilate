CREATE OR REPLACE FUNCTION ST_PercentBuffer(
	in_geom GEOMETRY,
	scale_factor FLOAT,
	tol FLOAT DEFAULT 0.001,
	step FLOAT DEFAULT 0.5
)

RETURNS GEOMETRY AS

$$
DECLARE
	current_area FLOAT;
	desired_area FLOAT;
	dev FLOAT;
	old_dev FLOAT;
	safety_counter INTEGER = 0;
	buff FLOAT = step;
	
BEGIN

current_area = ST_Area(ST_Buffer(in_geom, buff));
desired_area = ST_Area(in_geom)*scale_factor;
dev = (current_area-desired_area)/desired_area;

WHILE ABS(dev) > tol AND safety_counter < 50 LOOP

	IF dev < 0 THEN /* current area is smaller than desired area, increase the step */
		buff = buff + step;
	ELSE /* current area is larger than desired area, decrease the step */
		buff = buff - step;
	END IF;

	IF dev * old_dev < 0 THEN /* negative value indicates difference of sign, need to do a halving */
		step = step*0.5;
	END IF;

	old_dev = dev;
	dev = (current_area-desired_area)/desired_area;
	current_area = ST_Area(ST_Buffer(in_geom, buff));

	safety_counter = safety_counter + 1;
	RAISE NOTICE 'safety_counter: %', safety_counter;

	RAISE NOTICE 'current_area: %', current_area;
	RAISE NOTICE 'desired_area %', desired_area;
 	RAISE NOTICE 'dev: %', dev;
	RAISE NOTICE 'buff: %', buff;
-- 	RAISE NOTICE 'old_dev: %', old_dev;
-- 	RAISE NOTICE 'step: %', step;

END LOOP;

RETURN ST_Buffer(in_geom, step);

END
$$
LANGUAGE plpgsql;

DROP TABLE IF EXISTS buffresult;

CREATE TABLE buffresult AS (
SELECT
	id AS id,
	ST_PercentBuffer(geom, 99) AS geom
FROM
	public.shrinkpoly
);