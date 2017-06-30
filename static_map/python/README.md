# Iteration Mapping 
*Automating the creation of maps of metrics from a PostgreSQL database by iterating over different metrics or timeperiods*

## Purpose
Automate the generation of maps in QGIS so that looking at multiple metrics over time doesn't require a lot of manual layer creation and composer editing.

## Usage

### Setup
1. Create a PostgreSQL table of the metrics to map. [Congestion Mapper](https://github.com/CityofToronto/bdit_congestion/tree/master/congestion_mapping) assumes different metrics are in the same table, and each layer is a different filter on one single table.
3. The Python element requires a working [QGIS installation](http://www.qgis.org/en/site/forusers/download.html)
4. If wanting to work on the script outside of QGIS, set up a Python virtual environment for developing with QGIS based on [these instructions](http://gis.stackexchange.com/a/223325/36886).
5. Create your own subclass of `IteratingMapper` tailored to the metrics and timeperiods you want to be iterating over. You can have a look at [Congestion Mapper](https://github.com/CityofToronto/bdit_congestion/tree/master/congestion_mapping) as an example.

#### In QGIS 
1. Set up a new QGIS project with background layers properly styled. Note these layernames and to add them to the `BACKGROUND_LAYERNAMES` list.
2. Load a sample layer of data and style it. Save the style to a style file.
3. Set up the print composer.
4. When adding labels to the print composer, note their ids to add to the `COMPOSER_LABELS` dictionary.

   ![](img/composer_items.PNG)
5. Save the print composer as a template with `Composer > Save as Template...`

#### In Python 
`IterationMapper` is the base class for iterating maps in QGIS. For new mapping tasks this baseclass should be inherited in the spirit of `CongestionMapper`. `BACKGROUND_LAYERNAMES` and `COMPOSER_LABELS` should be modified for the new composition, noting the elements from the QGIS project and print composer template as per above. `COMPOSER_LABELS` is a dictionary that takes the following form, where each id in the print composer is a key, and the string to be formatted is its corresponding value. In the string to be formatted, insert placeholder variables in curly braces `{agg_period}` where these elements of the string will be generated when automating. Have a look at [Using % and .format() for great good!](https://pyformat.info/)

```python
COMPOSER_LABELS = {'map_title': '{agg_period} Top 50 {metric_attr} Road Segments'}
```

A new method to generate layers from SQL like `CongestionMapper.load_agg_layer()` would need to be written, which prepares custom SQL and then assigns it to the URI with `self.uri.setDataSource("", sql, "geom", "", "Rank")` before calling `IterationMapper.load_layer()`. 

The methods in `parsing_utils.py` are (mostly) specific to processing inputs related to congestion mapping, and the `parse_args()` method could be modified to process command-line inputs for different applications. There may be a way to have a generalizable argument parser that could be subclassed for future applications.

`map_metric.py` only contains code to set up the `CongestionMapper` from either command-line or scripted input, and then loop over metrics, years and months to call layer loading methods, updating labels, and finally printing. 

## Using the Python application
The script is designed for use as a standalone command-line application as well as a script that can be opened within QGIS.

### In the QGIS Python Console
*Only tested in QGIS LTR versions `2.14.8` and above*

1. Open the congestion QGIS project to automate.
2. Open the QGIS Python Console ![](img/qgis_python.PNG)
3. Reveal the editor by clicking on the highlighted button  
![](img/show_editor.PNG)
4. Open the `map_metric.py` script from this repo in the editor. The script should automagically detect that it's being run from the QGIS console, but there are some variables to edit.

##### Variables to edit in `map_metric.py`

1. `repo_path`:  Search for the first `if __name__ == '__console__':` block. `repo_path` helps the script find the other modules in this project to import. So change  

    `repo_path = r"C:\path\to\repo"`
2. **variables for what you want to map**: Search for the second `if __name__ == '__console__':` block. You'll find the below
    ```python
    # Variables to change
    # Paths
    templatepath = "K:\\Big Data Group\\Data\\GIS\\Congestion_Reporting\\top_50_template.qpt"
    stylepath = "K:\\Big Data Group\\Data\\GIS\\Congestion_Reporting\\top50style.qml"
    print_directory = r"C:\Users\rdumas\Documents\test\\"
    #print_format = ''
    
    # Setting up variables for iteration
    agg_level = 'year' #['year','quarter','month']
    metrics = ['b'] #['b','t'] for bti, tti
    yyyymmrange = [['201501', '201501']] 
    #for multiple ranges
    #yyyymmrange = [['201203', '201301'],['201207', '201209']] 
    hours_iterate = []
    timeperiod = [17,18]
    periodname = 'PM Peak'
    # Copy and paste your db.cfg file between the quotes
    s_config = '''
    '''
    ```  
   `templatepath` is the path to the print composer template  
   `stylepath` is the path to the style for the aggregation layer  
   `print_directory` is the directory to save the images  
   `hours_iterate` and `timeperiod` are mutually exclusive variables. `hours_iterate` should be a list of a start hour and end hour to produce an hourly map. `timeperiod` produces one map per aggregation period (year, quarter, or month) for a metric aggregated over [starthour, endhour] and a `periodname` (e.g. PM Peak, Daytime) can be supplied.
   The other variables should be fairly explanatory.  

3. After those changes have been made, hit the play arrow to run the script file. Be patient, it can take around 1 minute to load the print composer.
4. The images should be saved in the specified folder. It's now safe to close the project. Before you do it's probably wiser to not save the loaded layers, there have been random problems where projects are unable to open due to these layers somehow corrupting the project file. If the project file does become un-openable follow the troubleshooting [here](https://gis.stackexchange.com/questions/221621/how-to-fix-corrupted-qgis-project-file-that-causes-windows-to-freeze)

#### Command-line Application
****
**Untested**
****

## Contents

This folder contains a python command-line application to iterate over a range of dates and metrics and print maps from QGIS.
This application is currently only tested with QGIS `2.14.X`

### Contents:

#### iteration_mapper

Base object for iterating map creation with PyQGIS. 

**Attributes:**
 - `logger`: logging.logger object for logging messages
 - `dbsettings`: dictionary of database connection string parameters
 - `stylepath`: string filepath to load the metric layer's style 
 - `templatepath`: string filepath to load the print composer template
 - `projectfile`: (optional) if using standalone script string filepath to load the project
 - `console`: (optional) boolean value indicating whether QGIS Python console is used
 - `iface`: (optional) qgis.utils.iface object, used in QGIS Python console
 
**Public functions:**
 - `get_background_layers(layernamelist = BACKGROUND_LAYERNAMES)`: Return background layers
 - `update_labels(labels_dict = None, labels_update = None)`: Change the labels in the QgsComposition using a dictionary of update values
 - `update_canvas(iface = None)`: Update canvas with the new layer + background layers
 - `print_map(printpath, filetype = 'png')`: Print the map to the specified location
 - `clear_layer()`: Remove added layer
 - `close_project()`: Close the project, if loaded

##### parsing_utils

Parsing utilities for `map_metric.py` includign parsing command-line arguments. 

**Public Functions**:
 - `parse_args(args, prog = None, usage = None)`:
        Parse command line argument
 - `get_yyyymmdd(yyyy, mm, **kwargs)`:
        Combine integer yyyy and mm into a string date yyyy-mm-dd. 
 - `fullmatch(regex, string, flags=0)`:
        Emulate python-3.4 re.fullmatch().
 - `format_fromto_hr(hour1, hour2)`:
        Format hour1-hour2 as a string and append AM/PM
 - `validate_multiple_yyyymm_range(years_list, agg_level)`:
        Validate a list of pairs of yearmonth strings
 - `get_timerange(time1, time2)`:
        Validate provided times and create a timerange string to be inserted into PostgreSQL

##### map_metric

Main method. Contains logic for cycling over multiple years, hours of
the day, and metrics to load layers from the PostgreSQL DB, add them to a
template map and then print them to a png.

Detects whether the script is being called from the PyQGIS Console by checking `if __name__ == '__console__'`

## Challenges Solved

### Programming in PyQGIS
I thought that more documentation existed for PyQGIS before starting this project. I was mistaken. Three resources used were:  

1. The [PyQGIS Cookbook](http://docs.qgis.org/testing/en/docs/pyqgis_developer_cookbook/), useful for startup but rather sparse (and occasionally wrong)
2. The [PyQGIS tag](https://gis.stackexchange.com/questions/tagged/pyqgis) on GIS.se. Beware of undocumented changes to the API!
3. [The QGIS API Documentation](http://qgis.org/api/2.14/) (Very sparse)

An important thing to note from the [Cookbook's introduction](http://docs.qgis.org/testing/en/docs/pyqgis_developer_cookbook/intro.html) is that there are 4 different ways to interact with QGIS in Python, and the API is different for each:  
 - automatically run Python code when QGIS starts
 - issue commands in Python console within QGIS
 - create and use plugins in Python
 - create custom applications based on QGIS API

Some questions/challenges that were overcome (in order):
 - [Why do I get a NameError for QDomDocument when attempting to programmatically load a template in the QGIS Python console?](https://gis.stackexchange.com/questions/221580/why-do-i-get-a-nameerror-for-qdomdocument-when-attempting-to-programmatically-lo)
 - [How to fix corrupted QGIS project file that causes Windows to freeze?](https://gis.stackexchange.com/questions/221621/how-to-fix-corrupted-qgis-project-file-that-causes-windows-to-freeze)
 - [Loading QgsComposition from template without throwing “QgsComposition constructor is deprecated”?](https://gis.stackexchange.com/questions/222717/loading-qgscomposition-from-template-without-throwing-qgscomposition-constructo)
 - [How to show a QgsComposition created in the QGIS Python console?](https://gis.stackexchange.com/questions/222748/how-to-show-a-qgscomposition-created-in-the-qgis-python-console)
 - [Programmatically changing layers in QGIS Print Composer?](https://gis.stackexchange.com/questions/223999/programmatically-changing-layers-in-qgis-print-composer)
 - [PyQGIS get existing ComposerAttributeTable from composition?](http://gis.stackexchange.com/q/224164/36886)

### Python Objects
While working on this project at some point PyLint threw a warning because too many parameters were being passed in a function. Searching for this warning on StackOverflow led to [the answer](http://stackoverflow.com/a/816517):
>Some of the 10 arguments are presumably related. Group them into an object, and pass that instead.

This tied into another consideration: **Given that there are going to be more/other maps to automate, how do we make this project flexible/extensible to other tasks?** Is there a way to store and group variables and methods that are generalizable to other iterative mapping tasks into an object that can then be inherited for more specific tasks? **Yes.** This is the `IterationMapper` class, which is inherited by the `CongestionMapper` class. 

