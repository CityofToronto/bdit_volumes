# Static AADT Map

## 1.0 Purpose
The static map displays annual average daily volumes, from the volume model, created using a combined automated process.

## 2.0 Process Summary
![](flowdiagram.PNG)

## 3.0 Process
### 3.1 Volume Model
See [bdit_volumes](https://github.com/CityofToronto/bdit_volumes/) root repository for more information. 

### 3.2 PostgreSQL Tables
#### l2_aadt_2015
This table contains data created from the volume model as well as other attribute data describing the centrelines, and feeds into the Python script. The SQL script to create `l2_aadt_2015` is in the [sql folder](sql/).

#### Data Elements
Field Name|Description|Type
----------|-----------|----
l2_group_number|Level 2 group number (pkey)|Integer
linear_name_full|Road name|Text
fcode_desc|Road type|Text
dir_bin|Direction bin (1 for N/E, -1 for S/W)|Integer (-1, 1)
year|Year of volume data|Integer
avg_vol|AADT rounded to nearest 10|Numeric
geom|Geometry of road segment|Geometry

#### Join Description
Table|Joins On|Gives Fields
-----|--------|------------
prj_volume.aadt (original)|group_number (pkey)|dir_bin, year, avg_vol
prj_volume.centreline_groups_l2|l1_group_number|l2_group_number
prj_volume.centreline_groups_geom|group_number|linear_name_full
prj_volume.centreline_groups_l2_geom|l2_group_number|geom

### 3.3 Python Script
The Python script should be run from the QGIS Python Console, within the `aadt_map.qgs` project file. The script will run assuming that the user has readied the tools in [bdit_python_utilities repository](https://github.com/CityofToronto/bdit_python_utilities). 

`map_metric_Q.py`
 - Update paths (lines 21, 32-34, 40)
 - `mapper` function argument `gid` should be `l2_group_number` or another pkey field (line 61)
 - Update `yyyyrange` and `layername` if necessary (lines 38, 67)

Running the script will create a new layer in the project, which will use the style `style_traffic_volume_2015_Q.qml`, and also create a new composer from the template `template_2015_STREETS_Q.qpt`. 

The SQL query in the Python script will filter for the records on interest, and will also transform the geom of the source table into SRID 26917, as required by the style used in the QGIS project. 


### 3.4 QGIS & Print Composer
#### Settings
QGIS Version: 2.18.12 Las Palmas
 - This version or higher is required for the volume labels to be placed properly.

Project CRS: NAD83 / UTM zone 17N, EPSG SRID 26917
 - The project, `void_box` layer, and volume label layer need to share the same CRS for the style to display properly.

#### Project Layers
Layer|Description
-----|-----------
Volume Label Layer|Created from Python script<br>Has its own style file
Centreline Network|From street_centreline in the gis schema, with filter<br>Has its own style file
Land Boundaries|Shapefile of city zoning and shoreline boundaries
void_box|Not visible, used by Volume Label Layer style <br>to create gap in downtown labelling in main map view

#### Centreline Network Layer Filter
```SQL
("fcode_desc" IN ('Expressway','Major Arterial','Minor Arterial','Expressway Ramp') OR
"lf_name" IN ('Finch Ave E','Old Finch Ave','McNicoll Ave','Neilson Rd','Morningside Ave','Staines Rd','Sewell''s Rd','Meadowvale Rd','Plug Hat Rd','Beare Rd','Reesor Rd'))
AND NOT("lf_name" LIKE '%Dovercourt%' OR "lf_name" LIKE '%Cosburn%' OR "lf_name" LIKE '%Drumsnab%' OR "lf_name" LIKE '%Castle Frank%' OR "lf_name" LIKE '%Millwick%')
AND NOT(gid in (44165,43077,17625,16469,16468,19505,17360,18160,18062,18061,17984,17312,17141,15553))
```
 - The `AND NOT(gid...)` currently filters out the centrelines of Greenwood Ave north of Danforth.

#### Volume Label Layer Rules / Print Composer Map Items
Map Item|Rules/Description
--------|-----------------
Main|(1:40,000)<br>No labels of Gardiner Expressway<br>No labels within void_box geometry<br>No labels for select streets
Downtown (Inset A)|(1:15,000)<br>No labels of any Expressway
Gardiner (Inset B)|(1:30,000)<br>Only labels of Expressways
Lake Shore (Inset C)|(approx. 1:30,000)<br>Only labels of Lake Shore Blvd

 - The Main map view currently filters out Dovercourt, Cosburn, Drumsnab, Castle Frank, Millwick, and Greenwood north of Danforth.
