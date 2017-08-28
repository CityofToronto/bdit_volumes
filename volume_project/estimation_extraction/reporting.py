# -*- coding: utf-8 -*-
"""
Created on Mon May  1 11:58:02 2017

@author: qwang2
"""

import sys
import os
for x in os.walk('.'):
    sys.path.append(x[0])
    
import warnings
warnings.simplefilter('error', RuntimeWarning)

from datetime import datetime
from datetime import date
import pandas as pd
import cl_fcn
from utilities import vol_utils
import logging

class temporal_extrapolation(vol_utils):    
    
    def __init__(self, identifier_name):
        self.logger = logging.getLogger('volume_project.temporal_extrapolation')
        super().__init__()
        self.identifier_name = identifier_name
        self.get_clusterinfo()
        
        if self.identifier_name=='centreline_id':
            self.monthly_factors = self.get_sql_results('SELECT * FROM prj_volume.monthly_factors', [self.identifier_name,'dir_bin','year','weights'])
        else:
            self.monthly_factors = self.get_sql_results('SELECT * FROM prj_volume.monthly_factors_group', [self.identifier_name,'dir_bin','year','weights'])
        self.monthly_factors.set_index([self.identifier_name,'dir_bin','year'], inplace=True, drop=True)
        self.logger.debug('Read monthly factors from database')
        
    def calc_all_TO(self, start_number, year, freq):
        ''' This function iterates through all centreline_id/group_number, retrieves requested information and uploads to the database.
        
        Input: 
            start_number: default = 0; **index** of start centreline_id/group_number. 
            year: the year of interest
            freq: one of 'year', 'day', 'hour'
        Output:
            returns a tuple of a dataframe of volumes and a list of locations where no counts exist
            meanwhile, results are uploaded to the database; if that fails, saved to volumes.csv in the running directoryl
        '''
            
        ids = self.get_sql_results('SELECT DISTINCT ' + self.identifier_name + ', dir_bin FROM prj_volume.centreline_groups ORDER BY ' + self.identifier_name, columns = ['identifier', 'dir_bin'])

        volumes =  []
        non = []
        count = 0
        i = 0
        for identifier, dir_bin in zip(ids['identifier'], ids['dir_bin']):
            if i >= start_number:
                self.logger.info('#%i - Calculating volume for %i %i %i', i, identifier, dir_bin, count)
                try:
                    if freq == 'year':
                        v = self.get_volume(identifier, dir_bin, year)  
                        if v is not None:
                            if self.identifier_name == 'group_number':
                                volumes.append([None, dir_bin, year, int(v), identifier, 1])
                            else:
                                volumes.append([identifier, dir_bin, year, int(v), None, 1])
                            count = count + 1
                        else:
                            non.append([identifier, dir_bin])
                    elif freq == 'month':
                        for m in range(12):
                            v = self.get_volume(identifier, dir_bin, year, month = m+1)
                            if v is not None:
                                if self.identifier_name == 'group_number':
                                    volumes.append([None, dir_bin, year, m+1, int(v), identifier, 1])
                                else:
                                    volumes.append([identifier, dir_bin, year, m+1, int(v), None, 1])
                                count = count + 1
                            else:
                                non.append([identifier, dir_bin])
                                break
                    elif freq == 'hour':
                        for m in range(12):
                            v = self.get_volume(identifier, dir_bin, year, month = m+1, outtype = 'profile')
                            if v is not None:
                                for h in range(24):
                                    if self.identifier_name == 'group_number':
                                        volumes.append([None, dir_bin, year, m+1, h, int(v[h]), identifier, 1])
                                    else:
                                        volumes.append([identifier, dir_bin, year, m+1, h, int(v[h]), None, 1])
                                    count = count + 1
                            else:
                                non.append([identifier, dir_bin])
                                break
                except:
                    self.logger.error('Calculating Procedure Interrupted', exc_info=True)
                    break
    
                if count > 5000:
                    if freq == 'year':
                        self.upload_to_aadt(volumes,truncate=(i==start_number == 0))      
                    elif freq == 'month':
                        self.upload_to_daily_total(volumes,truncate=(i==start_number == 0))  
                    elif freq == 'hour':
                        self.upload_to_monthly_profile(volumes,truncate=(i==start_number == 0))  
                    count = 0
                    volumes = []
            i = i + 1

        try:
            if freq == 'year':
                self.upload_to_aadt(volumes,truncate=(start_number == 0))      
            elif freq == 'month':
                self.upload_to_daily_total(volumes,truncate=(start_number == 0))  
            elif freq == 'hour':
                self.upload_to_monthly_profile(volumes,truncate=(start_number == 0))  
        except:
            self.logger.error(sys.exc_info()[0])
            if freq == 'year':
                columns = ['centreline_id', 'dir_bin', 'year', 'volume', 'group_number','confidence']
            elif freq == 'month':
                columns = ['centreline_id', 'dir_bin', 'year', 'month', 'volume', 'group_number','confidence']
            elif freq == 'hour':
                columns = ['centreline_id', 'dir_bin', 'year', 'month', 'hour', 'volume', 'group_number','confidence']
            if self.identifier_name == 'centreline_id':
                volumes = pd.DataFrame(volumes, columns = columns) 
            else:
                volumes = pd.DataFrame(volumes, columns = columns) 
            volumes.to_csv('volumes.csv')
            self.logger.info('Saved results to volumes.csv')  

        return volumes, non
            
    def calc_date_factors(self, year, month, dates, identifier_value, dir_bin):
        '''
        This function calculates seaonal and annual factors and weights to apply on existing counts to estimate volume on another day.
        
        Input:
            count_date: target date (accepts both string/date type)
            dates: a list of dates that have counts
            centreline_id, dir_bin
        Output:
            dataframe with columns: count_date, factors_month (seasonality factors to be applied to the counts), weight_year (weighting of the count calculated based on recency)
        '''
  
        if (int(identifier_value), int(dir_bin), year) in self.monthly_factors.index:
            mfactors = [float(i) for i in self.monthly_factors.loc[(int(identifier_value), int(dir_bin), year)]['weights']]
        else: # Use average profile, denoted by index (0,0,0)
            mfactors = [float(i) for i in self.monthly_factors.loc[(0,0,0)]['weights']]
        mfactors.append(1/12)
        
        dates = pd.DataFrame(pd.to_datetime(dates), columns=['count_date'])
        dates['diff_y'] = abs(dates['count_date'].dt.year - year)
        maxdiff = max(dates['diff_y'])
        dates['factor_month'] = [mfactors[month-1]/ mfactors[m-1] for m in dates['count_date'].dt.month]
        if maxdiff <= 5:
            dates['weight_year'] = 1
        else:
            dates['weight_year'] = (dates['diff_y'] > 5)*(1-0.5*(dates['diff_y']-5)/(maxdiff-5)) + (dates['diff_y'] <= 5)
        dates['count_date'] = dates['count_date'].dt.date
        
        return dates
        
    def fill_in(self, records, hour=None):
        
        '''
        This function fills in missing data based on cluster centres.
        
        Input:
            cluster: a list of TOD cluster that is returned by KMeans clustering
            records: a dataframe of incomplete data to be filled in (can have multiple days/segments) with columns: centreline_id, dir_bin, count_date, time_15, volume
            hour: the requested hour (optional)
        Output:
            a dataframe containing the hour (if requested, otherwise whole day) of counts for each day/segment passed in       
        '''
        #print(len(records))
        to_classify = cl_fcn.remove_clustered_cl(records, self.tcldircl, self.identifier_name)
        self.logger.debug('Removed already clustered segments, %i segment/day(s) to cluster', len(to_classify['count_date'].drop_duplicates()))
        #print(to_classify)
        classified,_ = cl_fcn.fit_incomplete(self.cluster_profile, to_classify, self.identifier_name)
        
        if type(classified) == int:
            self.logger.error('Error in counts for %i %i')
            return None
        else:
            self.logger.debug('Clustered segments.')
        
        if classified is None:
            classified = self.tcldircl[[self.identifier_name, 'dir_bin', 'cluster']]
        else:
            classified = classified.append(self.tcldircl[[self.identifier_name, 'dir_bin', 'cluster']].drop_duplicates())
        self.logger.debug('Combined clustering infomation.')
        
        # Remove duplicates if multiple days of the same location is passed in
        classified = classified.groupby([self.identifier_name, 'dir_bin'], group_keys=False).apply(lambda x: x.ix[x.cluster.idxmax()]) 
        data = cl_fcn.fill_missing_values(self.cluster_profile, records, classified, self.identifier_name)
        self.logger.debug('Took the mode cluster if multiple clusters are assigned.')
        
        df = []
        for k,v in data.items():
            for i,a in zip(range(96),v):
                df.append([j for j in k]+[i, a])
        df = pd.DataFrame(df, columns = ['count_date', self.identifier_name, 'dir_bin', 'time_15', 'volume'])     
        
        if hour is None:
            return df
        else:
            return df[df['time_15']//4==int(hour)]
        
    def get_clusterinfo(self):
        
        ''' 
        This function retrieves cluster information from the database.
        '''
        
        clusterinfo = self.get_sql_results('SELECT cluster, time_15, vol_weight FROM prj_volume.cluster_profiles ORDER BY cluster, time_15', columns = ['cluster', 'time_15', 'vol_weight'])
        self.cluster_profile = list(clusterinfo.groupby('cluster')['vol_weight'].apply(list))
        if self.identifier_name == 'centreline_id':
            self.tcldircl = self.get_sql_results('SELECT cluster, centreline_id, dir_bin, identifier FROM prj_volume.clusters', columns=['cluster', 'centreline_id', 'dir_bin', 'identifier'])
        elif self.identifier_name == 'group_number':
            self.tcldircl = self.get_sql_results('SELECT cluster, group_id, dir_bin, identifier FROM prj_volume.clusters_group', columns=['cluster', 'group_number', 'dir_bin', 'identifier'])
        else:
            self.logger.error('Identifier (choose between centreline_id or group_number) wrong')
            raise Exception ('identifier wrong')

    def get_relevant_counts(self, identifier_value, dir_bin, year):

        '''
        This function gets all relevant counts to the request. (any counts that share the same centreline group and direction.)
        
        Input:
            db: database connection
            centreline_id, dir_bin
        Output:
            two dataframes (atr and tmc) with columns: centreline_id, dir_bin, group_number, count_date, year, month, day,count_time, volume, time_15
        '''
        
        self.logger.debug('Getting Relevant Counts for %s %i %i', self.identifier_name, identifier_value, dir_bin)
        parameters = [dir_bin, year, identifier_value]
        
        data = self.get_sql_results("query_relevant_counts.sql", columns=[self.identifier_name, 'dir_bin', 'count_date', 'year', 'month', 'day', 'count_time', 'count_type', 'volume'], replace_columns = {'place_holder_identifier_name':self.identifier_name}, parameters=parameters)
        data['volume'] = data['volume'].astype(int)
        tmc = data[data['count_type'] == 2][[self.identifier_name, 'dir_bin', 'count_date', 'year', 'month', 'day', 'count_time', 'volume']]
        atr = data[data['count_type'] == 1][[self.identifier_name, 'dir_bin', 'count_date', 'year', 'month', 'day', 'count_time', 'volume']]
        tmc['time_15'] = tmc.count_time.apply(lambda x: x.hour*4+x.minute//15)
        atr['time_15'] = atr.count_time.apply(lambda x: x.hour*4+x.minute//15)
        
        return tmc, atr    
        
    def get_volume(self, identifier_value, dir_bin, year, month=None, day=None, hour=None, outtype='volume'):
        
        ''' High level get volume function that processes input and calls appropriate functions for information.
        
        Input:
            identififer_value: centreline_id or group_number
            dir_bin
            year, (optional) month, (optional) day, (optional) hour
            outtype: one of 'volume' or 'profile' 
        Output:
            a list of volume profiles or a number.
        '''

        if day is not None:
            count_date = '-'.join([str(x) for x in [year,month,day]])
            if pd.to_datetime(count_date).weekday() in (5, 6):
                self.logger.info('Weekdays Only Please. For now.')
                return None
                
        tmc, atr = self.get_relevant_counts(identifier_value, dir_bin, year)
            
        if type(tmc) == int:
            self.logger.error('Invalid Database Connection.')
            return None
        elif tmc.empty and atr.empty:
            self.logger.info('No relevant counts to interpolate temporally.')
            return None
        
        if month is None:
            self.logger.info('Getting annual average volume')
            return self.get_volume_annualavg(tmc, atr, identifier_value, dir_bin, year)    
        else:
            p = self.get_volume_day_hour(tmc, atr, identifier_value, dir_bin, year, month, day, hour)
            if hour is not None:
                p = p[p['hour']==int(hour)]
            if outtype == 'profile':
                return list(p.groupby('hour', as_index=False).sum()['volume'])
            else:
                return sum(p['volume'])

    def get_volume_annualavg(self, tmc, atr, identifier_value, dir_bin, year):
        
        ''' This function calculates annual average weekday daily traffic. 
        
        Input: 
            tmc, atr: dataframes containing relevant tmc, atr counts 
            identifier_value: centreline_id/group_number
            dir_bin
            year
            
        Output:
            a dataframe of volumes 
        '''
        
        # No temporal aggregation while taking weighted average
        agglvl = 'dir_bin'
    
        if tmc[tmc['count_date'].astype(str).str.contains(str(year),na=False)].empty and atr[atr['count_date'].astype(str).str.contains(str(year),na=False)].empty:   
            # No counts in the requested year, use whatever that's available
            if atr.empty:
                self.logger.debug('%s %i %i: TMC from other years', self.identifier_name, identifier_value, dir_bin)
                data = self.fill_in(tmc)
            else:
                self.logger.debug('%s %i %i: ATR from other years', self.identifier_name, identifier_value, dir_bin)
                data = self.fill_in(atr)
        elif not atr[atr['count_date'].astype(str).str.contains(str(year), na=False)].empty:
            # ATR exists in the requested year
            self.logger.debug('%s %i %i: ATR from requested year', self.identifier_name, identifier_value, dir_bin)
            atr = atr[atr['count_date'].astype(str).str.contains(str(year), na=False)]
            data = self.fill_in(atr)
        else:
            # TMC only in the same year
            self.logger.debug('%s %i %i: TMC from requested year', self.identifier_name, identifier_value, dir_bin)
            tmc = tmc[tmc['count_date'].astype(str).str.contains(str(year), na=False)]
            data = self.fill_in(tmc)
            
        if data is None: # Error encountered
            return 0
        else:
            data = data.groupby([self.identifier_name,'dir_bin','count_date'], as_index=False).sum()

        # calculating factors without month, month=13
        factors = self.calc_date_factors(year, 13, data['count_date'], identifier_value, dir_bin)

        return self.take_weighted_average(data, None, agglvl, factors)['volume'][0]
            
    def get_volume_day_hour(self, tmc, atr, identifier_value, dir_bin, year, month, day, hour=None):
        
        ''' This function calcualtes daily total/profile based on information passed in.
        
        Input: 
            tmc, atr: dataframes containing relevant tmc, atr counts 
            identifier_value: centreline_id/group_number
            dir_bin
            year, month, day, (optional) hour
            
        Output:
            a dataframe of volumes     
        '''
        
        agglvl = 'time_15'
        
        if day is not None:
            count_date = date(year, month, day) 
            # 1. Same Day, Same centreline, Full ATR OR TMC
            # Report Directly
            if hour is not None:
                slicetmc, sliceatr = self.slice_data(tmc, atr,{self.identifier_name: identifier_value, 'count_date':count_date, 'hour':int(hour)})               
                if len(slicetmc) == 4 or len(sliceatr) == 4:
                    self.logger.info('Same Day, Same centreline, Full Hour ATR OR TMC, Report Directly')
                    #print(1)
                    return self.take_weighted_average(slicetmc, sliceatr, agglvl)
            else:
                slicetmc, sliceatr = self.slice_data(tmc, atr, {self.identifier_name: identifier_value, 'count_date':count_date})
                if len(sliceatr) == 96:
                    self.logger.info('Same Day, Same centreline, Full ATR - Report Directly')
                    #print(2)
                    return self.take_weighted_average(None, sliceatr, agglvl)
                
            # 2. Same Day, Same centreline, Partial Data
            # Fill in and Report
            slicetmc_1, sliceatr_1 = self.slice_data(tmc, atr, {self.identifier_name: identifier_value, 'count_date':count_date})
            '''
            print(len(slicetmc), len(sliceatr))
            print(len(slicetmc_1), len(sliceatr_1))
            '''
            if len(sliceatr) > 0 or len(slicetmc) > 0:
                #print(len(sliceatr), len(slicetmc))
                #print(len(sliceatr_1), len(slicetmc_1))
                if len(sliceatr) > len(slicetmc):
                    sliceatr_1 = self.fill_in(sliceatr_1, hour)
                    self.logger.info('Same Day, Same centreline, Fill in ATR')
                    #print(3)
                    return self.take_weighted_average(None, sliceatr_1, agglvl)
                else:
                    slicetmc_1 = self.fill_in(slicetmc_1, hour)
                    self.logger.info('Same Day, Same centreline, Fill in TMC')
                    #print(4)
                    return self.take_weighted_average(slicetmc_1, None, agglvl)
            elif len(sliceatr_1) > 48:
                sliceatr_1 = self.fill_in(sliceatr_1, hour)
                self.logger.info('Same Day, Same centreline, Fill in ATR')
                #print(5)
                return self.take_weighted_average(None, sliceatr_1, agglvl)
            elif len(slicetmc_1) > 24:
                slicetmc_1 = self.fill_in(slicetmc_1, hour)  
                self.logger.info('Same Day, Same centreline, Fill in TMC')
                print(6)
                return self.take_weighted_average(slicetmc_1, None, agglvl)
                
            # 3. Same Day, Same centreline group, Full ATR OR TMC
            # Report Directly
            if hour is not None:
                slicetmc, sliceatr = self.slice_data(tmc, atr,{'count_date':count_date, 'hour':int(hour)})
                if len(slicetmc) == 4 or len(sliceatr) == 4:
                    self.logger.info('Same Day, Same centreline group, Full Hour ATR OR TMC - Report Directly')
                    #print(7)
                    return self.take_weighted_average(slicetmc, sliceatr, agglvl)
            else:
                slicetmc, sliceatr = self.slice_data(tmc, atr, {'count_date':count_date})
                if len(sliceatr) == 96:
                    self.logger.info('Same Day, Same centreline group, Full ATR - Report Directly')
                    #print(8)
                    return self.take_weighted_average(None, sliceatr, agglvl) 
                    
            # 4. Same Day, Same centreline group, Partial Data
            # Fill in and Report
            slicetmc_1, sliceatr_1 = self.slice_data(tmc, atr, {'count_date':count_date})
            
            if len(sliceatr) > 0 or len(slicetmc) > 0:
                if len(sliceatr) > len(slicetmc):
                    sliceatr_1 = self.fill_in(sliceatr_1, hour)
                    self.logger.info('Same Day, Same centreline group, Fill in ATR')
                    #print(9)
                    return self.take_weighted_average(None, sliceatr_1, agglvl)
                else:
                    slicetmc_1 = self.fill_in(slicetmc_1, hour)
                    self.logger.info('Same Day, Same centreline group, Fill in TMC')
                    #print(10)
                    return self.take_weighted_average(slicetmc_1, None, agglvl)
            elif len(sliceatr_1) > 48:
                sliceatr_1 = self.fill_in(sliceatr_1, hour)
                self.logger.info('Same Da, Same centreline groupy, Fill in ATR')
                #print(11)
                return self.take_weighted_average(None, sliceatr_1, agglvl)
            elif len(slicetmc_1) > 24:
                slicetmc_1 = self.fill_in(slicetmc_1, hour)  
                self.logger.info('Same Day, Same centreline group, Fill in TMC')
                #print(12)
                return self.take_weighted_average(slicetmc_1, None, agglvl)

        # 5. Different Day, Same centreline, Full Hour
        if hour is not None:
            slicetmc, sliceatr = self.slice_data(tmc, atr, {self.identifier_name: identifier_value, 'hour':int(hour)}) 
            if slicetmc['time_15'].nunique() == 4 or sliceatr['time_15'].nunique() == 4:
                factors_date = self.calc_date_factors(year, month, slicetmc['count_date'].append( sliceatr['count_date']).unique(), identifier_value, dir_bin)
                self.logger.info('Different Day, Same centreline, Full Hour')
                #print(13)
                return self.take_weighted_average(slicetmc, sliceatr, agglvl, factors_date=factors_date)
        else:
            slicetmc, sliceatr = self.slice_data(tmc, atr, {self.identifier_name: identifier_value}) 
            if sliceatr['time_15'].nunique() == 96:
                factors_date = self.calc_date_factors(year, month, sliceatr['count_date'].append( sliceatr['count_date']).unique(), identifier_value, dir_bin)
                self.logger.info('Different Day, Same centreline, Full Hour')
                #print(14)
                return self.take_weighted_average(None, sliceatr, agglvl, factors_date=factors_date)
                
        # 6. Different Day, Same centreline, Partial Data
        slicetmc_1, sliceatr_1 = self.slice_data(tmc, atr, {self.identifier_name: identifier_value}) 
        if (not slicetmc_1.empty) or (not sliceatr_1.empty):
            factors_date = self.calc_date_factors(year, month, slicetmc_1['count_date'].append( sliceatr_1['count_date']).unique(), identifier_value, dir_bin)
        if sliceatr['time_15'].nunique() > 0 or slicetmc['time_15'].nunique() > 0:
            if sliceatr['time_15'].nunique() > slicetmc['time_15'].nunique():
                sliceatr_1 = self.fill_in(sliceatr_1, hour)
                self.logger.info('Different Day, Same centreline, Fill in ATR')
                print(15)
                return self.take_weighted_average(None, sliceatr_1, agglvl, factors_date=factors_date)
            else:
                slicetmc_1 = self.fill_in(slicetmc_1, hour)  
                self.logger.info('Different Day, Same centreline, Fill in TMC')
                #print(16)
                return self.take_weighted_average(slicetmc_1, None, agglvl, factors_date=factors_date)
        elif sliceatr_1['time_15'].nunique() > 48:
            sliceatr_1 = self.fill_in(sliceatr_1, hour)
            self.logger.info('Different Day, Same centreline, Fill in ATR')
            print(17)
            return self.take_weighted_average(None, sliceatr_1, agglvl, factors_date=factors_date)
        elif slicetmc_1['time_15'].nunique() > 24:
            slicetmc_1 = self.fill_in(slicetmc_1, hour)  
            self.logger.info('Different Day, Same centreline, Fill in TMC')
            #print(18)
            return self.take_weighted_average(slicetmc_1, None, agglvl, factors_date=factors_date)
        
        # 7. Different Day, Same centreline group, Full Hour
        if hour is not None:
            slicetmc, sliceatr = self.slice_data(tmc, atr, {'hour':int(hour)}) 
            if slicetmc['time_15'].nunique() == 4 or sliceatr['time_15'].nunique() == 4:
                factors_date = self.calc_date_factors(year, month, slicetmc['count_date'].append( sliceatr['count_date']).unique(), identifier_value, dir_bin)
                self.logger.info('Different Day, Same centreline group, Full Hour')
                #print(19)
                return self.take_weighted_average(slicetmc, sliceatr, agglvl, factors_date=factors_date)
        else:
            slicetmc, sliceatr = tmc, atr
            if sliceatr['time_15'].nunique() == 96:
                factors_date = self.calc_date_factors(year, month, sliceatr['count_date'].append( sliceatr['count_date']).unique(), identifier_value, dir_bin)
                self.logger.info('Different Day, Same centreline group, Full Hour')
                #print(20)
                return self.take_weighted_average(None, sliceatr, agglvl, factors_date=factors_date)
                
        # 8. Different Day, Same centreline group, Partial Data
        slicetmc_1, sliceatr_1 = tmc, atr
        factors_date = self.calc_date_factors(year, month, slicetmc_1['count_date'].append( sliceatr_1['count_date']).unique(), identifier_value, dir_bin)
        if sliceatr['time_15'].nunique() > 0 or slicetmc['time_15'].nunique() > 0:
            if sliceatr['time_15'].nunique() > slicetmc['time_15'].nunique():
                sliceatr_1 = self.fill_in(sliceatr_1, hour)
                self.logger.info('Different Day, Same centreline group, Fill in ATR')
                print(21)
                return self.take_weighted_average(None, sliceatr_1, agglvl, factors_date=factors_date)
            else:
                slicetmc_1 = self.fill_in(slicetmc_1, hour)  
                self.logger.info('Different Day, Same centreline group, Fill in TMC')
                #print(22)
                return self.take_weighted_average(slicetmc_1, None, agglvl, factors_date=factors_date)
        elif sliceatr_1['time_15'].nunique() > 48:
            sliceatr_1 = self.fill_in(sliceatr_1, hour)
            self.logger.info('Different Day, Same centreline group, Fill in ATR')
            print(23)
            return self.take_weighted_average(None, sliceatr_1, agglvl, factors_date=factors_date)
        elif slicetmc_1['time_15'].nunique() > 24:
            slicetmc_1 = self.fill_in(slicetmc_1, hour)  
            self.logger.info('Different Day, Same centreline group, Fill in TMC')
            print(24)
            return self.take_weighted_average(slicetmc_1, None, agglvl, factors_date=factors_date)
            
        return None
        
    def refresh_monthly_factors(self):
        '''
        This function refreshes monthly factors table in the database based on the current version of prj_volume.centreline_volumes.
        '''
        
        factors = self.get_sql_results("query_monthly_factors.sql", columns = [self.identifier_name, 'dir_bin','year','weights'], replace_columns = {'place_holder_identifier_name':self.identifier_name})
    
        f_sum = [0] * 12
        t = []
        for (i, d, y, weight) in zip(factors[self.identifier_name], factors['dir_bin'], factors['year'], factors['weights']):
            f = [float(x) for x in weight]
            f_sum = [x+j for x, j in zip(f, f_sum)]
            c = [str(float(x)) for x in weight]
            t.append([int(i),int(d),int(y),"{"+",".join(c)+"}"])
            
        f_sum = [i/len(factors) for i in f_sum]
        c = [str(float(x)) for x in f_sum]
        t.append([0,0,0,"{"+",".join(c)+"}"])
        
        if self.identifier_name == 'centreline_id':
            self.truncatetable('prj_volume.monthly_factors')
            self.inserttable('prj_volume.monthly_factors',t)
            self.logger.info('Updated monthly factors for centrelines')
        elif self.identifier_name == 'group_number':
            self.truncatetable('prj_volume.monthly_factors_group')
            self.inserttable('prj_volume.monthly_factors_group',t)
            self.logger.info('Updated monthly factors for centreline groups')
            
    def slice_data(self, df1, df2, args):
        
        '''
        This function slices the two dataframes passed in based on requirements.
        
        Input:
            df1, df2: dataframes to be sliced with columns: count_date, centreline_id, time_15
            args: dictionary. filter criteria. {name:value}
        Output:
            two dataframes after slicing
        '''
        
        df1['hour'] = df1['time_15']//4
        df2['hour'] = df2['time_15']//4
        
        for key,value in args.items():
            df1 = df1[df1[key]==value]
            df2 = df2[df2[key]==value]
            #print(key,value)
            #print(len(df1), len(df2))

        return df1, df2
        
    def take_weighted_average(self, tmc, atr, agglvl, factors_date=None):
        
        '''
        ** all data will be added up do not pass in redundant rows
        This function calculates a factored&weighted average volume for estimation.
        
        Input:
            tmc, atr: two dataframe to be processed with columns: count_date, centreline_id, time_15, volume
            factors_date: dataframe containing factors to be applied. specifications see function calc_date_factors
        
        Output:
            a weighted total volume/volume profile
        '''
        
        if factors_date is None:
            df = pd.concat([tmc,atr]).groupby([self.identifier_name, 'dir_bin', agglvl], as_index=False).mean()
            df['hour'] = df['time_15']//4
            return df
        else:

            df = pd.concat([tmc, atr]).merge(factors_date, on=['count_date']) 
            #print(df)
            if df.empty:
                raise ValueError('No value passed to take average.')
            df['volume'] = df['volume']*df['factor_month']
            df1 = []
            for (time_15), group in df.groupby(agglvl):        
                volume = 0 
                weights_sum = sum(group['weight_year'])
                for v,w in zip(group['volume'], group['weight_year']):
                    volume = volume + v*w/weights_sum

                df1.append([time_15//4, volume])
            #print(df1)
            return pd.DataFrame(df1, columns=['hour','volume'])
                
    def testing_hourly(self):
        ''' Pre-defined test cases 
            Weighted AVG taking ALL counts into account (1983-2016)'''
            
        if self.identifier_name != 'centreline_id':
            self.logger.error('Please create instance with identifier being centreline_id')
            return
        
        # (1) same date, directly retrieve TMC
        self.logger.info(self.get_volume(142, -1, 2002, 3, 11, 8)) # 41
        # (1) same date, Average of ATR and TMC
        self.logger.info(self.get_volume(1149, +1, 2004, 6, 24, 14)) # 61
        
        # (2) same date, Fill in ATR (partial data in that hour)
        self.logger.info(self.get_volume(890, -1, 2005, 8, 4, 9)) # ~5000
        # (2) same date, Fill in ATR (no count in that hour)
        self.logger.info(self.get_volume(1978, -1, 2005, 8, 4, 8)) # ~4000
        # (2) same date, Fill in TMC
        self.logger.info(self.get_volume(161, -1, 2005, 8, 11, 9)) # ~60
    
        # (3) same date, share volume with tcl 7636691, directly retrieve ATR
        self.logger.info(self.get_volume(14020872, -1, 2010, 4, 27, 3)) # 47
        
        # (4) same date, share volume with tcl 1821, fill in ATR  (partial data in that hour)
        self.logger.info(self.get_volume(1850, 1, 2012, 10, 30, 3)) # ~ 19
        # (4) same date, share volume with tcl 1821, fill in ATR  (no data in that hour)
        self.logger.info(self.get_volume(1850, 1, 2012, 10, 30, 2)) # ~ 30
        # (4) same date, share volume with tcl 7636691, fill in TMC
        self.logger.info(self.get_volume(14020872, -1, 2009, 7, 21, 18)) # ~180
        
        # (5) diff date, weighted avg of ATR
        self.logger.info(self.get_volume(117, +1, 2011, 6, 9, 20)) # ~55
        # (5) diff date, weighted avg of ATR and TMC
        self.logger.info(self.get_volume(142, -1, 2003, 3, 11, 8)) # ~40
        
        # (6) diff date, Fill in ATR
        self.logger.info(self.get_volume(8570852, 1, 2006, 8, 4, 12)) # ~60
        # (6) diff date, Fill in TMC
        self.logger.info(self.get_volume(112888, -1, 2006, 8, 11, 7)) # ~860
        
        # (7) diff date, share volume with tcl 7636691, full hour
        self.logger.info(self.get_volume(14020872, -1, 2011, 4, 27, 3)) # ~54   
        
        # (8) diff date, share volume with tcl 181, fill in TMC
        self.logger.info(self.get_volume(1863, 1, 2013, 4, 24, 13)) # ~15
        
    def testing_daily(self):
        ''' Pre-defined test cases 
            Weighted AVG taking ALL counts into account (1983-2016)'''
        
        if self.identifier_name != 'centreline_id':
            self.logger.error('Please create instance with identifier being centreline_id')
            return
        
        self.logger.info(self.get_volume(142, -1, 2002, 3, 11))  # 1549

        self.logger.info(self.get_volume(1149, +1, 2004, 6, 24))  # 978
        
        self.logger.info(self.get_volume(890, -1, 2005, 8, 4)) # ~77513
        
        self.logger.info(self.get_volume(161, -1, 2005, 8, 11)) # ~1131
    
        self.logger.info(self.get_volume(14020872, -1, 2010, 4, 27)) # 6205
    
        self.logger.info(self.get_volume(14020872, -1, 2009, 7, 21)) # ~3040
        self.logger.info(self.get_volume(14020872, -1, 2009, 7))  # ~3040
        
        self.logger.info(self.get_volume(117, +1, 2011, 6)) # ~1304
        
        self.logger.info(self.get_volume(8570852, 1, 2006, 8, 4)) # ~1403
        self.logger.info(self.get_volume(112888, -1, 2006, 8))  # ~8303

        self.logger.info(self.get_volume(14020872, -1, 2011, 4, 27))# ~5964
        
        self.logger.info(self.get_volume(1863, 1, 2013, 4, 24)) # ~381

    def upload_to_daily_total(self, volumes, truncate=True):
        ''' Upload to prj_volume.daily_total_by_month '''
        
        if self.identifier_name == 'centreline_id':
            groups = self.get_sql_results('SELECT centreline_id, dir_bin, group_number FROM prj_volume.centreline_groups', columns = ['centreline_id','dir_bin','group_number'])
            volumes = pd.DataFrame(volumes, columns = ['centreline_id','dir_bin','year','volume'])  
            volumes = pd.merge(volumes, groups, how='inner', on=['centreline_id','dir_bin'])
            volumes = volumes.values.tolist()
        if truncate:
            self.truncatetable('prj_volume.daily_total_by_month')
        self.inserttable('prj_volume.daily_total_by_month', volumes)
        self.logger.info('Uploaded results to prj_volume.daily_total_by_month')
        
    def upload_to_monthly_profile(self, volumes, truncate=True):
        ''' Upload to prj_volume.daily_profile_by_month '''
        
        if self.identifier_name == 'centreline_id':
            groups = self.get_sql_results('SELECT centreline_id, dir_bin, group_number FROM prj_volume.centreline_groups', columns = ['centreline_id','dir_bin','group_number'])
            volumes = pd.DataFrame(volumes, columns = ['centreline_id','dir_bin','year','volume'])  
            volumes = pd.merge(volumes, groups, how='inner', on=['centreline_id','dir_bin'])
            volumes = volumes.values.tolist()
        if truncate:
            self.truncatetable('prj_volume.daily_profile_by_month')
        self.inserttable('prj_volume.daily_profile_by_month', volumes)
        self.logger.info('Uploaded results to prj_volume.daily_profile_by_month')
        
    def upload_to_aadt(self, volumes, truncate=True):
        ''' Upload to prj_volume.aadt '''
        
        if self.identifier_name == 'centreline_id':
            groups = self.get_sql_results('SELECT centreline_id, dir_bin, group_number FROM prj_volume.centreline_groups', columns = ['centreline_id','dir_bin','group_number'])
            volumes = pd.DataFrame(volumes, columns = ['centreline_id','dir_bin','year','volume'])  
            volumes = pd.merge(volumes, groups, how='inner', on=['centreline_id','dir_bin'])
            
            volumes = volumes.values.tolist()
        if truncate:
            self.truncatetable('prj_volume.aadt')
        self.inserttable('prj_volume.aadt', volumes)
        self.logger.info('Uploaded results to prj_volume.aadt')