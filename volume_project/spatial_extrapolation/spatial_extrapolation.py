# -*- coding: utf-8 -*-
"""
Created on Fri May 19 11:19:28 2017

@author: qwang2
"""

import sys
import os
for x in os.walk('../'):
    sys.path.append(x[0])

import warnings
warnings.simplefilter('error',RuntimeWarning)

import logging
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn import preprocessing
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RationalQuadratic
from sklearn.gaussian_process.kernels import ExpSineSquared
from sklearn.metrics import mean_squared_error
from sklearn.metrics import r2_score
from sklearn.model_selection import train_test_split
from sklearn import linear_model
from scipy.spatial import KDTree
from scipy.stats.stats import pearsonr
from utilities import vol_utils

class spatial_extrapolation(vol_utils):    

    def __init__(self, sample_size):
        self.logger = logging.getLogger('volume_project.spatial_extrapolation')
        super().__init__()
        self.rc_lookup = {201200:'Major Arterials', 201300:'Minor Arterials', 201400:'Collectors', 201500:'Locals'}
        self.sample_size = sample_size
        
    def get_coord_data(self, road_class):
        
        return self.get_sql_results("query_coord_volume.sql",['from_x','from_y','to_x','to_y','volume'], parameters=[road_class])
     
    def GP_Kriging(self, data):
        volume = np.array(data['volume'])
        coord = np.array(data[['from_x','from_y','to_x','to_y']])
        
        coord = preprocessing.normalize(coord, axis=0)
        x_train, x_test, y_train, y_test = train_test_split(coord, volume, test_size=self.sample_size/100, random_state=0)
        kernel = RationalQuadratic(length_scale=1.0, length_scale_bounds=(1e-1, 10.0)) * RationalQuadratic(length_scale=1.0, length_scale_bounds=(1e-1, 10.0)) * ExpSineSquared(length_scale=1.0, length_scale_bounds=(1e-1, 10.0)) * ExpSineSquared(length_scale=1.0, length_scale_bounds=(1e-1, 10.0))
        gp = GaussianProcessRegressor(kernel=kernel)
        gp.fit(x_train, y_train)
        
        y_mean = gp.predict(x_test, return_std=False)
        plt.scatter(y_mean, y_test)
        
        #lims = [np.min([plt.xlim(), plt.ylim()]), np.max([plt.xlim(), plt.ylim()])]
        #plt.plot(lims, lims,'k-')
        plt.show()
    
    def Linear_Regression_Prox(self, data, road_class):
    
        dist = np.array(data[['from_x','from_y','to_x','to_y']])
        kdt = KDTree(dist, 12)
        
        orig = np.asarray([data['volume'].iloc[kdt.query(l,k=5)[1]].iloc[0] for l in dist])
        neighb = []
        for i in range(10):
            neighb.append([data['volume'].iloc[kdt.query(l,k=11)[1]].iloc[i+1] for l in dist])
        neighb = np.asarray(neighb).T
        x_train, x_test, y_train, y_test = train_test_split(neighb, orig, test_size=self.sample_size/100, random_state=0)    
        regr = linear_model.LinearRegression()
        score = []
        for i in range(10):
            regr.fit(x_train[:,0:i+1], y_train)
            y_predict = regr.predict(x_test[:,0:i+1])
            if i == 9:
                self.ScatterPlot(y_predict, y_test, road_class, regr.score(x_test, y_test), 'proximikty_regr',  ' Linear Regression (by proximity) \n with ' + str(i+2) + ' neighbours')
                
            score.append(np.sqrt(mean_squared_error(y_test,y_predict)))
            
        fig, ax = plt.subplots(figsize=[8,6])    
        ax.plot(np.linspace(2, 11, 10), score)
        ax.set_title(self.rc_lookup[road_class] + ' Root Mean Squared Error')
        ax.set_xlabel('Number of Neighbour')
        ax.set_ylabel('Root Mean Squared Error (veh)')
        fig.savefig('spatial_extrapolation/img/'+self.rc_lookup[road_class].lower().replace(' ', '_') +'_proximity_regr_scores.png')
    
    def Linear_Regression_Directional(self, road_class):
    
        data = self.get_sql_results("query_relation_groups.sql",columns = ['group_number','neighbour_vol','volume'], parameters = [road_class])
        neighb = list(data[data['neighbour_vol'].map(len) == 4]['neighbour_vol'])
        orig = list(data[data['neighbour_vol'].map(len) == 4]['volume'])
        x_train, x_test, y_train, y_test = train_test_split(neighb, orig, test_size=self.sample_size, random_state=0)
        
        regr = linear_model.LinearRegression()
        regr.fit(x_train, y_train)
        y_predict = regr.predict(x_test)
        
        self.ScatterPlot(y_predict, y_test, road_class, regr.score(x_test, y_test), 'directional_regr', ' Directional Linear Regression \n with 2 parallel and 2 perpendicular')
        
    def Average_Neighbours(self, road_class):
        data = self.get_sql_results("query_avg_neighbour_volumes.sql",columns = ['group_number','neighbour_vol','volume'], parameters = [road_class, self.sample_size])
        y_predict = data['neighbour_vol']
        y_test = data['volume']
        
        self.ScatterPlot(y_predict, y_test, road_class, r2_score(y_test, y_predict), 'neighbour_avg', ' Average of 5 Nearest Neighbours')
    
    def ScatterPlot(self, y_predict, y_test, road_class, coef_det, estimation_method, title_notes):
        
        fig, ax = plt.subplots(figsize=[8,6])
        
        ax.scatter(y_predict, y_test)
        ax.set_title(self.rc_lookup[road_class] + title_notes)
        ax.set_xlabel('Predicted Volume (veh)')
        ax.set_ylabel('Observed Volume (veh)')
        x = np.linspace(0.8*min(min(y_test),min(y_predict)), 1.1*max(max(y_predict),max(y_test)),2)
        ax.plot(x,x)
        
        ax.set_xlim(x)
        ax.set_ylim(x)
        
        ax.annotate('Root Mean Squared Error: ' + "{:.0f}".format(np.sqrt(mean_squared_error(y_test,y_predict))), xy=((x[1]-x[0])*0.06+x[0], x[1]*0.92), fontsize = 11)
        ax.annotate('Coef of Det: ' + "{:.3f}".format(coef_det), xy=((x[1]-x[0])*0.06+x[0], x[1]*0.86), fontsize = 11)
        fig.savefig('spatial_extrapolation/img/'+self.rc_lookup[road_class].lower().replace(' ','_') + '_' + estimation_method + '.png')