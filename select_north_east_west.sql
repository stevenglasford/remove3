DROP TABLE IF EXISTS EastWestNorth;
CREATE TABLE EastWestNorth AS 

WITH NumberedRows AS (
    SELECT
        osm_id,
        min_latitude,
        ROW_NUMBER() OVER (ORDER BY osm_id) AS rn,
        LEAD(min_latitude, 1) OVER (ORDER BY osm_id) as next_lat
    FROM
        eastwestgrid AS SortedRoads
),

SelectArterials AS (
    SELECT 
        osm_id,
        min_latitude

    FROM
        NumberedRows
    WHERE
        (rn % 6 = 1 OR rn % 6 = 4) OR min_latitude = next_lat
)

SELECT b.*
from (SELECT
        osm_id
    FROM 
        SelectArterials) a
left join planet_osm_line b On a.osm_id=b.osm_id;