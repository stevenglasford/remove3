DROP TABLE IF EXISTS NorthSouthNorth;
CREATE TABLE NorthSouthNorth AS 

WITH NumberedRows AS (
    SELECT
        osm_id,
        min_longitude,
        ROW_NUMBER() OVER (ORDER BY osm_id) AS rn,
        LEAD(min_longitude, 1) OVER (ORDER BY osm_id) as next_long
    FROM
        northsouthgrid AS SortedRoads
),

SelectArterials AS (
    SELECT 
        osm_id,
        min_longitude
    FROM
        NumberedRows
    WHERE
        (rn % 6 = 1 OR rn % 6 = 4) OR min_longitude = next_long
)

SELECT b.*
from (SELECT
        osm_id
    FROM 
        SelectArterials) a
left join planet_osm_line b On a.osm_id=b.osm_id;