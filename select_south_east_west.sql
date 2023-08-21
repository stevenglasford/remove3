DROP TABLE IF EXISTS EastWestSouth;
CREATE TABLE EastWestSouth AS 


WITH NumberedRows AS (
    SELECT
        osm_id,
        min_latitude,
        ROW_NUMBER() OVER (ORDER BY osm_id) AS rn,
        LEAD(min_latitude, 1) OVER (ORDER BY osm_id) as next_lat,
        way
    FROM
        eastwestgrid AS SortedRoads
),

SelectArterials AS (
    SELECT 
        osm_id,
        min_latitude,
        way
    FROM
        NumberedRows
    WHERE
        (rn % 6 = 2 OR rn % 6 = 5) OR min_latitude = next_lat
)

SELECT
    osm_id,
    way
FROM 
    SelectArterials;