DROP TABLE IF EXISTS NorthSouthVip;
CREATE TABLE NorthSouthVip AS 

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
        rn % 3 = 0 OR min_longitude = next_long
)

-- --Select living streets that already exists.
-- SelectExistingVip AS (
--     SELECT osm_id 
--     FROM planet_osm_line 
--     WHERE highway = 'living_street'
-- ),

-- SelectAll AS (
--     SELECT osm_id 
--     FROM SelectArterials
--     UNION ALL
--     SELECT osm_id 
--     FROM SelectExistingVip
-- )

SELECT b.*
from (SELECT
        osm_id
    FROM 
        SelectArterials) a
left join planet_osm_line b On a.osm_id=b.osm_id;