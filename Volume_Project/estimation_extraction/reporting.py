# -*- coding: utf-8 -*-
"""
Created on Mon May  1 11:58:02 2017

@author: qwang2
"""

import sys
sys.path.append('../12 Volume Clustering/')

import warnings
warnings.simplefilter('error', RuntimeWarning)

from datetime import datetime
import pandas as pd
import cl_fcn
import pickle
from utilities import vol_utils
import logging

class temporal_extrapolation(vol_utils):    
    
    def __init__(self, identifier_name):
        self.logger = logging.getLogger('volume_project.temporal_extrapolation')
        super().__init__()
        self.identifier_name = identifier_name
        self.get_clusterinfo()
   
    def calc_date_factors(self, date, dates, identifier_value, dir_bin):
        '''
        This function calculates seaonal and annual factors and weights to apply on existing counts to estimate volume on another day.
        
        Input:
            date: target date (accepts both string/date type)
            dates: a list of dates that have counts
            centreline_id, dir_bin
        Output:
            dataframe with columns: count_date, factors_month (seasonality factors to be applied to the counts), weight_year (weighting of the count calculated based on recency)
        '''
        try:
            monthly_factors = self.load_pkl("monthly_factors_"+self.identifier_name+".p")
            self.logger.debug('Reading monthly factors from pickle')
        except:
            self.logger.debug('Refreshing monthly factors from database')
            self.refresh_monthly_factors()
            monthly_factors = self.load_pkl("monthly_factors_"+self.identifier_name+".p")
            self.logger.debug('Monthly factors saved as pickle file')
            
        # if date is a year, then target month is 13 - weight = 1
        try:
            year = int(date)
            month = 13
        except:
            if type(date) == str:
                date = datetime.strptime(date, '%Y-%m-%d')
            year = date.year
            month = date.month
            
        if (int(identifier_value), int(dir_bin), year) in monthly_factors.index:
            mfactors = [float(i) for i in monthly_factors.iloc[monthly_factors.index.get_loc((int(identifier_value), int(dir_bin), year))]['weights']]
        else:
            mfactors = monthly_factors.loc['average']['weights']
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
        
        to_classify = cl_fcn.remove_clustered_cl(records, self.tcldircl, self.identifier_name)
        classified,_ = cl_fcn.fit_incomplete(self.cluster_profile, to_classify, self.identifier_name)
    
        if classified is None:
            classified = self.tcldircl[[self.identifier_name, 'dir_bin', 'cluster']]
        else:
            classified = classified.append(self.tcldircl[[self.identifier_name, 'dir_bin', 'cluster']].drop_duplicates())
            
        # Remove duplicates if multiple days of the same location is passed in
        classified = classified.groupby([self.identifier_name, 'dir_bin'], group_keys=False).apply(lambda x: x.ix[x.cluster.idxmax()]) 
        data = cl_fcn.fill_missing_values(self.cluster_profile, records, classified, self.identifier_name)
    
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
            two dataframes (atr and tmc) with columns: centreline_id, dir_bin, group_number, count_date, count_time, volume, time_15
        '''
        
        self.logger.debug('Getting Relevant Counts for %s %i %i', self.identifier_name, identifier_value, dir_bin)
        parameters = {'place_holder_identifier_name':self.identifier_name, 'place_holder_dir_bin': str(dir_bin), 'place_holder_year': str(year), 'place_holder_identifier_value': identifier_value}
        
        data = self.get_sql_results("query_relevant_counts.sql", columns=[self.identifier_name, 'dir_bin', 'count_date', 'count_time', 'count_type', 'volume'], parameters=parameters)
        data['volume'] = data['volume'].astype(int)
        
        tmc = data[data['count_type'] == 2][[self.identifier_name, 'dir_bin', 'count_date', 'count_time', 'volume']]
        atr = data[data['count_type'] == 1][[self.identifier_name, 'dir_bin', 'count_date', 'count_time', 'volume']]
        
        tmc['time_15'] = tmc.count_time.apply(lambda x: x.hour*4+x.minute//15)
        atr['time_15'] = atr.count_time.apply(lambda x: x.hour*4+x.minute//15)
        return tmc, atr    
        
    def get_volume(self, identifier_value, dir_bin, date, hour=None, profile=False):
     
        try:
            date = int(date)
            tmc, atr = self.get_relevant_counts(identifier_value, dir_bin, date)
        except:    
            if pd.to_datetime(date).weekday() in (5, 6):
                self.logger.info('Weekdays Only Please. For now.')
                return None
            if type(date) == str:
                date = datetime.strptime(date, '%Y-%m-%d').date()
            tmc, atr = self.get_relevant_counts(identifier_value, dir_bin, date.year)
            
        if type(tmc) == int:
            self.logger.error('Invalid Database Connection.')
            return None
        elif tmc.empty and atr.empty:
            self.logger.info('No relevant counts to interpolate temporally.')
            return None
            
        if hour is not None:    
            self.logger.info('Getting hourly volume')
            return self.get_volume_hour(tmc, atr, identifier_value, dir_bin, date, hour)
        elif type(date) == int:
            self.logger.info('Getting annual average volume')
            return self.get_volume_annualavg(tmc, atr, identifier_value, dir_bin, date)
        else:
            self.logger.info('Getting daily volume')
            p = self.get_volume_day(tmc, atr, identifier_value, dir_bin, date)
            if profile:
                return p
            else:
                return sum(p)

    def get_volume_annualavg(self, tmc, atr, identifier_value, dir_bin, year):
        
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
        
        data = data.groupby([self.identifier_name,'dir_bin','count_date'], as_index=False).sum()

        factors = self.calc_date_factors(year, data['count_date'], identifier_value, dir_bin)

        return self.take_weighted_average(data, None, agglvl, factors)
            
    def get_volume_day(self, tmc, atr, centreline_id, dir_bin, date):
        
        pass
    
    def get_volume_hour(self, tmc, atr, identifier_value, dir_bin, date, hour):
        
        agglvl = 'time_15'
        
        # 1. Same Day, Same centreline, Full Hour ATR OR TMC
        # Report Directly
        slicetmc, sliceatr = self.slice_data(tmc, atr, {self.identifier_name: identifier_value, 'count_date':date, 'hour':int(hour)})
        if len(slicetmc) == 4 or len(sliceatr) == 4:
            self.logger.info('Same Day, Same centreline, Full Hour ATR OR TMC, Report Directly')
            return self.take_weighted_average(slicetmc, sliceatr, agglvl)
    
        # 2. Same Day, Same centreline, Partial Data
        # Fill in and report
        slicetmc_1, sliceatr_1 = self.slice_data(tmc, atr, {self.identifier_name: identifier_value, 'count_date':date})
        if len(sliceatr) > 0 or len(slicetmc) > 0:
            if len(sliceatr) > len(slicetmc):
                sliceatr_1 =  self.fill_in(sliceatr_1, hour)
                self.logger.info('Same Day, Same centreline, Fill in ATR')
                return self.take_weighted_average(None, sliceatr_1, agglvl)
            else:
                slicetmc_1 = self.fill_in(slicetmc_1, hour)
                self.logger.info('Same Day, Same centreline, Fill in TMC')
                return self.take_weighted_average(slicetmc_1, None, agglvl)
        elif len(sliceatr_1) > 48:
            sliceatr_1 = self.fill_in(sliceatr_1, hour)
            self.logger.info('Same Day, Same centreline, Fill in ATR')
            return self.take_weighted_average(None, sliceatr_1, hour, agglvl)
        elif len(slicetmc_1) > 24:
            slicetmc_1 = self.fill_in(slicetmc_1, hour)
            self.logger.info('Same Day, Same centreline, Fill in TMC')
            return self.take_weighted_average(slicetmc_1, None, agglvl)
    
        # 3. Same Day, Same centreline group, Full Hour ATR OR TMC
        # Report Directly
        slicetmc, sliceatr = self.slice_data(tmc, atr, {'count_date':date, 'hour':int(hour)})
        if len(slicetmc) == 4 or len(sliceatr) == 4:
            self.logger.info('Same Day, Same centreline group, Full Hour ATR OR TMC - Report Directly')
            return self.take_weighted_average(slicetmc, sliceatr, agglvl)
            
        # 4. Same Day, Same centreline group, Partial Data
        # Fill in and Report
        slicetmc_1, sliceatr_1 = self.slice_data(tmc, atr, {'count_date':date})
        
        if len(sliceatr) > 0 or len(slicetmc) > 0:
            if len(sliceatr) > len(slicetmc):
                sliceatr_1 = self.fill_in(sliceatr_1, hour)
                self.logger.info('Same Day, Same centreline group, Fill in ATR')
                return self.take_weighted_average(None, sliceatr_1, agglvl)
            else:
                slicetmc_1 = self.fill_in(slicetmc_1, hour)
                self.logger.info('Same Day, Same centreline group, Fill in TMC')
                return self.take_weighted_average(slicetmc_1, None, agglvl)
        elif len(sliceatr_1) > 48:
            sliceatr_1 = self.fill_in(sliceatr_1, hour)
            self.logger.info('Same Day, Same centreline group, Fill in ATR')
            return self.take_weighted_average(None, sliceatr_1, agglvl)
        elif len(slicetmc_1) > 24:
            slicetmc_1 = self.fill_in(slicetmc_1, hour)  
            self.logger.info('Same Day, Same centreline group, Fill in TMC')
            return self.take_weighted_average(slicetmc_1, None, agglvl)
            
        # 5. Different Day, Same centreline, Full Hour
        # Apply Year-to-Year/Seasonality Factors/Weights and Report
        slicetmc, sliceatr = self.slice_data(tmc, atr, {self.identifier_name: identifier_value, 'hour':int(hour)})
        
        if slicetmc['time_15'].nunique() == 4 or sliceatr['time_15'].nunique() == 4:
            factors_date = self.calc_date_factors(date, slicetmc['count_date'].append( sliceatr['count_date']).unique(), identifier_value, dir_bin)
            self.logger.info('Different Day, Same centreline, Full Hour')
            return self.take_weighted_average(slicetmc, sliceatr, agglvl, factors_date=factors_date)
            
        # 6. Different Day, Same centreline, Partial Data
        # Fill in, Apply Year-to-Year/Seasonality Factors/Weights and Report
        slicetmc_1, sliceatr_1 = self.slice_data(tmc, atr, {self.identifier_name: identifier_value})
        if (not slicetmc_1.empty) or (not sliceatr_1.empty):
            factors_date = self.calc_date_factors(date, slicetmc_1['count_date'].append( sliceatr_1['count_date']).unique(), identifier_value, dir_bin)
        if sliceatr['time_15'].nunique() > 0 or slicetmc['time_15'].nunique() > 0:
            if sliceatr['time_15'].nunique() > slicetmc['time_15'].nunique():
                sliceatr_1 = self.fill_in(sliceatr_1, hour)
                self.logger.info('Different Day, Same centreline, Fill in ATR')
                return self.take_weighted_average(None, sliceatr_1, agglvl, factors_date=factors_date)
            else:
                slicetmc_1 = self.fill_in(slicetmc_1, hour) 
                self.logger.info('Different Day, Same centreline, Fill in TMC')
                return self.take_weighted_average(slicetmc_1, None, agglvl, factors_date=factors_date)
        elif sliceatr_1['time_15'].nunique() > 48:
            sliceatr_1 = self.fill_in(sliceatr_1, hour)
            self.logger.info('Different Day, Same centreline, Fill in ATR')
            return self.take_weighted_average(None, sliceatr_1, agglvl, factors_date=factors_date)
        elif slicetmc_1['time_15'].nunique() > 24:
            slicetmc_1 = self.fill_in(slicetmc_1, hour)    
            self.logger.info('Different Day, Same centreline, Fill in TMC')
            return self.take_weighted_average(slicetmc_1, None, agglvl, factors_date=factors_date) 
            
        # 7. Different Day, Same centreline group, Full Hour
        slicetmc, sliceatr = self.slice_data(tmc, atr, {'hour':int(hour)})
        if slicetmc['time_15'].nunique() == 4 or sliceatr['time_15'].nunique() == 4:
            factors_date = self.calc_date_factors(date, slicetmc['count_date'].append( sliceatr['count_date']).unique(), identifier_value, dir_bin)
            self.logger.info('Different Day, Same centreline group, Full Hour')
            return self.take_weighted_average(slicetmc, sliceatr, agglvl, factors_date=factors_date)
            
        # 8. Different Day, Same centreline group, Partial Data
        slicetmc_1, sliceatr_1 = tmc, atr
        factors_date = self.calc_date_factors(date, slicetmc_1['count_date'].append( sliceatr_1['count_date']).unique(), identifier_value, dir_bin)
        if sliceatr['time_15'].nunique() > 0 or slicetmc['time_15'].nunique() > 0:
            if sliceatr['time_15'].nunique() > slicetmc['time_15'].nunique():
                sliceatr_1 = self.fill_in(sliceatr_1, hour)
                self.logger.info('Different Day, Same centreline group, Fill in ATR')
                return self.take_weighted_average(None, sliceatr_1, agglvl, factors_date=factors_date)
            else:
                slicetmc_1 = self.fill_in(slicetmc_1, hour)  
                self.logger.info('Different Day, Same centreline group, Fill in TMC')
                return self.take_weighted_average(slicetmc_1, None, agglvl, factors_date=factors_date)
        elif sliceatr_1['time_15'].nunique() > 48:
            sliceatr_1 = self.fill_in(sliceatr_1, hour)
            self.logger.info('Different Day, Same centreline group, Fill in ATR')
            return self.take_weighted_average(None, sliceatr_1, agglvl, factors_date=factors_date)
        elif slicetmc_1['time_15'].nunique() > 24:
            slicetmc_1 = self.fill_in(slicetmc_1, hour)  
            self.logger.info('Different Day, Same centreline group, Fill in TMC')
            return self.take_weighted_average(slicetmc_1, None, agglvl, factors_date=factors_date)
        
        return None
        
    def refresh_monthly_factors(self):
        
        parameters = {'place_holder_identifier_name':self.identifier_name}
        factors = self.get_sql_results("query_monthly_factors.sql", columns = ['centreline_id', 'dir_bin','year','weights'], parameters=parameters)
    
        factors1 = factors.set_index(['centreline_id', 'dir_bin','year'])
        f_sum = [0] * 12
        for weight in factors1['weights']:
            f = [float(i) for i in weight]
            f_sum = [i+j for i, j in zip(f, f_sum)]
        f_sum = [i/len(factors) for i in f_sum]
        f_sum = pd.DataFrame([[f_sum]], index=['average'], columns=['weights'])
        factors1 = factors1.append(f_sum)
        pickle.dump(factors1, open("monthly_factors_"+self.identifier_name+".p","wb"))    
        
    def slice_data(self, df1, df2, args):
        
        '''
        This function slices the two dataframes passed in based on the optional criteria.
        
        Input:
            df1, df2: dataframes to be sliced with columns: count_date, centreline_id, time_15
            identifier_value, count_date, hour: (optional) filter criteria
        Output:
            two dataframes after slicing
        '''
        df1['hour'] = df1['time_15']//4
        df2['hour'] = df2['time_15']//4
        
        for key,value in args.items():
            df1 = df1[df1[key]==value]
            df2 = df2[df2[key]==value]

        return df1, df2
        
    def take_weighted_average(self, tmc, atr, agglvl, factors_date=None):
        '''
        ** all data will be added up do not pass in redundant rows
        This function calculates a factored&weighted average volume for estimation.
        
        Input:
            tmc, atr: two dataframe to be processed with columns: count_date, centreline_id, time_15, volume
            factors_date: dataframe containing factors to be applied. specifications see function calc_date_factors
        
        Output:
            a number that represents the average hourly volume
        '''
        if factors_date is None:
            df = pd.concat([tmc,atr]).groupby([self.identifier_name, 'dir_bin', agglvl], as_index=False).mean().groupby([self.identifier_name, 'dir_bin'], as_index=False).sum()

            return df['volume'][0]
        else:
            df = pd.concat([tmc, atr]).merge(factors_date, on=['count_date'])
            if df.empty:
                raise ValueError('No value passed to take average.')
            df['volume'] = df['volume']*df['factor_month']
            total = 0
            for (time_15), group in df.groupby(agglvl):        
                volume = 0 
                weights_sum = sum(group['weight_year'])
                for v,w in zip(group['volume'], group['weight_year']):
                    volume = volume + v*w/weights_sum
                total = total + volume
                
            return total       
            
    def testing(self):
        ''' Predefined test cases 
            Weighted AVG taking ALL counts into account (1983-2016)'''
            
        # (1) same date, directly retrieve ATR
        self.logger.info(self.get_volume(117, +1, '2010-06-09', 20)) # 42
        # (1) same date, directly retrieve TMC
        self.logger.info(self.get_volume(142, -1, '2002-03-11', 8)) # 39
        # (1) same date, Average of ATR and TMC
        self.logger.info(self.get_volume(1149, +1, '2004-06-24', 14)) # 61.5
        
        # (2) same date, Fill in ATR
        self.logger.info(self.get_volume(890, -1, '2005-08-04', 9)) # ~5000
        # (2) same date, Fill in TMC
        self.logger.info(self.get_volume(161, -1, '2005-08-11', 9)) # ~60
    
        # (3) same date, share volume with tcl 7636691, directly retrieve ATR
        self.logger.info(self.get_volume(14020872, -1, '2010-04-27', 3)) # 47
        
        # (4) same date, share volume with tcl 7636691, fill in TMC
        self.logger.info(self.get_volume(14020872, -1, '2009-07-21', 18)) # ~178
        
        # (5) diff date, weighted avg of ATR
        self.logger.info(self.get_volume(117, +1, '2011-06-09', 20)) # ~55
        # (5) diff date, weighted avg of ATR and TMC
        self.logger.info(self.get_volume(142, -1, '2003-03-11', 8)) # ~40
        # (5) diff date, weighted avg of ATR and TMC
        self.logger.info(self.get_volume(1149, +1, '2005-06-24', 14)) # ~50   
        
        # (6) diff date, Fill in ATR
        self.logger.info(self.get_volume(8570852, 1, '2006-08-04', 12)) # ~6
        # (6) diff date, Fill in TMC
        self.logger.info(self.get_volume(112888, -1, '2006-08-11', 7)) # ~760
        
        # (7) diff date, share volume with tcl 7636691, full hour
        self.logger.info(self.get_volume(14020872, -1, '2011-04-27', 3)) # ~54   
        
        # (8) diff date, share volume with tcl 181, fill in TMC
        self.logger.info(self.get_volume(118, 1, '2011-04-27', 16)) # ~22
        
    def testing_entire_TO(self):
        centrelines = self.get_sql_results('SELECT DISTINCT group_number, dir_bin FROM prj_volume.centreline_groups ORDER BY group_number', columns = ['identifier', 'dir_bin'])

        volumes =  []
        non = []
        i = 0
        for identifier, dir_bin in zip(centrelines['identifier'], centrelines['dir_bin']):
            self.logger.info('#%i - Calculating volume for %i %i', i, identifier, dir_bin)
            try:
                v = self.get_volume(identifier, dir_bin, '2015')  
            except:
                self.logger.error('Calculating Procedure Interrupted', exc_info=True)
                try:
                    self.upload_to_aadt(volumes)    
                except:
                    if self.identifier_name == 'centreline_id':
                        volumes = pd.DataFrame(volumes, columns = ['centreline_id', 'dir_bin', 'year', 'volume'])  
                    else:
                        volumes = pd.DataFrame(volumes,columns = ['centreline_id', 'dir_bin', 'year', 'volume', 'group_number']) 
                    volumes.to_csv('volumes.csv')
                    self.logger.info('Saved results to volumes.csv')
                    
                return volumes, non
                
            if v is not None:
                if self.identifier_name == 'centreline_id':
                    volumes.append([identifier, dir_bin, 2015, int(v)])
                else:
                    volumes.append([None, dir_bin, 2015, int(v), identifier])
            else:
                non.append([identifier, dir_bin])
            i = i + 1

        self.upload_to_aadt(volumes)    
        
        return volumes, non
        
    def upload_to_aadt(self, volumes):
        if self.identifier_name == 'centreline_id':
            groups = self.get_sql_results('SELECT centreline_id, dir_bin, group_number FROM prj_volume.centreline_groups', columns = ['centreline_id','dir_bin','group_number'])
            volumes = pd.DataFrame(volumes, columns = ['centreline_id','dir_bin','year','volume'])  
            volumes = pd.merge(volumes, groups, how='inner', on=['centreline_id','dir_bin'])
            
        volumes = volumes.values.tolist()
        self.truncatetable('prj_volume.aadt')
        self.inserttable('prj_volume.aadt', volumes)
        self.logger.info('Uploaded results to prj_volume.aadt')