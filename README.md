# remove3
A collection of information that attempts to implement a system called "remove3" onto a gridded system

There is an osm file of the city of Minneapolis. Called "minneapolis.osm"

This program attempts several things
1. altering the streets of Minneapolis in the most efficient manor in order to apply the remove3 transformation over any city.
2. It attempts to grade the griddedness of the city
3. It should be able to be implemented for any osm data map
4. Running the main alter.py script should result in the a new osm file called "<map_name>.remove3.osm"

TODO: in the near future I would also like to reroute all of the bus lines in the city in accordance with the remove3 principle of making express and local bus lines.

Goals: Make this process utilize all cores on a machine and be super fast. Vrooom

**********************************
Update: 8-26-2023

So far remove3 is actually running well. Currently I am testing to see if I can pull out the changes that were accomplished in the the main SQL calls.

Next step is to connect it to glasford.io
Not so sure how to do that yet, but I was thinking of just doing it in C# cus that is what the state of Minnesota government writes with. Though I might also make one in python.

*****************************************************
UPDATE 9-3-2023

The query calls are complete and improving and in the process of clearing and fixing edge cases (such as random squares that are selected).

Public Transport alterations needs to be implemented still, this will be a bigger project.

How to see your new remove3 city:

Step one: ensure you have the requists.
    1. Python 
    2. Postgres
    3. QGIS

Run the ./main.sh script. This will tell you what is wrong mostly, it will check dependencies as well. It will crash at the end but the queries for now are complete.

After the queries are ran open QGIS, and connect the postgres database that stores the altered database. 
QGIS will show you the new map rather nicey. There is a folder in this repo that contains some information and images of some of the output from the analysis on Minneapolis.