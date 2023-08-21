#This script is going to be used from the script: main.sh
# this bash program is available in the same location as this file
#usage: python alters_sql.py <database> <DB_user> <DB_host> <DB_port> <DB_password> <output_filename>

import sys
import psycopg2
import multiprocessing
import xml.etree.ElementTree as ET

def makeEastWestGrid(connection):
    with connection: 
        with connection.cursor() as cursor:
            with open("find_grid_with_sorting_east_west.sql", "r") as f:
                EWQuery = f.read()
            cursor.execute(EWQuery)

def makeNorthSouthGrid(connection):
    with connection:
        with connection.cursor() as cursor:
            with open("find_grid_with_sorting_north_and_south.sql", "r") as f:
                NSQuery = f.read()
            cursor.execute(NSQuery)    
            
db_name=sys.argv[1]
db_user=sys.argv[2]
db_host=sys.argv[3]
db_port=sys.argv[4]
db_password=sys.argv[5]
input_file=sys.argv[6]
output_filename=sys.argv[7]

#Fork two processes, one for getting of the North and South Bound another for the east and west
connection = psycopg2.connect(
        user=db_name,
        password=db_password,
        host=db_host,
        port=db_port,
        database=db_name
)

#run the two grid queries simulataneously to increase speed
NSQ = multiprocessing.Process(target=makeNorthSouthGrid)
EWQ = multiprocessing.Process(target=makeEastWestGrid)

##Start the grid queries
NSQ.start()
EWQ.start()

##Wait for the queries to complete
NSQ.join()
EWQ.join()


#get all of the northsouth arterials
with connection:
    with connection.cursor() as cursor:
        cursor.execute()
        ##Also fetchall fetchmany fetchall
        NSA = cursor.fetchall()

#get all of the northsouth Norths
with connection:
    with connection.cursor() as cursor:
        cursor.execute()
        ##Also fetchall fetchmany fetchall
        NSN = cursor.fetchall()

#get all of the northsouth Souths
with connection:
    with connection.cursor() as cursor:
        cursor.execute()
        ##Also fetchall fetchmany fetchall
        NSS = cursor.fetchall()

#get all of the northsouth VIP
with connection:
    with connection.cursor() as cursor:
        cursor.execute()
        ##Also fetchall fetchmany fetchall
        NSV = cursor.fetchall()

#get all of the eastwest arterials
with connection:
    with connection.cursor() as cursor:
        cursor.execute()
        ##Also fetchall fetchmany fetchall
        EWA = cursor.fetchall()

#get all of the eastwest easts
with connection:
    with connection.cursor() as cursor:
        cursor.execute()
        ##Also fetchall fetchmany fetchall
        EWE = cursor.fetchall()

#get all of the eastwest wests
with connection:
    with connection.cursor() as cursor:
        cursor.execute()
        ##Also fetchall fetchmany fetchall
        EWW = cursor.fetchall()

#get all of the eastwest VIP
with connection:
    with connection.cursor() as cursor:
        cursor.execute()
        ##Also fetchall fetchmany fetchall
        EWV = cursor.fetchall()

tree = ET.parse()
osmroot = tree.getroot()

def NSSouth(root, roads):
    ##Create a temporary dictionary for altering
    for road in roads:
        ##Create a temporary dictionary for altering
        node_data = {}

        ## get all of the nodes for the particular road
        for node in root.findall('node'):
            osm_id = node.get('id')
            lat = float(node.get('lat'))
            node_data[osm_id] = lat


#########NOTICE########
#Please drop all of the following processing tables once complete
#NorthSouthVip
#EastWestVip
#EastWestArterial
#NorthSouthArterial
#EastWestNorth
#EastWestSouth
#NorthSouthNorth
#NorthSouthSouth
#eastwestgrid
#northsouthgrid



#ensure the connection closes at the end
connection.close()

