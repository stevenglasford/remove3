-- Start the transaction
BEGIN;

-------------------NorthSouth arterials altering-------------------------------------------------
UPDATE planet_osm_line
SET oneway = 'no'  
FROM NorthSouthArterials
WHERE 
    planet_osm_line.osm_id = NorthSouthArterials.osm_id;

-------------------NorthSouth South Bound altering-------------------------------------------------
UPDATE planet_osm_line
SET oneway = 'yes'  
FROM NorthSouthSouth
WHERE 
    planet_osm_line.osm_id = NorthSouthSouth.osm_id AND
    ST_Y(ST_StartPoint(planet_osm_line.way)) < ST_Y(ST_EndPoint(planet_osm_line.way));

UPDATE planet_osm_line
SET way = ST_Reverse(planet_osm_line.way),  -- Reverse the way geometry
    oneway = 'yes'  -- Mark as one-way
FROM NorthSouthSouth
WHERE 
    planet_osm_line.osm_id = NorthSouthSouth.osm_id AND
    --check if the road direction is going the opposite direction
    ST_Y(ST_StartPoint(planet_osm_line.way)) > ST_Y(ST_EndPoint(planet_osm_line.way));

-------------------NorthSouth North Bound altering-------------------------------------------------
UPDATE planet_osm_line
SET oneway = 'yes'  
FROM NorthSouthNorth
WHERE 
    planet_osm_line.osm_id = NorthSouthNorth.osm_id AND
    ST_Y(ST_StartPoint(planet_osm_line.way)) > ST_Y(ST_EndPoint(planet_osm_line.way));

UPDATE planet_osm_line
SET way = ST_Reverse(planet_osm_line.way),  -- Reverse the way geometry
    oneway = 'yes'  -- Mark as one-way
FROM NorthSouthNorth
WHERE 
    planet_osm_line.osm_id = NorthSouthNorth.osm_id AND
    --check if the road direction is going the opposite direction
    ST_Y(ST_StartPoint(planet_osm_line.way)) < ST_Y(ST_EndPoint(planet_osm_line.way));

-------------------NorthSouth VIP Bound altering-------------------------------------------------
-- Update the planet_osm_line table based on the NorthSouthVip  table for roads that are already North to South
UPDATE planet_osm_line
SET oneway = 'no', -- Mark as one-way
    highway = 'living_street'
FROM NorthSouthVip
WHERE 
    planet_osm_line.osm_id = NorthSouthVip.osm_id;


-------------------EastWest East Bound altering-------------------------------------------------
UPDATE planet_osm_line
SET oneway = 'yes'  
FROM EastWestSouth
WHERE 
    planet_osm_line.osm_id = EastWestSouth.osm_id AND
    ST_X(ST_StartPoint(planet_osm_line.way)) < ST_X(ST_EndPoint(planet_osm_line.way));

UPDATE planet_osm_line
SET way = ST_Reverse(planet_osm_line.way),  -- Reverse the way geometry
    oneway = 'yes'  -- Mark as one-way
FROM EastWestSouth
WHERE 
    planet_osm_line.osm_id = EastWestSouth.osm_id AND
    --check if the road direction is going the opposite direction
    ST_X(ST_StartPoint(planet_osm_line.way)) > ST_X(ST_EndPoint(planet_osm_line.way));

-------------------EastWest West Bound altering-------------------------------------------------
UPDATE planet_osm_line
SET oneway = 'yes'  
FROM EastWestNorth
WHERE 
    planet_osm_line.osm_id = EastWestNorth.osm_id AND
    ST_X(ST_StartPoint(planet_osm_line.way)) > ST_X(ST_EndPoint(planet_osm_line.way));

UPDATE planet_osm_line
SET way = ST_Reverse(planet_osm_line.way),  -- Reverse the way geometry
    oneway = 'yes'  -- Mark as one-way
FROM EastWestNorth
WHERE 
    planet_osm_line.osm_id = EastWestNorth.osm_id AND
    --check if the road direction is going the opposite direction
    ST_Y(ST_StartPoint(planet_osm_line.way)) < ST_Y(ST_EndPoint(planet_osm_line.way));

-------------------EastWest VIP Bound altering-------------------------------------------------
-- Update the planet_osm_line table based on the NorthSouthVip  table for roads that are already North to South
UPDATE planet_osm_line
SET oneway = 'no',
    highway = 'living_street'
FROM EastWestVip
WHERE 
    planet_osm_line.osm_id = EastWestVip.osm_id;

-------------------EastWest Arterial Bound altering-------------------------------------------------
UPDATE planet_osm_line
SET oneway = 'no'  
FROM EastWestArterials
WHERE 
    planet_osm_line.osm_id = EastWestArterials.osm_id;

-- Commit the transaction
COMMIT;
