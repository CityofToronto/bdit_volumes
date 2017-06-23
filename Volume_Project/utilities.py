# -*- coding: utf-8 -*-
"""
Created on Wed Jun  7 10:06:22 2017

@author: qwang2
"""
import sys
import os
for x in os.walk('.'):
    sys.path.append(x[0]) 
    
from pg import DB
from pg import ProgrammingError

import configparser
import pandas as pd
import pickle
import logging

class vol_utils(object):
    
    def __init__(self):
        self.db_connect()
        
    def db_connect(self):
        CONFIG = configparser.ConfigParser()
        CONFIG.read('db.cfg')
        dbset = CONFIG['DBSETTINGS']
        self.db = DB(dbname=dbset['database'],host=dbset['host'],user=dbset['user'],passwd=dbset['password'])
        self.logger.info('Database connected.')
        
    def exec_file(self, filename):
        try:
            f = open(filename)
            exec(filename)
        except:
            for root_f, folders, files in os.walk('.'):
                if filename in files:
                    f = root_f + '/' + filename
                    break
            self.logger.info('Running ', f)
            exec(f)
            
        if f is None:
            self.logger.error('File ', filename, ' not found!')
            raise Exception ('File ', filename, ' not found!')
        
    def execute_sql(self, filename):
        f = None
        try:
            f = open(filename)
        except:
            for root_f, folders, files in os.walk('.'):
                if filename in files:
                    f = open(root_f + '/' + filename)
        if f is None:
            self.logger.error('File ', filename, ' not found!')
            raise Exception ('File not found!')
            
        sql = f.read()
        reconnect = 0
        while True:
            try:
                self.db.query(sql)
                return
            except ProgrammingError as pe:
                print(pe)
                self.db_connect()
                reconnect += 1
            if reconnect > 5:
                raise Exception ('Check DB connection. Cannot connect')
        
    def get_sql_results(self, filename, columns, parameters=None):
        
        f = None
        try:
            f = open(filename)
        except:
            for root_f, folders, files in os.walk('.'):
                if filename in files:
                    f = open(root_f + '/' + filename)
                    
        if f is None:
            if filename[:6] == 'SELECT': # Also accepts sql queries directly in string form
                sql = filename
            else:
                self.logger.error('File ', filename, ' not found!')
                raise Exception ('File not found!')
        else:    
            sql = f.read()
            
        if parameters is not None:
            for key,value in parameters.items():
                sql = sql.replace(key,str(value))

        reconnect = 0
        while True:
            try:
                return pd.DataFrame(self.db.query(sql).getresult(), columns = columns)
            except ProgrammingError as pe:
                self.db_connect()
                reconnect += 1
            if reconnect > 5:
                self.logger.error('Error in SQL', exc_info=True)
                raise Exception ('Check Error Message')
            
    def load_pkl(self,filename):
        f = None
        try:
            f = open(filename,"rb")
        except:
            for root_f, folders, files in os.walk('.'):
                if filename in files:
                    f = open(root_f + '/' + filename)
        if f is None:
            self.logger.error('File ', filename, ' not found!')
            raise Exception ('File not found!')
    
        return pickle.load(f) 
    
    def truncatetable(self, tablename):
        reconnect = 0
        while True:
            try:
                self.db.truncate(tablename)
                return
            except ProgrammingError as pe:
                print(pe)
                self.db_connect()
                reconnect += 1
            if reconnect > 5:
                self.logger.error('Error in SQL', exc_info=True)
                raise Exception ('Check Error Message')
                
    def inserttable(self, tablename, content):
        reconnect = 0
        while True:
            try:
                self.db.inserttable(tablename,content)
                break
            except ProgrammingError:
                self.db_connect()
                reconnect += 1
            if reconnect > 5:
                self.logger.error('Error in SQL', exc_info=True)
                raise Exception ('Check Error Message')
                
    def __exit__(self):
        self.db.close()
        