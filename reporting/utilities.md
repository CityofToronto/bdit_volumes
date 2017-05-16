# Volume Project Utilities
The recyclable functions in the volume project

## Test if two centrelines should share the same volume
spatial_interpolation/create_function_same_volumes.sql
Usage: same_volume(centreline_id, centreline_id) returns a boolean

## Fill in count values
clustering/cln_fcn.py
Usage: fill_missing_values(profiles, new, clusterinfo) 
Input:
	profiles: a list of cluster profile centres
	new: dataframe of new,incomplete days of data with columns: count_date, centreline_id, dir_bin
	clusterinfo: dataframe returned by function fit_incomplete with columns: centreline_id, dir_bin, cluster
Output:
	a dictionary with complete day profile filled in. key: (centreline_id, dir_bin, count_date); value: list of volumes of each 15min bin.

* if complete day data is passed in new, the function does nothing and includes the original data in the returned dictionary

## Fitting incomplete day data to clusters
clustering/cln_fcn.py
Usage: fit_incomplete(centrelines, new)
Input:
	centres: a list of cluster profile centers
	new: dataframe of new, incomplete days of data. with columns: count_date, centreline_id, dir_bin, volume, time_15
Output:
	a dataframe with columns: centreline_id, dir_bin, cluster

	