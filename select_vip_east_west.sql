DROP TABLE IF EXISTS EastWestVip;
CREATE TABLE EastWestVip AS 

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
        rn % 3 = 0 OR min_latitude = next_lat
),

--Select living streets that already exists.
SelectExistingVip AS (
    SELECT osm_id 
    FROM planet_osm_line
    WHERE highway = 'living_street'
),

SelectAll AS (
    SELECT osm_id 
    FROM SelectArterials
    UNION ALL
    SELECT osm_id 
    FROM SelectExistingVip
)


SELECT b.*
from (SELECT
        osm_id
    FROM 
        SelectAll) a
left join planet_osm_line b On a.osm_id=b.osm_id;
