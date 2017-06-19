# -*- coding: utf-8 -*-
"""
Created on Wed Jun  7 10:06:22 2017

@author: qwang2
"""
import sys
import os
for x in os.walk('.'):
    sys.path.append(x[0]) 

import pandas as pd
import pickle

def exec_file(filename):
    try:
        f = open(filename)
        exec(filename)
    except:
        for root_f, folders, files in os.walk('.'):
            if filename in files:
                f = root_f + '/' + filename
                break
        exec(f)
        
    if f is None:
        raise Exception ('File not found!')
    
def execute_sql(db, filename):
    f = None
    try:
        f = open(filename)
    except:
        for root_f, folders, files in os.walk('.'):
            if filename in files:
                f = open(root_f + '/' + filename)
    if f is None:
        raise Exception ('File not found!')
        
    sql = f.read()
    db.query(sql)

def get_sql_results(db, filename, columns):
    
    f = None
    try:
        f = open(filename)
    except:
        for root_f, folders, files in os.walk('.'):
            if filename in files:
                f = open(root_f + '/' + filename)
                
    if f is None:
        raise Exception ('File not found!')
        
    sql = f.read()
    return pd.DataFrame(db.query(sql).getresult(), columns = columns)

def load_pkl(filename):
    f = None
    try:
        f = open(filename,"rb")
    except:
        for root_f, folders, files in os.walk('.'):
            if filename in files:
                f = open(root_f + '/' + filename)
    if f is None:
        raise Exception ('File not found!')

    return pickle.load(f)
    