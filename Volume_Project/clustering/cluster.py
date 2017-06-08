# -*- coding: utf-8 -*-
"""
Created on Fri Apr  7 10:09:30 2017

@author: qwang2
"""

import pandas as pd
import cl_fcn
import pickle


class cluster(object):
    
    def __init__(self, db, data, nClusters = 6):
        self.nClusters = nClusters
        
        kmeans = cl_fcn.KMeans_cluster(nClusters, list(data['vol_weight']), metric=False)
        self.profile = kmeans.cluster_centers_
        data['cluster'] = kmeans.predict(list(data['vol_weight']))
        self.tcl_group = pd.DataFrame(db.query('SELECT * FROM prj_volume.centreline_groups').getresult(), columns = ['centreline_id','dir_bin','group_number'])
        # Assign one profile to each centerline_id, dir_bin
        tcldircl_com = cl_fcn.plot_mode_cl_consolidate(data, ('centreline_id','dir_bin'))
        # Assign one profile to each centreline group
        data = data.merge(self.tcl_group, on=['centreline_id','dir_bin'])
        clgrdircl_com = cl_fcn.plot_mode_cl_consolidate(data,('group_number','dir_bin'))
        
        self.tcldircl = tcldircl_com
        self.clgrdircl = clgrdircl_com
        self.percentile = cl_fcn.get_percentiles(data,[25,75])
        
    def plot_cluster_centres(self):
        cl_fcn.plot_profile(self.clgrdircl, self.profile, self.percentile)
        cl_fcn.plot_profile(self.tcldircl, self.profile, self.percentile)

    def fit_incomplete_data(self, datatmc, useResults=False):
        classify_tmcdata = cl_fcn.remove_clustered_cl(datatmc, self.tcldircl)
        [classified_tmcdata,distmtx] = cl_fcn.fit_incomplete(self.profile, classify_tmcdata)
        
        if useResults:
            classified_tmcdata = classified_tmcdata.merge(self.tcl_group, on=['centreline_id','dir_bin'])
            if len(classified_tmcdata) > 0:
                tcldircl_incom = cl_fcn.plot_mode_cl_consolidate(classified_tmcdata, ('centreline_id','dir_bin'))
                clgrdircl_incom = cl_fcn.plot_mode_cl_consolidate(classified_tmcdata, ('group_number','dir_bin'))
                self.tcldircl = self.tcldircl + tcldircl_incom
                self.clgrdircl = self.clgrdircl + clgrdircl_incom
                
        return classified_tmcdata, distmtx
        
    def interpolate_data(self, incomdata):
        df_tcldircl = pd.DataFrame(self.tcldircl, columns = ['cluster','centreline_id','dir_bin','identifier'])
        filled = cl_fcn.fill_missing_values(self.profile, incomdata, df_tcldircl)
        
        return filled
        
    def refresh_db_export(self, db):
        db.truncate('prj_volume.clusters')
        db.inserttable('prj_volume.clusters', self.tcldircl)
        db.truncate('prj_volume.clusters_group')
        db.inserttable('prj_volume.clusters_group', self.clgrdircl)
        pickle.dump(cluster,open("cluster.p","wb"))

    def explore_nClusters(self, data, upper_bound=20):
        cl_fcn.plot_metrics_find_k(list(data['vol_weight']), upper_bound)
        