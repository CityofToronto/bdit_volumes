# -*- coding: utf-8 -*-
"""
Created on Mon Sep 18 11:03:24 2017

@author: rrodger
"""
from psycopg2 import connect
import pandas.io.sql as pandasql
import configparser
from datetime import date, timedelta
import csv


def missingdates (start, end): #returns the dates between a start and an end date
    fullset = set(start + timedelta(x) for x in range((end - start).days))
    missingset = sorted(fullset - set([start, end]))
    return missingset
    
CONFIG = configparser.ConfigParser()
CONFIG.read('C:\\Users\\rrodger\\reed.cfg')
dbset = CONFIG['DBSETTINGS']
con = connect(**dbset)

start = date(2016, 1, 1)
end = date(2017, 7, 1)
sql = '''select a.arterycode, a.location, a.count_info_id, a.count_date, extract(dow from a.count_date) as dow, round(avg(b.count), 0) as avg_count
from qchen.rescu_countinfo a
inner join traffic.cnt_det b using (count_info_id)
where timecount >= \'''' + str(start) + '''\'
  and timecount <= \'''' + str(end) + '''\'
group by a.count_info_id
order by a.arterycode, a.count_date'''

counts = pandasql.read_sql(sql, con)
acode = 0

drops_per_month = []
dpm_index = []

i = -1

with open('H:\misseddays.csv','w') as misseddays:
    c = csv.writer(misseddays)
    for day in counts.itertuples():
        if acode != day[1]: #for a new arterycode
            i += 1
            previous_day = day[4] #set a sew start date
            acode = day[1]
            drops_per_month.append([[0]*12 for n in range(end.year - start.year)]) # adds interior list to store years and months for arterycode
            drops_per_month[i].append([0]*(end.month))
            dpm_index.append(acode)
            i = dpm_index.index(acode)
            continue
        month = -1
        year = -1
        for days in missingdates(previous_day, day[4]):
            
            if day[4].month - 1 != month: #if the year or month changes, alter index to assign count to appropriate bucket.
                month = days.month - 1
            if day[4].year != year + start.year:
                year = days.year - start.year 

            drops_per_month[i][year][month] = 1 + drops_per_month[i][year][month]
            
            c.writerow([acode, days, days.weekday()])
        previous_day = day[4]

with open('H:\drops_per_month.csv','w') as dpm:
    drops = csv.writer(dpm)
    for i, acode in enumerate(drops_per_month):
        ar_code = dpm_index[i]

        for j, year in enumerate(acode):
            cur_year = start.year + j
            
            for k, month in enumerate(year):
                cur_month = k
                
                drops.writerow([ar_code, cur_year, cur_month + 1, month])
