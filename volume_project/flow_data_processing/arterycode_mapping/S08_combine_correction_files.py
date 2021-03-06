# -*- coding: utf-8 -*-
"""
Created on Tue Jan 17 14:44:09 2017

@author: qwang2
"""

import pandas as pd
import numpy as np
import re


def combine_and_upload(db, directory):
    
    # File 1: TMC artery codes with short segments (<25m)
    e = pd.read_csv(directory+'tmc_short.csv')
    d = []
    for a,b,c in zip(e['arterycode'], e['centreline_id'], e['sideofint']):
        if not np.isnan(a):
            m = db.query('select match_on_case,artery_type from prj_volume.artery_tcl where arterycode = '+str(int(a))).getresult()[0]
            if m[0] == 10:
                case = db.query('select was_match_on_case from prj_volume.artery_tcl_manual_corr where arterycode = '+str(int(a))).getresult()[0][0]
            else:
                case = m[0]
            if c == 'N' or c == 'S':
                d.append([int(a),'Northbound',c,int(b),m[1],10,case])
                d.append([int(a),'Southbound',c,int(b),m[1],10,case])
            else:
                d.append([int(a),'Eastbound',c,int(b),m[1],10,case])
                d.append([int(a),'Westbound',c,int(b),m[1],10,case])
    df1 = pd.DataFrame(d, columns = ['arterycode','direction','sideofint','centreline_id','artery_type','match_on_case','was_match_on_case'])
    df1.to_csv(directory+'ready_tmc_short.csv', index = False)
    
    # File 2: TMC artery codes - manual corrections
    f = []
    e = pd.read_csv(directory+'tmc_corrections.csv')
    for a,b,c,d in zip(e['arterycode'], e['direction'], e['sideofint'],e['centreline_id']):
        m = db.query('select match_on_case,artery_type from prj_volume.artery_tcl where arterycode = '+str(int(a))).getresult()[0]
        if m[0] == 10:
            f.append([int(a),b,c,int(d),m[1],m[0],db.query('select was_match_on_case from prj_volume.artery_tcl_manual_corr where arterycode = '+str(int(a))).getresult()[0][0]])
        else:
            f.append([int(a),b,c,int(d),m[1],10,m[0]])
    # only one tmc to delete so far
    f.append([28112,'Eastbound','W',0,2,11,6])
    f.append([28112,'Westbound','W',0,2,11,6])
    f.append([28112,'Northbound','N',0,2,11,6])
    f.append([28112,'Southbound','N',0,2,11,6])
    f.append([28112,'Eastbound','E',0,2,11,6])
    f.append([28112,'Westbound','E',0,2,11,6])
    
    df2 = pd.DataFrame(f, columns = ['arterycode','direction','sideofint','centreline_id','artery_type','match_on_case','was_match_on_case'])
    df2.to_csv(directory+'ready_tmc_corrections.csv', index = False)
    
    # File 3: ATR artery codes - manual corrections
    e = pd.read_csv(directory+'ready_atr_corrections.csv')
    f = []
    for a,b,c,d,g,h in zip(e['arterycode'], e['direction'], e['sideofint'],e['centreline_id'],e['match_on_case'],e['was_match_on_case']):
        if np.isnan(h):
            case = db.query('select match_on_case from prj_volume.artery_tcl where arterycode = '+str(int(a))).getresult()[0][0]
            if case == 10:
                case = db.query('select was_match_on_case from prj_volume.artery_tcl_manual_corr where arterycode = '+str(int(a))).getresult()[0][0]     
        else:
            case = h
        if np.isnan(d):
            m = db.query('select apprdir, sideofint from traffic.arterydata where arterycode= ' + str(int(a))).getresult()[0]
            f.append([int(a),m[0],m[1],0,1,g,case])
        else:
            f.append([int(a),b,c,int(d),1,g,case])
    df3 = pd.DataFrame(f, columns = ['arterycode','direction','sideofint','centreline_id','artery_type','match_on_case','was_match_on_case'])
    
    # File 4: randomly spotted errors
    e = pd.read_csv(directory+'fixes_additional.csv')
    f = []
    num = re.compile('\d+')
    for a,b in zip(e['arterycode'],e['comment']):
        if a not in list(df3['arterycode']):
            m = db.query('select match_on_case, direction, sideofint,artery_type from prj_volume.artery_tcl JOIN prj_volume.arteries USING (arterycode) where arterycode = '+str(int(a))).getresult()[0]
            if m[0] == 10:
                case = db.query('select was_match_on_case from prj_volume.artery_tcl_manual_corr where arterycode = '+str(int(a))).getresult()[0][0]     
            else:
                case = m[0]
            if b.find('remove')<0:
                d = num.search(b)
                try:
                    c = int(b[d.start():d.end()])
                except:
                    print('ERROR')
                f.append([int(a),m[1],m[2],c,m[3],10,case])
            else:
                c = 0
                f.append([int(a),m[1],m[2],c,m[3],11,case])
        
    df4 = pd.DataFrame(f, columns = ['arterycode','direction','sideofint','centreline_id','artery_type','match_on_case','was_match_on_case'])
    
    # File 5: failed arterycodes
    e = pd.read_csv(directory+'failed_matches_case09.csv')
    f = []
    for a,b,c,d,g,h in zip(e['arterycode'], e['direction'], e['sideofint'],e['centreline_id'],e['count_type'],e['comment']):
        if np.isnan(d):
            if g == '24 HOUR':
                f.append([int(a),b,c,0,1,11,9])
            else:
                f.append([int(a),b,c,0,2,11,9])
        else:
            if h == 'TMC' or g == 'R':
                f.append([int(a),b,c,int(d),2,10,9])
            else:
                f.append([int(a),b,c,int(d),1,10,9])
    df5 = pd.DataFrame(f, columns = ['arterycode','direction','sideofint','centreline_id','artery_type','match_on_case','was_match_on_case'])
    
    df = pd.concat([df1,df2,df3,df4,df5])
    df.drop_duplicates(subset = ['arterycode', 'direction', 'sideofint'], keep = 'first', inplace = True)
    df.to_csv(directory+'all_corrections.csv',index = False)
    df['was_match_on_case'] = df['was_match_on_case'].astype(int)
    
    return df.values.tolist()

    
    
