# -*- coding: utf-8 -*-
"""
Created on Thu May  4 09:05:08 2017

@author: qwang2
"""

from pg import DB
import configparser
import pandas as pd
import pickle

# CONNECTION SET UP
CONFIG = configparser.ConfigParser()
CONFIG.read('db.cfg')
dbset = CONFIG['DBSETTINGS']
db = DB(dbname=dbset['database'],host=dbset['host'],user=dbset['user'],passwd=dbset['password'])

factors = pd.DataFrame(db.query('SELECT centreline_id, dir_bin, y, array_agg(month_weight ORDER BY m) AS month_weight \
        FROM( SELECT centreline_id, dir_bin, y, m, avg_daily_volume/SUM(avg_daily_volume) OVER (PARTITION BY centreline_id, dir_bin, y) AS month_weight \
              FROM(SELECT centreline_id, dir_bin, y, m, AVG(daily_volume) AS avg_daily_volume, COUNT(*) AS num_counts \
                   FROM (SELECT centreline_id, dir_bin, EXTRACT(YEAR FROM count_bin::date) AS y, EXTRACT(MONTH FROM count_bin::date) AS m, SUM(volume) AS daily_volume \
                         FROM (SELECT centreline_id, dir_bin, count_bin, SUM(volume) AS volume FROM prj_volume.centreline_volumes WHERE count_type = 1 GROUP BY centreline_id, dir_bin, count_bin) Z \
                         GROUP BY centreline_id, dir_bin, count_bin::date \
                         HAVING count(*) = 96) A \
                   GROUP BY centreline_id, dir_bin, y, m \
                   ORDER BY centreline_id, dir_bin, y, m) B \
              WHERE num_counts > 5) C \
        GROUP BY centreline_id, dir_bin, y \
        HAVING COUNT(DISTINCT m) = 12').getresult(), columns = ['centreline_id', 'dir_bin','year','weights'])

factors1 = factors.set_index(['centreline_id', 'dir_bin','year'])
f_sum = [0] * 12
for weight in factors1['weights']:
    f = [float(i) for i in weight]
    f_sum = [i+j for i,j in zip(f, f_sum)]
f_sum = [i/len(factors) for i in f_sum]
f_sum = pd.DataFrame([[f_sum]],index=['average'],columns=['weights'])
factors1 = factors1.append(f_sum)
pickle.dump(factors1,open("monthly_factors.p","wb"))