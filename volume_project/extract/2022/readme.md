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

## RESCU Data
After assessing the lane stats, the minimum valid volumes should stay the same as 2021:
 - Lakeshore weekends and weekdays - 2000 vehicles per lane
 - Gardiner Expressway weekends and weekdays - 10000 vehicles per lane
 - DVP weekdays - 15000 per lane
 - DVP weekends - 10000 per lane
Note: there were no detectors with volume counts on the Allen Expressway.