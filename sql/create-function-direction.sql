CREATE OR REPLACE FUNCTION direction(angle double precision)
	RETURNS TEXT AS $$
DECLARE
	result refcursor;
BEGIN
	angle := angle + 17.5;
	result := '';
	IF (angle >= 60 AND angle <= 120) OR (angle >= 240 AND angle <= 300) THEN
		result := 'E/W';
	ELSIF (angle >= 150 AND angle <= 210) OR angle >= 330 OR angle <= 30 THEN
		result := 'N/S';
	ELSE
		result := 'DIAG';
	END IF;
	RETURN result;		
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;