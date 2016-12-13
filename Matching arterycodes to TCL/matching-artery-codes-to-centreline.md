# Matching arterycodes to centreline
The scripts map arterycodes referenced in FLOW database to Toronto centreline segments for further volume analysis. The table structures and relevant fields are shown below.

**Table arterydata**

Field Name|Type|Description|Example  
----------|----|-----------|-------  
arterycode|bigint|primary key, unique identifier|5123  
apprdir|text|direction of this segment|Northbound  
sideofint|text|side of intersection|E  
location|text|text description of the segment/intersection|Yonge St N/B N of Adelaide St  
linkid|text|8digits@8digits, 8 digits being the start and end node_ids, only 8 digits if it refers to an intersection only|  

*Note:* There are two types of geometry that arterycodes could refer to: line segment and intersection. Single intersection arterycodes are used for recording turning movement counts only. All other counts are recorded on line segments. There is no explicit indication of the geometry that each arterycode refers to. This information is extracted from the format of the linkids.

**Table centreline**

Field Name|Type|Description|Example  
----------|----|-----------|-------  
centreline_id|bigint|primary key, unique identifier|1000215  
linear_name_full|text|full name of the street that the segment lies on|Don Mills Rd  
from_intersection_id|bigint|intersection id at from node|  
to_intersection_id|bigint|intersection id at to node|  
(low/high)_num_(odd/even)|int|low/high numbers of the even/odd sides of the street|35  

## 1. Create geometry for arterycodes based on end nodes
### Step 1:   
De-couple the linkid field in **Table arterydata** and match with *from_intersection_id* and *to_intersection_id* from **Table centreline**    
Script:**create-table-arteries.sql**   
Result: **Table aharpal.arteries**   

### Step 2:   
Geocode case 3&5 according to location names in **match.py**  

Num|Case|Number Records|Number Matched|Number Failed
---|----|--------------|:--------------:|:-------------:
3|Line segments no nodes matched|73|34|5
5|Intersection not matched|138|123|15

Line segments are matched to point locations. There are 34 others that are matched directly to centreline_id by street name and number which clears the need to geocode. 

### Step 3:   
Make POSTGIS geometry objects based on (updated) coordinates: **update-table-arteries.sql**

**Table aharpal.arteries**

Field Name|Type|Description
----------|----|-----------
arterycode|bigint|from Table arterydata
fnode_id|bigint|from linkid
tnode_id|bigint|from linkid
fx,fy|double|x,y coordinates of fnode_id in MTM projection (2019)
tx,ty|double|x,y coordinates of tnode_id in MTM projection (2019)
ty|double|y coordinate of tnode_id in MTM projection (2019)
loc|Geometry|ST_Point or ST_Linestring

**Record Breakdown:**

Num|Case|#Records(before geocoding)|#Records(after geocoding)
---|----|:--------------:|:---------------:
1|Line segments both nodes matched|20260|20294
2|Line segments only one node matched|413|447
3|Line segments no nodes matched|73|5
4|Intersection matched|4802|4925
5|Intersection not matched|138|15
 |TOTAL|25686|25686
 
## 2. Map arterycodes to centreline_ids
Result Table: prj_volume.artery_tcl **(create-table-artery_tcl.sql)**   
**CONSTRAINT primary key (arterycode,direction,sideofint)   
**Table prj_volume.artery_tcl**

Field Name|Type|Description
----------|----|-----------
arterycode|bigint|from arterydata
direction|text|from arterydata (field apprdir)
sideofint|text|from arterydata
centreline_id|bigint|from centreline

Step 1: Geocode/String matching for features with no geometry information **(match.py)**
1. extract street names and number(if exists) match centreline segments based on street number and name
2. for laneways: fuzzy string match names
3. Geocode line segments and point locations that have no geometry information and are not matched in 1&2
	
Step 2: Node/Spatial match for segments with complete geometry **(match-segment-arterycodes.sql)**
1. match fnode,tnode of arterycode and centreline segment
2. calculating Hausdorff distance between artercode segment and centreline segment and match to the closest one

Step 3: spatial+direction match for segments with only one node **(match-segments-w-missing-point.sql)**
1. Find closest line to the point and check segment direction and side of street and assign centreline_id
		
Step 4: Node+Spatial match for turning movement count locations **(artery-tmc.sql)**
1. match fnode/tnode with centreline
2. for unmatched nodes, create a buffer around the point(intersection) and find the intersecting centreline segment and assign direction to them
	
Case|Actual Geometry Type|Geometry type by matching nodes|Method|Script|Matched|Failed
----|--------------------|-------------------------------|------|------|-----|-------
1|Line|Line|Match fnode,tnode|**match-segment-arterycodes.sql**|17841|N/A
2|Line|Line|Calculating Hausdorff distance|**match-segment-arterycodes.sql**|2419|N/A
3|Line|Point|Match to centreline intersection and check azimuth/approach|**match-segments-w-missing-point.sql**|???|?
4|Line|Point|Find closest line and check segment direction|**match-segments-w-missing-point.sql**|408|5
5|Line|Null|Match street name and number|**match.py**|34|N/A
6|Point|Point|Match fnode_id or tnode_id on all centreline segments|**match-tmc-arterycodes.sql**|4688|N/A
7|Point|Point**|Create buffer around intersection and create records for all possible combinations of side and direction|**match-tmc-arterycodes.sql**|196|80
8|Point|Null|@_@??|**match.py**|0|15

**123 records obtained geometry from google geocoding API and 153 obtained geometry from **Table centreline**. Failed matches result from misalignment between the projections. matched ones need to be checked carefully.
 
