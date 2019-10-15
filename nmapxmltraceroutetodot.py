#!/usr/bin/python

# Convert nmap XML traceroute output to Graphviz DOT file.
# Author: unknown
#   I found this somewhere on the net and can't seem to locate the source.
#   I'm uploading it here on Github so I don't lose it.

import sys
import lxml.objectify
import pygraphviz

nxml=lxml.objectify.parse(sys.argv[1])
doc=nxml.getroot()
topology = pygraphviz.AGraph()

lastaddr="scanner"
topology.add_node(lastaddr)

if len(doc.findall(".//trace"))==0:
       print("Hmm..no trace information. Try nmap again with --traceroute option")
       sys.exit(1)  

for nmaphost in doc.findall(".//host"):
       #figure out what this host has for child elements
       hosttags=[]
       hostaddr=''
       for child in nmaphost.getchildren():
              hosttags.append(child.tag)

       if 'trace' in hosttags:            
              for nhop in nmaphost.trace.hop:
                     if nhop.attrib.get("ttl")=='1':
                            #don't add node here if you don't like duplicates
                            if nhop.attrib.get("host"):
                                   #topology.add_node(nhop.attrib.get("ipaddr"),label=nhop.attrib.get("host"))
                                   topology.add_edge('scanner',nhop.attrib.get("ipaddr")+"_"+nhop.attrib.get("host"))
                            else:
                                   topology.add_edge('scanner',nhop.attrib.get("ipaddr"))
                     else:
                            #print "that", nhop.attrib.get("ipaddr"), nhop.attrib.get("host")
                            if nhop.attrib.get("host"):
                                   topology.add_edge(lastaddr,nhop.attrib.get("ipaddr")+"_"+nhop.attrib.get("host"))
                            else:
                                   topology.add_edge(lastaddr,nhop.attrib.get("ipaddr"))
                     if nhop.attrib.get("host"):
                            lastaddr=nhop.attrib.get("ipaddr")+"_"+nhop.attrib.get("host")
                     else:
                            lastaddr=nhop.attrib.get("ipaddr")
#write our output:
topology.write('out.dot')
       #dot - filter for drawing directed graphs
       #neato - filter for drawing undirected graphs
       #twopi - filter for radial layouts of graphs
       #circo - filter for circular layout of graphs
       #fdp - filter for drawing undirected graphs
       #sfdp - filter for drawing large undirected graphs
#topology.layout(prog='fdp') # use which layout from the list above^
#topology.draw('out.png')
