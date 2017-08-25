# Volume Count Extraction and Estimation (Factor-based)

Extract volume counts wherever possible and estimate volumes based on spatial relationships and temporal (TOD, seasonal, yearly) factors.

## Process:
![volume_model_3.png](volume_model_3.png)

## Implementation:
The figure below illustrates implementation of the algorithm. Each box represents a function in the script and detauks on all functions are documented in the sections below.
![volume_model_4.png](volume_model_4.png)
### Core Functions
* calc_all_TO(self, start_number, year, freq)
  - iterates through all centreline_id/group_number, retrieves requested information and uploads to the database
* get_volume(self, identifier_value, dir_bin, year, month=None, day=None, hour=None, outtype='volume')
  - high level get volume function that processes input and calls appropriate functions (get_volume_annualavg/get_volume_day_hour) for information.
* get_volume_annualavg(self, tmc, atr, identifier_value, dir_bin, year)
  - calculates annual average weekday daily traffic
* get_volume_day_hour(self, tmc, atr, identifier_value, dir_bin, year, month, day, hour=None)
  - calcualtes daily total/profile based on information passed in
* upload_to_daily_total(self, volumes, truncate=True)
  - uploads to prj_volume.daily_total_by_month
* upload_to_monthly_profile(self, volumes, truncate=True)
  - uploads to prj_volume.daily_profile_by_month
* upload_to_aadt(self, volumes, truncate=True)
  - uploads to prj_volume.aadt
  
### Helping functions
* calc_date_factors(self, year, month, dates, identifier_value, dir_bin)
  - Monthly Factor: Applied when the requested location is counted in another month. Relative weights of each month compared to the average. Only locations with counts in all month of a year is used. If the location and year requested were not counted, an average profile derived from all locations is used. (**average profile is heavily skewed towards patterns with rescu stations as it requires a location to be counted in every month of the year**)
  - Yearly Weights: Applied when the count is >5 years away from the requested date because of the decreased relativity. When absolute year difference is less than 5, weight = 1; from the sixth year, the weight linearly decreases to 0.5 (weight for the most distant year). Volumes are calculated based on these normalized weightings.
* fill_in(self, records, hour=None)
  - Utilize clustering information to fill in the TOD profile. If the location is classified before with complete-day counts, the fill-in procedure will use the profile identified there. If the location does not have a complete-day count classification, profile will be classified based on the incomplete counts. 
* get_clusterinfo(self)
  - Get clustering information from the database.
* get_relevant_counts(self, identifier_value, dir_bin, year)
  - Retrieve all relevant counts from the database: same centreline group, any time.
* refresh_monthly_factors(self)
  - refreshes monthly factors table in the database based on the current version of prj_volume.centreline_volumes
* slice_data(self, df1, df2, args)
  - Slice data based on the criteria passed in. 
  - If all args is empty, returns original.
* take_weighted_average(self, tmc, atr, agglvl, factors_date=None)
  - Take weighted average of the counts. 
  - If factors are omitted, a normal average will be taken.
### Testing functions
* testing_hourly(self)
* testing_daily(self)
  - These are testing functions that outputs numbers to logging file to compare with the commented value at the end of each function call.
  - Testing function not used because a lot of these are estimated,approximate values.

### Improvements
* More robust yearly weights calculation.
