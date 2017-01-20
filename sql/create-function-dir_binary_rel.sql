CREATE OR REPLACE FUNCTION dir_binary_rel(angle_a double precision, angle_b double precision)
	RETURNS INTEGER AS $$
DECLARE
	result integer;
	diff numeric;
BEGIN
	result := 0;
	diff := abs(angle_a - angle_b);
	IF (angle_a <= 135) OR (angle_a >= 315) THEN
		result := 1;
	ELSE
		result := -1;
	END IF;


	IF (angle_b IS NULL) THEN
		result := 99;
	ELSIF (diff < 40 OR diff > 320) THEN
		result := result * 1;
	ELSIF (diff > 140 AND diff < 220) THEN
		result := result * -1;
	ELSE
		result := 0;
	END IF;

	
	RETURN result;		
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;