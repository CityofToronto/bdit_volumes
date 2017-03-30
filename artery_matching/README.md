# Matching arterycodes to centreline
The scripts map arterycodes referenced in FLOW database to Toronto centreline segments for further volume analysis. The table structures and relevant fields are shown below.

**Table node**
Field Name|Type|Description|Example  
----------|----|-----------|-------  
node_id|text|identifier|N000005333
link_id|bigint|8 digits corresponding to the ones in linkid of table arterydata and the intersection ids in centreline|14015169
x_coord|double precision|x coordinate of the node|
y_coord|double precision|y coordinate of the node|
  
**Table arterydata**

Field Name|Type|Description|Example  
----------|----|-----------|-------  
arterycode|bigint|primary key, unique identifier|5123  
apprdir|text|direction of this segment|Northbound  
sideofint|text|side of intersection|E  
location|text|text description of the segment/intersection|Yonge St N/B N of Adelaide St  
linkid|text|8digits@8digits, 8 digits being the start and end node_ids, only 8 digits if it refers to an intersection only|  
count_type|text|indicates count type('R','P' refer to turning movement counts, '24 HOUR' refers to automatic counts)|'R'  

*Note:* There are two types of geometry that arterycodes could refer to: line segment and intersection. Single intersection arterycodes are used for recording turning movement counts only. All other counts are recorded on line segments. Geometry of arterycodes is inferred from linkid. 

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
De-couple the linkid field in **Table arterydata** and match with *linkid* from **Table node**    
Script:**create-table-arteries.sql**   
Result: **Table prj_volume.arteries**   

### Step 2:   
Geocode case 3&5 according to location names in **3. geocode-and-match-street-number.py**  

Num|Case|Number Records|Number Matched|Number Failed
---|----|--------------|:--------------:|:-------------:
3|Line segments no nodes matched|73|34|5
5|Intersection not matched|138|123|15

### Step 3:   
Make POSTGIS geometry objects based on (updated) coordinates: **4. update-table-arteries.sql**

**Table prj_volume.arteries**

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

Step 1: Match based on node_ids *(case 1)*
1. match fnode_id and tnode_id in prj_volume.arteries with from_intersection_id and to_intersection_id in prj_volume.centreline
2. when multiple centreline segments have the same nodes, a match is found based on similarity of street names

Step 2: Geocode/String matching for features with no geometry information **3. geocode-and-match-street-number.py**  *(case 5)*
1. extract street names and number(if exists) match centreline segments based on street number and name
2. for laneways: fuzzy string match names
3. Geocode line segments and point locations that have no geometry information and are not matched in case 1
	
Step 3: Node/Spatial match for segments with complete geometry **(5. match-atr-spatially.sql)**
1. match (fnode or tnode) and direction, take the longest qualifying segment *(case 2)*
2. calculating Hausdorff distance<sup>1</sup> between artercode segment and centreline segment and match to the closest one *(case 12)*

Step 4: spatial+direction match for segments with only one node **(6. match-atr-seg-w-missing-point.sql)**
1. if the point coincides with a centreline node, find the correct segment attached to the node based on direction *(case 3)*
2. find closest line to the point and check segment direction and side of street and assign centreline_id *(case 4)*
		
Step 5: Node+Spatial match for turning movement count locations **(7. match-tmc-arterycodes.sql)**
1. match fnode/tnode with centreline. For unmatched nodes, create a buffer around the point(intersection) and find the intersecting centreline segment
2. assign directions to them (typically 8 approaches with exceptions of midblock counts and special intersections)
	
Step 6: Quality Control and Corrections **(8. combine_correction_files.py, 9. update-match.sql, 10. short-segs-corr.sql)**
1. errors are spotted in quality control and recorded in csv files
2. csv files are combined and uploaded to table artery_tcl_manual_corr
3. update table artery_tcl with table artery_tcl_manual_corr
4. to fix the [misalignment of roads](https://github.com/CityofToronto/bdit_volumes/blob/master/Matching%20arterycodes%20to%20TCL/TMC%20issues%20log.md), segments shorter than 25m and not intercepted by a planning boundary are checked with the raw count table to see if there are counts in all directions, if so, these segments are included and directions reassigned.


Case|Actual Geometry Type|Geometry type in database|Method|Script|Number|Number(after correction)|
----|--------------------|-------------------------|------|------|------|------------------------
1|Line|Line|Match fnode,tnode|**match-segment-arterycodes.sql**|17910|17906
2|Line|Line|Match (fnode *OR* tnode) *AND* direction, choose the longest qualifying segment|**match-segment-arterycodes.sql**|1961|1934
3|Line|Point|Match to centreline intersection and check azimuth/approach|**match-segments-w-missing-point.sql**|257|244
4|Line|Point|Find closest line and check segment direction|**match-segments-w-missing-point.sql**|91|86
5|Line|Null|Match street name and number|**match.py**|182|175
6|Point(intersection)|Point|Match fnode_id or tnode_id on centreline segments|**match-tmc-arterycodes.sql**|4664|4392
7|Point(intersection)|Point|Snap to the closest intersection within 30m in centreline|**match-tmc-arterycodes.sql**|115|108
8|Point(not intersection)|Point|Create 15m buffer around point and create records for all possible combinations of side and direction|**match-tmc-arterycodes.sql**|98|96
9|Point/Line|Null|Fail to have geometry/match|130|1
10|||Manually Corrected||511
11|||Outside of Toronto boundary/ Doesn't exist in tcl|44|83
12|Line|Line|[taking records failed to match from case 2] Calculating Hausdorff distance|**match-segment-arterycodes.sql**|234|193
 
1. Definition of Hausdorff distance: maximum distance of a set to the nearest point in the other set.
