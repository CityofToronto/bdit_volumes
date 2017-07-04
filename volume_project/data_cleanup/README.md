# cnt_det_clean (FLOW ATR DATA)

## MODIFIED IN cnt_det_clean
**[cleanup_anomalies.sql](cleanup_anomalies.sql)**  

1. Shift time bins so that all timestamps represent the start of the count period
2. Set speed_class to NULL for non-speed counts (so that in future queries, speed_class will not be grouped by)

## DELETED IN cnt_det_clean
**[cleanup_anomalies.sql](cleanup_anomalies.sql)**  

3. Delete records where all day volume = 0
4. Remove duplicate entries (exact same volume profile for one day at one location)
5. Remove Entries where volume between 8am and 12am is 0 AND (whole day count is present OR less than 8h count)

## FLAGGED IN cnt_det_clean
**[flag_anomalies.sql](flag_anomalies.sql)**  

6. Hourly records in 15 min bins (one entry for an hour, 0 volumes in other 15 min bins) (Flag 3)
7. Less than 32 records (8h) in one day (Flag 1)
8. Double/triple/quadruple loading (volumes different) (Flag 2) 
9. Compute and Filter Daily Volume based on caps on Road Class (Flag 4) and median/stddev (Flag 5)   
	
## TO BE DECIDED:
1. Delete duplicates and get the good profile out instead of ignoring them
```sql
SELECT count_info_id, arterycode, count_date, timecount::time, speed_class
FROM traffic.countinfo join prj_volume.cnt_det_clean using (count_info_id)
WHERE (arterycode, count_date, timecount::time, speed_class) IN
	(SELECT arterycode, count_date, timecount::time, speed_class
	FROM traffic.countinfo JOIN prj_volume.cnt_det_clean USING (count_info_id)
	GROUP BY arterycode, count_date, timecount::time, speed_class
	HAVING COUNT(count)>1)
ORDER BY arterycode, count_date, timecount::time, speed_class
```
2. Put same day ATR and SPEED counts side by side and compare
```sql
SELECT *
FROM (SELECT arterycode, count_date, sum(count) as count
	FROM traffic.countinfo join prj_volume.cnt_det_clean using (count_info_id)
	WHERE category_id IN (3,4)
	GROUP BY count_info_id, arterycode, count_date) A


	JOIN 

	(SELECT arterycode, count_date, sum(count)
	FROM traffic.countinfo join prj_volume.cnt_det_clean using (count_info_id)
	WHERE category_id NOT IN (3,4)
	GROUP BY arterycode, count_date, count_info_id) B

	USING (arterycode, count_date)
```
3. Investigate loadings where only one speed bin has value in all time bins (262 count_info_ids)
```sql
SELECT count_info_id, arterycode, count_date
FROM (SELECT count_info_id, arterycode, count_date, timecount::time
	FROM traffic.countinfo join prj_volume.cnt_det_clean using (count_info_id)
	GROUP BY count_info_id, arterycode, count_date, timecount::time
	HAVING sum(count) = max(count) AND count(count) > 1) A
GROUP BY count_info_id, arterycode, count_date
HAVING COUNT(*)  = (
	SELECT count(DISTINCT timecount::time)
	FROM prj_volume.cnt_det_clean
	WHERE count_info_id = A.count_info_id)
ORDER BY arterycode, count_date
```  
4. Compute range and std of counts at one location in one 15 minute bin across counts from different days

```sql
SELECT arterycode, count_time, max(count), min(count), avg(count),stddev(count)
FROM (
	SELECT sum(count) AS count, timecount::time as count_time, arterycode
	FROM prj_volume.cnt_det_clean JOIN traffic.countinfo USING (count_info_id)
	WHERE flag IS NULL AND count_date >= '2010-01-01'
	GROUP BY arterycode, count_date, timecount::time
	) A
GROUP BY arterycode, count_time
HAVING (max(count)-min(count)) > avg(count) AND max(count)>10
ORDER BY stddev(count) DESC 
```
 - appears to be hourly volume (combination of very big numbers and 0 volumes in one day; but daily sum can be ridiculous too) [14900,02:30]
 - a lot of counts with a few very weird days [20549,04:15]
 - appears to be just high variance segment?? 
 - full day of count but very ridiculous daily total [2055,20141009]

# det_clean (FLOW TMC DATA)
**[cleanup_tmc.sql](cleanup_tmc.sql)**  

## MODIFIED IN det_clean

1. Shift time bins so that all timestamps represent the start of the count period
2. Combine rows that complement each other. (Multiple rows belong to the same count bin, but only one non-zero volume for each column)
3. Sum rows that belong to the same 15min bin but volumes are recorded at multiple irregular timestamps (Flag 2)
4. Aggregate 5min binned volume to 15min bins


## DELETED IN det_clean

5. Delete records so that count_info_id and (arterycode, count_date) have one-to-one relationship
6. Delete identical duplicates 
7. Delete days with <5h count
8. Delete records where all-day car volume = 0
9. Delete records that belong to designated break time and volume = 0 (9:30-10:00, 12:00-13:00, 15:00-16:00)
10. Delete duplicate count bins and one or more have no volume (Multiple rows belong to the same count bin, but one entire row is zero)
11. Delete records where any car turning movement is NULL

## FLAGGED IN det_clean 
**[flag_tmc.sql](flag_tmc.sql)** 
 
* Smaller number takes precedence
12. Volume recorded at a irregular timestamp but a regular 15min bin is nonexistent (Flag 1)
13. Duplicate time bins (Flag 3)
14. Count bin in break time and count is 2 stddev from median/stddev (Flag 4)
15. Hourly records instead of 15min records (Flag 5)
16. Random drops due to human error (based on 1st and 2nd derivatives) (Flag 6)