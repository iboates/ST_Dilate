CREATE OR REPLACE FUNCTION ST_Dilate(
	in_geom GEOMETRY,
	scale_factor FLOAT,
	tol FLOAT DEFAULT 0.001,
	guess FLOAT DEFAULT 1,
	safety INTEGER DEFAULT 1000
)

RETURNS GEOMETRY AS

$$
DECLARE
	step FLOAT = guess/2;
	current_area FLOAT = ST_Area(ST_Buffer(in_geom, guess));
	desired_area FLOAT = ST_Area(in_geom)*scale_factor;
	dev FLOAT = (current_area-desired_area)/desired_area;
	old_dev FLOAT;
	safety_counter INTEGER = 0;
BEGIN

	IF scale_factor < 0 THEN
		RAISE NOTICE 'Negative scale factor encountered (%) when dilating geom %, NULL geometry returned instead.', scale_factor, in_geom;
		RETURN NULL;
	END IF;

	WHILE ABS(dev) > tol LOOP

		IF safety_counter > safety THEN /* Can't find suitable distance after many iterations, terminate the function to prevent extreme hangs. */
  			RAISE NOTICE 'Could not find suitable buffer distance when dilating geom % after % iterations, NULL geometry returned instead. Consider adjusting "guess" parameter value or initial step size.', in_geom, safety;
 			RETURN NULL;
 		END IF;
  		safety_counter = safety_counter + 1;

		/* Save the old deviation to be compared later to the new one later, calculate the current area and the new deviation from the desired area. */
		old_dev = dev;
		current_area = ST_Area(ST_Buffer(in_geom, guess));
		dev = (current_area - desired_area) / desired_area;

		IF dev < 0 THEN /* Current area is smaller than desired area, increase the buffer distance by the step. */
			guess = guess + step;
		ELSIF dev > 0 THEN /* Current area is larger than desired area, decrease the buffer distance by the step. */
			guess = guess - step;
		ELSE /* Technically shouldn't ever happen because then ABS(dev) is indeed lesser than tol but here just in case. */
			EXIT;
		END IF;

 		IF dev * old_dev < 0 THEN /* Negative value indicates difference of sign, which means we just overestimated the area after underestimating it or vice versa, need to half the step. */
			step = step * 0.5;
		END IF;

	END LOOP;

	RETURN ST_Buffer(in_geom, guess);

END
$$
LANGUAGE plpgsql IMMUTABLE COST 100;

COMMENT ON ST_Dilate IS 'Created by Isaac Boates. Use of this software is at the user''s own risk, and no responsibility is claimed by the author in the event of damages, whether tangible or financial caused directly or indirectly by the use of this software.'