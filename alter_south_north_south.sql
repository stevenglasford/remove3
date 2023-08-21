-- This query alters and installs the North/South southbound roads
BEGIN;

-- Update the geometry. NEED TO DO: CHECK THE EXISTING DIRECTION OF THE ROAD
UPDATE planet_osm_line
SET way = ST_Reverse(way)
WHERE osm_id IN (SELECT osm_id from NorthSouthSouth);
---Can use the PostGIS command ST_StartPoint
---Can use the PostGIS command ST_EndPoint

--Check the direction of the road



--Update the oneway attribute
UPDATE planet_osm_line
SET oneway = CASE
                WHEN oneway = 'yes' THEN '-1'
                WHEN oneway = '-1'  THEN 'yes'
                ---not sure if this correct
                ELSE oneway
            END
WHERE osm_id IN (SELECT osm_id FROM NorthSouthSouth);

-- Commit to the transactions
COMMIT;