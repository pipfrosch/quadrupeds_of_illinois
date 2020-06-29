#!/usr/bin/env python3
import sys
import os
import pathlib
import datetime
import pytz
from xml.dom import minidom

def showUsage():
    print ("Usage: " + sys.argv[0] + " path/to/contents.opf")
    sys.exit(1)

def getTime():
    now = pytz.utc.localize(datetime.datetime.utcnow())
    return now.strftime("%Y-%m-%dT%H:%M:%SZ")

def updateTimestamp(xml):
    try:
        mydom = minidom.parse(xml)
    except:
        print (xml + " is not a valid XML file.")
        sys.exit(1)
    try:
        root = mydom.getElementsByTagName('package')[0]
    except:
        print ("Could not find root package node.")
        sys.exit(1)
    try:
        metadata = root.getElementsByTagName('metadata')[0]
    except:
        print ("Could not find metadata node.")
        sys.exit(1)
    metalist = metadata.getElementsByTagName('meta')
    for meta in metalist:
        if meta.hasAttribute("property") and meta.getAttribute("property") == "dcterms:modified":
            meta.parentNode.removeChild(meta)
    now = mydom.createTextNode(getTime())
    node = mydom.createElement('meta');
    node.appendChild(now)
    node.setAttribute("property","dcterms:modified")
    metadata.appendChild(node)
    string = mydom.toprettyxml(indent="  ",newl="\n",encoding="UTF-8").decode()
    string = '\n'.join([x for x in string.split("\n") if x.strip()!=''])
    fh = open(xml, "w")
    fh.write(string)
    fh.close()

def main():
    if len(sys.argv) != 2:
        showUsage()
    opf = pathlib.Path(sys.argv[1])
    if not opf.exists():
        showUsage()
    updateTimestamp(sys.argv[1])

if __name__ == "__main__":
    main()
