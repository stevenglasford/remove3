-- Create a new table to store the northsouthgrid so it doesn't need to recompute multiple times
DROP TABLE IF EXISTS eastwestgrid;
CREATE TABLE eastwestgrid AS 

WITH GridSelection AS (-- Assuming the previous GridIntersections CTE is already there
    WITH RoadIntersections AS (
        SELECT
            a.osm_id AS road1,
            b.osm_id AS road2,
            ST_Intersection(a.way, b.way) AS intersection
        FROM
            planet_osm_line a
        JOIN planet_osm_line b ON ST_Intersects(a.way, b.way)
        WHERE
            --Only select the roadways, skip bike paths and other non-roadways
            (a.highway = 'motorway' OR a.highway = 'corridor' OR a.highway = 'trunk' OR a.highway = 'secondary_link' OR a.highway='secondary_link' OR 
            a.highway='tertiary' OR a.highway='tertiary_link' OR a.highway='residential' OR a.highway='primary_link' OR a.highway='primary' OR a.highway='motor_link') AND
            (b.highway = 'motorway' OR b.highway = 'corridor' OR b.highway = 'trunk' OR b.highway = 'secondary_link' OR b.highway='secondary_link' OR
            b.highway='tertiary' OR b.highway='tertiary_link' OR b.highway='residential' OR b.highway='primary_link' OR b.highway='primary' OR b.highway='motor_link') AND

            a.name IS NOT NULL AND
            b.name IS NOT NULL AND
            a.osm_id < b.osm_id  AND -- Avoid duplicate intersections
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
    ),

    -- 1. Total Intersections per road
    TotalIntersections AS (
        SELECT
            a.osm_id AS road,
            COUNT(DISTINCT b.osm_id) AS total_intersections
        FROM
            planet_osm_line a
        JOIN planet_osm_line b ON ST_Intersects(a.way, b.way) 
        WHERE 
            a.highway IS NOT NULL AND
            b.highway IS NOT NULL AND
            a.osm_id <> b.osm_id
        GROUP BY
            a.osm_id
    ),

    -- 2. Grid Intersections per road
    GridIntersectionsCount AS (
        SELECT
            road1 AS road,
            COUNT(DISTINCT road2) AS grid_intersections
        FROM
            GridIntersections
        GROUP BY
            road1
    )

    -- 3. Filtering streets with more than 5 non-grid intersections
    SELECT
        t.road osm_id,
        (SELECT 
            way
        FROM planet_osm_line pol
        WHERE pol.osm_id = t.road
        --If there are multiple returns then select the first as all of the entries will be homogeneous
        LIMIT 1)
    FROM
        TotalIntersections t
    LEFT JOIN
        GridIntersectionsCount g ON t.road = g.road
    WHERE
        t.total_intersections - COALESCE(g.grid_intersections, 0) > 5
),

-- Calculate the orientation of each road
RoadOrientations AS (
    SELECT
        osm_id,
        DEGREES(
            ATAN2(
                ST_Y(ST_EndPoint(way)) - ST_Y(ST_StartPoint(way)),
                ST_X(ST_EndPoint(way)) - ST_X(ST_StartPoint(way))
            )
        ) AS orientation_angle
    FROM 
        GridSelection
),

-- Filter for north-south roads
EastWestRoads AS (
    SELECT 
        *
    FROM 
        RoadOrientations
    WHERE 
        (ABS(orientation_angle) < 45) OR 
        (ABS(orientation_angle - 180) < 45)
),

-- Find the minimum latitude for each east-west road
MinLatitude AS (
    SELECT 
        osm_id, 
        MIN(ST_Y(ST_StartPoint(way))) AS min_latitude,
        way
    FROM 
        GridSelection
    WHERE 
        osm_id IN (SELECT osm_id FROM EastWestRoads)
    GROUP BY 
        osm_id,
        way
),

--Filter out all of the curvy lake roads and other curvy roads
Straightness AS (
    SELECT 
        osm_id,
        min_latitude,
        way
    FROM 
        MinLatitude
    WHERE 
        --Filter out the case when the denominator is zero
        CASE 
            WHEN ST_Distance(ST_StartPoint(way), ST_EndPoint(way)) = 0 THEN NULL
            ELSE ST_Length(way) / ST_Distance(ST_StartPoint(way), ST_EndPoint(way))
        END >= 0.95
)

-- Finally, sort the east-west roads from north to sort based on minimum latitude
SELECT 
    s.osm_id, 
    s.min_latitude,
    s.way
FROM 
    straightness s
ORDER BY 
    s.min_latitude ASC;