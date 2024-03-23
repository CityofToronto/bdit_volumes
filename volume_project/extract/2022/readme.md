# Extracting 2022 Volume Data for TEPS

We've done this pretty much annually, now we have some documentation!

We are extracting:
- ATR data from Miovision
- Short Term ATR counts
- RESCU data

All volume counts will be matched to the 2022-07-05 version of the centreline.

Some recent precedents (in other repos) to refer to:
- This [data request](https://github.com/Toronto-Big-Data-Innovation-Team/bdit_data_requests/tree/master/volumes/atr/miovision/2023-02-03_UofT_miovision_to_centreline_update)
- This assessment of [RESCU data](https://github.com/CityofToronto/bdit_data-sources/tree/master/volumes/rescu/date_evaluation)

All volume tables were prepared using this format:
- centreline_id (based on `gis.centreline_20220705`)
- dir_bin (1 for north or east, -1 for south or west)
- count_bin (the 15 minute datetime bin)
- volume (aka the count)
- count_type (`1` for 24 hour RESCU counts, `3` for classifications, `4` for speed volume)
- speed_class (`null` for classifications)
- vehicle_class (`null` for speed volume)
- volume_id (`count_info_id` for the ATR tables, the unique id in the volume table for other table types)

## Miovision Data
There are two steps to this process:
1. Rerun the miovision to centreline conflation table with the 2022-07-05 centreline data (see [this file](miovision_sqls/miovision_atr_2022.sql))
2. Rerun this [data request](https://github.com/Toronto-Big-Data-Innovation-Team/bdit_data_requests/tree/master/volumes/atr/miovision/2023-02-03_UofT_miovision_to_centreline_update) with the 2022-07-05 miovision to centreline conflation table (see [this file](miovision_sqls/miovision_centreline_20220705.sql))

After the data request is rerun, check to see if there are any instances where the `centreline_id` is null and the `volume` is greater than 0: 
```
SELECT * FROM mio_atr_centreline_20220705 WHERE centreline_id IS NULL AND volume > 0
```
There are also no notes in the `anomalous_range_notes` field, but miovision data that was marked as anomalous (where `project_level IN ('do-not-use', 'questionable')`) was omitted. The only non "do not use" or "questionable" entries in the anomalous range table in 2022 are for bicycles, which are not included in this request.

## Short Term ATR counts
The table `traffic.arteries_centreline` is updated daily. Only 23 Of the unique arterycode and centreline_id combinations in 2022 did not have a `gis.centreline_20220705` equivalent (out of 1191), so no further centreline mapping was needed.

Two types of short term counts were provided:
- speed volume data was extracted using [this code](short_term_count_sqls/speedvol.sql)
- classification data was extracted using [this code](short_term_count_sqls/classvol.sql)

The table `scannon.oti_class` was created using [this code](short_term_count_sqls/oti_class.sql) to map classification id numbers to their descriptions.

## RESCU Data
After assessing the lane stats, the minimum valid volumes should stay the same as 2021:
 - Lakeshore weekends and weekdays - 2000 vehicles per lane
 - Gardiner Expressway weekends and weekdays - 10000 vehicles per lane
 - DVP weekdays - 15000 per lane
 - DVP weekends - 10000 per lane
Note: there were no detectors with volume counts on the Allen Expressway.

The following three sql files were used to determine volume thresholds (and which detectors met the thresholds on which days):
- [01_lane_stats.sql](rescu_sqls/01_lane_stats.sql) calculates volume counts by lane by day type (weekday or weekend)
- [02_daily_cor_stats.sql](rescu_sqls/02_daily_cor_stats.sql) calculates daily volumes by corridor (which is used to make the graphs in Excel)
- [03_vol_threshold_check.sql](rescu_sqls/03_vol_threshold_check.sql) determines the days and detectors that had counts at or above the thresholds

The structure of RESCU data within the `bigdata` database changed significantly from 2023 to 2024 (for the better)!!! However, one unfortunate consequence was that there was no link between the rescu detectors and the `centreline_id`, so this was recreated (for detectors with volume counts above the thresholds only) using [this code](rescu_sqls/rescu_centreline).

Two volume counts were prepared based on RESCU data:
- [rescu_counts_centreline.sql](rescu_sqls/rescu_counts_centreline.sql) contains total volume counts in 15 minute bins
- [rescu_counts_centreline.sql](rescu_sqls/rescu_spdvol_centreline.sql) contains speed volume counts in 15 minute bins