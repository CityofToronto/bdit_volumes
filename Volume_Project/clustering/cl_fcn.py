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
from matplotlib import cm

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


def fill_missing_values(profiles, new, clusterinfo, identifier_name, plot=None):
    
    ''' This function takes in a list of volume profiles and a dataframe of new, incomplete days of data as well as their clustering information and fill the missing time bins.
    
    Input:
        profiles: a list of cluster profile centres
        new: dataframe of new,incomplete days of data with columns: count_date, centreline_id, dir_bin
        clusterinfo: dataframe returned by function fit_incomplete with columns: centreline_id, dir_bin, cluster
    Output:
        a dictionary with complete day profile filled in. key: (centreline_id, dir_bin, count_date); value: list of volumes of each 15min bin.
    '''
    
    if new.empty:
        return None
    filled = {}
    for (count_date, tcl, dirc), newdata in new.groupby(['count_date',identifier_name,'dir_bin']):
        if len(newdata) == 96:
            filled[(count_date, tcl, dirc)] = newdata['volume']
            continue
        profile = profiles[int(clusterinfo[(clusterinfo[identifier_name]==tcl) & (clusterinfo['dir_bin'] == dirc)].loc[:,'cluster'])]  

        sum_vol = float(sum(newdata['volume']))
        sum_weights = float(sum([profile[i] for i in newdata['time_15']]))
        newdata = newdata.sort_values(by=['time_15'])
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
        if plot is not None:
            if [tcl,dirc,count_date] in plot:     
                plt.figure()
                plt.plot(profile*total_vol)
                plt.plot(complete_profile,'g*')
                plt.plot(incomplete_time15, incomplete_profile,'r+')
        filled[(count_date, tcl, dirc)] = complete_profile
        
    return filled
    
def fit_incomplete(centres, new, identifier_name, plot=None):
    
    '''
    This function takes a list of volume profile cluster centres and incomplete days of data and fits the data to one of the profiles.
    
    Input:
        centres: a list of cluster profile centers
        new: dataframe of new, incomplete days of data. with columns: count_date, centreline_id, dir_bin, volume, time_15
    Output:
        a dataframe with columns: centreline_id, dir_bin, cluster
    '''
    
    if new.empty:
        return None, None
    cls = []
    distmtx = []
    for (count_date, tcl, dirc), newdata in new.groupby(['count_date',identifier_name,'dir_bin']):
        mindist = 100
        total_vol = 100
        cl = -1
        i = 0
        svol = sum(newdata['volume'])
        row = []
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
                total_vol = svol/s
                
            row.append(dist/len(newdatacp))
            i = i + 1
        row.append(len(newdatacp))
        distmtx.append(row)
        cls.append([count_date,tcl,dirc,cl])
        if plot is not None:
            if [tcl,dirc,count_date] in plot:     
                plt.figure()
                plt.plot(centres[cl]*total_vol, label = 'fitted profile')
                plt.plot(newdata['time_15'], newdata['volume'],'r*',label = 'data')
                print(str(tcl) + ' ' + str(dirc) + ' ' + str(count_date))
                (x1,x2) = plt.xlim()
                (y1,y2) = plt.ylim()
                plt.annotate('order = ' + str(np.floor(np.log10(mindist/len(newdatacp)))), xy=((x2-x1)*0.04+x1, y2*0.80), fontsize = 14)
                plt.annotate('dist = ' + str(mindist/len(newdatacp)), xy=((x2-x1)*0.04+x1, y2*0.90), fontsize = 14)
                plt.xlabel('index of 15min bins')
                plt.ylabel('Volume (veh)')
                plt.legend(bbox_to_anchor=(1.45, 1.05))
                plt.show()
    return pd.DataFrame(cls,columns=['count_date',identifier_name,'dir_bin','cluster']), distmtx  
    
def get_percentiles(data, percentiles):
    p = {}
    for (clusternum), group in data.groupby(['cluster']):
        p[clusternum] = {}
        for percent in percentiles:
            p[clusternum][percent] = []
            for i in range(96):
                p[clusternum][percent].append(np.percentile([x[i] for x in group['vol_weight']],percent))
    return p

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
        kmeans = KMeans_cluster(i+2, data, avgWithinSS, ch, sc, ve)
    
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
    
def plot_mode_cl_consolidate(clusterinfo, dkey=('centreline_id, dir_bin')):
    
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
    for (datakey), group in clusterinfo.groupby(dkey):
        row = []
        if len(group['cluster'].unique())==1:
            row.append(group['cluster'].unique()[0])
        else:
            '''
            plt.figure()
            plt.scatter(len(group['cluster']), group['cluster'].value_counts().max()/len(group['cluster']))        
            plt.xlabel('# days')
            plt.ylabel('% share of dominant cluster') 
            '''
            row.append(group['cluster'].value_counts().idxmax())
            a.append(group['cluster'].value_counts().max()/len(group['cluster']))
            
        for i in range(len(datakey)):
            row.append(datakey[i])
        row.append(int(datakey[0])*int(datakey[1]))
        tcldircl.append(row)
    '''
    if a:
        plt.figure()
        n, bins, patches = plt.hist(a, 20)
    '''
    return tcldircl

def plot_profile(clusterinfo, profile, percentile = {}):
    
    '''
    This function takes clustering information and the cluster centers and plots to screen the profiles annotated by the percentage  of each cluster in the data.
    
    Input:
        clusterinfo: nested list returned by plot_mode_cl_consolidate
        profile: cluster centers
    Output:
        charts to screen
    '''
    
    colors = [(100/255,0,100/255),(255/255,0,0),(155/255,155/255,155/255),(0,255/255,0),(255/255,135/255,0),(0,0,255/255)]
    nClusters = len(profile)
    df = pd.DataFrame(clusterinfo,columns=['cluster','group_number','dir_bin','identifier'])['cluster'].value_counts()
    for (i,prof) in zip(range(nClusters), profile):
        fig, ax = plt.subplots(figsize=[3.5,2.5])
        ax.plot([x/4 for x in range(96)],prof,color=colors[i])
        
        if percentile:
            lowp = list(percentile[i].keys())[0]
            highp = list(percentile[i].keys())[1]
            ax.fill_between([x/4 for x in range(96)], percentile[i][lowp], percentile[i][highp], alpha=0.10,color=colors[i])
            
        (x1,x2) = ax.get_xlim()
        (y1,y2) = ax.get_ylim()
        ax.annotate("{:.0f}".format(df[i]/len(clusterinfo)*100)+'%', xy=((x2-x1)*0.04+x1, y2*0.90), fontsize = 14)
    
        ax.set_xlabel('Hour')
        ax.set_ylabel('% of Daily Volume')

def remove_clustered_cl(incomdata, tcldircl, identifier_name):
    
    '''
    This function takes in a dataframe of incomplete day atr counts retrieved from get_incompleteday_data and a (centreline_id, dir_bin):cluster# look up dataframe and returns a dataframe with already clustered location removed to be passed to fcn fit_incomplete.
    
    Input:
        incomdata: dataframe with columns centreline_id, dir_bin (at least)
        tcldircl: nested list returned by fcn plot_mode_cl_consolidate each sublist has 4 values: cluster#, centreline_id, dir_bin, identifier      
    Output:
        data: incomdata with overlapping entries with tcldircl removed
    '''
    
    data = incomdata.copy()
    tcldircl = pd.DataFrame(tcldircl, columns = ['cluster',identifier_name,'dir_bin','identifier'])
    data = data.merge(tcldircl, on=[identifier_name,'dir_bin'], how = 'left')
    data.fillna(100,inplace=True)
    data = data[data['cluster']==100]
    del data['cluster']
    del data['identifier']
    
    return data
    
'''
def backup_roadclass():
    
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