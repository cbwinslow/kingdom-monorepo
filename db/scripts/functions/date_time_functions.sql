-- PostgreSQL Enhanced Date/Time Functions
-- Wrapper functions that make date/time operations easier and safer

-- Function: Safe date parsing with fallback
CREATE OR REPLACE FUNCTION safe_parse_date(
    date_string TEXT,
    format_string TEXT DEFAULT 'YYYY-MM-DD',
    fallback_date DATE DEFAULT NULL
)
RETURNS DATE AS $$
BEGIN
    IF date_string IS NULL OR smart_trim(date_string) = '' THEN
        RETURN fallback_date;
    END IF;
    
    BEGIN
        RETURN to_date(date_string, format_string);
    EXCEPTION WHEN OTHERS THEN
        RETURN fallback_date;
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION safe_parse_date IS 
'Safely parses date string with fallback value if parsing fails';

-- Function: Safe timestamp parsing with fallback
CREATE OR REPLACE FUNCTION safe_parse_timestamp(
    timestamp_string TEXT,
    format_string TEXT DEFAULT 'YYYY-MM-DD HH24:MI:SS',
    fallback_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
    IF timestamp_string IS NULL OR smart_trim(timestamp_string) = '' THEN
        RETURN fallback_timestamp;
    END IF;
    
    BEGIN
        RETURN to_timestamp(timestamp_string, format_string);
    EXCEPTION WHEN OTHERS THEN
        RETURN fallback_timestamp;
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION safe_parse_timestamp IS 
'Safely parses timestamp string with fallback value if parsing fails';

-- Function: Age in years (more precise than extract)
CREATE OR REPLACE FUNCTION age_in_years(
    birth_date DATE,
    reference_date DATE DEFAULT CURRENT_DATE
)
RETURNS INTEGER AS $$
BEGIN
    IF birth_date IS NULL THEN
        RETURN NULL;
    END IF;
    
    IF birth_date > reference_date THEN
        RETURN NULL;
    END IF;
    
    RETURN date_part('year', age(reference_date, birth_date))::INTEGER;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION age_in_years IS 
'Calculates age in years between two dates';

-- Function: Business days between dates
CREATE OR REPLACE FUNCTION business_days_between(
    start_date DATE,
    end_date DATE,
    include_start BOOLEAN DEFAULT true
)
RETURNS INTEGER AS $$
DECLARE
    current_date DATE;
    days_count INTEGER := 0;
    start_offset INTEGER := CASE WHEN include_start THEN 0 ELSE 1 END;
BEGIN
    IF start_date IS NULL OR end_date IS NULL THEN
        RETURN NULL;
    END IF;
    
    IF start_date > end_date THEN
        RETURN -business_days_between(end_date, start_date, include_start);
    END IF;
    
    current_date := start_date + start_offset;
    
    WHILE current_date <= end_date LOOP
        -- Check if day is not Saturday (6) or Sunday (0)
        IF EXTRACT(DOW FROM current_date) NOT IN (0, 6) THEN
            days_count := days_count + 1;
        END IF;
        current_date := current_date + 1;
    END LOOP;
    
    RETURN days_count;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION business_days_between IS 
'Calculates the number of business days (Mon-Fri) between two dates';

-- Function: Add business days to a date
CREATE OR REPLACE FUNCTION add_business_days(
    start_date DATE,
    days_to_add INTEGER
)
RETURNS DATE AS $$
DECLARE
    current_date DATE := start_date;
    days_added INTEGER := 0;
    direction INTEGER := SIGN(days_to_add);
BEGIN
    IF start_date IS NULL OR days_to_add IS NULL THEN
        RETURN NULL;
    END IF;
    
    IF days_to_add = 0 THEN
        RETURN start_date;
    END IF;
    
    WHILE days_added < ABS(days_to_add) LOOP
        current_date := current_date + direction;
        
        -- Check if day is not Saturday (6) or Sunday (0)
        IF EXTRACT(DOW FROM current_date) NOT IN (0, 6) THEN
            days_added := days_added + 1;
        END IF;
    END LOOP;
    
    RETURN current_date;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION add_business_days IS 
'Adds specified number of business days to a date (skips weekends)';

-- Function: Is business day
CREATE OR REPLACE FUNCTION is_business_day(
    check_date DATE
)
RETURNS BOOLEAN AS $$
BEGIN
    IF check_date IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Check if day is not Saturday (6) or Sunday (0)
    RETURN EXTRACT(DOW FROM check_date) NOT IN (0, 6);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION is_business_day IS 
'Checks if a date is a business day (Mon-Fri)';

-- Function: Start of week (Monday-based)
CREATE OR REPLACE FUNCTION start_of_week(
    input_date DATE,
    week_starts_on INTEGER DEFAULT 1  -- 1 = Monday, 0 = Sunday
)
RETURNS DATE AS $$
BEGIN
    IF input_date IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN input_date - ((EXTRACT(DOW FROM input_date)::INTEGER + 7 - week_starts_on) % 7);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION start_of_week IS 
'Returns the start date of the week containing the input date';

-- Function: End of week
CREATE OR REPLACE FUNCTION end_of_week(
    input_date DATE,
    week_starts_on INTEGER DEFAULT 1  -- 1 = Monday, 0 = Sunday
)
RETURNS DATE AS $$
BEGIN
    IF input_date IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN start_of_week(input_date, week_starts_on) + 6;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION end_of_week IS 
'Returns the end date of the week containing the input date';

-- Function: Start of month
CREATE OR REPLACE FUNCTION start_of_month(
    input_date DATE
)
RETURNS DATE AS $$
BEGIN
    IF input_date IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN date_trunc('month', input_date)::DATE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION start_of_month IS 
'Returns the first day of the month containing the input date';

-- Function: End of month
CREATE OR REPLACE FUNCTION end_of_month(
    input_date DATE
)
RETURNS DATE AS $$
BEGIN
    IF input_date IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN (date_trunc('month', input_date) + INTERVAL '1 month - 1 day')::DATE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION end_of_month IS 
'Returns the last day of the month containing the input date';

-- Function: Quarter of year
CREATE OR REPLACE FUNCTION quarter_of_year(
    input_date DATE
)
RETURNS INTEGER AS $$
BEGIN
    IF input_date IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN EXTRACT(QUARTER FROM input_date)::INTEGER;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION quarter_of_year IS 
'Returns the quarter (1-4) of the year for the input date';

-- Function: Start of quarter
CREATE OR REPLACE FUNCTION start_of_quarter(
    input_date DATE
)
RETURNS DATE AS $$
BEGIN
    IF input_date IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN date_trunc('quarter', input_date)::DATE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION start_of_quarter IS 
'Returns the first day of the quarter containing the input date';

-- Function: End of quarter
CREATE OR REPLACE FUNCTION end_of_quarter(
    input_date DATE
)
RETURNS DATE AS $$
BEGIN
    IF input_date IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN (date_trunc('quarter', input_date) + INTERVAL '3 months - 1 day')::DATE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION end_of_quarter IS 
'Returns the last day of the quarter containing the input date';

-- Function: Format timestamp with timezone
CREATE OR REPLACE FUNCTION format_timestamp_tz(
    input_timestamp TIMESTAMP WITH TIME ZONE,
    target_timezone TEXT DEFAULT 'UTC',
    format_string TEXT DEFAULT 'YYYY-MM-DD HH24:MI:SS TZ'
)
RETURNS TEXT AS $$
BEGIN
    IF input_timestamp IS NULL THEN
        RETURN NULL;
    END IF;
    
    BEGIN
        RETURN to_char(input_timestamp AT TIME ZONE target_timezone, format_string);
    EXCEPTION WHEN OTHERS THEN
        RETURN to_char(input_timestamp, format_string);
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION format_timestamp_tz IS 
'Formats timestamp in specified timezone with custom format';

-- Function: Time elapsed in human-readable format
CREATE OR REPLACE FUNCTION time_elapsed_human(
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
)
RETURNS TEXT AS $$
DECLARE
    elapsed INTERVAL;
    result TEXT := '';
BEGIN
    IF start_time IS NULL THEN
        RETURN NULL;
    END IF;
    
    elapsed := end_time - start_time;
    
    IF elapsed < INTERVAL '1 minute' THEN
        RETURN EXTRACT(EPOCH FROM elapsed)::INTEGER || ' seconds';
    ELSIF elapsed < INTERVAL '1 hour' THEN
        RETURN EXTRACT(EPOCH FROM elapsed)::INTEGER / 60 || ' minutes';
    ELSIF elapsed < INTERVAL '1 day' THEN
        RETURN EXTRACT(EPOCH FROM elapsed)::INTEGER / 3600 || ' hours';
    ELSIF elapsed < INTERVAL '30 days' THEN
        RETURN EXTRACT(EPOCH FROM elapsed)::INTEGER / 86400 || ' days';
    ELSIF elapsed < INTERVAL '365 days' THEN
        RETURN ROUND(EXTRACT(EPOCH FROM elapsed)::NUMERIC / 2592000, 1) || ' months';
    ELSE
        RETURN ROUND(EXTRACT(EPOCH FROM elapsed)::NUMERIC / 31536000, 1) || ' years';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION time_elapsed_human IS 
'Converts time difference to human-readable format (e.g., "5 days", "2 hours")';

-- Function: Is date in range
CREATE OR REPLACE FUNCTION is_date_in_range(
    check_date DATE,
    start_date DATE,
    end_date DATE,
    inclusive BOOLEAN DEFAULT true
)
RETURNS BOOLEAN AS $$
BEGIN
    IF check_date IS NULL OR start_date IS NULL OR end_date IS NULL THEN
        RETURN NULL;
    END IF;
    
    IF inclusive THEN
        RETURN check_date >= start_date AND check_date <= end_date;
    ELSE
        RETURN check_date > start_date AND check_date < end_date;
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION is_date_in_range IS 
'Checks if a date falls within a specified range';

-- Function: Overlapping date ranges
CREATE OR REPLACE FUNCTION date_ranges_overlap(
    start1 DATE,
    end1 DATE,
    start2 DATE,
    end2 DATE
)
RETURNS BOOLEAN AS $$
BEGIN
    IF start1 IS NULL OR end1 IS NULL OR start2 IS NULL OR end2 IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN start1 <= end2 AND start2 <= end1;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION date_ranges_overlap IS 
'Checks if two date ranges overlap';

-- Function: Get timezone offset in hours
CREATE OR REPLACE FUNCTION get_timezone_offset(
    timezone_name TEXT,
    reference_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
)
RETURNS NUMERIC AS $$
BEGIN
    IF timezone_name IS NULL THEN
        RETURN NULL;
    END IF;
    
    BEGIN
        RETURN EXTRACT(EPOCH FROM (reference_time AT TIME ZONE timezone_name) - 
                                   (reference_time AT TIME ZONE 'UTC')) / 3600.0;
    EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION get_timezone_offset IS 
'Returns the timezone offset in hours from UTC for a given timezone';
