# -*- coding: utf-8 -*-
"""
Created on Mon Jun  5 14:31:55 2017

@author: qwang2
"""

import sys
import os
for x in os.walk('.'):
    sys.path.append(x[0]) 

import S03_geocode_and_match_street_number as S03
import S08_combine_correction_files as S08
import pandas as pd

from utilities import vol_utils
from cluster import cluster
from reporting import temporal_extrapolation
from datetime import datetime

class prepare_flow_data(vol_utils):
    def __init__(self,):
        super().__init__()
    def __enter__(self):
        return self
    def arterycode_matching(self, manual_update=False):
        print('Identifying new codes...')
        self.execute_sql("query_new_arterycodes.sql")
        print('Creating geometry...')
        self.execute_sql("S01_create-table-arteries.sql")
        print('Matching by node_ids...')
        self.execute_sql("S02_match-atr-by-nodes.sql")
        print('Geocoding and matching by street address...')
        S03.geocode_match(self.db)
        print('Updating geometry...')
        self.execute_sql("S04_update-geometry-arteries.sql")
        print('Matching spatially...')
        self.execute_sql("S05_match-atr-spatially.sql")
        print('Matching lines with missing point...')
        self.execute_sql("S06_match-atr-seg-w-missing-point.sql")
        print('Matching turning movement counts')
        self.execute_sql("S07_match-tmc-arterycodes.sql")
        if manual_update:
            manual_corr = S08.combine_and_upload('./arterycode_mapping/Artery Match Correction Files/')
            self.truncatetable("prj_volume.artery_tcl_manual_corr")
            self.inserttable("prj_volume.artery_tcl_manual_corr",manual_corr)
        print('Updating with manual corrections...')
        self.execute_sql("S09_update-match.sql")
        self.execute_sql("S10_short-segs-corr.sql")
        self.execute_sql("S11_update_wrong_geom.sql")
        
        return self.get_sql_results("query_new_arterycodes_match.sql", ['arterycode','location','shape','centreline_id','direction','sideofint','artery_type','match_on_case'])

                
    def cleanup_traffic_counts(self):

        print("Cleaning up counts...")
        self.execute_sql("cleanup_anomalies.sql")
        self.execute_sql("cleanup_tmc.sql")
        print("Flagging counts...")
        self.execute_sql("flag_anomalies.sql")
        self.execute_sql("flag_tmc.sql")
 
        
    def populate_volumes_table(self):
       
        self.execute_sql("create-table-tmc_turns.sql")
        self.execute_sql("create-table-tmc_turns_corr.sql")
        print("Populating ATR counts...")
        self.execute_sql("update-table-centreline_volumes-atr.sql")
        print("Populating TMC counts...")
        
        self.execute_sql("update-table-centreline_volumes-tmc.sql")
        self.execute_sql("create-table-cluster_atr_volumes.sql")
        
    def __exit__(self):
        self.db.close()
        
if __name__ == '__main__':
    
    tStart = datetime.now()
        
    pfd = prepare_flow_data()
    newmatch = pfd.arterycode_matching()
    
    print(datetime.now()-tStart)   
    
    tStart = datetime.now()
    pfd = prepare_flow_data()
    pfd.cleanup_traffic_counts()
    
    tStart = datetime.now()
    pfd.populate_volumes_table()
    
    tStart = datetime.now()
    clst = cluster(nClusters = 6)
    include_incomplete = False

    if include_incomplete == True:
        clst.fit_incomplete_data(pd.DataFrame(), include_incomplete)
        clst.refresh_db_export()
    else:
        clst.refresh_db_export()
    
    
    tex = temporal_extrapolation('group_number') 
    tex.testing_entire_TO()
    del tex
    
    print(datetime.now()-tStart)