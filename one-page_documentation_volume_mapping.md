This document provides an overview of the methodology for mapping raw turning movement count (TMC) and automatic traffic recorder (ATR) count data to the [City of Toronto's Centreline](http://www1.toronto.ca/wps/portal/contentonly?vgnextoid=9acb5f9cd70bb210VgnVCM1000003dd60f89RCRD) segments.

## Process
The following diagram outlines the process for transforming raw TMC and ATR data mapped to the City's current node and segment geographic system, FLOW, to a single table consisting of all count data mapped to the City's centreline system.
Color Schema:  
 - **Orange**: Original tables from FLOW, consisting of raw count and geometry data.
 - **White**: Intermediate tables used for processing and transforming the data.
 - **Green**: The final table, consisting of processed count data mapped to the City's centreline system.

!['process'](process.png)

## Grid Angle Correction
The City of Toronto's road network approximates a traditional grid system, with most major streets generally being classified as either east-west or north-south. The orientation of this grid, however, deviates from "true north" by approximately 16.7 degrees. As a result, the processes and/or fields related to the direction of counts or segments are first re-oriented by +16.7 degrees prior to processing.

As centrelines are reflective of non-directional segments (as opposed to vehicle counts which are directional), mapping count data to centrelines only is insufficient; the addition of a second field (`dir_bin`) indicating direction of travel is imperative to future mapping and modelling exercises.

## Data Dictionary

### centreline_volumes
Field Name|Type|Description
:----------:|:----:|-----------
volume_id|serial|autoincrementing integer assigned to each unique count record
centreline_id|integer|foreign key to `centreline`
dir_bin|integer|quasi-binary value (-1 or 1) indicating direction of count (see #Grid-Angle-Correction)
count_bin|timestamp|date and time of the count
volume|integer|volume 
count_type|integer|1 for ATR counts, 2 for TMC counts
