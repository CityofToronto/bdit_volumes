from datetime import time
from qgis.core import QgsVectorLayer
from iteration_mapper import IteratingMapper


class VolumeMapper( IteratingMapper ):
    """Holds settings for iterating over multiple congestion maps
    
    Inherits from IteratingMapper
    
    Attributes:
        agg_level: The aggregation level to use
        metric: The metric currently being mapped.
        METRICS: static dictionary holding strings for each metric to be used to update 
            composer levels or in SQL scripts
        COMPOSER_LABELS: static dictionary holding base string labels for the print 
            composer to be updated for each map
        BACKGROUND_LAYERS: static list holding the names of the background layers to be 
            displayed on the map
    """

    METRICS = {'aadt':{'sql_acronym':'sum',
                       'metric_name':'Annual average daily traffic',
                       'stat_description':'Average 24 hour traffic volume '
                      }}

    COMPOSER_LABELS = {}
    IteratingMapper.COMPOSER_LABELS = COMPOSER_LABELS
    BACKGROUND_LAYERNAMES = [u'street_centreline']
    IteratingMapper.BACKGROUND_LAYERNAMES = BACKGROUND_LAYERNAMES
    
    
    def __init__(self, logger, dbsettings, stylepath, templatepath, sql_string, *args, **kwargs):
        """Initialize CongestionMapper and parent object
        """
        super(VolumeMapper, self).__init__(logger, dbsettings, stylepath, templatepath, sql_string,*args, **kwargs)
        #self.agg_level = agg_level
        self.metric = None
        self.background_layers = self.get_background_layers(self.BACKGROUND_LAYERNAMES)
        
        
    def load_agg_layer(self, year, layername=None):
        """Create a QgsVectorLayer from a connection and specified parameters
        Args:
            yyyymmdd: the starting aggregation date for the period as a string
                digestible by PostgreSQL into a DATE
            timeperiod: string representing a PostgreSQL timerange
            layername: string name to give the layer
        Returns:
            QgsVectorLayer from the specified sql query with provided layername"""
        
        self.load_layer(layername, sql_params)
        return self
        
            
    def set_metric(self, metric_id):
        """Set the metric for mapping based on the provided key
        """
        if metric_id not in self.METRICS:
            raise ValueError('{metric_id} is unsupported'.format(metric_id=metric_id))
        self.metric = self.METRICS[metric_id]
        return self

    def update_table(self):
        """Update the table in the composition to use current layer
        """
        table = self.composition.getComposerItemById('table').multiFrame()
        table.setVectorLayer(self.layer)
        return self