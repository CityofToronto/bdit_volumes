# -*- coding: utf-8 -*-
"""
Created on Fri Apr  7 10:09:30 2017

@author: qwang2
"""

import pandas as pd
import cl_fcn
from utilities import vol_utils
import logging

class cluster(vol_utils):
    
    def __init__(self, nClusters = 6):
        self.logger = logging.getLogger('volume_project.clustering')
        super().__init__()
        
        self.nClusters = nClusters
        data = self.get_data_individual(br = [('20100101','20170101')])
        kmeans = cl_fcn.KMeans_cluster(nClusters, list(data['vol_weight']), metric=False)
        self.profile = kmeans.cluster_centers_
        data['cluster'] = kmeans.predict(list(data['vol_weight']))
        self.tcl_group = self.get_sql_results('SELECT * FROM prj_volume.centreline_groups', columns = ['centreline_id','dir_bin','group_number'])
        # Assign one profile to each centerline_id, dir_bin
        tcldircl_com = cl_fcn.plot_mode_cl_consolidate(data, ('centreline_id','dir_bin'))
        # Assign one profile to each centreline group
        data = data.merge(self.tcl_group, on=['centreline_id','dir_bin'])
        clgrdircl_com = cl_fcn.plot_mode_cl_consolidate(data,('group_number','dir_bin'))
        
        self.tcldircl = tcldircl_com
        self.clgrdircl = clgrdircl_com
        self.percentile = cl_fcn.get_percentiles(data,[25,75])
        
        self.logger.info('Clustering initialization done.')
        
    def explore_nClusters(self, data, upper_bound=20):
        cl_fcn.plot_metrics_find_k(list(data['vol_weight']), upper_bound) 

    def fit_incomplete_data(self, datatmc, useResults=False):
        if datatmc.empty:
            self.logger.debug('No data passing in, reading TMC data from 2010 to 2017')
            datatmc = self.get_data_tmc(('20100101','20170101'))
        self.logger.debug('Classifying incomplete data')
        classify_tmcdata = cl_fcn.remove_clustered_cl(datatmc, self.tcldircl)
        [classified_tmcdata,distmtx] = cl_fcn.fit_incomplete(self.profile, classify_tmcdata)
        
        if useResults:
            self.logger.debug('Adding incomplete data fit to clustering results.')
            classified_tmcdata = classified_tmcdata.merge(self.tcl_group, on=['centreline_id','dir_bin'])
            if len(classified_tmcdata) > 0:
                tcldircl_incom = cl_fcn.plot_mode_cl_consolidate(classified_tmcdata, ('centreline_id','dir_bin'))
                clgrdircl_incom = cl_fcn.plot_mode_cl_consolidate(classified_tmcdata, ('group_number','dir_bin'))
                self.tcldircl = self.tcldircl + tcldircl_incom
                self.clgrdircl = self.clgrdircl + clgrdircl_incom
                
        return classified_tmcdata, distmtx
        
    def get_data_individual(self, br=[]):
    
        '''
        This function takes in a database connection and a list of breakpoints to retrieve COMPLETE (96 obs) individual day counts in a dataframe.
        
        Input:
            db: database connection
            br: (optional, default to empty) a list of (startdate,enddate) tuples. In case reading in everything is too big.
                Python will read data in by parts and concatenate.
        Output:
            data: dataframe with the columns: count_date, centreline_id, dir_bin, vol_weight(an array of 96, normalized 15min volume)
                    Each row is counts for one day at one location.
        '''
        
        if br == []:
            data = self.get_sql_results('SELECT count_date, centreline_id, dir_bin, array_agg(vol_weight ORDER BY timecount) FROM prj_volume.cluster_atr_volumes WHERE complete_day = True GROUP BY count_date, centreline_id, dir_bin', columns=['count_date','centreline_id','dir_bin','vol_weight'])
        else:
            data = pd.DataFrame()
            for (b1,b2) in br:            
                data = data.append(self.get_sql_results('SELECT count_date, centreline_id, dir_bin, array_agg(vol_weight ORDER BY timecount) FROM prj_volume.cluster_atr_volumes WHERE complete_day = True AND count_date >= \'' + b1 + '\' AND count_date <= \'' + b2 + '\' GROUP BY count_date, centreline_id, dir_bin', columns=['count_date','centreline_id','dir_bin','vol_weight']))
        
        return data
        
    def get_data_tmc(self, timeline):
        
        ''' 
        This function takes in a database connection and returns a dataframe with turning movement count data in the specified time frame.
        
        Input:
            timeline: a tuple of start and end dates of the interested period. Ex: ('20090101', '20170101')
        Output:
            data: dataframe with the following columns: timecount, volume, centreline_id, dir_bin, time_15
        '''
        
        data = self.get_sql_results('SELECT count_bin::date as count_date, count_bin::time as timecount, centreline_id, dir_bin, volume FROM prj_volume.centreline_volumes WHERE count_type = 2 AND count_bin >= \'' + timeline[0] + '\' AND count_bin <= \'' + timeline[1] + '\'',columns = ['count_date','timecount','centreline_id','dir_bin','volume'])
        data['volume'] = data['volume'].astype(int)
        data['time_15'] = data.timecount.apply(lambda x: x.hour*4+x.minute//15)
        
        return data
        
    def get_incompleteday_data(self):
        
        '''
        This function takes in a database connection and returns NOT full-day ATR counts.
        Output Dataframe:
            count_date, timecount, volume, centreline_id, dir_bin, time_15
            Each row is one 15min observation.
        '''
        
        data = self.get_sql_results('SELECT count_date, timecount, vol, centreline_id, dir_bin FROM prj_volume.cluster_atr_volumes WHERE complete_day = False',columns=['count_date','timecount','volume','centreline_id','dir_bin'])
        data['volume'] = data['volume'].astype(int)
        data['time_15'] = data.timecount.apply(lambda x: x.hour*4+x.minute//15)
        data = data.sort_values(by=['centreline_id','count_date','dir_bin','time_15'])
    
        return data
        
    def interpolate_data(self, incomdata):
        if incomdata.empty:
            self.logger.debug('No data passed in. Reading in incomplete ATR data from DB')
            incomdata = self.get_incompleteday_data()
            
        df_tcldircl = pd.DataFrame(self.tcldircl, columns = ['cluster','centreline_id','dir_bin','identifier'])
        filled = cl_fcn.fill_missing_values(self.profile, incomdata, df_tcldircl)
        
        return filled    
        
    def plot_cluster_centres(self):
        cl_fcn.plot_profile(self.clgrdircl, self.profile, self.percentile)
        cl_fcn.plot_profile(self.tcldircl, self.profile, self.percentile)

    def refresh_db_export(self):
        self.db.truncate('prj_volume.clusters')
        self.db.inserttable('prj_volume.clusters', self.tcldircl)
        self.db.truncate('prj_volume.clusters_group')
        self.db.inserttable('prj_volume.clusters_group', self.clgrdircl)
        self.db.truncate('prj_volume.cluster_profiles')
        self.db.inserttable('prj_volume.cluster_profiles', [[c,t+1,y] for x,c in zip(self.profile,range(self.nClusters)) for y,t in zip(x,range(96))])
        self.logger.info('Exported clustering results to DB')

    
        