#!/usr/bin/env python

# Specific to adzuna salary data processing.
# Usage:
# `scriptname inputfilename outputfilename`
# (reads location tree from hard-coded location)
# Adds location columns from location tree.

import csv
import sys

# We'll read in original location tree file:
infile = file("GADS4/data/kaggle_salary/Location_Tree.csv", 'r')

level = {1:{},2:{},3:{},4:{},5:{},6:{},7:{}}

for line in infile:
  line = line.replace('"','').rstrip()
  line = line.split("~")
  for term_idx in range(1, 1 + len(line)):
    # Find the level itself at its level:
    level[term_idx][line[term_idx-1]] = line[term_idx-1]
    # Find the levels below at their levels:
    for ref_idx in range(1, term_idx):
      level[ref_idx][line[term_idx-1]] = line[ref_idx-1]

# With the location data ready, apply to the input data and write out:
reader = csv.reader(open(sys.argv[1], 'r'))
writefile = open(sys.argv[2], 'w')
writer = csv.writer(writefile)

# Prepare the header, identifying where the right location field is:
header = reader.next()
loc_index_header = header.index("LocationNormalized")
writer.writerow(header +
                ['loc1', 'loc2', 'loc3', 'loc4', 'loc5', 'loc6', 'loc7'])
# Write out every line of data with new location columns:
for line in reader:
  # Adapt to possible row names:
  if len(line) > len(header):
    loc_index = loc_index_header + 1
    start_index = 1
  else:
    loc_index = loc_index_header
    start_index = 0
  loc = line[loc_index]
  writer.writerow(line[start_index:] + [level[1].get(loc, ""),
                          level[2].get(loc, ""),
                          level[3].get(loc, ""),
                          level[4].get(loc, ""),
                          level[5].get(loc, ""),
                          level[6].get(loc, ""),
                          level[7].get(loc, "")])

# Make sure the output file is finalized.
writefile.close()
