select highway,osm_id from planet_osm_roads where highway is not null limit 2;

--Getting the roadway columns, find results in planet_osm_roads_columns.txt
\d+ planet_osm_roads
