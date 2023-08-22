-- Save the results for faster speeds
DROP TABLE IF EXISTS EastWestArterials;
CREATE TABLE EastWestArterials AS 

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
        rn % 6 = 0 OR min_latitude = next_lat
)

SELECT
    osm_id
FROM 
    SelectArterials;