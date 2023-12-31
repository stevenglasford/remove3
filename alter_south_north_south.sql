-- Start the transaction
BEGIN;

-- Update the planet_osm_line table based on the roads_info table for roads that are already South to North
UPDATE planet_osm_line
SET oneway = 'yes'  -- Mark as one-way
FROM NorthSouthSouth
WHERE 
    planet_osm_line.osm_id = NorthSouthSouth.osm_id AND
    ST_Y(ST_StartPoint(planet_osm_line.way)) > ST_Y(ST_EndPoint(planet_osm_line.way));

-- Update the planet_osm_line table based on the roads_info table for roads that are North to South
UPDATE planet_osm_line
SET way = ST_Reverse(planet_osm_line.way),  -- Reverse the way geometry
    oneway = 'yes'  -- Mark as one-way
FROM NorthSouthSouth
WHERE 
    planet_osm_line.osm_id = NorthSouthSouth.osm_id AND
    ST_Y(ST_StartPoint(planet_osm_line.way)) < ST_Y(ST_EndPoint(planet_osm_line.way));

-- Commit the transaction
COMMIT;
