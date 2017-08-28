# -*- coding: utf-8 -*-
"""
Created on Mon Aug 21 10:44:48 2017

@author: qwang2
"""

import sys
import os
for x in os.walk('.'):
    sys.path.append(x[0])

import warnings
warnings.simplefilter('error', RuntimeWarning)

from cluster import cluster
from reporting import temporal_extrapolation
from spatial_extrapolation import spatial_extrapolation
from datetime import datetime
import logging
import pandas as pd


if __name__ == '__main__':
    
    logger = logging.getLogger('volume_project')
    logger.setLevel(logging.INFO)
    
    if not logger.handlers:
        handler = logging.FileHandler('volume_project.log', mode='w')
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    '''    
    # 2. (optional) Cluster
    tStart = datetime.now()
    # 2.1 Cluster counts
    clst = cluster(nClusters = 6)
    # 2.2 Fit turning movement counts (incomplete day counts)
    include_incomplete = False
    if include_incomplete == True:
        clst.fit_incomplete_data(pd.DataFrame(), include_incomplete)
        clst.refresh_db_export()
    else:
        clst.refresh_db_export()
    del clst
    logger.info('Finished clustering in %s', str(datetime.now()-tStart))   
    '''
    # 3. Calculate volume based on existing counts
    tStart = datetime.now()
    tex = temporal_extrapolation('group_number') 
    # 3.1 (optional) Refersh factors
    #tex.refresh_monthly_factors()
    # 3.2 Calculate for all locations that are ever counted 
    year = 2015
    start_number = 0
    freq = 'hour'
    vol, non = tex.calc_all_TO(start_number, year, freq)
    del tex
    logger.info('Finished calculating AADT for Toronto in %s', str(datetime.now()-tStart))   
    '''
    # 4. Calculate volume for locations that are never counted
    tStart = datetime.now()
    spa = spatial_extrapolation()
    # 4.1 Fill in the entire city (method pre-determined)
    spa.fill_all()
    del spa
    logger.info('Finished filling in AADT for Toronto in %s', str(datetime.now()-tStart))      
    '''