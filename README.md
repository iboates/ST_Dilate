# ST_Dilate

PostGIS function for dilating (inflating and deflating) polygon geometries.

![](http://iboates.alpheca.uberspace.de/wordpress/wp-content/uploads/2018/04/buffers.png)

## Installation

Run the contents of **ST_Dilate.sql** on your database. The role running it will need to have sufficient priveleges to create functions.

## Use

Call the function any time you want to return a dilated polygon, similar to other PostGIS functions that return a `geoemtry` type, like `ST_Buffer`. See the below example:

`SELECT id, ST_Dilate(geom, 1.5) from my_table;`

This will return the records from `my_table`, with their geometries dilated to 150%.

## Parameters

The parameters for the function are:

* `in_geom GEOMETRY` - The geometry to be dilated. Must be of polygon type.
* `scale_factor GEOMETRY` - Factor by which to dilate the polygon. Cannot be negative. If less than 1, a shrinking will occur. If greater than 1, an expansion will occur.
* `tol FLOAT` - Tolerance value. Since the solution is iterative, an exact dilation is near-impossible. The geometry returned will be the first one found that whose normalized difference from the theoretical dilated area (`scale factor * ST_Area(in_geom)`) is less than this value. Default value is 0.001 (0.1%).
* `guess` - The first buffer distance that will be tested. Subsequent attempts will be plus or minus half of this amount until it is necessary to switch from expansion to growth or vice versa. It is a good idea to set this value to be approximately around the order of magnitude of the expected required distance. Default value is 1.
* `safety` - The number of attempted buffer operations before giving up and returning a NULL geometry. Since the solution is iterative, this acts as a failsafe to prevent infinte loops from occuring in the event of unexpected behaviour. Default value is 1000.

## How it works

The function first calculates the desired final area by multiplying `in_geom`‘s area by scale_factor. It then buffers `in_geom` using a distance value of `guess`. After comparing the area of the resultant buffered polygon with the desired final area, it increments (if the resultant buffered polygon’s area was too small) or decrements (if it was too big) `guess` by half of itself and tries again. If the resultant buffer polygon’s area is bigger than the desired final area on the last run, and is smaller on the current run, the amount by which `guess` is incremented or decremented is halved. Once the resultant buffered polygon’s area is sufficiently similar to the desired final area (if the normalized difference is less than `tol`), then this resultant buffered polygon is returned.

`safety` is a parameter that indicates the maximum number of attempts to find the correct final buffered polygon before giving up and returning a `NULL` geometry. This is intended to be a failsafe measure to avoid creating an infinite loop and causing damage to the greater system in the event of unintended behaviour.

## The `guess` parameter

The blue line is the first attempt at dilating a polygon, using a guess value of 25. The orange line is the same polygon, but with a guess value of 100.

![](http://iboates.alpheca.uberspace.de/wordpress/wp-content/uploads/2018/04/dilation_chart.png)

We can clearly see that changing this initial guess can have significant effects on the amount of iterations needed to arrive at the correctly buffered polygon. This is important to keep in mind when dilating your polygons. Changing the tolerance would have an effect, too – but at the cost of precision.
