DROP TABLE IF EXISTS NorthSouthVip;
CREATE TABLE NorthSouthVip AS 

WITH NumberedRows AS (
    SELECT
        osm_id,
        min_longitude,
        ROW_NUMBER() OVER (ORDER BY osm_id) AS rn,
        LEAD(min_longitude, 1) OVER (ORDER BY osm_id) as next_long,
        way
    FROM
        northsouthgrid AS SortedRoads
),

SelectArterials AS (
    SELECT 
        osm_id,
        min_longitude,
        way
    FROM
        NumberedRows
    WHERE
        rn % 3 = 0 OR min_longitude = next_long
)

SELECT
    osm_id,
    way
FROM 
    SelectArterials;