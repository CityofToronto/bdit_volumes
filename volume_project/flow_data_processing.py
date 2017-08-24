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


from utilities import vol_utils

from datetime import datetime
import logging

class prepare_flow_data(vol_utils):
    def __init__(self):
        self.logger = logging.getLogger('volume_project.prepare_flow_data')
        super().__init__()

    def __enter__(self):
        return self
        
    def arterycode_matching(self, manual_update=False):
        self.logger.info('Identifying new codes...')
        self.execute_sql("query_new_arterycodes.sql")
        self.logger.info('Creating geometry...')
        self.execute_sql("S01_create-table-arteries.sql")
        self.logger.info('Matching by node_ids...')
        self.execute_sql("S02_match-atr-by-nodes.sql")
        self.logger.info('Geocoding and matching by street address...')
        S03.geocode_match(self.db)
        self.logger.info('Updating geometry...')
        self.execute_sql("S04_update-geometry-arteries.sql")
        self.logger.info('Matching spatially...')
        self.execute_sql("S05_match-atr-spatially.sql")
        self.logger.info('Matching lines with missing point...')
        self.execute_sql("S06_match-atr-seg-w-missing-point.sql")
        self.logger.info('Matching turning movement counts')
        self.execute_sql("S07_match-tmc-arterycodes.sql")
        if manual_update:
            manual_corr = S08.combine_and_upload(self.db, './arterycode_mapping/Artery Match Correction Files/')
            self.truncatetable("prj_volume.artery_tcl_manual_corr")
            self.inserttable("prj_volume.artery_tcl_manual_corr",manual_corr)
        self.logger.info('Updating with manual corrections...')
        self.execute_sql("S09_update-match.sql")
        self.execute_sql("S10_short-segs-corr.sql")
        self.execute_sql("S11_update_wrong_geom.sql")
        
        return self.get_sql_results("query_new_arterycodes_match.sql", ['arterycode','location','shape','centreline_id','direction','sideofint','artery_type','match_on_case'])

                
    def cleanup_traffic_counts(self):

        self.logger.info("Cleaning up counts...")
        self.execute_sql("cleanup_anomalies.sql")
        self.execute_sql("cleanup_tmc.sql")
        self.logger.info("Flagging counts...")
        self.execute_sql("flag_anomalies.sql")
        self.execute_sql("flag_tmc.sql")
        
    def populate_volumes_table(self):
       
        self.execute_sql("create-table-tmc_turns.sql")
        self.execute_sql("create-table-tmc_turns_corr.sql")
        self.logger.info("Populating ATR counts...")
        self.execute_sql("update-table-centreline_volumes-atr.sql")
        self.logger.info("Populating TMC counts...")
        
        self.execute_sql("update-table-centreline_volumes-tmc.sql")
        self.execute_sql("create-table-cluster_atr_volumes.sql")
        
    def __exit__(self):
        self.db.close()
        
if __name__ == '__main__':
    
    logger = logging.getLogger('volume_project')
    logger.setLevel(logging.INFO)
    
    if not logger.handlers:
        handler = logging.FileHandler('volume_project.log', mode='w')
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    
    # 1. Prepare Data
    pfd = prepare_flow_data()
    
    # 1.1 Arterycode matching
    tStart = datetime.now()        
    newmatch = pfd.arterycode_matching()
    logger.info('Finished Arterycode Matching in %s', str(datetime.now()-tStart))
    # 1.2 Clean up counts
    tStart = datetime.now()
    pfd.cleanup_traffic_counts()
    logger.info('Finished clean up counts in %s', str(datetime.now()-tStart))   
    # 1.3 Populating volume tables
    tStart = datetime.now()
    pfd.populate_volumes_table()
    logger.info('Finished populating volume tables in %s', str(datetime.now()-tStart))   
    del pfd
    