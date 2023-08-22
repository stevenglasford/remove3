#usage: main.sh <osm_file> <postgres_user> <postgres_password> <pg_host> <pg_port> <postgres_DB_name>

#This file contains the controlling aspects of the remove3 program
#Check if there is already a conversion from the OSM to psql

##Requistites
#1. Postgres
#2. osm2pgsql https://osm2pgsql.org/
#3. python
#4. raw OSM data, included in this repo is the OSM data for the city of Minneapolis
#5. postgis
#6. osmosis

#Check to see if the information was already parsed using osm2pgsql
MAIN_FILE=./minneapolis.osm #hardcode the file for testing
#MAIN_FILE=$1 #Use the first command line argument in production
PG_USER="postgres"
# PG_USER=$2
PG_PASSWORD="minneapolis"
# PG_PASSWORD=$3 #The postgres password should be the second command line argument
PG_HOST="localhost"
# PG_HOST=$4
PG_PORT=5432
# PG_PORT=$5
DATABASE_NAME="osm"
# DATABASE_NAME=$6
OUTPUT_FILE="minneapolis.alters.osm"
# OUTPUT_FILE=$7

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
    if psql -lqt | cut -d \| -f 1 | grep -qw $DATABASE_NAME; then
        echo "The OSM database exists, I will just use that one"
    else
        echo "The OSM database backup exists, but it hasn't been loaded yet, I will load it for you"
        echo "I will make a new database called osm, if you don't to do that please refuse the password"
        psql -h $PG_HOST -d $DATABASE_NAME -U $PG_USER -W -f ${MAIN_FILE}.sql
    fi
else
    #osm2pgsql has not been ran, it must be ran
    osm2pgsql -c -d $DATABASE_NAME -U $PG_USER -H $PG_HOST $MAIN_FILE -W
    # osm2pgsql -c -d osm -U postgres -H localhost ./minneapolis.osm
    #export the database to a sql file so it is able to revisited
    pg_dump -U $PG_USER -h $PG_HOST -p 5432 -d $DATABASE_NAME > ${MAIN_FILE}.sql
fi

##create the postgis extension in postgis
psql -h $PG_HOST -U $PG_USER -d $DATABASE_NAME -c 'CREATE EXTENSION IF NOT EXISTS postgis;'

OUTPUT_FILE=${MAIN_FILE}.remove3.osm
python alters_sql.py $DATABASE_NAME $PG_USER $PG_HOST $PG_PORT $PG_PASSWORD $MAIN_FILE "${MAIN_FILE}.remove3.osm"

##pull out the altered osm file and save it
osmosis --read-pgsql host=$PG_HOST database=$DATABASE_NAME user=$PG_USER password=$PG_PASSWORD --write-xml file=$OUTPUT_FILE