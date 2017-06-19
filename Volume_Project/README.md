# Traffic Volumes Modelling Project - Usage
This repository contains the scripts for and data tables needed to get from FLOW datatables to a complete volume map based on the Toronto centreline. 

## 1. Purpose
Develop a methodology for estimating traffic volumes on road segments in the City of Toronto.

## 2. Data Tables and Preprocessing

### 2.1 FLOW (traffic schema)
Tables in the traffic schema should be up-to-date by running scipts in [update_db](preprocessing/update_db/). Required tables are traffic.cnt_det, traffic.det, traffic.countinfo, traffic.countinfomics.

### 2.2 Centreline 
Table prj_volume.centreline should be up-to-date. 

### 2.3 Preprocessing
The procedures outlined below do not need to be refreshed whenever new data come in. They only need to be refreshed once the centreline table gets updated.
#### 2.3.1 [Corridor Definition](preprocessing/corridors/)
Corridors should be defined and stored in prj_volume.corr_dir

#### 2.3.2 [Centreline Grouping](preprocessing/spatial_interpolation)
Groups centrelines and directions that share the same volume and assign a unique group_number. 

## 3. Functionality
Based on the new information, some or all of the functions below should be re-run from the master script [run.py](run.py). Detailed description about each procedure can be found under the linked folders. 

### 3.1 [Arterycode Matching] (arterycode_matching/)
### 3.2 [Clean up Counts] (data_cleanup/)
### 3.3 [Populate Volume Tables] (populate_datatables/)
### 3.4 [Clustering] (clustering/)
### 3.5 [Estimate Volumes (Temporal Extrapolation)] (estimation_extraction/)
### 3.6 [Estimate Volumes (Spatial Extrapolation)] (spatial_extrapolation/)
