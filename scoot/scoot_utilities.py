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
import statsmodels.api as sm

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

def my_curve_fit(ax, x, y, func1, func2=None, color1='b', color2=None, fitname='Model name missing', p01=None, p02=None, remove_outliers = True):
    
    if remove_outliers:
        [ax.scatter(a,b, color = 'r', label=None) for a,b in zip(x, y) if (a>=3*b or b>=3*a)]
        x1 = [a for a,b in zip(x,y) if (a<=3*b and b<=3*a)]
        y1 = [b for a,b in zip(x,y) if (a<=3*b and b<=3*a)]
        x = x1
        y = y1
    
    if func2 is not None:
        minERR = 1000000
        for pct in np.linspace(10, 85, 18):
            step = np.percentile(x, pct)
            x_1 = [i for i in x if i < step]
            x_2 = [i for i in x if i >= step]
            y_1 = [j for (i,j) in zip(x,y) if i < step]
            y_2 = [j for (i,j) in zip(x,y) if i >= step]
            
            f1 = sm.OLS(y_1,x_1).fit()
                
            conn_point = f1.predict(step)
            x_2.append(step)
            y_2.append(conn_point)
            sigma = np.ones(len(x_2))
            sigma[-1] = 0.001
            
            if p02 is None:
                try:
                    popt, pcov = curve_fit(func2, x_2, y_2, sigma=sigma)
                except: # does not fit -> move on
                    continue
            else:
                try:
                    popt, pcov = curve_fit(func2, x_2, y_2, p0=p02, sigma=sigma)
                except: # does not fit -> move on
                    continue
            
            y_actual = y_1 + y_2
            y_predict = np.append(f1.predict(x_1), func2(x_2, *popt)[:-1])
            err = sum([(a-b)*(a-b) for a,b in zip(y_actual, y_predict)])    
            if err < minERR:
                minERR  = err
                minf1 = f1
                minstep = step
                miny_2 = func2(np.linspace(step, max(x_2), max(x_2)-step), *popt)
                minpct = pct
                
        if minpct < 75:
            ax.plot(minstep, minf1.predict(minstep), 'go', ms = 15)
            ax.plot(np.linspace(1,minstep,minstep), minf1.predict(np.linspace(1,minstep,minstep)), label=None, linewidth=3, color = color2)
            ax.plot(np.linspace(minstep, max(x_2), max(x_2)-minstep), miny_2, label=fitname, linewidth=3, color = color2)
        
            return f1, err, popt, step 
            
    # if passing in a linear function OR percentile of connection point > 80
    f1 = sm.OLS(y,x).fit()
    ax.plot(x, f1.predict(x), label=fitname, linewidth=3, color = color1)
    y_actual = y
    y_predict = f1.predict(x)
    
    return f1, sum([(a-b)*(a-b) for a,b in zip(y_actual, y_predict)]), None, None   
