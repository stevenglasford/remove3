-- Start the transaction
BEGIN;

-------------------NorthSouth arterials altering-------------------------------------------------

UPDATE planet_osm_line
SET oneway = 'no'  
FROM NorthSouthArterials
WHERE 
    planet_osm_line.osm_id = NorthSouthSouth.osm_id;

COMMIT;
