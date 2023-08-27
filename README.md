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
Update: 9-26-2023

So far remove3 is actually running well. Currently I am testing to see if I can pull out the changes that were accomplished in the the main SQL calls.

Next step is to connect it to glasford.io
Not so sure how to do that yet, but I was thinking of just doing it in C# cus that is what the state of Minnesota government writes with. Though I might also make one in python.