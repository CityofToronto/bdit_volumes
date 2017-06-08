# -*- coding: utf-8 -*-
"""
Created on Mon Jun  5 14:31:55 2017

@author: qwang2
"""

import sys
import os
for x in os.walk('.'):
    sys.path.append(x[0]) 

from pg import DB
import configparser
import S03_geocode_and_match_street_number as S03
import pandas as pd
from cluster import cluster
import cl_fcn
import reporting
import spatial_extrapolation
import utilities

def arterycode_matching(db, manual_update=False):
    print('Identifying new codes...')
    #execute_sql(db, "query_new_arterycodes.sql")
    print('Creating geometry...')
    utilities.execute_sql(db, "S01_create-table-arteries.sql")
    print('Matching by node_ids...')
    utilities.execute_sql(db, "S02_match-atr-by-nodes.sql")
    print('Geocoding and matching by street address...')
    S03.geocode_match(db)
    print('Updating geometry...')
    utilities.execute_sql(db, "S04_update-geometry-arteries.sql")
    print('Matching spatially...')
    utilities.execute_sql(db, "S05_match-atr-spatially.sql")
    print('Matching lines with missing point...')
    utilities.execute_sql(db, "S06_match-atr-seg-w-missing-point.sql")
    print('Matching turning movement counts')
    utilities.execute_sql(db, "S07_match-tmc-arterycodes.sql")
    if manual_update:
        exec("S08_combine_correction_files.py")
    print('Updating with manual corrections...')
    utilities.execute_sql(db, "S09_update-match.sql")
    utilities.execute_sql(db, "S10_short-segs-corr.sql")

    return utilities.get_sql_results(db, "query_new_arterycodes_match.sql", ['arterycode','location','shape','centreline_id','direction','sideofint','artery_type','match_on_case'])

def cleanup_traffic_counts(db):
    
    print("Cleaning up counts...")
    utilities.execute_sql(db, "cleanup_anomalies.sql")
    utilities.execute_sql(db, "cleanup_tmc.sql")
    print("Flagging counts...")
    utilities.execute_sql(db, "flag_anomalies.sql")
    utilities.execute_sql(db, "flag_tmc.sql")
    
def populate_volumes_table(db):
    
    utilities.execute_sql(db, "create-table-tmc_turns.sql")
    utilities.execute_sql(db, "create-table-tmc_turns_corr.sql")
    print("Populating ATR counts...")
    utilities.execute_sql(db, "update-table-centreline_volumes-atr.sql")
    print("Populating TMC counts...")
    utilities.execute_sql(db, "update-table-centreline_volums-tmc.sql")
    utilities.execute_sql(db, "create-table-cluster_atr_volumes.sql")
    
if __name__ == '__main__':

    # CONNECTION SET UP
    CONFIG = configparser.ConfigParser()
    CONFIG.read('db.cfg')
    dbset = CONFIG['DBSETTINGS']
    db = DB(dbname=dbset['database'],host=dbset['host'],user=dbset['user'],passwd=dbset['password'])
    
    new_match = arterycode_matching(db, manual_update = False)
    
    cleanup_traffic_counts(db)
    
    populate_volumes_table(db)

    print("Clustering...")
    C = cluster(db, cl_fcn.get_data_individual(db, br = [('20100101','20170101')]), nClusters = 6)

    include_incomplete = False

    if include_incomplete == True:
        C.fit_incomplete_data(cl_fcn.get_data_tmc(db, ('20100101','20170101')), include_incomplete)
        C.refresh_db_export(db)
    else:
        C.refresh_db_export(db)

    print("Refreshing Monthly Factors...")
    reporting.refresh_monthly_factors(db)
    
    reporting.testing_entire_TO(db, C)

    