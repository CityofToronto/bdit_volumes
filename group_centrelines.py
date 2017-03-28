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

pairs = pd.read_csv('pairs2.csv', names = ['c1','c2','same'])
pairs = pairs[pairs['same']=='t']

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

db.truncate('prj_volume.centreline_groups')
db.inserttable('prj_volume.centreline_groups',table)

tcl_no_merge = [x for t in db.query('SELECT centreline_id FROM prj_volume.centreline_groups RIGHT JOIN prj_volume.centreline USING (centreline_id) WHERE group_number is null and feature_code < 202000').getresult() for x in t]
for tcl in tcl_no_merge:
    table.append([tcl,count])
    count = count + 1

db.truncate('prj_volume.centreline_groups')
db.inserttable('prj_volume.centreline_groups',table)
db.close()