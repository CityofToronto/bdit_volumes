# -*- coding: utf-8 -*-
"""
Created on Mon Dec  5 09:55:31 2016

@author: qwang2
"""

from fuzzywuzzy import fuzz
import pandas as pd
import re
import AddressFunctions as AF
import numpy as np

def MatchStreetNumber(n,b1,e1,b2,e2):
    if n % 2 == b1 % 2:
        if n >= b1 and n <= e1:
            return True
        else:
            return False
    else:
        if n >= b2 and n <= e2:
            return True
        else:
            return False

def Geocode(db,ac,s1,s2):
    
    if s2 != '' :
        (add,lat,lon) = AF.geocode(str(s1)+' and '+str(s2))
    else:
        (add,lat,lon) = AF.geocode(str(s1))
    if lat is None:
        return False
    artery = {}
    artery['arterycode'] = ac
    artery['fx'],artery['fy'] = lon,lat
    artery['source'] = 'geo'
    db.upsert('prj_volume.arteries',artery)
    
    return True

def geocode_match_lingstrings(db, roads, tcl_fl):
    
    matched = 0
    geocoded = 0
    failed = 0
    
    # Get line segments that need to be matched/geocoded
    nogeomL = pd.DataFrame(db.query('SELECT arterycode, sideofint, apprdir, location, street1, street2 FROM prj_volume.arteries JOIN traffic.arterydata USING (arterycode) WHERE tnode_id IS NOT NULL AND fnode_id IS NOT NULL AND fx IS NULL AND tx IS NULL').getresult(), columns=['arterycode','sideofint','direction','location','street1','street2'])
    
    
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
            f = Geocode(db,ac,s1,s2)
            if f:
                geocoded = geocoded +1
                
        # Try matching to centreline       
        if not f and m is not None:        
            number = int(number)
            street = street.lower()
            
            # Find street numbers in the centreline file
            icl = tcl_fl.get_group(street[0].upper())
            for (clid,c,b1,e1,b2,e2) in zip(icl['centreline_id'],icl['linear_name_full'],icl['low_num_l'],icl['high_num_l'],icl['low_num_r'],icl['high_num_r']):
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
            # try geocoding if cannot be matched
            if not f:
                f = Geocode(db,ac,str(number) + ' ' + street, '')
                if f:
                    geocoded = geocoded +1
    
        # Geocoding failed and matching failed
        if not f:
            db.upsert('prj_volume.artery_tcl',{'arterycode':ac,'direction':dirc,'sideofint':side,'match_on_case':9, 'artery_type':1})
            failed = failed + 1
            
    return (matched,geocoded,failed)
    
def geocode_points(db):
    
    geocoded = 0
    failed = 0
    
    # Get points that need to be matched/geocoded
    nogeomP = db.query('SELECT arterycode, location, street1, street2 FROM prj_volume.arteries JOIN traffic.arterydata USING (arterycode) WHERE tnode_id is NULL and fx is NULL').getresult()
    nogeomP = pd.DataFrame.from_records(nogeomP, columns = ['arterycode', 'location', 'street1', 'street2'])
    
    for (ac, loc, s1, s2) in zip(nogeomP['arterycode'],nogeomP['location'],nogeomP['street1'], nogeomP['street2']):
        if s1 is None:
            m1 = None
        else:
            m1 = re.search('#(\s)*[0-9]+', s1)
		
        if s2 is None:
            m2 = None
        else:
            m2 = re.search('#(\s)*[0-9]+', s2)
    
        if m1 is not None:
            f = Geocode(db,ac,s1[m1.start()+1:], '')
        elif m2 is not None:
            f = Geocode(db,ac,s2[m2.start()+1:], '')
        else:
            f = Geocode(db,ac,s1,s2)
        if not f:
            db.upsert('prj_volume.artery_tcl',{'arterycode':ac,'direction':'','sideofint':'', 'match_on_case':9, 'artery_type':2})
            failed = failed + 1
        else:
            geocoded = geocoded + 1
            
    return (0,geocoded,failed)
    
def match_by_street_number(db, roads, tcl_fl):
    # Match directly by street number
    matchNameNumber = pd.DataFrame(db.query("SELECT arterycode, apprdir, sideofint, location, street1, street2 FROM traffic.arterydata JOIN prj_volume.arteries USING (arterycode) \
    WHERE location SIMILAR TO '%\d%' AND location NOT SIMILAR TO '%PX\s*\d+%' AND count_type NOT IN ('R', 'P') AND location NOT LIKE '%HIGHWAY%' AND location NOT LIKE '% LN %' AND location NOT SIMILAR TO '\ALN %' AND location NOT LIKE '%RAMP%'\
    AND (position(street1 in street2)>0 or position(street2 in street1)>0) AND street1 IS NOT NULL AND street2 IS NOT NULL").getresult(), columns=['arterycode','direction','sideofint','location','street1','street2'])
    
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
    
        for (clid,cfull,cpart,b1,e1,b2,e2) in zip(icl['centreline_id'],icl['linear_name_full'],icl['linear_name'],icl['low_num_l'],icl['high_num_l'],icl['low_num_r'],icl['high_num_r']):
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
                
    return (matchedNN,0,0)
    
def geocode_match(db):
    roads = re.compile('\s(AVE|RD|ROAD|PKWY|ST|CRES|PL|BLVD|DR|GT|CRT|GDNS|TER|WAY|LANE|TRL|CIR|CRCL|PARK|TCS|HTS|GROVE|SQ|GATE)\s([EWNS])?');
    tcl = pd.DataFrame(db.query('SELECT geo_id AS centreline_id, lf_name AS linear_name_full, street_strip(lf_name) AS linear_name, lonuml, hinuml, lonumr, hinumr FROM gis.centreline').getresult(), columns = ['centreline_id', 'linear_name_full', 'linear_name', 'low_num_l', 'high_num_l', 'low_num_r', 'high_num_r'])
    tcl['first_letter'] = tcl.linear_name_full.str[0]
    tcl_fl = tcl.groupby('first_letter')
    
    results = []

    results.append(geocode_match_lingstrings(db, roads, tcl_fl))
    results.append(match_by_street_number(db, roads, tcl_fl))
    results.append(geocode_points(db))
    
    (matched,geocoded,failed) = np.sum(np.array(results),axis=0)