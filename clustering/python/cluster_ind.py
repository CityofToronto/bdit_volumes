# -*- coding: utf-8 -*-
"""
Created on Fri Apr  7 10:09:30 2017

@author: qwang2
"""
from pg import DB
import configparser
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
import cl_fcn
import pickle


# CONNECTION SET UP
CONFIG = configparser.ConfigParser()
CONFIG.read('db.cfg')
dbset = CONFIG['DBSETTINGS']

db = DB(dbname=dbset['database'],host=dbset['host'],user=dbset['user'],passwd=dbset['password'])

br = [('20100101','20170101')]
data = cl_fcn.get_data_individual(db, br)

#tcl = cl_fcn.get_tcl_rc_mapping(db)

nClusters = 6
cm_subsection = np.linspace(0,1,nClusters)
colorsrc = [cm.jet(x) for x in cm_subsection]

#cl_fcn.plot_metrics_find_k(list(data['vol_weight']), 20)

kmeans = cl_fcn.KMeans_cluster(nClusters, list(data['vol_weight']), metric=False)
profile = kmeans.cluster_centers_
data['cluster'] = kmeans.predict(list(data['vol_weight']))

# Assign one profile to each centerline_id, dir_bin
tcldircl_com = cl_fcn.plot_mode_cl_consolidate(data, ('centreline_id','dir_bin'))

# Assign one profile to each centreline group
tcl_group = pd.DataFrame(db.query('SELECT * FROM prj_volume.centreline_groups').getresult(), columns = ['centreline_id','group_number'])
data = data.merge(tcl_group, on='centreline_id')
clgrdircl_com = cl_fcn.plot_mode_cl_consolidate(data,('group_number','dir_bin'))

# Plot TOD profile for each cluster center
percentile = cl_fcn.get_percentiles(data,[25,75])
cl_fcn.plot_profile(clgrdircl_com, profile, percentile)
cl_fcn.plot_profile(tcldircl_com, profile, percentile)
'''
datatmc = cl_fcn.get_data_tmc(db, ('2010-01-01','2011-01-01'))
classify_tmcdata = cl_fcn.remove_clustered_cl(datatmc, tcldircl_com)

[classified_tmcdata,distmtx] = cl_fcn.fit_incomplete(profile, classify_tmcdata)

# Get incomplete day count data
incomdata = cl_fcn.get_incompleteday_data(db)

# Remove centrelines that are already clustered
classify_incomdata = cl_fcn.remove_clustered_cl(incomdata, tcldircl_com)

# Classify Incomplete Data and Deal with duplicates
clusters_incom = cl_fcn.fit_incomplete(profile, classify_incomdata)

clusters_incom = clusters_incom.merge(tcl_group, on='centreline_id')
tcldircl_incom = cl_fcn.plot_mode_cl_consolidate(clusters_incom, ('centreline_id','dir_bin'))
clgrdircl_incom = cl_fcn.plot_mode_cl_consolidate(clusters_incom, ('group_number','dir_bin'))

tcldircl = tcldircl_com + tcldircl_incom
clgrdircl = clgrdircl_com + clgrdircl_incom
df_tcldircl = pd.DataFrame(tcldircl, columns = ['cluster','centreline_id','dir_bin','identifier'])

# Interpolate Incomplete Data
filled = cl_fcn.fill_missing_values(profile, incomdata, df_tcldircl)

# Insert into Database
db.truncate('prj_volume.clusters')
db.inserttable('prj_volume.clusters', tcldircl)
db.truncate('prj_volume.clusters_group')
db.inserttable('prj_volume.clusters_group', clgrdircl)
db.close()


for l in distmtx:
    plt.imshow([l,l],cmap='hot')
    break
plt.show()
'''
pickle.dump(profile,open("ClusterCentres.p","wb"))
pickle.dump(tcldircl,open("ClusterResults.p","wb"))