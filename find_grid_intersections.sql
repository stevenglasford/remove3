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
        ST_Distance(ST_StartPoint(a.way), ST_EndPoint(a.way)) > 0 AND  -- filter "zero" roads
        ST_Distance(ST_StartPoint(b.way), ST_EndPoint(b.way)) > 0
),

GridIntersections AS (
    SELECT
        road1,
        road2,
        intersection,
        -- Calculate the angle between the roads using the dot product
        DEGREES(ACOS(
            LEAST(GREATEST(
                (ST_X(ST_StartPoint(a.way)) - ST_X(ST_EndPoint(a.way))) * 
                (ST_X(ST_StartPoint(b.way)) - ST_X(ST_EndPoint(b.way))) +
                (ST_Y(ST_StartPoint(a.way)) - ST_Y(ST_EndPoint(a.way))) * 
                (ST_Y(ST_StartPoint(b.way)) - ST_Y(ST_EndPoint(b.way)))
                /
                (ST_Distance(ST_StartPoint(a.way), ST_EndPoint(a.way)) *
                ST_Distance(ST_StartPoint(b.way), ST_EndPoint(b.way))),
            -1), 1)  -- Clamping the value to [-1, 1]
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