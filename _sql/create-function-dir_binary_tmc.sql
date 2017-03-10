CREATE OR REPLACE FUNCTION dir_binary_tmc(angle double precision, dir text)
	RETURNS INTEGER AS $$
DECLARE
	result smallint;
	aligned smallint;
BEGIN
	result := 0;
	IF (angle <= 135) OR (angle >= 315) THEN
		result := 1;
	ELSE
		result := -1;

	END IF;

	IF (dir = 'NB') THEN
		IF (angle < 90 OR angle > 270) THEN
			aligned := 1;
		ELSE
			aligned := -1;
		END IF;
	ELSIF (dir = 'SB') THEN
		IF (angle > 90 AND angle < 270) THEN
			aligned := 1;
		ELSE
			aligned := -1;
		END IF;
	ELSIF (dir = 'EB') THEN
		IF (angle < 180 OR angle > 360) THEN
			aligned := 1;
		ELSE
			aligned := -1;
		END IF;
	ELSIF (dir = 'WB') THEN
		IF (angle > 180 AND angle < 360) THEN
			aligned := 1;
		ELSE
			aligned := -1;
		END IF;
	END IF;
		
	RETURN result*aligned;		
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;