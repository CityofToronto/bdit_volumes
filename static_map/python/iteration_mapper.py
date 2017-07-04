from qgis.core import *
from qgis.gui import QgsMapCanvas, QgsMapCanvasLayer
from qgis.PyQt.QtCore import QFileInfo
from qgis.PyQt.QtXml import QDomDocument

class IteratingMapper( object ):
    """Hold settings for iterating over multiple maps.
    
    This is a base object for holding necessary attributes for opening a QGIS print composer template, adding background layers, then iterating over the creation of new layers and saving them as images. 
    
    Attributes:
        logger: logging.logger object for logging messages
        dbsettings: dictionary of database connection string parameters
        stylepath: string filepath to load the metric layer's style 
        templatepath: string filepath to load the print composer template
        projectfile: (optional) if using standalone script string filepath to load the
            project
        console: (optional) boolean value indicating whether QGIS Python console is used
        iface: (optional) qgis.utils.iface object, used in QGIS Python console
    """
    BACKGROUND_LAYERNAMES = []
    COMPOSER_LABELS = {}
    
    def __init__(self, logger, dbsettings, stylepath, templatepath, *args, **kwargs):
        """Initiate IteratingMapper with logger, dbsettings, stylepath, templatepath"""
        self.logger = logger
        self.uri = self._new_uri(dbsettings)
        
        self.logger.info('Loading template')
        self.stylepath = stylepath
        self.template = QDomDocument()
        with open(templatepath, 'r') as templateFile:
            templateContent = templateFile.read()
            self.template.setContent(templateContent)
        
        self.project = None
        if kwargs.get('projectfile', False):
            raise NotImplementedError('Loading projects causes Python to crash')
            self.logger.info('Loading project')
            self.project = QgsProject.instance()
            self.project.read(QFileInfo(kwargs.pop('projectfile', None)))
        
        self.logger.info('Loading print composer')
        printcomposer = self._load_print_composer(console=kwargs.pop('console', False), iface=kwargs.pop('iface', None))
        self.composition = printcomposer['QgsComposition']
        self.map_settings = printcomposer['QgsMapSettings']
        self.composer_view = printcomposer['QgsComposerView']
        
        self.logger.info('Setting Map Registry and getting background layers')
        self.map_registry = QgsMapLayerRegistry.instance()
        self.background_layers = self.get_background_layers()
        self.layer = None
        self.logger.info('Mapper created successfully')
    
    def _new_uri(self, dbset):
        """Create a new URI based on the database settings and return it

        Args:
            dbset: dictionary of database connection settings

        Returns:
            PyQGIS uri object"""
        uri = QgsDataSourceURI()
        uri.setConnection(dbset['host'], "5432", dbset['database'], dbset['user'], dbset['password'])
        return uri

    def _load_print_composer(self, console=True, template = None, iface = None):
        """Load a print composer template from object template or template argument

        Args:
            template: QDomDocument object read from a file
            console: boolean if method is used in QGIS console
            iface: qgis.utils.iface object if method is used in QGIS console

        Returns:
            composition: a QGSCompsition loaded from the provided template 
            composerView: a QgsComposerView loaded from the provided template 
                (QGIS Python Console only)
            mapSettings: a QgsMapSettings object associated with composition"""
        
        if template is None:
            template = self.template
        
        composerView = None

        if console:
            composerView = iface.createNewComposer()
            composerView.composition().loadFromTemplate(template)
            composition = composerView.composition()
            mapSettings = composition.mapSettings()
        else:
            #canvas = QgsMapCanvas()
            # Next three lines from http://kartoza.com/en/blog/how-to-create-a-qgis-pdf-report-with-a-few-lines-of-python/
            #bridge = QgsLayerTreeMapCanvasBridge(
            #    QgsProject.instance().layerTreeRoot(), canvas)
            #bridge.setCanvasLayers()
            #mapSettings = canvas.mapSettings()
            mapSettings = QgsMapSettings()
            composition = QgsComposition(mapSettings)
            composition.loadFromTemplate(template)
#            map_item = composition.getComposerItemById('map')
#            map_item.setMapCanvas(canvas)
        return {'QgsComposition': composition,
                'QgsMapSettings': mapSettings,
                'QgsComposerView': composerView}
    
    def get_background_layers(self, layernamelist = BACKGROUND_LAYERNAMES):
        """Return background layers"""

        layers = [self.map_registry.mapLayersByName(name)[0] for name in layernamelist]
        layerslist = [QgsMapCanvasLayer(layer) for layer in layers]
        return layerslist
    
    def load_layer(self, layer_name, provider_name):
        """Load a vector layer based on the object's URI with layer_name, and provider_name
        
        Args:
            layer_name : name for the layer
            provider_name: name of the provider
        Returns:
            self
        """
        self.layer = QgsVectorLayer(self.uri.uri(False), layer_name, provider_name)
        self.map_registry.addMapLayer(self.layer)
        self.layer.loadNamedStyle(self.stylepath)
        return self

    def update_labels(self, labels_dict = None, labels_update = None):
        """Change the labels in the QgsComposition using a dictionary of update values

        Iterates over the keys (label ids) and values (strings to update) of the labels_dict
        Finds the corresponding element of the composition, and updates it based on keys and 
        values provided in labels_update.

        Args:
            labels_dict: dictionary of labels to change of form 
                {'label_id':'label_text to {update_section}'}
            labels_update: dictionary of values to update labels with
                format: {'update_section':'update_value'}
        Returns:
            None"""
        if labels_dict is None:
            labels_dict = type(self).COMPOSER_LABELS
        self.logger.info("Updating labels %s", labels_dict)
        for label_id, label_text in labels_dict.items():
            self.composition.getComposerItemById(label_id).setText(label_text.format(**labels_update))
    
    def update_canvas(self, iface = None):
        """Update canvas with the new layer + background layers"""
        layerslist = [QgsMapCanvasLayer(self.layer)] + self.background_layers
        if iface is not None:
            iface.mapCanvas().setLayerSet(layerslist)
            iface.mapCanvas().refresh()
        else:
            raise NotImplementedError("This hasn't been developed for standalone")
    
    def print_map(self, printpath, filetype = 'png'):
        """Print the map to the specified location
        
        Args:
            printpath: string path to print to
            filetype: ['png','pdf'] determines type of image to print
        Raises:
            NotImplementedError: If filetype is not supported
        """
        
        self.composition.refreshItems()
        if filetype == 'png':
            image = self.composition.printPageAsRaster(0)
            image.save(printpath)
        elif filetype == 'pdf':
            self.composition.exportAsPDF(printpath)
        else:
            raise NotImplementError('{filetype} is not supported'.format(filetype=filetype))
    
    def clear_layer(self):
        """Remove added layer"""
        self.map_registry.removeMapLayer(self.layer)
        self.layer = None
    
    def close_project(self):
        """Close the project, if loaded"""
        if self.project is not None:
            self.project.clear()
            self.project = None

    #TODO: Cleanup, not sure if actually needed
#    def set_composition_layers(self):
#        layerslist = [QgsMapCanvasLayer(self.layer)] + self.background_layers
#        map_item = composition.getComposerItemById('map')
#        map_item.