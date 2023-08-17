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
PG_PASSWORD="minneapolis"
# PG_PASSWORD=$2 #The postgres password should be the second command line argument

#check to see if the postgres is installed and everything
if [ pg_isready ]; then
    echo "postgres is ready to go"
else 
    echo "postgres is not properly installed and configured"
    exit 1
fi 

#check to see if python is installed
if [[ "$(python -V)" =~ "Python 3" ]]; then
    echo "Python is installed"
else 
    echo "Python is not installed"
    exit 2
fi

if test -f "${MAIN_FILE}.sql"; then
    #SQL file has been dumped and can be loaded into the computer
    #Check to see if the osm information is loaded into postgres
    if [ psql -lqt | cut -d \| -f 1 | grep -qw osm ]; then
        echo "The OSM database exists, I will just use that one"
    else
        echo "The OSM database backup exists, but it hasn't been loaded yet, I will load it for you"
        echo "I will make a new database called osm, if you don't to do that please refuse the password"
        psql -h localhost -d osm -U postgres -W -f ${MAIN_FILE}.sql
    fi
then
    #osm2pgsql has not been ran, it must be ran
    osm2pgsql -c -d osm -U postgres -H localhost $MAIN_FILE -W
    # osm2pgsql -c -d osm -U postgres -H localhost ./minneapolis.osm
    #export the database to a sql file so it is able to revisited
    pg_dump -U postgres -h localhost -p 5432 -d osm > ${MAIN_FILE}.sql
fi

