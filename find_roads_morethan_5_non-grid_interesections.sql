-- Assuming the previous GridIntersections CTE is already there
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
    t.road,
    COALESCE(g.grid_intersections, 0) AS grid_intersections,
    t.total_intersections,
    t.total_intersections - COALESCE(g.grid_intersections, 0) AS non_grid_intersections
FROM
    TotalIntersections t
LEFT JOIN
    GridIntersectionsCount g ON t.road = g.road
WHERE
    t.total_intersections - COALESCE(g.grid_intersections, 0) > 5;
