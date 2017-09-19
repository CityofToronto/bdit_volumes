import configparser 
from psycopg2 import connect
from psycopg2.extras import RealDictCursor 
import psycopg2.sql as pgsql
import hug
# import os
# os.chdir(r'C:\Users\rdumas\Documents\GitHub\bdit_volumes\interactive_map\volume_api')



CONFIG = configparser.ConfigParser()
CONFIG.read('../../db.cfg')
dbsettings = CONFIG['DBSETTINGS']

sql = pgsql.SQL('SELECT hh, volume FROM prj_volume.centreline_hourly_group12 WHERE year = {year} AND centreline_id = {centreline_id}')

@hug.get(examples='year=2015&centreline_id=3154251')
def get_volume_year_link(year: hug.types.number, centreline_id: hug.types.number):
    '''Return 24hr volume profile for a given year and centreline_id'''
    con = connect(**dbsettings)
    with con.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql.format(year=pgsql.Literal(year),
                               centreline_id=pgsql.Literal(centreline_id)))
        data = cur.fetchall()
    con.close()
    data_dict = {'hh': [], 'volume': []}
    for row in data:
        data_dict['hh'].append(row['hh'])
        data_dict['volume'].append(row['volume'])
    return data_dict

    