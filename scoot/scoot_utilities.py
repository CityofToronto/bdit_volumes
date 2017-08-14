# -*- coding: utf-8 -*-
"""
Created on Wed Aug  2 11:45:21 2017

@author: qwang2
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
from sklearn.metrics import mean_squared_error
import pandas as pd

def fill_in_linear(data):
    i = 0
    while i < len(data):
        if data[i] == 0:
            j = i
            while i<len(data) and data[i]==0:
                i = i + 1
            if i == len(data):
                increment = (data[0]-data[j-1]) / (len(data)-j+1)
            else:
                increment = (data[i]-data[j-1])/(i-j+1)
            base = data[j-1]
            
            while j < i:
                data[j] = base + increment
                base = data[j]
                j = j + 1
        else:
            i = i + 1
            
    return data
    
def aggregate_data(min_bins_start, df, volume):
    i = 1
    j = 1
    v = []
    for var in range(len(min_bins_start)-1):
        a = min_bins_start[var]
        b = min_bins_start[var+1]
        # i points to the scoot bin immediately before interested time period
        while df['seconds'].iloc[i] < a:
            i = i + 1
        i = i - 1
        # j points to the scoot bin immediately after interested time period
        while df['seconds'].iloc[j] < b and j!=len(df)-1:
            j = j + 1
            
        if j - i == 1: # [i,a,b,j]
            v.append(df[volume].iloc[i]/df['CycleTime'].iloc[i]*(b-a))
        elif j - i == 2: # [i,a,i+1(j-1),b,j]
            v.append(df[volume].iloc[i]*((df['seconds'].iloc[i+1]-a)/df['CycleTime'].iloc[i])+df[volume].iloc[j-1]*((b-df['seconds'].iloc[j-1])/df['CycleTime'].iloc[j-1]))
        else:   # [i,a,i+1,i+2,...,j-1,b,j]
            vt = 0
            for k in range(j-1-(i+1)):
                vt = vt + df[volume].iloc[i+k+1]
            v.append(vt+df[volume].iloc[i]*((df['seconds'].iloc[i+1]-a)/df['CycleTime'].iloc[i])+df[volume].iloc[j-1]*((b-df['seconds'].iloc[j-1])/df['CycleTime'].iloc[j-1]))

    return v

def aggregate_lanes(df,aggregation):
    cnt = 0
    for lst in aggregation:
        df['detector'+str(cnt)] = df[lst].sum(axis=1)
        cnt = cnt + 1
    return df
    
def add_y_eq_x(ax):
    
    lims = [
    np.min([ax.get_xlim(), ax.get_ylim()]),  # min of both axes
    np.max([ax.get_xlim(), ax.get_ylim()]),  # max of both axes
    ]
    ax.plot(lims, lims, 'k-', alpha=0.75)
 
def func_exp(x,a,b):
    if not hasattr(x, '__iter__'):
        return a*np.exp(b*x)
    else:
        return a*np.exp([b*x0 for x0 in x])
    
def func_lin(x,a,b):
    if not hasattr(x, '__iter__'):
        return a * x + b
    else:
        return [a*x0+b for x0 in x]

def func_quad(x,a,b,c):
    if not hasattr(x, '__iter__'):
        return a*x*x + b*x + c
    else:
        return [a*x0*x0 + b*x0 + c for x0 in x]

def my_curve_fit(ax, x, y, func1, func2=None, step=None, color='b', fitname='Model name missing', p01=None, p02=None):
    if func2 is None:
        fit_1 = [(a,b) for a,b in zip(x, y)]
        fit_2 = []
    else:
        fit_2 = [(a,b) for a,b in zip(x, y) if a>step]
        fit_1 = [(a,b) for a,b in zip(x, y) if a<=step]
        
    if fit_1:
        if p01 is None:
            popt, pcov = curve_fit(func1, [x[0] for x in fit_1], [x[1] for x in fit_1])
        else:
            popt, pcov = curve_fit(func1, [x[0] for x in fit_1], [x[1] for x in fit_1], p0=p01)
             
        line = ax.plot(np.linspace(1,max([x[0] for x in fit_1]),max([x[0] for x in fit_1])), func1(range(max([x[0] for x in fit_1])), *popt), label=fitname, linewidth=3, color = color)
        y_actual = [x[1] for x in fit_1]
        y_predict = func1([x[0] for x in fit_1], *popt)
                
        
    if fit_2:
        if fit_1:
            conn_point = func1(step, *popt)
            fit_2.append((step, conn_point))
            sigma = np.ones(len(fit_2))
            sigma[-1] = 0.001
        else:
            return None
        if p02 is None:
            try:
                popt, pcov = curve_fit(func2, [x[0] for x in fit_2], [x[1] for x in fit_2], sigma=sigma)
            except: # does not fit -> move on
                line.pop(0).remove()
                return None
        else:
            try:
                popt, pcov = curve_fit(func2, [x[0] for x in fit_2], [x[1] for x in fit_2], p0=p02, sigma=sigma)
            except: # does not fit -> move on
                line.pop(0).remove()
                return None
        ax.plot(np.linspace(step,max([x[0] for x in fit_2]),max([x[0] for x in fit_2])-step), func2(np.linspace(step,max([x[0] for x in fit_2]),max([x[0] for x in fit_2])-step), *popt), label=None, linewidth=3, color = color)
        y_actual = y_actual + [x[1] for x in fit_2]
        y_predict = np.append(y_predict, func2([x[0] for x in fit_2], *popt))
        
    return sum([abs(a-b) for a,b in zip(y_actual, y_predict)])    
    