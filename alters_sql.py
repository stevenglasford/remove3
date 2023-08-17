#This script is going to be used from the script: main.sh
# this bash program is available in the same location as this file
#usage: python alters_sql.py <database> <DB_user> <DB_host> <DB_port> <DB_password> <output_filename>

import sys
import psycopg2

db_name=sys.argv[1]
db_user=sys.argv[2]
db_host=sys.argv[3]
db_port=sys.argv[4]
db_password=sys.argv[5]
output_filename=sys.argv[6]

connection = psycopg2.connect(
        user=db_name,
        password=db_password,
        host=db_host,
        port=db_port,
        database=db_name
)
#try connecting to the Postgres table
with connection:
    with connection.cursor() as cursor:
        cursor.execute()
        ##Also fetchall fetchmany fetchall
        record = cursor.fetchone()

#ensure the connection closes at the end
connection.close()