select highway,osm_id from planet_osm_roads where highway is not null limit 2;

--Getting the roadway columns, find results in planet_osm_roads_columns.txt
\d+ planet_osm_roads

select distinct highway from planet_osm_roads;
--     highway     
-- ----------------
 
--  trunk
--  footway
--  cycleway
--  secondary
--  trunk_link
--  secondary_link
--  construction
--  primary
--  residential
--  track
--  primary_link
--  motorway_link
--  motorway
--  service
--  path
-- (16 rows)

select way from planet_osm_roads where name is not null limit 1;
--result found in ways_example.txt

\d+ planet_osm_roads_way_idx 
--            Index "public.planet_osm_roads_way_idx"
--  Column |  Type  | Key? | Definition | Storage | Stats target 
-- --------+--------+------+------------+---------+--------------
--  way    | box2df | yes  | way        | plain   | 
-- gist, for table "public.planet_osm_roads"
-- Options: fillfactor=100


--- An interesting query from chatgpt it tries to select the roadways that form a grid
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
            ST_Dot(ST_StartPoint(a.way) - ST_EndPoint(a.way),
                   ST_StartPoint(b.way) - ST_EndPoint(b.way)) /
            (ST_Length(a.way) * ST_Length(b.way))
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

--Select all of the roadways that need to be converted into arterials

--Select all of the roadways that need to be converted into northbound


--Select all of the roadways that need to be converted into southbound

--Select all of the roadways that need to be converted into VIP

--Select all of the roadways that are "straight", trying to remove curvy roads around the lakes
SELECT 
    road_name,
    geometry
FROM 
    roads
WHERE 
    ST_Length(geometry) / ST_Distance(ST_StartPoint(geometry), ST_EndPoint(geometry)) >= 0.95;
