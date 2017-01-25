CREATE OR REPLACE FUNCTION dir_binary(angle double precision)
	RETURNS INTEGER AS $$
DECLARE
	result refcursor;
BEGIN
	result := 0;
	IF (angle <= 135) OR (angle >= 315) THEN
		result := 1;
	ELSE
		result := -1;

	END IF;
	RETURN result;		
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;