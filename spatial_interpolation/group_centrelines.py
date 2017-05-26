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

pairs = pd.read_csv('pairs_directional.csv', names = ['c1','c2','dirc','same'])
pairs = pairs[pairs['same']=='t']
pairs['c1'] = pairs['c1'].astype(int)
pairs['c2'] = pairs['c2'].astype(int)
pairs['dirc'] = pairs['dirc'].astype(int)

pairs['c1'] = pairs['c1']*pairs['dirc']
pairs['c2'] = pairs['c2']*pairs['dirc']

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
        table.append([abs(tcl),int(tcl/abs(tcl)),count])
    count = count + 1

db.truncate('prj_volume.centreline_groups')
db.inserttable('prj_volume.centreline_groups',table)

tcl_no_merge = [x for t in db.query('SELECT centreline_id*dir_bin FROM prj_volume.centreline_groups RIGHT JOIN (SELECT centreline_id, (CASE oneway_dir_code WHEN 0 THEN UNNEST(ARRAY[1,-1]) ELSE oneway_dir_code * dir_binary((ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape))+0.292)*180/pi()) END) AS dir_bin, feature_code FROM prj_volume.centreline) A USING (centreline_id, dir_bin) WHERE group_number is null and feature_code < 202000').getresult() for x in t]
for tcl in tcl_no_merge:
    table.append([abs(int(tcl)),int(tcl/abs(tcl)),count])
    count = count + 1

db.truncate('prj_volume.centreline_groups')
db.inserttable('prj_volume.centreline_groups',table)
db.close()