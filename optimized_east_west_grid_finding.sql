---This was a query to see if chatgpt could make a more efficient finding algoritm,
--it was unsuccessful, but is interesting nonetheless
--- Dont use this one

-- Create a new table to store the optimized eastwestgrid
CREATE TABLE IF NOT EXISTS optimized_eastwestgrid AS

WITH RoadIntersections AS (
    SELECT a.osm_id AS road1, b.osm_id AS road2, ST_Intersection(a.way, b.way) AS intersection
    FROM planet_osm_line a
    JOIN planet_osm_line b ON ST_Intersects(a.way, b.way)
    WHERE a.highway IS NOT NULL 
    AND b.highway IS NOT NULL 
    AND a.osm_id < b.osm_id  
    AND ST_Distance(ST_StartPoint(a.way), ST_EndPoint(a.way)) > 0 
    AND ST_Distance(ST_StartPoint(b.way), ST_EndPoint(b.way)) > 0
),
GridIntersections AS (
    SELECT road1, road2, intersection,
    DEGREES(ACOS(
        LEAST(GREATEST(
            (ST_X(ST_StartPoint(a.way)) - ST_X(ST_EndPoint(a.way))) * 
            (ST_X(ST_StartPoint(b.way)) - ST_X(ST_EndPoint(b.way))) +
            (ST_Y(ST_StartPoint(a.way)) - ST_Y(ST_EndPoint(a.way))) * 
            (ST_Y(ST_StartPoint(b.way)) - ST_Y(ST_EndPoint(b.way))) 
            /
            (ST_Distance(ST_StartPoint(a.way), ST_EndPoint(a.way)) * 
            ST_Distance(ST_StartPoint(b.way), ST_EndPoint(b.way))), 
        -1), 1)
    )) AS angle
    FROM RoadIntersections
    JOIN planet_osm_line a ON RoadIntersections.road1 = a.osm_id
    JOIN planet_osm_line b ON RoadIntersections.road2 = b.osm_id
),
TotalIntersections AS (
    SELECT a.osm_id AS road, COUNT(DISTINCT b.osm_id) AS total_intersections
    FROM planet_osm_line a
    JOIN planet_osm_line b ON ST_Intersects(a.way, b.way) 
    WHERE a.highway IS NOT NULL 
    AND b.highway IS NOT NULL 
    AND a.osm_id <> b.osm_id
    GROUP BY a.osm_id
),
GridIntersectionsCount AS (
    SELECT road1 AS road, COUNT(DISTINCT road2) AS grid_intersections
    FROM GridIntersections
    GROUP BY road1
),
GridSelection AS (
    SELECT t.road osm_id, pol.way
    FROM TotalIntersections t
    LEFT JOIN GridIntersectionsCount g ON t.road = g.road
    JOIN planet_osm_line pol ON pol.osm_id = t.road
    WHERE t.total_intersections - COALESCE(g.grid_intersections, 0) > 5
    LIMIT 1
),
RoadOrientations AS (
    SELECT osm_id,
    DEGREES(ATAN2(
        ST_Y(ST_EndPoint(way)) - ST_Y(ST_StartPoint(way)),
        ST_X(ST_EndPoint(way)) - ST_X(ST_StartPoint(way))
    )) AS orientation_angle
    FROM GridSelection
),
EastWestRoads AS (
    SELECT * FROM RoadOrientations
    WHERE ABS(orientation_angle) < 45 OR ABS(orientation_angle - 180) < 45
),
MinLatitude AS (
    SELECT osm_id, MIN(ST_Y(ST_StartPoint(way))) AS min_latitude
    FROM GridSelection
    WHERE EXISTS (SELECT 1 FROM EastWestRoads ew WHERE ew.osm_id = GridSelection.osm_id)
    GROUP BY osm_id
)
SELECT m.osm_id, m.min_latitude
FROM MinLatitude m
ORDER BY m.min_latitude ASC;
