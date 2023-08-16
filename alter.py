###Usage: altering_minneapolis.py <osm_file>
from lxml import etree as ET
import sys
import os
from concurrent.futures import ProcessPoolExecutor

### Set concurrency chunk size
chunk_size = 1000000


def find_highways_in_chunk(chunk):
    highways = []
    root = ET.fromstring(chunk)
    
    # Iterate through all the ways in this chunk
    for way in root.findall('way'):
        for tag in way.findall('tag'):
            if tag.get('k') == 'highway':
                highways.append(way)
                break
                
    return highways

def simple_extract_highways(filename):
    tree = ET.parse(filename)
    root = tree.getroot()

    highways = []

    for way in root.findall('way'):
        for tag in way.findall('tag'):
            if tag.get('k') == 'highway':
                highways.append(way)
                break
    
    return highways

def split_file_into_chunks(filename,chunk_size):
    chunks = []
    with open(filename, 'r', encoding='utf-8)') as file:
        while True:
            start_of_chunk = file.tell() #remember the start of this chunk
            chunk = file.read(chunk_size)  # read the desired chunk size
            if not chunk:  # end of file
                break

            # continue reading until the next closing way tag to ensure valid XML fragments
            while '</way>' not in chunk and chunk:
                line = file.readline()
                chunk += line
            # once the valid chunk is found, append to the chunks list
            chunks.append(chunk)
    return chunks

def extract_highways_parallel(filename, num_processes=None):
    highways = []

    with open(filename, 'r', encoding='utf-8') as file:
        chunk = file.read(chunk_size)
        while chunk:
            next_chunk = file.read(chunk_size)
            chunk += next_chunk.split('</osm>', 1)[0]

            if '</osm>' in next_chunk:
                chunk += '</osm>'

            highways.extend(find_highways_in_chunk(chunk))

    return highways

if __name__ == '__main__':
    with ProcessPoolExecutor as executor:
        chunks = split_file_into_chunks(sys.argv[1])
        results = list(executor.map(find_highways_in_chunk, chunks))

    highways_list = [item for sublist in results for item in sublist]

    for highway in highways_list:
        print(ET.tostring(highway, pretty_print=True).decode('utf-8'))

#search for the roadways
findword = 'highways'


#findIt = tree.xpath()

###Current limitations:
#   1.  is that the buses have yet to be properly implemented

###################################################################

###1. Open the OSM file (basically download the area you wish to alter)

###2. Read in the XML data
#import the saved planetary data for the city of minneapolis
# minneapolis = ET.parse(sys.argv[1]).getroot()

###3. Search for highways,
    ###a. Save the highways into an array, save only the way ID
# highways = simple_extract_highways(sys.argv[1])

###4. Maybe save the highway information into a SQL table

###5. Create two categories into a stack, North and South, East and West
    ##Note: As long as the OSM data is under the amount of ram available it should be fine
    ##a. Check the number of cores on the computer
    ##b. Open the number of threads, assign a number to each thread.
    ##c. each thread starts to work on the data set, if thread 0 then it ony looks at items in highway array
            ###use the formula: num_threads*i+thread_id for assigning which part of the array the thread should look at
            ###Make sure all numbers start with 0
        ##i. using the way_id, grab all of the nd tags and the reference numbers, save the reference into a special stack/or vector
        ##ii. go through the stack of references, collecting the coordinates of the of the reference point
                ##Save the reference point and the coordinates into a tuple, (reference,lat,long)
        ##iii. Determine the straightness of the roadway, using linear regression, selecting only 5 points at the same time (make it changable), 
                ##selecting only the roadways with more than greater than .95 regression 
        ##iv. Also create another linear equation involving all of the points on the roadway while looking at the regression
            ##1. Also keep a running score of the straightest part of the roadway. 
                ###For example 3rd ave S is in Downtown, where it is straight, then goes by the convention center, where it is curvy. Then it 
                    ###becomes very straight until it is broken by the 35W, but the last segment is very straight and this should be where 
                    ###the line is created. This straight line should correspond to the ordering of the roadway.
        ##v. Also Determine if the road is part of the grid, for each reference point, check if there is another reference point for another highway
            ##if there is an intersection
                ##1. Create a linear equation with the top and bottom 5 points (make programmable) of the intersection
                ##2. Identify the intersecting roadway and lookup the adjacent points (the top and bottom 5 points or whatever number)
                ##3. Create a linear equation for the other intersecting roadway
                ##4. Check the angle between the intersecting roadways using the linear equation. Angle should be 90degrees
                ##5. A roadway can have up to 3 none standard intersections (such as Hennepin Ave)

        ##vi. if the roadway is more than abs|45| degrees then it is north/south bound, otherwise it is east/west bound. Add the tuple into the correct stack
                ##Remove any roadway that does not adhere to the grid.
                ## ALSO: make sure to grade the city and give a grid score. This score should be the total number of gridded_roadways/total_roadways

    ##d. sort roadways from west to east and north to south
        ##a. Sort roadways
        ##b. Check to see if there are similar roadways, AKA roadways that are split up for one reason or another (such as Nicolett being split 
            # by the old Kmart), Sort the roadways by lat or long, depending if it is north and sout or west and east
            ###i. Make a new data structure (likely a dictionary) where, after sorting the rodway based off of east/west and north/south 
                    ###where all of the roadway data before is stored together. 
                    ###For example, if 3rd ave S has points above and below 35W, they should be grouped together. Or Nicollett has the break at old kmart

###6. Create Remove3
    ##a. Using the same number of cores as the other multiprocess system, open all of the cores
    ##b. Create a new function that looks at the given roadway and
        ##i. implements the arterial
        ##ii. implements southbound
        ##iii. implements northbound
        ##iv. implements VIP (should add a boolean to determine if busways will be implemented on all of the VIPs)
                ###TODO: implement the new bus lines
    ##c. Create a new multiprocess value in python called "place" starting at zero, Even numbers will be north and south, odd numbers east west
        ##If the place value exceeds the number of entries in a particular column then go to the still full column
    ##d. Send information into threads, implementing the following rule
        ###For example, even numbers are north and south, if an even number take the street that corresponds with the place number,
            ###if the 6 modulo of the place is 0, then it is an arterial, 
            ###modulo of 1 is southbound
            ###modulo of 2 is northbound
            ###modulo of 3 is vip
            ###modulo of 4 is southbound
            ###modulo of 5 is northbound

###7. Open JOSM to see results

###Things to watch out for:
    ###Make sure the downtown corridor is correct, it is likely this area is all messed up since the 
    ###Make sure the interstates are not really incorporated
    ###Bus routes will be totally fucked up, unless new routes are created (This will be hard to route across the Mississippi)
