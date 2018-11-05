#map_metric.py
#! python2
"""Automate printings maps of congestion metrics using PyQGIS

###############################################

WARNING 

This is abstract example code to base subclassing 
iteration_mapper on. It **won't** work if you run 
it as is.

WARNING

###############################################
"""

# Update this path to the folder containing the static_map folder:
staticmap_dir = r"C:\Users\qchen\Documents\GitHub\bdit_volumes"

import sys
sys.path.append(staticmap_dir + r"\static_map\python")
import logging
from qgis.utils import iface
from volume_mapper import VolumeMapper

#If run from the QGIS console
if __name__ == '__console__':
    import ConfigParser
    
    # Variables to change
    # Paths
    templatepath = staticmap_dir + r"\static_map\template_2015_STREETS_Q.qpt"
    stylepath = staticmap_dir + r"\static_map\style_traffic_volume_2015_Q.qml"
    print_directory = staticmap_dir + r"\static_map\test"
    #print_format = ''
    
    # Setting up variables for iteration
    yyyyrange = [2015] 
    # Copy and paste your db.cfg file between the quotes
    s_config = '''C:\Users\qchen\default.cfg'''
    
    # The script can take it from here.
    

    config = ConfigParser.ConfigParser()
    config.read(s_config)
    dbset = config._sections['DBSETTINGS']
    
    FORMAT = '%(asctime)-15s %(message)s'
    logging.basicConfig(level=logging.DEBUG, format=FORMAT)
    LOGGER = logging.getLogger(__name__)

    
    sql = '''(SELECT l2_group_number, linear_name_full, fcode_desc, dir_bin, year, avg_vol, st_transform(geom,26917) as geom
        FROM qchen.l2_aadt_2015
        WHERE year = {year} 
        AND (fcode_desc IN ('Expressway','Major Arterial','Minor Arterial')
        OR linear_name_full IN ('Finch Ave E','Old Finch Ave','McNicoll Ave','Neilson Rd','Morningside Ave','Staines Rd','Sewell''s Rd','Meadowvale Rd','Plug Hat Rd','Beare Rd','Reesor Rd'))
        )'''
    
    mapper = VolumeMapper(LOGGER, dbset, stylepath, templatepath, sql, gid='l2_group_number', console=True, iface=iface)
    #(self, logger, dbsettings, stylepath, templatepath, sql_string, *args, **kwargs)
    LOGGER.debug('created the mapper, about to go into the loop')
    
    for year in yyyyrange:
        LOGGER.debug('just entered the loop')
        layername = str(year) + ' L2 Test 2'

        #mapper.uri.setDataSource() needs to be called
        sql_params = {'year':year}
        LOGGER.debug('about to load the sql layer')
        mapper.load_sql_layer(layername, sql_params)
        LOGGER.debug('loaded the layer')
        mapper.update_canvas(iface = iface)
        mapper.print_map(print_directory + layername + '.png' )
        
        '''
        update_values = {'agg_period': _get_agg_period(agg_level, year, month),
                         'period_name': periodname,
                         'from_to_hours': format_fromto_hr(hour1, hour2), 
                         'stat_description': mapper.metric['stat_description'],
                         'metric_attr': mapper.metric['metric_attr']
                        }
        '''
        #TODO Fix this hack
        #mapper.update_labels(labels_dict = CongestionMapper.COMPOSER_LABELS, labels_update = update_values)

        
        #mapper.clear_layer()
