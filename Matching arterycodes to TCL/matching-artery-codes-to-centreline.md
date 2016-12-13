# Matching arterycodes to centreline
## 1. Create geometry for arterycodes based on fnode, tnode
**create-table-arteries.sql**
result: aharpal.arteries

CREATE table not_matched in prj_volume

Geocode lines and segments according to location names in **match.py**

update geometry based on updated coordinates: **update-table-arteries.sql**

## 2. Map arterycodes to centreline
Table: prj_volume.artery_tcl (**create-table-artery_tcl.sql**)

Step 1: Geocode/String matching for features with no geometry information
	1. extract street names and number(if exists) match centreline segments based on street number and name
	2. for laneways: fuzzy string match names
	3. Geocode line segments and point locations that have no geometry information and are not matched in 1&2
	
Step 2: Node/Spatial match for segments with complete geometry
	1. match fnode,tnode of arterycode and centreline segments
	2. calculating Hausdorff distance between artercode segment and centreline segment and match to the closest one

Step 3: spatial+direction match for segments with only one node 
	1. Find closest line to the point and check segment direction and side of street and assign centreline_id
		
Step 4: Node+Spatial match for turning movement count locations
	1. match fnode/tnode with centreline
	2. for unmatched nodes, create a buffer around the point(intersection) and find the intersecting centreline segment and assign direction to them
	
	
Case|Actual Geometry Type|Geometry type by matching nodes|Method|Script|Matched
----|--------------------|-------------------------------|------|------|-------
1|Line|Line|match fnode,tnode or calculating distance based on Hausdorff distance|**match-segment-arterycodes.sql**|20457
2|Line|Null|Match street name and number|**match.py**|geocode 34 segments as points, match 34 segments, geocode 123 points, 20 failed
3|Line|Point|find closest line and check segment direction|**match-segments-w-missing-point.sql**|match 408 segments, 5 failed
4|Point|Null|Geocode|**match.py**|79 failed because of projection misalignment
5|Point|Point|Create buffer around intersection and create records for all possible combinations of side and direction|**artery-tmc.sql**|4688 matched by node_id, 197 matched spatially