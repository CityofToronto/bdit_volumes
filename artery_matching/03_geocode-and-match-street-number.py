# -*- coding: utf-8 -*-
"""
Created on Mon Dec  5 09:55:31 2016

@author: qwang2
"""

from fuzzywuzzy import fuzz
import pandas as pd
import re
import AddressFunctions as AF
from pg import DB
import configparser

def MatchStreetNumber(n,b1,e1,b2,e2):
    if n % 2 == 1:
        if n >= b1 and n <= e1:
            return True
        else:
            return False
    else:
        if n >= b2 and n <= e2:
            return True
        else:
            return False

def Geocode(s1,s2):
    if s2 != '' :
        (add,lat,lon) = AF.geocode(s1+' and '+s2)
    else:
        (add,lat,lon) = AF.geocode(s1)
    if lat is None:
        print(s1+' and '+s2)
        return False
    artery = {}
    artery['arterycode'] = ac
    artery['fx'],artery['fy'] = lon,lat
    artery['source'] = 'geo'
    db.upsert('prj_volume.arteries',artery)
    return True

CONFIG = configparser.ConfigParser()
CONFIG.read('db.cfg')
dbset = CONFIG['DBSETTINGS']

db = DB(dbname=dbset['database'],host=dbset['host'],user=dbset['user'],passwd=dbset['password'])
proxies = {'http':'http://137.15.73.132:8080'}

roads = re.compile('\s(AVE|RD|ROAD|PKWY|ST|CRES|PL|BLVD|DR|GT|CRT|GDNS|TER|WAY|LANE|TRL|CIR|CRCL|PARK|TCS|HTS|GROVE|SQ|GATE)\s([EWNS])?');
tcl = db.query('SELECT centreline_id, linear_name_full, linear_name, low_num_odd, high_num_odd, low_num_even, high_num_even FROM prj_volume.centreline').getresult()
tcl = pd.DataFrame.from_records(tcl, columns = ['centreline_id', 'linear_name_full', 'linear_name', 'low_num_odd', 'high_num_odd', 'low_num_even', 'high_num_even'])
tcl['first_letter'] = tcl.linear_name_full.str[0]
tcl_fl = tcl.groupby('first_letter')

matched = 0
geocoded = 0

nogeomL = db.query('SELECT arterycode, sideofint, apprdir, location, street1, street2 FROM prj_volume.arteries JOIN traffic.arterydata USING (arterycode) WHERE tnode_id IS NOT NULL AND fnode_id IS NOT NULL AND fx IS NULL AND tx IS NULL').getresult()
nogeomL = pd.DataFrame.from_records(nogeomL,columns=['arterycode','sideofint','direction','location','street1','street2'])


for (ac,loc,dirc,side,s1,s2) in zip(nogeomL['arterycode'],nogeomL['location'],nogeomL['direction'],nogeomL['sideofint'],nogeomL['street1'], nogeomL['street2']):
    f = False
    s1 = s1 + ' '
    s2 = s2 + ' '
    m = re.search('#(\s)*[0-9]+', s1)
    # Check for street numbers
    if m is not None:
        m = re.search('[0-9]+', s1)
        n = roads.search(s1)
        street = s1[m.end()+1:n.end()].strip()
        number = s1[m.start():m.end()].strip()
        
    elif re.search('#(\s)*[0-9]+', s2) is not None:
        m = re.search('[0-9]+', s2)
        n = roads.search(s2)
        street = s2[m.end()+1:n.end()].strip()
        number = s2[m.start():m.end()].strip()
    
    # Check for laneways
    elif loc.find('LN') > 0 or loc.find('LANEWAY') > 0 or loc.find('LNWY') > 0 or loc.find('LANE') > 0:
        f = False 
        maxmatch = 0
        icl = tcl_fl.get_group('L')
        for (clid, c) in zip(icl['centreline_id'],icl['linear_name_full']):
            mc = fuzz.partial_token_set_ratio(c,loc)
            if mc < maxmatch:
                maxmatch = mc
                clid000 = clid
        if maxmatch > 80:
            db.upsert('prj_volume.artery_tcl', {'arterycode':ac, 'centreline_id':clid000, 'direction':dirc, 'sideofint':side, 'match_on_case':5, 'artery_type':1})
            f = True
            matched = matched + 1
    # Treat as regular intersection and Geocode
    else:
        f = Geocode(s1,s2)
        if f:
            geocoded = geocoded +1
    # match street number and name        
    if not f and m is not None:        
        number = int(number)
        street = street.lower()
        
        # Find these street numbers in the centreline file
        icl = tcl_fl.get_group(street[0].upper())
        for (clid,c,b1,e1,b2,e2) in zip(icl['centreline_id'],icl['linear_name_full'],icl['low_num_odd'],icl['high_num_odd'],icl['low_num_even'],icl['high_num_even']):
            c = c.lower()        
            mc = fuzz.ratio(street, c)
            mp = fuzz.partial_ratio(street, c)
            if mc > 95:
                if MatchStreetNumber(number, b1,e1,b2,e2):
                    f = True
                    db.upsert('prj_volume.artery_tcl', {'arterycode':ac, 'centreline_id':clid, 'direction':dirc, 'sideofint':side, 'match_on_case': 5, 'artery_type':1})
                    matched = matched + 1
                    break
            elif mc > 85 and mp > 95:
                if MatchStreetNumber(number, b1,e1,b2,e2):
                    f = True
                    db.upsert('prj_volume.artery_tcl', {'arterycode':ac, 'centreline_id':clid, 'direction':dirc, 'sideofint':side, 'match_on_case':5, 'artery_type':1})
                    matched = matched + 1
                    break
        # try geocoding if cannot find street and number
        if not f:
            f = Geocode(str(number) + ' ' + street, '')
            if f:
                geocoded = geocoded +1

    # no luck after trying everything
    if not f:
        db.upsert('prj_volume.artery_tcl',{'arterycode':ac,'direction':dirc,'sideofint':side,'match_on_case':9, 'artery_type':1})

nogeomP = db.query('SELECT arterycode, location, street1, street2 FROM prj_volume.arteries JOIN traffic.arterydata USING (arterycode) WHERE tnode_id is NULL and fx is NULL').getresult()
nogeomP = pd.DataFrame.from_records(nogeomP, columns = ['arterycode', 'location', 'street1', 'street2'])

for (ac, loc, s1, s2) in zip(nogeomP['arterycode'],nogeomP['location'],nogeomP['street1'], nogeomP['street2']):
    m1 = re.search('#(\s)*[0-9]+', s1)
    m2 = re.search('#(\s)*[0-9]+', s2)

    if m1 is not None:
        f = Geocode(s1[m1.start()+1:], '')
    elif m2 is not None:
        f = Geocode(s2[m2.start()+1:], '')
    else:
        f = Geocode(s1,s2)
    if not f:
        db.upsert('prj_volume.artery_tcl',{'arterycode':ac,'direction':'','sideofint':'', 'match_on_case':9, 'artery_type':2})
    else:
        geocoded = geocoded + 1

matchNameNumber = db.query("SELECT arterycode, apprdir, sideofint, location, street1, street2 FROM traffic.arterydata JOIN prj_volume.arteries USING (arterycode) \
WHERE location SIMILAR TO '%\d%' AND location NOT SIMILAR TO '%PX\s*\d+%' AND count_type NOT IN ('R', 'P') AND location NOT LIKE '%HIGHWAY%' AND location NOT LIKE '% LN %' AND location NOT SIMILAR TO '\ALN %' AND location NOT LIKE '%RAMP%'\
AND (position(street1 in street2)>0 or position(street2 in street1)>0) AND street1 IS NOT NULL AND street2 IS NOT NULL").getresult()
matchNameNumber = pd.DataFrame.from_records(matchNameNumber,columns=['arterycode','direction','sideofint','location','street1','street2'])
matchedNN = 0

for (ac,loc,dirc,side,s1,s2) in zip(matchNameNumber['arterycode'],matchNameNumber['location'],matchNameNumber['direction'],matchNameNumber['sideofint'],matchNameNumber['street1'], matchNameNumber['street2']):
    s1 = s1 + ' '
    s2 = s2 + ' '
    # Get street numbers
    m = re.search('[0-9]+', loc)
    number = int(loc[m.start():m.end()].strip())

    m = re.search('[0-9]+', s1)
    if m is not None or s2 == ' ':
        n = roads.search(s1)
        if m is None:
            street = s1
        elif n is None:
            street = s1[m.end()+1:].strip().lower()
        else:
            street = s1[m.end()+1:n.end()].strip().lower()
    else:
        m = re.search('[0-9]+', s2)
        n = roads.search(s2)
        if m is None:
            street = s2
        elif n is None:
            street = s2[m.end()+1:].strip().lower()
        else:
            street = s2[m.end()+1:n.end()].strip().lower()
    street = street.replace(' road', ' rd')
    
    try:
        icl = tcl_fl.get_group(street[0].upper())
    except:
        continue

    for (clid,cfull,cpart,b1,e1,b2,e2) in zip(icl['centreline_id'],icl['linear_name_full'],icl['linear_name'],icl['low_num_odd'],icl['high_num_odd'],icl['low_num_even'],icl['high_num_even']):
        cfull = cfull.lower()       
        cpart = cpart.lower()
        if n is None:
            mc = fuzz.ratio(street, cpart)
            mp = fuzz.partial_ratio(street, cpart)
        else:
            mc = fuzz.ratio(street, cfull)
            mp = fuzz.partial_ratio(street, cfull)
        if mc > 95:
            if MatchStreetNumber(number, b1,e1,b2,e2):
                db.upsert('prj_volume.artery_tcl', {'arterycode':ac, 'centreline_id':clid, 'direction':dirc, 'sideofint':side, 'match_on_case': 5, 'artery_type':1})
                matchedNN = matchedNN + 1
                break
        elif mc > 85 and mp == 100:
            if MatchStreetNumber(number, b1,e1,b2,e2):
                db.upsert('prj_volume.artery_tcl', {'arterycode':ac, 'centreline_id':clid, 'direction':dirc, 'sideofint':side, 'match_on_case':5, 'artery_type':1})
                matchedNN = matchedNN + 1
                break

db.close()