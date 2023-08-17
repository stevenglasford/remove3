#This file contains the controlling aspects of the remove3 program
#Check if there is already a conversion from the OSM to psql

##Requistites
#1. Postgres
#2. osm2pgsql https://osm2pgsql.org/
#3. python
#4. raw OSM data, included in this repo is the OSM data for the city of Minneapolis

#Check to see if the information was already parsed using osm2pgsql
MAIN_FILE=./minneapolis.osm #hardcode the file for testing
#MAIN_FILE=$1 #Use the first command line argument in production
if test -f "${MAIN_FILE}.sql"; then
    #SQL file has been dumped and can be loaded into the computer
    #Check to see if the osm information is loaded into postgres
then 
    #osm2pgsql has not been ran, it must be ran
fi