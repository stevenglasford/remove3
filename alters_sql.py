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

print(db_password)

#Fork two processes, one for getting of the North and South Bound another for the east and west
connection = psycopg2.connect(
        user=db_user,
        password=db_password,
        host=db_host,
        port=db_port,
        database=db_name
)

#run the two grid queries simulataneously to increase speed
NSQ = multiprocessing.Process(target=makeNorthSouthGrid(connection))
EWQ = multiprocessing.Process(target=makeEastWestGrid(connection))

##Start the grid queries
NSQ.start()
EWQ.start()

##Wait for the queries to complete
NSQ.join()
EWQ.join()


#get all of the northsouth arterials
with connection: 
    with connection.cursor() as cursor:
        with open("select_arterials_north_south.sql", "r") as f:
            SNSA = f.read()
        cursor.execute(SNSA)

#get all of the northsouth Norths
with connection:
    with connection.cursor() as cursor:
        with open("select_north_north_south.sql", "r") as f:
            SNSN = f.read()
        cursor.execute(SNSN)

#get all of the northsouth Souths
with connection:
    with connection.cursor() as cursor:
        with open("select_south_north_south.sql", "r") as f:
            SNSS = f.read()
        cursor.execute(SNSS)

#get all of the northsouth VIP
with connection:
    with connection.cursor() as cursor:
        with open("select_vip_north_south.sql", "r") as f:
            SNSV = f.read()
        cursor.execute(SNSV)

#get all of the eastwest arterials
with connection:
    with connection.cursor() as cursor:
        with open("select_arterials_east_west.sql", "r") as f:
            SEWA = f.read()
        cursor.execute(SEWA)

#get all of the eastwest easts
with connection:
    with connection.cursor() as cursor:
        with open("select_north_east_west.sql", "r") as f:
            SEWN = f.read()
        cursor.execute(SEWN)

#get all of the eastwest wests
with connection:
    with connection.cursor() as cursor:
        with open("select_south_east_west.sql", "r") as f:
            SEWS = f.read()
        cursor.execute(SEWS)

#get all of the eastwest VIP
with connection:
    with connection.cursor() as cursor:
        with open("select_vip_east_west.sql", "r") as f:
            SEWV = f.read()
        cursor.execute(SEWS)

##Alter the SQL table
with connection:
    with connection.cursor() as cursor:
        with open("alters.sql", "r") as f:
            alters = f.read()
        cursor.execute(alters)

##Clean up the temporary tables made for speed enhancments
with connection:
    with connection.cursor() as cursor:
        with open('littletablecleanup.sql', 'r') as f:
            cleanup = f.read()
        cursor.execute(cleanup)

#ensure the connection closes at the end
connection.close()

