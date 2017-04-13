# -*- coding: utf-8 -*-
"""
Created on Mon Apr 10 14:30:58 2017

@author: qwang2
"""
from sklearn.cluster import KMeans
from sklearn import metrics
from scipy.spatial.distance import cdist, pdist
from sklearn.decomposition import PCA
from sklearn.cluster import KMeans

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

def get_tcl_rc_mapping(db):
    
    '''
    This function takes a database connection and returns a dataframe that contains the mapping of centreline_id to its road class.
    tcl contains the following columns:
        - centreline_id (index column)
        - feature_code
        - feature_code_desc
    '''
        
    tcl = pd.DataFrame(db.query('SELECT DISTINCT centreline_id, feature_code, feature_code_desc FROM prj_volume.centreline WHERE feature_code <= 201800').getresult(), columns=['centreline_id','feature_code','feature_code_desc'])
    tcl = tcl.set_index(tcl['centreline_id'])
    
    return tcl
    
def get_data_individual(db, br=[]):
    
    '''
    This function takes in a database connection and a list of breakpoints to retrieve COMPLETE (96 obs) individual day counts in a dataframe.
    
    Input:
        db: database connection
        br: (optional, default to empty) a list of (startdate,enddate) tuples. In case reading in everything is too big.
            Python will read data in by parts and concatenate.
    Output:
        data: dataframe with the columns: count_info_id, arterycode, count_date, centreline_id, dir_bin, 
                vol_weight(an array of 96, normalized 15min volume)
                Each row is counts for one day at one location.
    '''
    
    if br == []:
        data = pd.DataFrame(db.query('SELECT count_info_id, arterycode, count_date, centreline_id, dir_bin, array_agg(vol_weight ORDER BY timecount) FROM prj_volume.atr_volumes WHERE complete_day = True GROUP BY count_info_id,arterycode, count_date, centreline_id, dir_bin').getresult(), columns=['count_info_id','arterycode','count_date','centreline_id','dir_bin','vol_weight'])
    else:
        data = pd.DataFrame()
        for (b1,b2) in br:            
            data = data.append(pd.DataFrame(db.query('SELECT count_info_id, arterycode, count_date, centreline_id, dir_bin, array_agg(vol_weight ORDER BY timecount) FROM prj_volume.atr_volumes WHERE complete_day = True AND count_date >= \'' + b1 + '\' AND count_date <= \'' + b2 + '\' GROUP BY count_info_id,arterycode, count_date, centreline_id, dir_bin').getresult(), columns=['count_info_id','arterycode','count_date','centreline_id','dir_bin','vol_weight']))
        
    data = data.set_index(data['count_info_id'])
    
    return data
    
def get_data_aggregated(db):
    
    '''
    This function takes in a database connection and returns a dataframe with the normalized average counts at a count location.
    '''
    
    data = pd.DataFrame(db.query('SELECT * FROM prj_volume.vol_profile_tcl_summary ORDER BY centreline_id, dir_bin, timecount').getresult(), columns=['centreline_id','dir_bin','timecount','vol','vol_weight'])
    
    return data
    
def get_incompleteday_data(db):
    
    '''
    This function takes in a database connection and returns NOT full-day ATR counts.
    Output Dataframe:
        count_info_id, timecount, volume, centreline_id, dir_bin, time_15
        Each row is one 15min observation.
    '''
    
    data = pd.DataFrame(db.query('SELECT count_info_id, timecount, vol, centreline_id, dir_bin FROM prj_volume.atr_volumes WHERE complete_day = False').getresult(),columns=['count_info_id','timecount','volume','centreline_id','dir_bin'])
    data['volume'] = data['volume'].astype(int)
    data['time_15'] = data.timecount.apply(lambda x: x.hour*4+x.minute//15)
    data = data.sort_values(by=['count_info_id','time_15'])

    return data

def remove_clustered_cl(incomdata, tcldircl):
    
    '''
    This function takes in a dataframe of incomplete day atr counts retrieved from get_incompleteday_data and a (centreline_id, dir_bin):cluster# look up dataframe and returns a dataframe with already clustered location removed to be passed to fcn fit_incomplete.
    
    Input:
        incomdata: dataframe with columns centreline_id, dir_bin (at least)
        tcldircl: nested list returned by fcn plot_mode_cl_consolidate each sublist has 4 values: cluster#, centreline_id, dir_bin, identifier      
    Output:
        data: incomdata with overlapping entries with tcldircl removed
    '''
    
    data = incomdata.copy()
    tcldircl = pd.DataFrame(tcldircl, columns = ['cluster','centreline_id','dir_bin','identifier'])
    data = data.merge(tcldircl, on=['centreline_id','dir_bin'], how = 'left')
    data.fillna(100,inplace=True)
    data = data[data['cluster']==100]
    
    return data
    
def KMeans_cluster(nClusters, x, metric=False, avgWithinSS=[], ch=[], sc=[], ve=[]):
    
    '''
    This function takes a list of features and return a trained kmeans classifier with the option of returning evaluation metrics.
    
    Input:
        nClusters: # of clusters
        x: nested list of features to cluster
        metric: bool. whether to calculate evaluation metrics.
        avgWithinSS: metric. average distance within cluster
        ch: Calinski Harabaz score
        sc: Silhouette Coefficient (-1~1) 
        ve: Variance Explained    
    Output:
        kmeans: trained classifier object
    '''
    
    kmeans = KMeans(n_clusters = nClusters).fit(x)
    if metric:
        labels = kmeans.labels_
        centroids = kmeans.cluster_centers_
        D = cdist(x, centroids, 'euclidean')
        dist = np.min(D,axis=1)
        avgWithinSS.append(sum(dist)/np.array(x).shape[0])
        ch.append(metrics.calinski_harabaz_score(np.array(x), np.array(labels)))
        sc.append(metrics.silhouette_score(np.array(x), np.array(labels), metric='euclidean'))
        ve.append(100*(sum(pdist(x)**2)/np.array(x).shape[0]-sum(dist**2))/(sum(pdist(x)**2)/np.array(x).shape[0]))
    return kmeans

def plot_mode_cl_consolidate(cluster, dkey=('centreline_id, dir_bin')):
    
    '''
    This function takes a dataframe with clustering information and returns a nested list with the assignment of ONE cluster number for each specified key (default centreline_id, dir_bin)
    
    Input:
        cluster: dataframe with the columns specified in dkey and cluster#
        dkey: key of unique cluster #
    Output:
        tcldircl: nested list that contains [cluster#, dkey, identifier(id*direction)]
        to screen: scatter plot: % share of dominant cluster vs. # days of observations
                    histogram: distribution of % share of dominant cluster
    '''
    
    a = []
    tcldircl = []
    for (datakey), group in cluster.groupby(dkey):
        row = []
        if len(group['cluster'].unique())==1:
            row.append(group['cluster'].unique()[0])
        else:
            plt.scatter(len(group['cluster']), group['cluster'].value_counts().max()/len(group['cluster']))        
            plt.xlabel('# days')
            plt.ylabel('% share of dominant cluster')   
            row.append(group['cluster'].value_counts().idxmax())
            a.append(group['cluster'].value_counts().max()/len(group['cluster']))
            
        for i in range(len(datakey)):
            row.append(datakey[i])
        row.append(int(datakey[0])*int(datakey[1]))
        tcldircl.append(row)
    if a:
        plt.figure()
        n, bins, patches = plt.hist(a, 20)
    
    return tcldircl

def plot_profile(cluster, profile):
    
    '''
    This function takes clustering information and the cluster centers and plots to screen the profiles annotated by the percentage  of each cluster in the data.
    
    Input:
        cluster: nested list returned by plot_mode_cl_consolidate
        profile: cluster centers
    Output:
        charts to screen
    '''
    
    nClusters = len(profile)
    fig, ax = plt.subplots(nClusters, 1, figsize=[7,nClusters*5])
    df = pd.DataFrame(cluster,columns=['cluster','group_number','dir_bin','identifier'])['cluster'].value_counts()
    for (i,prof) in zip(range(nClusters), profile):
        ax[i].plot(prof)
        (x1,x2) = ax[i].get_xlim()
        (y1,y2) = ax[i].get_ylim()
        ax[i].annotate("{:.0f}".format(df[i]/len(cluster)*100)+'%', xy=((x2-x1)*0.04+x1, y2*0.90), fontsize = 14)

def plot_metrics_find_k(data, m):

    '''
    This function takes a nested list of features and a upper limit of # clusters and plots 4 evaluation metrics for each cluster # choice between 2 and m. Used for finding the best k systematically.
    
    Input:
        data: nested list of features
        m: upper limit of number of clusters
    Output:
        4 graphs to screen
    '''
    
    avgWithinSS = []
    ch = []
    sc = []
    ve = []
    # KMeans Clustering
    for i in range(m):
        print('Running ', i+2, ' clusters')    
        clusters = KMeans_cluster(i+2, data, avgWithinSS, ch, sc, ve)
    
    plt.figure()
    plt.title('Sum of Squares within Clusters')
    plt.plot([x+2 for x in range(m)], avgWithinSS)
    plt.figure()
    plt.title('Calinski Harabaz Score')
    plt.plot([x+2 for x in range(m)], ch)
    plt.figure()
    plt.title('Silhouette Coefficient')
    plt.plot([x+2 for x in range(m)], sc)
    plt.figure()
    plt.title('Percentage Variance Explained')
    plt.plot([x+2 for x in range(m)], ve)
    plt.show()
    
def fit_incomplete(centres, new):
    cls = []
    for (count_info_id, tcl, dirc), newdata in new.groupby(['count_info_id','centreline_id','dir_bin']):
        mindist = 100
        cl = -1
        i = 0
        svol = sum(newdata['volume'])
        for centre in centres:
            newdatacp = newdata.copy()
            dist = 0
            s = 0
            for time in newdatacp['time_15']:
                s = s + centre[time]
            newdatacp['volume'] = newdatacp['volume']/svol*s
            for (time, volume) in zip(newdatacp['time_15'],newdatacp['volume']):
                dist = dist + (volume-centre[time])*(volume-centre[time])
    
            if dist<mindist:
                mindist = dist
                cl = i
            i = i + 1
        cls.append([tcl,dirc,cl])
        
    return pd.DataFrame(cls,columns=['centreline_id','dir_bin','cluster'])
    
def fill_missing_values(profiles, new, clusterinfo):
    
    filled = {}
    for (count_info_id, tcl, dirc), newdata in new.groupby(['count_info_id','centreline_id','dir_bin']):
        profile = profiles[int(clusterinfo[clusterinfo['identifier']==(tcl*dirc)].loc[:,'cluster'])]  
        sum_vol = sum(newdata['volume'])
        sum_weights = sum(profile[newdata['time_15']])
        
        total_vol = sum_vol/sum_weights
        j = 0
        incomplete_profile = list(newdata['volume'])
        incomplete_time15 = list(newdata['time_15'])
        complete_profile = []
        for i in range(96):
            if j == len(newdata):
                complete_profile.append(total_vol*profile[i])
                continue
            if i == incomplete_time15[j]:
                if total_vol*profile[i]>50 and incomplete_profile[j]==0:
                    complete_profile.append(total_vol*profile[i])
                else:
                    complete_profile.append(incomplete_profile[j])
                j = j + 1
            else:
                complete_profile.append(total_vol*profile[i])
        if count_info_id in (806,858,1126495,1119867,561468,1429401):     
            plt.figure()
            plt.plot(profile*total_vol)
            plt.plot(complete_profile,'g*')
            plt.plot(incomplete_time15, incomplete_profile,'r+')
        filled[count_info_id] = complete_profile
    return filled
    