WITH RoadIntersections AS (
    SELECT
        a.osm_id AS road1,
        b.osm_id AS road2,
        ST_Intersection(a.way, b.way) AS intersection
    FROM
        planet_osm_line a
    JOIN planet_osm_line b ON ST_Intersects(a.way, b.way)
    WHERE
        a.highway IS NOT NULL AND
        b.highway IS NOT NULL AND
        a.osm_id < b.osm_id  -- Avoid duplicate intersections
),

The error you're encountering is because PostGIS (and PostgreSQL) doesn't support the - operator for geometry data types. My apologies for that oversight.

Instead of the direct - operation on geometries, you should be calculating the vector differences between the X and Y coordinates separately.

Let's correct the angle calculation section. The angle between two vectors u=(x1,y1)u=(x1​,y1​) and v=(x2,y2)v=(x2​,y2​) can be computed as:
angle=arccos⁡(u⋅v∣u∣∣v∣)angle=arccos(∣u∣∣v∣u⋅v​)
Where:

    u⋅vu⋅v is the dot product, calculated as x1×x2+y1×y2x1​×x2​+y1​×y2​.
    ∣u∣∣u∣ is the magnitude (or length) of vector uu, calculated as x12+y12x12​+y12​

    ​, and similarly for ∣v∣∣v∣.

The dot product and the magnitudes must be calculated using the actual X and Y differences of the starting and ending points of the lines.

Here's the corrected SQL section:

sql

GridIntersections AS (
    SELECT
        road1,
        road2,
        intersection,
        -- Calculate the angle between the roads using the dot product
        DEGREES(ACOS(
            (ST_X(ST_StartPoint(a.way)) - ST_X(ST_EndPoint(a.way))) * 
            (ST_X(ST_StartPoint(b.way)) - ST_X(ST_EndPoint(b.way))) +
            (ST_Y(ST_StartPoint(a.way)) - ST_Y(ST_EndPoint(a.way))) * 
            (ST_Y(ST_StartPoint(b.way)) - ST_Y(ST_EndPoint(b.way)))
            /
            (ST_Distance(ST_StartPoint(a.way), ST_EndPoint(a.way)) *
             ST_Distance(ST_StartPoint(b.way), ST_EndPoint(b.way)))
        )) AS angle
    FROM
        RoadIntersections
    JOIN planet_osm_line a ON RoadIntersections.road1 = a.osm_id
    JOIN planet_osm_line b ON RoadIntersections.road2 = b.osm_id
)

SELECT
    road1,
    road2,
    intersection
FROM
    GridIntersections
WHERE
    -- Check if the angle is close to 90 degrees (with some tolerance)
    ABS(angle - 90) < 5;