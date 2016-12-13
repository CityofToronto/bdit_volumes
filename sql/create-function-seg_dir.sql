CREATE OR REPLACE FUNCTION seg_dir(oneway_code double precision, dir text, seg geom)
	RETURNS TEXT AS $$
DECLARE
	result refcursor;
BEGIN
	result := '';
	IF (oneway_code = 0) THEN
		result := 'BOTH';
	ELSE
		IF (dir = 'EB' OR dir = 'WB') THEN
			IF (ST_X(ST_StartPoint(seg)) > ST_X(ST_EndPoint(seg))) THEN
				IF (oneway_code = 1) THEN
					result := 'EB';
				ELSE
					result := 'WB';
				END IF;
			ELSE
				IF (oneway_code = 1) THEN
					result := 'WB';
				ELSE
					result := 'EB';
				END IF;
			END IF;
		ELSE
			IF (ST_Y(ST_StartPoint(seg)) > ST_Y(ST_EndPoint(seg))) THEN
				IF (oneway_code = 1) THEN
					result := 'SB';
				ELSE
					result := 'NB';
				END IF;
			ELSE
				IF (oneway_code = 1) THEN
					result := 'NB';
				ELSE
					result := 'SB';
				END IF;
			END IF;
		END IF;
	END IF;
	RETURN result;		
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;