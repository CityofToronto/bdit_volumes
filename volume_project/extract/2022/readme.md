# Extracting 2022 Volume Data for TEPS

We've done this pretty much annually, now we have some documentation!

We are extracting:
- ATR data from Miovision
- ATR counts from MOVE
- RESCU data

All volume counts will be matched to the 2022-07-05 version of the centreline.

Some recent precedents (in other repos) to refer to:
- This [data request](https://github.com/Toronto-Big-Data-Innovation-Team/bdit_data_requests/tree/master/volumes/atr/miovision/2023-02-03_UofT_miovision_to_centreline_update)
- This assessment of [RESCU data](https://github.com/CityofToronto/bdit_data-sources/tree/master/volumes/rescu/date_evaluation)

## Miovision Data
There are two steps to this process:
1. Rerun the miovision to centreline conflation table with the 2022-07-05 centreline data (see [this file](miovision_sqls/miovision_atr_2022.sql))
2. Rerun this [data request](https://github.com/Toronto-Big-Data-Innovation-Team/bdit_data_requests/tree/master/volumes/atr/miovision/2023-02-03_UofT_miovision_to_centreline_update) with the 2022-07-05 miovision to centreline conflation table (see [this file](miovision_sqls/miovision_centreline_20220705.sql))

After the data request is rerun, check to see if there are any instances where the `centreline_id` is null and the `volume` is greater than 0: 
```
SELECT * FROM mio_atr_centreline_20220705 WHERE centreline_id IS NULL AND volume > 0
```
There are also no notes in the `anomalous_range_notes` field, but miovision data that was marked as anomalous (where `project_level IN ('do-not-use', 'questionable')`) was omitted. The only non "do not use" or "questionable" entries in the anomalous range table in 2022 are for bicycles, which are not included in this request.


## RESCU Data
After assessing the lane stats, the minimum valid volumes should stay the same as 2021:
 - Lakeshore weekends and weekdays - 2000 vehicles per lane
 - Gardiner Expressway weekends and weekdays - 10000 vehicles per lane
 - DVP weekdays - 15000 per lane
 - DVP weekends - 10000 per lane
Note: there were no detectors with volume counts on the Allen Expressway.