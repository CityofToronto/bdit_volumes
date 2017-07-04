import unittest
import sys
import logging
from iteration_mapper import IteratingMapper

class IteratingMapperTestCase(unittest.TestCase):

    def setup(self):
        gui_flag = True
        self.app = QgsApplication(sys.argv, gui_flag)
        self.app.initQgis()
        FORMAT = '%(asctime)-15s %(message)s'
        logging.basicConfig(level=logging.INFO, format=FORMAT)
        LOGGER = logging.getLogger(__name__)
dbsettings = {'host': 'localhost',
              'database': 'test',
              'user': 'test',
              'password': 'test'}
stylepath = r"K:\Big Data Group\Data\GIS\Congestion_Reporting\top50style.qml"
templatepath = 'K:\\Big Data Group\\Data\\GIS\\Congestion_Reporting\\top_50_template.qpt'
        self.mapper = IteratingMapper(LOGGER, dbsettings, stylepath, templatepath)
        
    def teardown(self):
        self.mapper.close_project()
        self.mapper = None
        self.app.exitQgis()
    
    
if __name__ == '__main__':
    unittest.main()