# -*- coding: utf-8 -*-
"""
Created on Wed Mar 22 14:12:15 2017

@author: qwang2
"""

import pandas as pd
from pg import DB
import configparser

# CONNECTION SET UP
CONFIG = configparser.ConfigParser()
CONFIG.read('db.cfg')
dbset = CONFIG['DBSETTINGS']

db = DB(dbname=dbset['database'],host=dbset['host'],user=dbset['user'],passwd=dbset['password'])

# pairs.csv - merge segments where intersecting segment(s) is of equal or lower class or intersecting segment(s) is lower than Collector 
# pairs2.csv - merge segments where intersecting segment(s) is lower than Collector  
# that is, locals intersecting locals will be separate in pairs.csv but merged in pairs2.csv
# pairs_directional.csv - directional segments

pairs = pd.read_csv('pairs_groups.csv', names = ['c1','c2','same'])
pairs = pairs[pairs['same']=='t']
pairs['c1'] = pairs['c1'].astype(int)
pairs['c2'] = pairs['c2'].astype(int)

root = list(set(list(pd.DataFrame(pairs['c1']).drop_duplicates()['c1'])+list(pd.DataFrame(pairs['c2']).drop_duplicates()['c2'])))
to_visit = []
visited = []
chains = []
while root:
    current = root.pop()
    visited.append(current)
    to_visit.extend(list(pairs.groupby('c1').get_group(current)['c2']))
    chain = [current]

    while to_visit:
        current = to_visit.pop()
        if current not in visited:
            chain.append(current)            
            root.remove(current)
            to_visit.extend(list(pairs.groupby('c1').get_group(current)['c2']))
            visited.append(current)
    
    chains.append(chain)

groups = {}
count = 1
table = []
for group in chains:
    for tcl in group:
        table.append([tcl,count])
    count = count + 1

db.truncate('prj_volume.centreline_groups_l2')
db.inserttable('prj_volume.centreline_groups_l2',table)

group_no_merge = [x for t in db.query('SELECT DISTINCT group_number FROM prj_volume.centreline_groups LEFT JOIN prj_volume.centreline_groups_l2 ON (group_number=l1_group_number) WHERE l2_group_number IS NULL').getresult() for x in t]

for tcl in group_no_merge:
    table.append([tcl,count])
    count = count + 1

db.truncate('prj_volume.centreline_groups_l2')
db.inserttable('prj_volume.centreline_groups_l2',table)
db.close()