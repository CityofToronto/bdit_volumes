# Evaluating Fit to Clusters

## Metric
Take minimum of distance to average profile normalized by number of points. (distance/point)

## Results
### Distribution
![histogram](img/histogram.png)
Zooming in on the highest three columns:
![histogram_zoom](img/histogram_zoom.png)
The distribution is concentrated at the lower end but the tail is long.

### Visual Validation
To make sense of the distances, a visual inspection of the profiles is shown below.
Degree of fit reduces from left to right, top to bottom.

![7-9](img/7-9.png)
![6-0](img/6-0.png)
![6-3](img/6-3.png)
![6-8](img/6-8.png)
![5-1](img/5-1.png)
![5-3](img/5-3.png)
![5-6](img/5-6.png)
![5-8](img/5-8.png)
![4-1](img/4-1.png)
![4-7](img/4-7.png)
![3-1](img/3-1.png)

The cutoff for a good fit should be drawn somewhere on the order of -5. However, the lesser fit profiles are generally locations with very low volume and therefore highly possible to see no volume during 15min and exhibits no particular time of day trend. These generally fit to a more flat distribution. which, when calculating hourly/daily volume, will give an average of the observations, which is reasonable given the circumstances. 

## Analysis
### Distance distribution by cluster
![distribution_by_cluster](img/distribution_by_cluster.png)

Cluster 2 (relatively consistent volume throughout the day) are generally lesser fit. Same is demonstrated in the profiles above, the lesser fit ones mostly belong to this cluster. 
Same goes for cluster 5, which also represents no particular up/down trend during the day.

### Distance distribution by road class
![distribution_by_roadclass](img/distribution_by_roadclass.png)

As expected, reliability of the clustering process decreases as total volume decreases because of
1. lack of pattern on roads with less volume
2. counts are more susceptible to random errors. 

### Percent Difference between Min and Second Min
![diff-min-sec-min](img/diff-min-sec-min.PNG)

Below are examples in the first bin, middle bin, and last bin, respectively.  
![diff-mins-1](img/diff-mins-1.png)
![diff-mins-2](img/diff-mins-2.png)
![diff-mins-3](img/diff-mins-3.png)

Ideally, the percent difference should be close to 1. However, the plots suggest that
1. at least two of our cluster centres should quite similar
2. some of the data is messy.
