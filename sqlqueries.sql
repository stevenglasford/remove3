select highway,osm_id from planet_osm_roads where highway is not null limit 2;

--Getting the roadway columns, find results in planet_osm_roads_columns.txt
\d+ planet_osm_roads

select distinct highway from planet_osm_roads;
--     highway     
-- ----------------
 
--  trunk
--  footway
--  cycleway
--  secondary
--  trunk_link
--  secondary_link
--  construction
--  primary
--  residential
--  track
--  primary_link
--  motorway_link
--  motorway
--  service
--  path
-- (16 rows)

select way from planet_osm_roads where name is not null limit 1;
--result found in ways_example.txt

\d+ planet_osm_roads_way_idx 
--            Index "public.planet_osm_roads_way_idx"
--  Column |  Type  | Key? | Definition | Storage | Stats target 
-- --------+--------+------+------------+---------+--------------
--  way    | box2df | yes  | way        | plain   | 
-- gist, for table "public.planet_osm_roads"
-- Options: fillfactor=100

select 