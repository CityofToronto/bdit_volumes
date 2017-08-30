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


import sys
sys.path.append(r"C:\Users\dolejar\Documents\bdit_volumes\static_map\python")
import logging
from qgis.utils import iface
from volume_mapper import VolumeMapper

#If run from the QGIS console
if __name__ == '__console__':
    import ConfigParser
    
    # Variables to change
    # Paths
    templatepath = r"C:\Users\dolejar\Documents\bdit_volumes\static_map\template_test5_shadow.qpt"
    stylepath = r"C:\Users\dolejar\Documents\bdit_volumes\static_map\centreline_style_4.qml"
    print_directory = r"C:\Users\dolejar\Documents\bdit_volumes\static_map\test"
    #print_format = ''
    
    # Setting up variables for iteration
    yyyyrange = [2015] 
    # Copy and paste your db.cfg file between the quotes
    s_config = '''C:\Users\dolejar\default.cfg'''
    
    # The script can take it from here.
    

    config = ConfigParser.ConfigParser()
    config.read(s_config)
    dbset = config._sections['DBSETTINGS']
    
    FORMAT = '%(asctime)-15s %(message)s'
    logging.basicConfig(level=logging.DEBUG, format=FORMAT)
    LOGGER = logging.getLogger(__name__)

    
    sql = '''(SELECT *
        FROM prj_volume.aadt_l2
        WHERE year = {year} 
        AND fcode_desc != 'Local'
        AND fcode_desc != 'Collector' 
        )'''
    
    mapper = VolumeMapper(LOGGER, dbset, stylepath, templatepath, sql, gid='id', console=True, iface=iface)
    #(self, logger, dbsettings, stylepath, templatepath, sql_string, *args, **kwargs)
    LOGGER.debug('created the mapper, about to go into the loop')
    
    for year in yyyyrange:
        LOGGER.debug('just entered the loop')
        layername = str(year) + ' Test Layer'

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
