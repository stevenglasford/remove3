-- Start the transaction
BEGIN;

-- Update the planet_osm_line table based on the roads_info table for roads that are already North to South
UPDATE planet_osm_line
SET way = planet_osm_line.way,  -- Replace with any additional columns you may want to update
    oneway = 'yes'  -- Mark as one-way
FROM roads_info
WHERE 
    planet_osm_line.osm_id = roads_info.osm_id AND
    ST_Y(ST_StartPoint(planet_osm_line.way)) > ST_Y(ST_EndPoint(planet_osm_line.way));

-- Update the planet_osm_line table based on the roads_info table for roads that are South to North
UPDATE planet_osm_line
SET way = ST_Reverse(planet_osm_line.way),  -- Reverse the way geometry
    oneway = 'yes'  -- Mark as one-way
FROM roads_info
WHERE 
    planet_osm_line.osm_id = roads_info.osm_id AND
    ST_Y(ST_StartPoint(planet_osm_line.way)) < ST_Y(ST_EndPoint(planet_osm_line.way));

-- Commit the transaction
COMMIT;
