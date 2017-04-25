# Matching new arterycodes from FLOW

The scripts in this folder maps new arterycodes from LIVE FLOW connection to Toronto Centreline Geometry.
New/Changed arterycodes will be stored in table prj_volume.new_arterydata. Fields that need to be extracted from FLOW are: arterycode, count_type, location, apprdir, sideofint, linkid.

### Step 1: Label new codes and create geometry  
Separate new arterycodes and changed arterycodes and create geometry for new arterycodes in prj_volume.arteries [**create_geometry.sql**](create_geometry.sql)  

### Step 2: Inspect changed arterycodes  
So far, the changes have been minor and almost all of them relate to the description. Depending on the changes made in the future, plans for updating changes will be made accordingly.

### Step 3: Match ATR arterycodes [**new_atr.sql**](new_atr.sql)  
Matching methods used here are:
1. Node id match for both start and end node 
2. start or end node id match and direction match (for centrelines that are separated by non-road segments)

The script will produce a list of unmatched segments (if any) to screen for inspection.

### Step 4: Match TMC arterycodes [**new_tmc.sql**](new_tmc.sql)  
TMC arterycodes are matched based on spatial relationship with connecting centreline segments. If the intersection involves major corridor, direction will be assigned based on the direction of the corridor. Otherwise, directions are assigned based on Azimuth.

The script will produce a list of unmatched intersections (if any) to screen for inspection. (In the current update, no mid-block TMC is found, can adjust accordingly if the problem arises in the future.)

### QC: Run [short segments (misalignment) check](../10_short-segs-corr.sql)  

