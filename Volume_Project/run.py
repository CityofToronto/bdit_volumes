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

class prepare_flow_data(vol_utils):
    def __init__(self,):
        super().__init()
        
    def arterycode_matching(self, manual_update=False):
        print('Identifying new codes...')
        #execute_sql(self.db, "query_new_arterycodes.sql")
        print('Creating geometry...')
        self.execute_sql("S01_create-table-arteries.sql")
        print('Matching by node_ids...')
        self.execute_sql(self.db, "S02_match-atr-by-nodes.sql")
        print('Geocoding and matching by street address...')
        S03.geocode_match(self.db)
        print('Updating geometry...')
        self.execute_sql(self.db, "S04_update-geometry-arteries.sql")
        print('Matching spatially...')
        self.execute_sql(self.db, "S05_match-atr-spatially.sql")
        print('Matching lines with missing point...')
        self.execute_sql(self.db, "S06_match-atr-seg-w-missing-point.sql")
        print('Matching turning movement counts')
        self.execute_sql(self.db, "S07_match-tmc-arterycodes.sql")
        if manual_update:
            S08.combine_and_upload(self.db,'./arterycode_mapping/Artery Match Correction Files/')
        print('Updating with manual corrections...')
        self.execute_sql(self.db, "S09_update-match.sql")
        self.execute_sql(self.db, "S10_short-segs-corr.sql")
        self.execute_sql(self.db, "S11_update_wrong_geom")
        
        return self.get_sql_results(self.db, "query_new_arterycodes_match.sql", ['arterycode','location','shape','centreline_id','direction','sideofint','artery_type','match_on_case'])

                
    def cleanup_traffic_counts(self):

        print("Cleaning up counts...")
        self.execute_sql(self.db, "cleanup_anomalies.sql")
        self.execute_sql(self.db, "cleanup_tmc.sql")
        print("Flagging counts...")
        self.execute_sql(self.db, "flag_anomalies.sql")
        self.execute_sql(self.db, "flag_tmc.sql")
 
        
    def populate_volumes_table(self):
       
        self.execute_sql(self.db, "create-table-tmc_turns.sql")
        self.execute_sql(self.db, "create-table-tmc_turns_corr.sql")
        print("Populating ATR counts...")
        self.execute_sql(self.db, "update-table-centreline_volumes-atr.sql")
        print("Populating TMC counts...")
        
        self.execute_sql(self.db, "update-table-centreline_volumes-tmc.sql")
        self.execute_sql(self.db, "create-table-cluster_atr_volumes.sql")
        
    def __exit__(self):
        self.db.close()
        
if __name__ == '__main__':
    '''
    with prepare_flow_data() as pfd:
        pfd.arterycode_matching()
        pfd.cleanup_traffic_counts()
        pfd.populate_volumes_table()
    '''
    
    clst = cluster(nClusters = 6)
    '''
    include_incomplete = False

    if include_incomplete == True:
        clst.fit_incomplete_data(pd.DataFrame(), include_incomplete)
        clst.refresh_db_export()
    else:
        clst.refresh_db_export()
    '''
    #with temporal_extrapolation() as temex:
   