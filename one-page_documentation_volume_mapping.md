This document provides an overview of the methodology of mapping tmc and atr volume counts to centreline segments.

## Process
The following diagram outlines the steps taken going from raw data to one final table.  
Color Schema:  
 - Orange: Raw tables from FLOW  
 - White: Intermediate tables  
 - Green: Final table  

!['process'](process.png)

## Table content: centreline_volumes
Field Name|Type|Description
:----------:|:----:|-----------
volume_id|integer sequence|serial assigned to each volume count record
centreline_id|integer|FK to Table Centreline
dir_bin|integer|-1 if angle between start and end point of a segment (after correcting for 16.7 degrees) is between 135 and 315 degrees; +1 otherwise
count_bin|timestamp|date and time of the count
volume|integer|volume 
count_type|integer|1 for ATR counts, 2 for TMC counts

