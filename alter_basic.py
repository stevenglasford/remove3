####Update: This script is not really the best method to do this, it is too finicky




###Usage: altering_minneapolis.py <osm_file>
from lxml import etree as ET
import sys
import os
import time
import multiprocessing
from concurrent.futures import ProcessPoolExecutor

super_filename = "minneapolis.osm"
#super_filename = sys.argv[1]

def simple_extract_highways(filename):
    tree = ET.parse(filename)
    root = tree.getroot()

    highways = []

    for way in root.findall('way'):
        for tag in way.findall('tag'):
            if tag.get('k') == 'highway':
                highways.append(way)
                print(way)
                break
    
    return highways


simplerstart=time.perf_counter()
simple_extract_highways(super_filename)
simpleend=time.perf_counter
