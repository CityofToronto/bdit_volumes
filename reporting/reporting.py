# -*- coding: utf-8 -*-
"""
Created on Mon May  1 11:58:02 2017

@author: qwang2
"""

import sys
sys.path.append('../12 Volume Clustering/')

from pg import DB
from datetime import datetime
import configparser
import pandas as pd
import cl_fcn
import pickle

def calc_date_factors(date, dates, centreline_id, dir_bin):
    
    monthly_factors = pickle.load(open("monthly_factors.p", "rb"))
    if type(date) == str:
        date = datetime.strptime(date,'%Y-%m-%d')
    year = date.year
    month = date.month
    if (int(centreline_id), int(dir_bin), year) in monthly_factors.index:
        mfactors = [float(i) for i in monthly_factors.loc[(int(centreline_id), int(dir_bin), year)]['weights']]
    else:
        mfactors = monthly_factors.loc['average']['weights']
        
    dates = pd.DataFrame(pd.to_datetime(dates), columns=['count_date'])
    dates['diff_y'] = abs(dates['count_date'].dt.year - year)
    maxdiff = max(dates['diff_y'])
    dates['factor_month'] = [mfactors[m-1] / mfactors[month] for m in dates['count_date'].dt.month]
    dates['weight_year'] = (dates['diff_y'] > 5)*(1-0.5*(dates['diff_y']-5)/(maxdiff-5)) + (dates['diff_y'] < 5)
    dates['count_date'] = dates['count_date'].dt.date
    
    return dates
        
def fill_in(profiles, records, hour):
    
    tcldircl = pickle.load(open("../12 Volume Clustering/ClusterResults.p", "rb"))
    tcldircl = pd.DataFrame(tcldircl, columns = ['cluster','centreline_id','dir_bin','identifier'])
    
    to_classify = records.merge(tcldircl, on=['centreline_id','dir_bin'], how='left')
    to_classify.fillna(100, inplace=True)
    classified, _ = cl_fcn.fit_incomplete(profiles, to_classify[to_classify['cluster'] == 100])
    if not to_classify[to_classify['cluster']!= 100].empty:
        if classified.empty:
            classified = to_classify[to_classify['cluster']!= 100][['centreline_id','dir_bin','cluster']].drop_duplicates()
        else:
            classified.append(to_classify[to_classify['cluster']!= 100][['centreline_id','dir_bin','cluster']].drop_duplicates())
    data = cl_fcn.fill_missing_values(profiles, records, classified)
    df = []
    for k,v in data.items():
        for i,a in zip(range(96),v):
            df.append([j for j in k]+[i, a])
    df = pd.DataFrame(df, columns = ['count_date','centreline_id','dir_bin','time_15','volume'])     

    return df[df['time_15']//4==int(hour)]
    
def get_group_members(db, centreline_id):
    
    members = db.query('SELECT centreline_id FROM prj_volume.centreline_groups WHERE group_number = (SELECT group_number FROM prj_volume.centreline_groups WHERE centreline_id = ' + centreline_id + ' LIMIT 1)').getresult()
    members = [int(i[0]) for i in members]
    
    return members
    
def get_relavant_counts(db, centreline_id, dir_bin):

    tmc = pd.DataFrame(db.query('SELECT centreline_id, dir_bin, group_number, count_bin::date as count_date, count_bin::time as count_time, volume FROM prj_volume.centreline_volumes JOIN prj_volume.centreline_groups USING (centreline_id) WHERE count_type = 2 AND dir_bin = ' + dir_bin + ' AND group_number = (SELECT group_number FROM prj_volume.centreline_groups WHERE centreline_id = ' + centreline_id + ' LIMIT 1) ORDER BY centreline_id, dir_bin, count_date, count_time').getresult(), columns = ['centreline_id','dir_bin','group_number','count_date','count_time','volume'])
    
    tmc['time_15'] = tmc.count_time.apply(lambda x: x.hour*4+x.minute//15)
    
    atr = pd.DataFrame(db.query('SELECT centreline_id, dir_bin, AVG(group_number)::int AS group_number, count_bin::date AS count_date, count_bin::time AS count_time, SUM(volume) FROM prj_volume.centreline_volumes JOIN prj_volume.centreline_groups USING (centreline_id) WHERE group_number = (SELECT group_number FROM prj_volume.centreline_groups WHERE centreline_id = ' + centreline_id + ' LIMIT 1) AND dir_bin = ' + dir_bin + ' AND count_type = 1 GROUP BY centreline_id, dir_bin, count_bin ORDER BY centreline_id, dir_bin, count_bin').getresult(), columns = ['centreline_id','dir_bin','group_number','count_date','count_time','volume'])

    atr['time_15'] = atr.count_time.apply(lambda x: x.hour*4+x.minute//15)
    
    return tmc, atr
    
def get_volume(db, profiles, centreline_id, dir_bin, date, hour):
    
    if pd.to_datetime(date).weekday() in (5,6):
        print('Weekdays Only Please. For now.')
        return None
        
    tmc, atr = get_relavant_counts(db, centreline_id, dir_bin)
    '''
    ############################################ TESTING SECTION######################
    slicetmc, sliceatr = slice_data(tmc, atr, centreline_id=int(centreline_id), hour=int(hour))

    return calc_date_factors(date, slicetmc['count_date'].append(sliceatr['count_date']).unique(), centreline_id, dir_bin)
    '''
    ##################################################################################
    
    if type(date) == str:
        date = datetime.strptime(date,'%Y-%m-%d').date()
    
    # Same Day, Same centreline, Full Hour ATR OR TMC
    # Report Directly
    slicetmc, sliceatr = slice_data(tmc, atr, centreline_id=int(centreline_id), count_date=date, hour=int(hour))
    if len(slicetmc) == 4 or len(sliceatr) == 4:
        print('Same Day, Same centreline, Full Hour ATR OR TMC, Report Directly')
        return take_weighted_average(slicetmc, sliceatr)

    # Same Day, Same centreline, Partial Data
    # Fill in and report
    slicetmc_1, sliceatr_1 = slice_data(tmc, atr, centreline_id=int(centreline_id), count_date=date)
    if len(sliceatr) > 0 or len(slicetmc) > 0:
        if len(sliceatr) > len(slicetmc):
            sliceatr_1 =  fill_in(profiles, sliceatr_1, hour)
            return take_weighted_average(None, sliceatr_1)
        else:
            slicetmc_1 = fill_in(profiles, slicetmc_1, hour)
            return take_weighted_average(slicetmc_1, None)
    elif len(sliceatr_1) > 48:
        sliceatr_1 = fill_in(profiles, sliceatr_1, hour)
        return take_weighted_average(None, sliceatr_1, hour)
    elif len(slicetmc_1) > 24:
        slicetmc_1 = fill_in(profiles, slicetmc_1, hour)
        return take_weighted_average(slicetmc_1, None)

    # Same Day, Same centreline group, Full Hour ATR OR TMC
    # Report Directly
    slicetmc, sliceatr = slice_data(tmc, atr, count_date=date, hour=int(hour))
    if len(slicetmc) == 4 or len(sliceatr) == 4:
        print('Same Day, Same centreline group, Full Hour ATR OR TMC - Report Directly')
        return take_weighted_average(slicetmc, sliceatr)
        
    # Same Day, Same centreline group, Partial Data
    # Fill in and Report
    slicetmc_1, sliceatr_1 = slice_data(tmc, atr, count_date=date)
    
    if len(sliceatr) > 0 or len(slicetmc) > 0:
        if len(sliceatr) > len(slicetmc):
            sliceatr_1 = fill_in(profiles, sliceatr_1, hour)
            return take_weighted_average(None, sliceatr_1)
        else:
            sliceatr_1 = fill_in(profiles, sliceatr_1, hour)
            return take_weighted_average(slicetmc_1, None)
    elif len(sliceatr_1) > 48:
        sliceatr_1 = fill_in(profiles, sliceatr_1, hour)
        return take_weighted_average(None, sliceatr_1)
    elif len(slicetmc_1) > 24:
        sliceatr_1 = fill_in(profiles, slicetmc_1, hour)    
        return take_weighted_average(slicetmc_1, None)
        
    # Different Day, Same centreline, Full Hour
    # Apply Year-to-Year/Seasonality Factors/Weights and Report
    slicetmc, sliceatr = slice_data(tmc, atr, centreline_id=int(centreline_id), hour=int(hour))
    
    if slicetmc['time_15'].nunique() == 4 or sliceatr['time_15'].nunique() == 4:
        factors_date = calc_date_factors(date, slicetmc['count_date'].append( sliceatr['count_date']).unique(), centreline_id, dir_bin)
        print('Different Day, Same centreline, Full Hour')
        return take_weighted_average(slicetmc, sliceatr, factors_date=factors_date)
        
    # Different Day, Same centreline, Partial Data
    # Fill in, Apply Year-to-Year/Seasonality Factors/Weights and Report
    slicetmc_1, sliceatr_1 = slice_data(tmc, atr, centreline_id=int(centreline_id))
    factors_date = calc_date_factors(date, slicetmc_1['count_date'].append( sliceatr_1['count_date']).unique(), centreline_id, dir_bin)
    if sliceatr['time_15'].nunique() > 0 or slicetmc['time_15'].nunique() > 0:
        if sliceatr['time_15'].nunique() > slicetmc['time_15'].nunique():
            sliceatr_1 = fill_in(profiles, sliceatr_1, hour)
            return take_weighted_average(None, sliceatr_1)
        else:
            sliceatr_1 = fill_in(profiles, slicetmc_1, hour)    
        return take_weighted_average(slicetmc_1, None)
    elif sliceatr_1['time_15'].nunique() > 48:
        sliceatr_1 = fill_in(profiles, sliceatr_1, hour)
        return take_weighted_average(None, sliceatr_1)
    elif slicetmc_1['time_15'].nunique() > 24:
        sliceatr_1 = fill_in(profiles, slicetmc_1, hour)    
        return take_weighted_average(slicetmc_1, None) 
        
    # Different Day, Same centreline group, Full Hour
    slicetmc, sliceatr = slice_data(tmc, atr, hour=int(hour))
    if slicetmc['time_15'].nunique() == 4 or sliceatr['time_15'].nunique() == 4:
        factors_date = calc_date_factors(date, slicetmc['count_date'].append( sliceatr['count_date']).unique(), centreline_id, dir_bin)
        return take_weighted_average(slicetmc, sliceatr, factors_date=factors_date)
        
    # Different Day, Same centreline group, Partial Data
    slicetmc_1, sliceatr_1 = tmc, atr
    if sliceatr['time_15'].nunique() > 0 or slicetmc['time_15'].nunique() > 0:
        if sliceatr['time_15'].nunique() > slicetmc['time_15'].nunique():
            sliceatr_1 = fill_in(profiles, sliceatr_1, hour)
            return take_weighted_average(None, sliceatr_1)
        else:
            sliceatr_1 = fill_in(profiles, slicetmc_1, hour)    
        return take_weighted_average(slicetmc_1, None)
    elif sliceatr_1['time_15'].nunique() > 48:
        sliceatr_1 = fill_in(profiles, sliceatr_1, hour)
        return take_weighted_average(None, sliceatr_1)
    elif slicetmc_1['time_15'].nunique() > 24:
        sliceatr_1 = fill_in(profiles, slicetmc_1, hour)    
        return take_weighted_average(slicetmc_1, None)
        
def slice_data(df1, df2, centreline_id=None, count_date=None, hour=None):

    slice1 = df1[((df1['count_date']==count_date)|(count_date is None))&((df1['centreline_id']==centreline_id)|(centreline_id is None))&((df1['time_15']//4==hour)|(hour is None))]
    slice2 = df2[((df2['count_date']==count_date)|(count_date is None))&((df2['centreline_id']==centreline_id)|(centreline_id is None))&((df2['time_15']//4==hour)|(hour is None))]
    
    return slice1, slice2
    
def take_weighted_average(tmc, atr, factors_date=None):
    '''
    ** all data will be added up do not pass in redundant rows
    '''
    if factors_date is None:
        df = pd.concat([tmc,atr]).groupby(['centreline_id','dir_bin','time_15'],as_index=False).mean().groupby(['centreline_id','dir_bin']).sum()
        return df['volume'][0]
    else:
        df = pd.concat([tmc,atr]).merge(factors_date, on=['count_date'])
        df['volume'] = df['volume']*df['factor_month']
        total = 0
        
        for (time_15), group in df.groupby('time_15'):        
            volume = 0 
            weights_sum = sum(group['weight_year'])
            for v,w in zip(group['volume'], group['weight_year']):
                volume = volume + v*w/weights_sum
            total = total + volume
            
        return total
       
if __name__ == "__main__":
    # CONNECTION SET UP
    CONFIG = configparser.ConfigParser()
    CONFIG.read('db.cfg')
    dbset = CONFIG['DBSETTINGS']
    db = DB(dbname=dbset['database'],host=dbset['host'],user=dbset['user'],passwd=dbset['password'])
    '''
    centreline_id = input("Centreline_id?")
    dir_bin = input("direction(+1/-1)?")
    date = input("date(yyyy-mm-dd)?")
    hour = input("Hour?")
    '''
    centreline_id = '1153'
    dir_bin = '-1'
    date = '2006-08-04'
    hour = '9'
    
    profiles = pickle.load(open("../12 Volume Clustering/ClusterCentres.p", "rb"))

    print(get_volume(db, profiles, centreline_id, dir_bin, date, hour))
    
    db.close()