# -*- coding: utf-8 -*-
"""
Created on Fri May 19 11:19:28 2017

@author: qwang2
"""

import sys
sys.path.append('../12 Volume Clustering/')

import warnings
warnings.simplefilter('error',RuntimeWarning)

from pg import DB
from datetime import datetime
import configparser
import pandas as pd
import pickle
import numpy as np
import matplotlib.pyplot as plt
from sklearn import preprocessing
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RationalQuadratic
from sklearn.gaussian_process.kernels import ExpSineSquared
from sklearn.model_selection import train_test_split
from sklearn import linear_model
from scipy.spatial import KDTree
from scipy.stats.stats import pearsonr

if __name__ == "__main__":
    
    # CONNECTION SET UP
    CONFIG = configparser.ConfigParser()
    CONFIG.read('db.cfg')
    dbset = CONFIG['DBSETTINGS']
    db = DB(dbname=dbset['database'],host=dbset['host'],user=dbset['user'],passwd=dbset['password'])
    '''
    data = pd.DataFrame(db.query("SELECT ST_X(ST_StartPoint(shape)), ST_Y(ST_StartPoint(shape)), ST_X(ST_EndPoint(shape)), ST_Y(ST_EndPoint(shape)), volume FROM (SELECT group_number, dir_bin, volume, (CASE WHEN dir_binary(ST_Azimuth(ST_StartPoint(shape), ST_EndPoint(shape))) = dir_bin THEN shape ELSE ST_REVERSE(shape) END) AS shape FROM (SELECT ST_LineMerge(ST_Union(shape)) AS shape, group_number, dir_bin, AVG(volume)::int AS volume FROM prj_volume.aadt JOIN prj_volume.centreline USING (centreline_id) JOIN prj_volume.centreline_groups USING (centreline_id, dir_bin) WHERE feature_code=201200 GROUP BY group_number, dir_bin) A) B").getresult(), columns = ['from_x','from_y','to_x','to_y','volume'])
    
    #GP Kriging
    #for (feature_code,feature_code_desc), group in data.groupby(['feature_code','feature_code_desc']):
        #print(feature_code_desc, len(group))

        #if feature_code < 10:
    group = data
    volume = np.array(group['volume'])
    coord = np.array(group[['from_x','from_y','to_x','to_y']])
    
    coord = preprocessing.normalize(coord, axis=0)
    x_train, x_test, y_train, y_test = train_test_split(coord, volume, test_size=0.3, random_state=0)
    kernel = RationalQuadratic(length_scale=1.0, length_scale_bounds=(1e-1, 10.0)) * RationalQuadratic(length_scale=1.0, length_scale_bounds=(1e-1, 10.0)) * ExpSineSquared(length_scale=1.0, length_scale_bounds=(1e-1, 10.0)) * ExpSineSquared(length_scale=1.0, length_scale_bounds=(1e-1, 10.0))
    gp = GaussianProcessRegressor(kernel=kernel)
    gp.fit(x_train, y_train)
    
    y_mean = gp.predict(x_test, return_std=False)
    plt.scatter(y_mean, y_test)
    
    #lims = [np.min([plt.xlim(), plt.ylim()]), np.max([plt.xlim(), plt.ylim()])]
    #plt.plot(lims, lims,'k-')
    plt.show()
    '''
    '''
    # Linear Regression Proximity               
    #dist = preprocessing.normalize(np.array(data[['from_x','from_y','to_x','to_y']]),axis=0)]
    dist = np.array(data[['from_x','from_y','to_x','to_y']])
    kdt = KDTree(dist, 12)
    
    orig = np.asarray([data['volume'].iloc[kdt.query(l,k=5)[1]].iloc[0] for l in dist])
    neighb = []
    for i in range(10):
        neighb.append([data['volume'].iloc[kdt.query(l,k=11)[1]].iloc[i+1] for l in dist])
    neighb = np.asarray(neighb).T
    x_train, x_test, y_train, y_test = train_test_split(neighb, orig, test_size=0.3, random_state=0)    
    regr = linear_model.LinearRegression()
    score = []
    for i in range(10):
        regr.fit(x_train[:,0:i+1], y_train)
        y_predict = regr.predict(x_test[:,0:i+1])
        plt.scatter(y_predict, y_test)
        plt.show()
        score.append(regr.score(x_test[:,0:i+1], y_test))
    plt.plot(score)
        #plt.scatter(i+1,pearsonr(orig, neighb)[0])
    '''
    # Linear Regression Directional
    volumes = pd.DataFrame(db.query('SELECT group_number, AVG(volume) FROM prj_volume.aadt JOIN prj_volume.centreline USING (centreline_id) WHERE feature_code=201200 GROUP BY group_number').getresult(), columns = ['group_number','volume'])