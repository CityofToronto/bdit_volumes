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
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import train_test_split
from sklearn import linear_model
from scipy.spatial import KDTree
from scipy.stats.stats import pearsonr


def get_coord_data(road_class):
    f = open("query_coord_volume.sql","r")
    sql = f.read() 
    sql = sql.replace("201200",str(road_class))
    data = pd.DataFrame(db.query(sql).getresult(), columns = ['from_x','from_y','to_x','to_y','volume'])
    
    return data
    
def GP_Kriging(data):
    volume = np.array(data['volume'])
    coord = np.array(data[['from_x','from_y','to_x','to_y']])
    
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

def Linear_Regression_Prox(data):

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
        if i == 9:
            plt.scatter(y_predict, y_test)
            x = np.linspace(0.9*min(min(y_test),min(y_predict)), 1.1*max(max(y_predict),max(y_test)),2)
            plt.xlim(x)
            plt.plot(x,x)
            plt.show()
        score.append(mean_squared_error(y_test,y_predict))
    plt.plot(score)
    plt.show()

def Linear_Regression_Directional(road_class):
    f = open("query_relation_groups.sql","r")
    #f = open("query_neighbour_volumes.sql","r")
    sql = f.read() 
    sql = sql.replace("201200",str(road_class))
    data = pd.DataFrame(db.query(sql).getresult(),columns = ['group_number','neighbour_vol','volume'])
    neighb = list(data[data['neighbour_vol'].map(len) == 4]['neighbour_vol'])
    orig = list(data[data['neighbour_vol'].map(len) == 4]['volume'])
    x_train, x_test, y_train, y_test = train_test_split(neighb, orig, test_size=0.3, random_state=0)
    
    
    regr = linear_model.LinearRegression()
    regr.fit(x_train, y_train)
    y_predict = regr.predict(x_test)
    plt.scatter(y_predict, y_test)
    x = np.linspace(0.9*min(min(y_test),min(y_predict)), 1.1*max(max(y_predict),max(y_test)),2)
    plt.xlim(x)
    plt.plot(x,x)
    plt.show()
    print(regr.score(x_test, y_test))
    
def Average_Neighbours(data):
    dist = np.array(data[['from_x','from_y','to_x','to_y']])
    kdt = KDTree(dist, 12)
    
    orig = np.asarray([data['volume'].iloc[kdt.query(l,k=5)[1]].iloc[0] for l in dist])
    neighb = []
    for i in range(5):
        neighb.append([data['volume'].iloc[kdt.query(l,k=11)[1]].iloc[i+1] for l in dist])
    neighb = np.asarray(neighb).T
    y_predict = np.mean(neighb,axis=1)
    plt.scatter(y_predict, orig)
    x = np.linspace(0.9*min(min(orig),min(y_predict)), 1.1*max(max(y_predict),max(orig)),2)
    plt.xlim(x)
    plt.ylim(x)
    plt.plot(x,x)
    plt.show()

if __name__ == "__main__":
    '''
    # CONNECTION SET UP
    CONFIG = configparser.ConfigParser()
    CONFIG.read('db.cfg')
    dbset = CONFIG['DBSETTINGS']
    db = DB(dbname=dbset['database'],host=dbset['host'],user=dbset['user'],passwd=dbset['password'])
    
    for road_class in [201200,201300,201400]:
        Linear_Regression_Prox(get_coord_data(road_class))
        Linear_Regression_Directional(road_class)
    '''
    Linear_Regression_Directional(201500)
    
    data = pd.read_csv('arterial_blocks.csv')
