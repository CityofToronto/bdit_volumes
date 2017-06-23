-- Create a new table
CREATE TEMPORARY TABLE temp_det (LIKE prj_volume.det_clean);

INSERT INTO temp_det
SELECT *, NULL AS flag, NULL AS time15
FROM traffic.det
WHERE count_info_id NOT IN (SELECT DISTINCT count_info_id FROM prj_volume.det_clean);

-- Deal with the four cases where multiple count_info_ids corresponds to the same arterycode+count_date
-- so that count_info_id has one-to-one relationship with (arterycode, count_date)
DELETE FROM temp_det
WHERE count_info_id IN (9235,3868,3869);

UPDATE temp_det
SET count_info_id = 8999 
WHERE count_info_id = 8938;

-- Delete entries where all day volume = 0
-- count_info_id 21277, all peds count. can be added back if needed.
DELETE FROM temp_det
WHERE count_info_id IN
	(SELECT count_info_id
	FROM temp_det JOIN traffic.countinfomics USING (count_info_id)
	GROUP BY count_info_id
	HAVING SUM(n_cars_r+n_cars_t+n_cars_l+s_cars_r+s_cars_t+s_cars_l+e_cars_r+e_cars_t+e_cars_l+w_cars_r+w_cars_t+w_cars_l) = 0);		

-- Shift time bins from end of count period to start of count period
UPDATE 	temp_det
SET count_time = count_time - INTERVAL '15 minutes';

-- Set up a time15 column for easier querying
UPDATE temp_det
SET time15 = (EXTRACT(HOUR FROM count_time) * 4 + CEILING((EXTRACT(MINUTE FROM count_time)+(EXTRACT(SECOND FROM count_time)/60)) / 15))::int;

-- Combine rows that complement each other
-- multiple rows that belong to the same 15min bin, but only one row have data (!=0) for each column
DROP TABLE IF EXISTS temptable;	

CREATE TEMPORARY TABLE temptable (LIKE temp_det);

INSERT INTO temptable
SELECT MAX(id) AS id , count_info_id, MAKE_TIMESTAMP(1899,01,01,time15/4, time15%4*15, 0),  MAX(n_cars_r) AS n_cars_r, MAX(n_cars_t) AS n_cars_t, MAX(n_cars_l) AS n_cars_l, MAX(
       s_cars_r) AS s_cars_r, MAX(s_cars_t) AS s_cars_t, MAX(s_cars_l) AS s_cars_l, MAX(e_cars_r) AS e_cars_r, MAX(e_cars_t) AS e_cars_t, MAX(e_cars_l) AS e_cars_l, MAX(w_cars_r) AS w_cars_r, MAX(
       w_cars_t) AS w_cars_t, MAX(w_cars_l) AS w_cars_l, MAX(n_truck_r) AS n_truck_r, MAX(n_truck_t) AS n_truck_t, MAX(n_truck_l) AS n_truck_l, MAX(s_truck_r) AS s_truck_r, MAX(
       s_truck_t) AS s_truck_t, MAX(s_truck_l) AS s_truck_l, MAX(e_truck_r) AS e_truck_r, MAX(e_truck_t) AS e_truck_t, MAX(e_truck_l) AS e_truck_l, MAX(w_truck_r) AS w_truck_r, MAX(
       w_truck_t) AS w_truck_t, MAX(w_truck_l) AS w_truck_l, MAX(n_bus_r) AS n_bus_r, MAX(n_bus_t) AS n_bus_t, MAX(n_bus_l) AS n_bus_l, MAX(s_bus_r) AS s_bus_r, MAX(s_bus_t) AS s_bus_t, MAX(
       s_bus_l) AS s_bus_l, MAX(e_bus_r) AS e_bus_r, MAX(e_bus_t) AS e_bus_t, MAX(e_bus_l) AS e_bus_l, MAX(w_bus_r) AS w_bus_r, MAX(w_bus_t) AS w_bus_t, MAX(w_bus_l) AS w_bus_l, MAX(
       n_peds) AS n_peds, MAX(s_peds) AS s_peds, MAX(e_peds) AS e_peds, MAX(w_peds) AS w_peds, MAX(n_bike) AS n_bike, MAX(s_bike) AS s_bike, MAX(e_bike) AS e_bike, MAX(w_bike) AS w_bike, MAX(
       n_other) AS n_other, MAX(s_other) AS MAX, MAX(e_other) AS e_other, MAX(w_other) AS w_other
FROM temp_det
GROUP BY count_info_id, time15
HAVING COUNT(*) > 1 AND 
	COALESCE(MAX(n_cars_r),0) = COALESCE(SUM(n_cars_r), 0) AND COALESCE(MAX(n_cars_t),0) = COALESCE(SUM(n_cars_t), 0) AND COALESCE(MAX(n_cars_l),0) = COALESCE(SUM(n_cars_l), 0) AND COALESCE(MAX(s_cars_r),0) = COALESCE(SUM(s_cars_r), 0) AND 
	COALESCE(MAX(s_cars_t),0) = COALESCE(SUM(s_cars_t), 0) AND COALESCE(MAX(s_cars_l),0) = COALESCE(SUM(s_cars_l), 0) AND COALESCE(MAX(e_cars_r),0) = COALESCE(SUM(e_cars_r), 0) AND COALESCE(MAX(e_cars_t),0) = COALESCE(SUM(e_cars_t), 0) AND 
	COALESCE(MAX(e_cars_l),0) = COALESCE(SUM(e_cars_l), 0) AND COALESCE(MAX(w_cars_r),0) = COALESCE(SUM(w_cars_r) , 0) AND COALESCE(MAX(w_cars_t),0) = COALESCE(SUM(w_cars_t), 0) AND COALESCE(MAX(w_cars_l),0) = COALESCE(SUM(w_cars_l), 0) AND 
	COALESCE(MAX(n_truck_r),0) = COALESCE(SUM(n_truck_r), 0) AND COALESCE(MAX(n_truck_t),0) = COALESCE(SUM(n_truck_t), 0) AND COALESCE(MAX(n_truck_l),0) = COALESCE(SUM(n_truck_l), 0) AND COALESCE(MAX(s_truck_r),0) = COALESCE(SUM(s_truck_r), 0) AND 
	COALESCE(MAX(s_truck_t),0) = COALESCE(SUM(s_truck_t), 0) AND COALESCE(MAX(s_truck_l),0) = COALESCE(SUM(s_truck_l), 0) AND COALESCE(MAX(e_truck_r),0) = COALESCE(SUM(e_truck_r), 0) AND COALESCE(MAX(e_truck_t),0) = COALESCE(SUM(e_truck_t) , 0) AND 
	COALESCE(MAX(e_truck_l),0) = COALESCE(SUM(e_truck_l), 0) AND COALESCE(MAX(w_truck_r),0) = COALESCE(SUM(w_truck_r), 0) AND COALESCE(MAX(w_truck_t),0) = COALESCE(SUM(w_truck_t), 0) AND COALESCE(MAX(w_truck_l),0) = COALESCE(SUM(w_truck_l), 0) AND 
	COALESCE(MAX(n_bus_r),0) = COALESCE(SUM(n_bus_r) ,  0) AND COALESCE(MAX(n_bus_t),0) = COALESCE(SUM(n_bus_t), 0) AND COALESCE(MAX(n_bus_l),0) = COALESCE(SUM(n_bus_l), 0) AND COALESCE(MAX(s_bus_r),0) = COALESCE(SUM(s_bus_r), 0) AND 
	COALESCE(MAX(s_bus_t),0) = COALESCE(SUM(s_bus_t), 0) AND COALESCE(MAX(s_bus_l),0) = COALESCE(SUM(s_bus_l) ,  0) AND COALESCE(MAX(e_bus_r),0) = COALESCE(SUM(e_bus_r), 0) AND COALESCE(MAX(e_bus_t),0) = COALESCE(SUM(e_bus_t),0) AND 
	COALESCE(MAX(e_bus_l),0) = COALESCE(SUM(e_bus_l),0) AND COALESCE(MAX(w_bus_r),0) = COALESCE(SUM(w_bus_r), 0) AND COALESCE(MAX(w_bus_t),0) = COALESCE(SUM(w_bus_t) ,  0) AND COALESCE(MAX(w_bus_l),0) = COALESCE(SUM(w_bus_l), 0) AND 
	COALESCE(MAX(n_peds),0) = COALESCE(SUM(n_peds), 0) AND COALESCE(MAX(s_peds),0) = COALESCE(SUM(s_peds), 0) AND COALESCE(MAX(e_peds),0) = COALESCE(SUM(e_peds), 0) AND COALESCE(MAX(w_peds),0) = COALESCE(SUM(w_peds) ,  0) AND
	COALESCE(MAX(n_bike),0) = COALESCE(SUM(n_bike), 0) AND COALESCE(MAX(s_bike),0) = COALESCE(SUM(s_bike), 0) AND COALESCE(MAX(e_bike),0) = COALESCE(SUM(e_bike), 0) AND COALESCE(MAX(w_bike),0) = COALESCE(SUM(w_bike), 0) AND 
	COALESCE(MAX(n_other),0) = COALESCE(SUM(n_other) ,  0) AND COALESCE(MAX(s_other),0) = COALESCE(SUM(s_other), 0) AND COALESCE(MAX(e_other),0) = COALESCE(SUM(e_other), 0) AND COALESCE(MAX(w_other),0) = COALESCE(SUM(w_other),0);

DELETE FROM temp_det
WHERE (count_info_id, time15) IN 
	(SELECT count_info_id, time15
	FROM temp_det
	GROUP BY count_info_id, time15
	HAVING COUNT(*) > 1 AND 
		COALESCE(MAX(n_cars_r),0) = COALESCE(SUM(n_cars_r), 0) AND COALESCE(MAX(n_cars_t),0) = COALESCE(SUM(n_cars_t), 0) AND COALESCE(MAX(n_cars_l),0) = COALESCE(SUM(n_cars_l), 0) AND COALESCE(MAX(s_cars_r),0) = COALESCE(SUM(s_cars_r), 0) AND 
		COALESCE(MAX(s_cars_t),0) = COALESCE(SUM(s_cars_t), 0) AND COALESCE(MAX(s_cars_l),0) = COALESCE(SUM(s_cars_l), 0) AND COALESCE(MAX(e_cars_r),0) = COALESCE(SUM(e_cars_r), 0) AND COALESCE(MAX(e_cars_t),0) = COALESCE(SUM(e_cars_t), 0) AND 
		COALESCE(MAX(e_cars_l),0) = COALESCE(SUM(e_cars_l), 0) AND COALESCE(MAX(w_cars_r),0) = COALESCE(SUM(w_cars_r) , 0) AND COALESCE(MAX(w_cars_t),0) = COALESCE(SUM(w_cars_t), 0) AND COALESCE(MAX(w_cars_l),0) = COALESCE(SUM(w_cars_l), 0) AND 
		COALESCE(MAX(n_truck_r),0) = COALESCE(SUM(n_truck_r), 0) AND COALESCE(MAX(n_truck_t),0) = COALESCE(SUM(n_truck_t), 0) AND COALESCE(MAX(n_truck_l),0) = COALESCE(SUM(n_truck_l), 0) AND COALESCE(MAX(s_truck_r),0) = COALESCE(SUM(s_truck_r), 0) AND 
		COALESCE(MAX(s_truck_t),0) = COALESCE(SUM(s_truck_t), 0) AND COALESCE(MAX(s_truck_l),0) = COALESCE(SUM(s_truck_l), 0) AND COALESCE(MAX(e_truck_r),0) = COALESCE(SUM(e_truck_r), 0) AND COALESCE(MAX(e_truck_t),0) = COALESCE(SUM(e_truck_t) , 0) AND 
		COALESCE(MAX(e_truck_l),0) = COALESCE(SUM(e_truck_l), 0) AND COALESCE(MAX(w_truck_r),0) = COALESCE(SUM(w_truck_r), 0) AND COALESCE(MAX(w_truck_t),0) = COALESCE(SUM(w_truck_t), 0) AND COALESCE(MAX(w_truck_l),0) = COALESCE(SUM(w_truck_l), 0) AND 
		COALESCE(MAX(n_bus_r),0) = COALESCE(SUM(n_bus_r) ,  0) AND COALESCE(MAX(n_bus_t),0) = COALESCE(SUM(n_bus_t), 0) AND COALESCE(MAX(n_bus_l),0) = COALESCE(SUM(n_bus_l), 0) AND COALESCE(MAX(s_bus_r),0) = COALESCE(SUM(s_bus_r), 0) AND 
		COALESCE(MAX(s_bus_t),0) = COALESCE(SUM(s_bus_t), 0) AND COALESCE(MAX(s_bus_l),0) = COALESCE(SUM(s_bus_l) ,  0) AND COALESCE(MAX(e_bus_r),0) = COALESCE(SUM(e_bus_r), 0) AND COALESCE(MAX(e_bus_t),0) = COALESCE(SUM(e_bus_t),0) AND 
		COALESCE(MAX(e_bus_l),0) = COALESCE(SUM(e_bus_l),0) AND COALESCE(MAX(w_bus_r),0) = COALESCE(SUM(w_bus_r), 0) AND COALESCE(MAX(w_bus_t),0) = COALESCE(SUM(w_bus_t) ,  0) AND COALESCE(MAX(w_bus_l),0) = COALESCE(SUM(w_bus_l), 0) AND 
		COALESCE(MAX(n_peds),0) = COALESCE(SUM(n_peds), 0) AND COALESCE(MAX(s_peds),0) = COALESCE(SUM(s_peds), 0) AND COALESCE(MAX(e_peds),0) = COALESCE(SUM(e_peds), 0) AND COALESCE(MAX(w_peds),0) = COALESCE(SUM(w_peds) ,  0) AND
		COALESCE(MAX(n_bike),0) = COALESCE(SUM(n_bike), 0) AND COALESCE(MAX(s_bike),0) = COALESCE(SUM(s_bike), 0) AND COALESCE(MAX(e_bike),0) = COALESCE(SUM(e_bike), 0) AND COALESCE(MAX(w_bike),0) = COALESCE(SUM(w_bike), 0) AND 
		COALESCE(MAX(n_other),0) = COALESCE(SUM(n_other) ,  0) AND COALESCE(MAX(s_other),0) = COALESCE(SUM(s_other), 0) AND COALESCE(MAX(e_other),0) = COALESCE(SUM(e_other), 0) AND COALESCE(MAX(w_other),0) = COALESCE(SUM(w_other),0));

INSERT INTO temp_det
SELECT *
FROM temptable;

-- Delete count breaks that shows up as 0 volume
DELETE FROM temp_det
WHERE id IN 
	(SELECT id
	FROM 
	(SELECT id, (COALESCE(n_cars_r,0) + COALESCE(n_cars_t,0) + COALESCE(n_cars_l,0) + COALESCE(s_cars_r,0) + COALESCE(s_cars_t,0) + 	COALESCE(s_cars_l,0) + COALESCE(e_cars_r,0) + COALESCE(e_cars_t,0) + 
			COALESCE(e_cars_l,0) + COALESCE(w_cars_r,0) + COALESCE(w_cars_t,0) + COALESCE(w_cars_l,0) + COALESCE(n_truck_r,0) + COALESCE(n_truck_t,0) + COALESCE(n_truck_l,0) + COALESCE(s_truck_r,0) + 
			COALESCE(s_truck_t,0) + COALESCE(s_truck_l,0) + COALESCE(e_truck_r,0) + COALESCE(e_truck_t,0) + COALESCE(e_truck_l,0) + COALESCE(w_truck_r,0) + COALESCE(w_truck_t,0) + COALESCE(w_truck_l,0) + 
			COALESCE(n_bus_r,0) + COALESCE(n_bus_t,0) + COALESCE(n_bus_l,0) + COALESCE(s_bus_r,0) + COALESCE(s_bus_t,0) + COALESCE(s_bus_l,0) + COALESCE(e_bus_r,0) + COALESCE(e_bus_t,0) + COALESCE(e_bus_l,0) + 
			COALESCE(w_bus_r,0) + COALESCE(w_bus_t,0) + COALESCE(w_bus_l,0) + COALESCE(n_peds,0) + COALESCE(s_peds,0) + COALESCE(e_peds,0) + COALESCE(w_peds,0) + COALESCE(n_bike,0) + COALESCE(s_bike,0) + 
			COALESCE(e_bike,0) + COALESCE(w_bike,0) + COALESCE(n_other,0) + COALESCE(s_other,0) + COALESCE(e_other,0) + COALESCE(w_other,0)) AS total, 
		time15, count_info_id
	FROM temp_det) A
	WHERE A.total < 10 AND time15 IN (39,38,49,50,51,48,61,62,63,60));

-- Delete complete duplicates
-- Only one count_info_ids returned:1910
DROP TABLE IF EXISTS temptable;

CREATE TABLE temptable AS 
(SELECT DISTINCT ON (count_info_id, count_time) *
FROM temp_det
WHERE count_info_id IN (SELECT count_info_id
	FROM (SELECT count_info_id, timecount
		FROM (SELECT count_info_id, ARRAY[n_cars_r, n_cars_t, n_cars_l, 
		       s_cars_r, s_cars_t, s_cars_l, e_cars_r, e_cars_t, e_cars_l, w_cars_r, 
		       w_cars_t, w_cars_l, n_truck_r, n_truck_t, n_truck_l, s_truck_r, 
		       s_truck_t, s_truck_l, e_truck_r, e_truck_t, e_truck_l, w_truck_r, 
		       w_truck_t, w_truck_l, n_bus_r, n_bus_t, n_bus_l, s_bus_r, s_bus_t, 
		       s_bus_l, e_bus_r, e_bus_t, e_bus_l, w_bus_r, w_bus_t, w_bus_l, 
		       n_peds, s_peds, e_peds, w_peds, n_bike, s_bike, e_bike, w_bike, 
		       n_other, s_other, e_other, w_other] AS data, count_time::time as timecount
			FROM temp_det) A
		GROUP BY count_info_id, timecount, data
		HAVING COUNT(*) > 1) B
	GROUP BY count_info_id
	HAVING count(*) = (SELECT COUNT(DISTINCT count_time::time) FROM temp_det C WHERE B.count_info_id = C.count_info_id)));

DELETE FROM temp_det
WHERE count_info_id IN (SELECT count_info_id FROM temptable);

INSERT INTO temp_det
SELECT *
FROM temptable;

-- Delete days where there are too few counts
-- only one count_info_id - 2201
DELETE FROM temp_det
WHERE count_info_id IN (
	SELECT count_info_id
	FROM temp_det
	GROUP BY count_info_id
	HAVING COUNT(*) < 20);

-- Delete duplicate time bins with one row being all 0
DELETE FROM temp_det
WHERE (COALESCE(n_cars_r,0) + COALESCE(n_cars_t,0) + COALESCE(n_cars_l,0) + COALESCE(s_cars_r,0) + COALESCE(s_cars_t,0) + COALESCE(s_cars_l,0) + COALESCE(e_cars_r,0) + COALESCE(e_cars_t,0) + 
	COALESCE(e_cars_l,0) + COALESCE(w_cars_r,0) + COALESCE(w_cars_t,0) + COALESCE(w_cars_l,0) + COALESCE(n_truck_r,0) + COALESCE(n_truck_t,0) + COALESCE(n_truck_l,0) + COALESCE(s_truck_r,0) + 
	COALESCE(s_truck_t,0) + COALESCE(s_truck_l,0) + COALESCE(e_truck_r,0) + COALESCE(e_truck_t,0) + COALESCE(e_truck_l,0) + COALESCE(w_truck_r,0) + COALESCE(w_truck_t,0) + COALESCE(w_truck_l,0) + 
	COALESCE(n_bus_r,0) + COALESCE(n_bus_t,0) + COALESCE(n_bus_l,0) + COALESCE(s_bus_r,0) + COALESCE(s_bus_t,0) + COALESCE(s_bus_l,0) + COALESCE(e_bus_r,0) + COALESCE(e_bus_t,0) + COALESCE(e_bus_l,0) + 
	COALESCE(w_bus_r,0) + COALESCE(w_bus_t,0) + COALESCE(w_bus_l,0) + COALESCE(n_peds,0) + COALESCE(s_peds,0) + COALESCE(e_peds,0) + COALESCE(w_peds,0) + COALESCE(n_bike,0) + COALESCE(s_bike,0) + 
	COALESCE(e_bike,0) + COALESCE(w_bike,0) + COALESCE(n_other,0) + COALESCE(s_other,0) + COALESCE(e_other,0) + COALESCE(w_other,0)) = 0

	AND 

	(count_info_id, count_time::time) IN (
	SELECT count_info_id, count_time
	FROM (SELECT id, (COALESCE(n_cars_r,0) + COALESCE(n_cars_t,0) + COALESCE(n_cars_l,0) + COALESCE(s_cars_r,0) + COALESCE(s_cars_t,0) + COALESCE(s_cars_l,0) + COALESCE(e_cars_r,0) + COALESCE(e_cars_t,0) + 
			COALESCE(e_cars_l,0) + COALESCE(w_cars_r,0) + COALESCE(w_cars_t,0) + COALESCE(w_cars_l,0) + COALESCE(n_truck_r,0) + COALESCE(n_truck_t,0) + COALESCE(n_truck_l,0) + COALESCE(s_truck_r,0) + 
			COALESCE(s_truck_t,0) + COALESCE(s_truck_l,0) + COALESCE(e_truck_r,0) + COALESCE(e_truck_t,0) + COALESCE(e_truck_l,0) + COALESCE(w_truck_r,0) + COALESCE(w_truck_t,0) + COALESCE(w_truck_l,0) + 
			COALESCE(n_bus_r,0) + COALESCE(n_bus_t,0) + COALESCE(n_bus_l,0) + COALESCE(s_bus_r,0) + COALESCE(s_bus_t,0) + COALESCE(s_bus_l,0) + COALESCE(e_bus_r,0) + COALESCE(e_bus_t,0) + COALESCE(e_bus_l,0) + 
			COALESCE(w_bus_r,0) + COALESCE(w_bus_t,0) + COALESCE(w_bus_l,0) + COALESCE(n_peds,0) + COALESCE(s_peds,0) + COALESCE(e_peds,0) + COALESCE(w_peds,0) + COALESCE(n_bike,0) + COALESCE(s_bike,0) + 
			COALESCE(e_bike,0) + COALESCE(w_bike,0) + COALESCE(n_other,0) + COALESCE(s_other,0) + COALESCE(e_other,0) + COALESCE(w_other,0)) AS total, 
		count_time::time, count_info_id
		FROM temp_det) A
	GROUP BY count_info_id, count_time
	HAVING count(*) > 1 and sum(total) = MAX(total));
	
-- Take sum of irregular timestamps and respective regular 15min bin
DROP TABLE IF EXISTS temptable;
CREATE TEMPORARY TABLE temptable (LIKE temp_det);

INSERT INTO temptable
SELECT *
FROM temp_det A
WHERE (EXTRACT(second FROM count_time) != 0 or EXTRACT(minute FROM count_time)::int % 5 != 0) AND 
	time15 IN 
		(SELECT time15
		FROM temp_det B
		WHERE A.count_info_id = B.count_info_id AND EXTRACT(second FROM count_time) = 0 AND EXTRACT(minute FROM count_time)::int % 15 = 0);

DELETE FROM temp_det
WHERE id IN (SELECT id FROM temptable);

INSERT INTO temp_det
SELECT MAX(id), count_info_id, MAKE_TIMESTAMP(1899,1,1,time15/4::int, time15%4*15,0), SUM(COALESCE(n_cars_r,0)),SUM(COALESCE(n_cars_t,0)),SUM(COALESCE(n_cars_l,0)),SUM(COALESCE(s_cars_r,0)),SUM(COALESCE(s_cars_t,0)),SUM(COALESCE(s_cars_l,0)),SUM(COALESCE(e_cars_r,0)),SUM(COALESCE(e_cars_t,0) ),
	SUM(COALESCE(e_cars_l,0)),SUM(COALESCE(w_cars_r,0)),SUM(COALESCE(w_cars_t,0)),SUM(COALESCE(w_cars_l,0)),SUM(COALESCE(n_truck_r,0)),SUM(COALESCE(n_truck_t,0)),SUM(COALESCE(n_truck_l,0)),SUM(COALESCE(s_truck_r,0)),
	SUM(COALESCE(s_truck_t,0)),SUM(COALESCE(s_truck_l,0)),SUM(COALESCE(e_truck_r,0)),SUM(COALESCE(e_truck_t,0)),SUM(COALESCE(e_truck_l,0)),SUM(COALESCE(w_truck_r,0)),SUM(COALESCE(w_truck_t,0)),SUM(COALESCE(w_truck_l,0)),
	SUM(COALESCE(n_bus_r,0)),SUM(COALESCE(n_bus_t,0)),SUM(COALESCE(n_bus_l,0)),SUM(COALESCE(s_bus_r,0)),SUM(COALESCE(s_bus_t,0)),SUM(COALESCE(s_bus_l,0)),SUM(COALESCE(e_bus_r,0)),SUM(COALESCE(e_bus_t,0)),SUM(COALESCE(e_bus_l,0)),
	SUM(COALESCE(w_bus_r,0)),SUM(COALESCE(w_bus_t,0)),SUM(COALESCE(w_bus_l,0)),SUM(COALESCE(n_peds,0)),SUM(COALESCE(s_peds,0)),SUM(COALESCE(e_peds,0)),SUM(COALESCE(w_peds,0)),SUM(COALESCE(n_bike,0)),SUM(COALESCE(s_bike,0)),
	SUM(COALESCE(e_bike,0)),SUM(COALESCE(w_bike,0)),SUM(COALESCE(n_other,0)),SUM(COALESCE(s_other,0)),SUM(COALESCE(e_other,0)),SUM(COALESCE(w_other,0)), NULL AS flag, time15
FROM temptable
GROUP BY count_info_id, time15;
	
-- Aggregate records in 5min bins to 15min bins
DROP TABLE IF EXISTS temptable;
CREATE TEMPORARY TABLE temptable (LIKE temp_det);

INSERT INTO temptable
SELECT *
FROM temp_det
WHERE EXTRACT(MINUTE FROM count_time)::int%15!=0 AND flag IS NULL;

DELETE FROM temp_det
WHERE count_info_id IN (SELECT count_info_id FROM temptable);

INSERT INTO temp_det
SELECT MAX(id), count_info_id, MAKE_TIMESTAMP(1899,1,1,time15/4::int, time15%4*15,0), SUM(COALESCE(n_cars_r,0)),SUM(COALESCE(n_cars_t,0)),SUM(COALESCE(n_cars_l,0)),SUM(COALESCE(s_cars_r,0)),SUM(COALESCE(s_cars_t,0)),SUM(COALESCE(s_cars_l,0)),SUM(COALESCE(e_cars_r,0)),SUM(COALESCE(e_cars_t,0) ),
	SUM(COALESCE(e_cars_l,0)),SUM(COALESCE(w_cars_r,0)),SUM(COALESCE(w_cars_t,0)),SUM(COALESCE(w_cars_l,0)),SUM(COALESCE(n_truck_r,0)),SUM(COALESCE(n_truck_t,0)),SUM(COALESCE(n_truck_l,0)),SUM(COALESCE(s_truck_r,0)),
	SUM(COALESCE(s_truck_t,0)),SUM(COALESCE(s_truck_l,0)),SUM(COALESCE(e_truck_r,0)),SUM(COALESCE(e_truck_t,0)),SUM(COALESCE(e_truck_l,0)),SUM(COALESCE(w_truck_r,0)),SUM(COALESCE(w_truck_t,0)),SUM(COALESCE(w_truck_l,0)),
	SUM(COALESCE(n_bus_r,0)),SUM(COALESCE(n_bus_t,0)),SUM(COALESCE(n_bus_l,0)),SUM(COALESCE(s_bus_r,0)),SUM(COALESCE(s_bus_t,0)),SUM(COALESCE(s_bus_l,0)),SUM(COALESCE(e_bus_r,0)),SUM(COALESCE(e_bus_t,0)),SUM(COALESCE(e_bus_l,0)),
	SUM(COALESCE(w_bus_r,0)),SUM(COALESCE(w_bus_t,0)),SUM(COALESCE(w_bus_l,0)),SUM(COALESCE(n_peds,0)),SUM(COALESCE(s_peds,0)),SUM(COALESCE(e_peds,0)),SUM(COALESCE(w_peds,0)),SUM(COALESCE(n_bike,0)),SUM(COALESCE(s_bike,0)),
	SUM(COALESCE(e_bike,0)),SUM(COALESCE(w_bike,0)),SUM(COALESCE(n_other,0)),SUM(COALESCE(s_other,0)),SUM(COALESCE(e_other,0)),SUM(COALESCE(w_other,0)), 3 AS flag, time15
FROM temptable
GROUP BY count_info_id, time15;

INSERT INTO prj_volume.det_clean
SELECT *
FROM temp_det;
