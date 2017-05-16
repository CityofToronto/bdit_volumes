# Schema prj_volume Overview and Breakdown
## Tables
There are three categories of tables in the schema:
1. Reference/Raw Tables

!['prj_volume_tables_1'](prj_volume_tables_1.png)

|Table Name|Description|Notes|
|----------|-----------|-----|
|arteries|geometry information for arterycodes|source indicates the source of coordinate information (geocoding, flow, centreline, null)|
|centreline|Toronto centreline||
|centreline_dual|dual of the centreline table with the addition of directions|used for mapping 2-way volume|
|centreline_groups|grouping of centrelines sharing the same volume||
|centreline_intersections|intersections in Toronto||
|cnt_det_clean|ATR counts in flow|clean version of traffic.cnt_det, with bad records deleted or flagged|
|det_clean|TMC counts in flow|clean version of traffic.det, with bad records deleted or flagged|
|new_arterydata|new/modified arterycodes||


2. Intermediate Tables

!['prj_volume_tables_2'](prj_volume_tables_2.png)

|Table Name|Description|Notes|
|----------|-----------|-----|
|corr_dir|major corridor definition||
|tmc_turns|a table that links vehicle movement with centrelines|movement text corresponds to the columns in det/det_clean|
|actery_tcl|a table that links arterycodes (both ATR and TMC) to centrelines||
|clusters|cluster results||
|cluster_atr_volumes|volumes used for clustering|vol_weight is null for incomplete day counts indicated by the field complete_day|
|clusters_group|cluster results w.r.t. centreline groups||


3. Volume Tables

!['prj_volume_tables_3'](prj_volume_tables_3.png)

|Table Name|Description|Notes|
|----------|-----------|-----|
|centreline_volumes|ultimate volumes table|one entry for one location, datetime, type, and class|
|atr_daily_summary|daily atr volumes|from 2009-2016, aggregated complete-day data from centreline_volumes|
|tmc_daily_summary|daily tmc volumes|from 2009-2016, aggregated complete-day data from centreline_volumes|
