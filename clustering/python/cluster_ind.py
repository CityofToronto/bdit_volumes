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
tcldircl = cl_fcn.plot_mode_cl_consolidate(data, ('centreline_id','dir_bin'))

# Assign one profile to each centreline group
tcl_group = pd.DataFrame(db.query('SELECT * FROM prj_volume.centreline_groups').getresult(), columns = ['centreline_id','group_number'])
data = data.merge(tcl_group, on='centreline_id')
clgrdircl = cl_fcn.plot_mode_cl_consolidate(data,('group_number','dir_bin'))

# Plot TOD profile for each cluster center
cl_fcn.plot_profile(clgrdircl, profile)
cl_fcn.plot_profile(tcldircl, profile)

# Get incomplete day count data
incomdata = cl_fcn.get_incompleteday_data(db)

# Remove centrelines that are already clustered
classify_incomdata = cl_fcn.remove_clustered_cl(incomdata, tcldircl)

# Classify Incomplete Data and Deal with duplicates
clusters_incom = cl_fcn.fit_incomplete(profile, classify_incomdata)

clusters_incom = clusters_incom.merge(tcl_group, on='centreline_id')
tcldircl_incom = cl_fcn.plot_mode_cl_consolidate(clusters_incom, ('centreline_id','dir_bin'))
clgrdircl_incom = cl_fcn.plot_mode_cl_consolidate(clusters_incom, ('group_number','dir_bin'))

tcldircl = tcldircl + tcldircl_incom
clgrdircl = clgrdircl + clgrdircl_incom
df_tcldircl = pd.DataFrame(tcldircl, columns = ['cluster','centreline_id','dir_bin','identifier'])

# Interpolate Incomplete Data
filled = cl_fcn.fill_missing_values(profile, incomdata, df_tcldircl)

# Insert into Database
db.truncate('prj_volume.clusters')
db.inserttable('prj_volume.clusters', tcldircl)
db.truncate('prj_volume.clusters_group')
db.inserttable('prj_volume.clusters_group', clgrdircl)
db.close()

cm_subsection = np.linspace(0,1,nRC)
colorsc = [cm.jet(x) for x in cm_subsection]

# Bar graph for road class distribution of each cluster
# Stacked bar graph for cluster distribution within each road class
fig2,ax2 = plt.subplots(figsize=[7,7])
accum = [0]*nRC

for i in np.arange(nClusters):
    ax[i][1].bar(np.arange(nRC)+0.25, [a/b*100 for a,b in zip(list(rc_summary.loc[i,:]),list(rc_total))], width=0.5)
    ax[i][1].set_xticks(np.arange(nRC)+0.5)
    ax[i][1].set_xlim([0,nRC])
    ax[i][1].set_xticklabels(list(rc_summary.columns),rotation=20)
    (x1,x2) = ax[i][0].get_xlim()
    (y1,y2) = ax[i][0].get_ylim()
    ax[i][0].annotate("{:.0f}".format(cl_total[i]/len(datadict)*100)+"%", xy=((x2-x1)*0.04+x1, y2*0.90), fontsize = 14)
    
    ax2.bar(np.arange(nRC)+0.25, list(rc_summary.loc[i,:]), width=0.5, bottom=accum, color=colors[i])
    ax2.set_xticklabels(list(rc_summary.columns),rotation=30)
    accum = [sum(x) for x in zip(accum, list(rc_summary.loc[i,:]))]
    
# Stacked bar graph for road class distribution within each cluster
fig3,ax3 = plt.subplots(figsize=[7,7])
accum = [0]*nClusters
for i in np.arange(nRC):
    ax3.bar(np.arange(nClusters)-0.25, list(rc_summary.iloc[:,i]), width=0.5, bottom = accum, color=colors[i], label=rc_summary.columns[i])
    accum = [sum(x) for x in zip(accum, list(rc_summary.iloc[:,i]))]
plt.legend(bbox_to_anchor=(1,1), loc=2)
'''
plt.show()
