DROP TABLE IF EXISTS public.st_dilate_testresult;
CREATE TABLE public.st_dilate_testresult (
	test_name TEXT,
	expected_area FLOAT,
	actual_area FLOAT,
	deviation FLOAT,
	geom GEOMETRY
);

DO
$$
DECLARE polygon GEOMETRY = ST_GeomFromText('Polygon ((-0.83966746 0.695962, 0.30760095 0.695962, 0.30760095 -0.29928741, -0.83966746 -0.29928741, -0.83966746 0.695962))');
DECLARE multipolygon GEOMETRY = ST_GeomFromText('MultiPolygon (((-0.83966746 0.695962, 0.30760095 0.695962, 0.30760095 -0.29928741, -0.83966746 -0.29928741, -0.83966746 0.695962)))');
BEGIN
INSERT INTO
	public.st_dilate_testresult
VALUES
(
	'Base polygon',
	NULL,
	ST_Area(polygon),
	NULL,
	polygon
),
(
	'Base multipolygon',
	NULL,
	ST_Area(multipolygon),
	NULL,
	multipolygon
),
(
	'Polygon, positive scale factor',
	1.5*ST_Area(polygon),
	ST_Area(ST_Dilate(polygon, 1.5)),
	(ST_Area(ST_Dilate(polygon, 1.5)) - 1.5*ST_Area(polygon)) / 1.5*ST_Area(polygon),
	ST_Dilate(polygon, 1.5)
),
(
	'Polygon, negative scale factor',
	1.5*ST_Area(polygon),
	ST_Area(ST_Dilate(polygon, -1)),
	(ST_Area(ST_Dilate(polygon, -1)) - 1.5*ST_Area(polygon)) / 1.5*ST_Area(polygon),
	ST_Dilate(polygon, -1)
),
(
	'Multipolygon, positive scale factor',
	1.5*ST_Area(multipolygon),
	ST_Area(ST_Dilate(multipolygon, 1.5)),
	(ST_Area(ST_Dilate(multipolygon, 1.5)) - 1.5*ST_Area(multipolygon)) / 1.5*ST_Area(multipolygon),
	ST_Dilate(multipolygon, 1.5)
),
(
	'Multiolygon, negative scale factor',
	1.5*ST_Area(multipolygon),
	ST_Area(ST_Dilate(multipolygon, -1)),
	(ST_Area(ST_Dilate(multipolygon, -1)) - 1.5*ST_Area(multipolygon)) / 1.5*ST_Area(multipolygon),
	ST_Dilate(multipolygon, -1)
),
(
	'Trip safety',
	1.5*ST_Area(polygon),
	ST_Area(ST_Dilate(polygon, 1000, safety:=1, guess:=0.0001)),
	(ST_Area(ST_Dilate(polygon, 1000, safety:=1, guess:=0.0001)) - 1.5*ST_Area(polygon)) / 1.5*ST_Area(polygon),
	ST_Dilate(polygon, 1000, safety:=1, guess:=0.0001)
)
;
END
$$;