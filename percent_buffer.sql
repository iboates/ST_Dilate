CREATE OR REPLACE FUNCTION ST_PercentBuffer(
	in_geom GEOMETRY,
	scale_factor FLOAT,
	tol FLOAT DEFAULT 0.001,
	step FLOAT DEFAULT 0.5
)

RETURNS GEOMETRY AS

$$
DECLARE
	buff FLOAT = step*2;
	current_area FLOAT = ST_Area(ST_Buffer(in_geom, buff));
	desired_area FLOAT = ST_Area(in_geom)*scale_factor;
	dev FLOAT = (current_area-desired_area)/desired_area;
	old_dev FLOAT;
	safety_counter INTEGER = 0;
	
BEGIN

RAISE NOTICE 'initial area: %', ST_Area(in_geom);
RAISE NOTICE ' ';

--current_area = ST_Area(ST_Buffer(in_geom, buff));
--desired_area = ST_Area(in_geom)*scale_factor
--dev = (current_area-desired_area)/desired_area;

WHILE ABS(dev) > tol AND safety_counter < 50 LOOP

	RAISE NOTICE 'current_area: %', current_area;
	RAISE NOTICE 'desired_area %', desired_area;
 	RAISE NOTICE 'dev: %', dev;
	RAISE NOTICE 'buff: %', buff;
 	RAISE NOTICE 'old_dev: %', old_dev;
 	RAISE NOTICE ' ';

 	current_area = ST_Area(ST_Buffer(in_geom, buff));

	old_dev = dev;
	dev = (current_area-desired_area)/desired_area;

	IF dev < 0 THEN /* current area is smaller than desired area, increase the buffer distance by the step */
		buff = buff + step;
	ELSE /* current area is larger than desired area, decrease the buffer distance by the step */
		buff = buff - step;
	END IF;
	
	IF dev * old_dev < 0 THEN /* negative value indicates difference of sign, need to do a halving */
		RAISE NOTICE '=====HALVING=====';
		step = step*0.5;
	END IF;

	safety_counter = safety_counter + 1;
	RAISE NOTICE 'safety_counter: %', safety_counter;

-- 	RAISE NOTICE 'step: %', step;

END LOOP;

RETURN ST_Buffer(in_geom, buff);

END
$$
LANGUAGE plpgsql;

DROP TABLE IF EXISTS buffresult;

CREATE TABLE buffresult AS (
SELECT
	id AS id,
	ST_PercentBuffer(geom, 2.5) AS geom,
	ST_Area(ST_PercentBuffer(geom, 2.5)) AS area
FROM
	public.shrinkpoly
);