# Spatial Extrapolation

## Purpose
To fill in gaps in the City of Toronto's count program in order to provide a complete picture of volumes across the entire city.

## Methodology
Several methods are tested for this purpose and are detailed below.

1. Average of Nearest Neighbours  
nearest neighbours: 5 (or less) segments of the same road class that are maximum 300m (nearest point to point distance) away from the target segment

2. Linear Regression (Based on Proximity only)  
Take the volumes of the nearest 5 segments of the same road class as dependent variables (ordered by proximity).

3. Linear Regression (Directional)  
Take the volumes of the nearest 2 parallel segments and 2 perpendicular segments as dependent variables.

4. Kriging   
Implemented using the Gaussian Process model from scikit-learn  
Input: (4-dimensional) from_x, from_y, to_x, to_y (coordinate information from the start and end of the segment)  
Output: volume  
Covariance matrix is constructed based on the coordinate information of the segments in order to find the spatial correlation of volumes.

## Results

  
## Current Implementation

