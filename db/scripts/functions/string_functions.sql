-- PostgreSQL Enhanced String Functions
-- Wrapper functions that make string operations easier and safer

-- Function: Safe substring with bounds checking
CREATE OR REPLACE FUNCTION safe_substring(
    input_string TEXT,
    start_pos INTEGER,
    length INTEGER DEFAULT NULL
)
RETURNS TEXT AS $$
BEGIN
    IF input_string IS NULL THEN
        RETURN NULL;
    END IF;
    
    IF start_pos < 1 THEN
        start_pos := 1;
    END IF;
    
    IF start_pos > char_length(input_string) THEN
        RETURN '';
    END IF;
    
    IF length IS NULL OR length < 0 THEN
        RETURN substring(input_string FROM start_pos);
    END IF;
    
    RETURN substring(input_string FROM start_pos FOR length);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION safe_substring IS 
'Safe substring extraction with automatic bounds checking and NULL handling';

-- Function: Smart trim that handles multiple whitespace types
CREATE OR REPLACE FUNCTION smart_trim(
    input_string TEXT,
    trim_internal BOOLEAN DEFAULT false
)
RETURNS TEXT AS $$
BEGIN
    IF input_string IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Remove leading and trailing whitespace, including various unicode spaces
    input_string := regexp_replace(input_string, '^\s+|\s+$', '', 'g');
    
    -- Optionally collapse internal whitespace
    IF trim_internal THEN
        input_string := regexp_replace(input_string, '\s+', ' ', 'g');
    END IF;
    
    RETURN input_string;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION smart_trim IS 
'Enhanced trim that handles all whitespace types and optionally normalizes internal spaces';

-- Function: Safe string concatenation with separator
CREATE OR REPLACE FUNCTION safe_concat(
    separator TEXT DEFAULT '',
    VARIADIC strings TEXT[] DEFAULT ARRAY[]::TEXT[]
)
RETURNS TEXT AS $$
DECLARE
    result TEXT := '';
    str TEXT;
    first BOOLEAN := true;
BEGIN
    FOREACH str IN ARRAY strings
    LOOP
        IF str IS NOT NULL AND str <> '' THEN
            IF first THEN
                result := str;
                first := false;
            ELSE
                result := result || separator || str;
            END IF;
        END IF;
    END LOOP;
    
    RETURN NULLIF(result, '');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION safe_concat IS 
'Safely concatenates strings with separator, skipping NULL and empty values';

-- Function: Truncate with ellipsis
CREATE OR REPLACE FUNCTION truncate_with_ellipsis(
    input_string TEXT,
    max_length INTEGER,
    ellipsis TEXT DEFAULT '...'
)
RETURNS TEXT AS $$
BEGIN
    IF input_string IS NULL THEN
        RETURN NULL;
    END IF;
    
    IF char_length(input_string) <= max_length THEN
        RETURN input_string;
    END IF;
    
    IF max_length < char_length(ellipsis) THEN
        RETURN substring(input_string FROM 1 FOR max_length);
    END IF;
    
    RETURN substring(input_string FROM 1 FOR max_length - char_length(ellipsis)) || ellipsis;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION truncate_with_ellipsis IS 
'Truncates string to specified length and adds ellipsis if truncated';

-- Function: Title case conversion
CREATE OR REPLACE FUNCTION to_title_case(
    input_string TEXT
)
RETURNS TEXT AS $$
BEGIN
    IF input_string IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN initcap(lower(input_string));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION to_title_case IS 
'Converts string to title case (first letter of each word capitalized)';

-- Function: Slugify (URL-friendly string)
CREATE OR REPLACE FUNCTION slugify(
    input_string TEXT,
    separator TEXT DEFAULT '-'
)
RETURNS TEXT AS $$
BEGIN
    IF input_string IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Convert to lowercase
    input_string := lower(input_string);
    
    -- Replace accented characters with ASCII equivalents
    input_string := unaccent(input_string);
    
    -- Replace non-alphanumeric characters with separator
    input_string := regexp_replace(input_string, '[^a-z0-9]+', separator, 'g');
    
    -- Remove leading and trailing separators
    input_string := regexp_replace(input_string, format('^%s+|%s+$', separator, separator), '', 'g');
    
    -- Collapse multiple separators
    input_string := regexp_replace(input_string, format('%s+', separator), separator, 'g');
    
    RETURN input_string;
EXCEPTION WHEN undefined_function THEN
    -- If unaccent extension is not available, skip that step
    input_string := lower(input_string);
    input_string := regexp_replace(input_string, '[^a-z0-9]+', separator, 'g');
    input_string := regexp_replace(input_string, format('^%s+|%s+$', separator, separator), '', 'g');
    input_string := regexp_replace(input_string, format('%s+', separator), separator, 'g');
    RETURN input_string;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION slugify IS 
'Converts string to URL-friendly slug (lowercase, no special characters)';

-- Function: Extract numbers from string
CREATE OR REPLACE FUNCTION extract_numbers(
    input_string TEXT,
    return_as_array BOOLEAN DEFAULT false
)
RETURNS TEXT AS $$
DECLARE
    numbers TEXT;
BEGIN
    IF input_string IS NULL THEN
        RETURN NULL;
    END IF;
    
    IF return_as_array THEN
        -- Return all number sequences as comma-separated
        SELECT string_agg(matched, ',')
        INTO numbers
        FROM (
            SELECT regexp_matches(input_string, '\d+', 'g') AS matched
        ) t;
    ELSE
        -- Return only digits concatenated
        numbers := regexp_replace(input_string, '\D', '', 'g');
    END IF;
    
    RETURN NULLIF(numbers, '');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION extract_numbers IS 
'Extracts numeric characters from a string';

-- Function: Safe string comparison (case-insensitive, NULL-safe)
CREATE OR REPLACE FUNCTION safe_string_equals(
    str1 TEXT,
    str2 TEXT,
    case_sensitive BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF str1 IS NULL AND str2 IS NULL THEN
        RETURN true;
    END IF;
    
    IF str1 IS NULL OR str2 IS NULL THEN
        RETURN false;
    END IF;
    
    IF case_sensitive THEN
        RETURN str1 = str2;
    ELSE
        RETURN lower(str1) = lower(str2);
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION safe_string_equals IS 
'NULL-safe string comparison with optional case sensitivity';

-- Function: Format phone number
CREATE OR REPLACE FUNCTION format_phone_number(
    phone_number TEXT,
    format_type TEXT DEFAULT 'US'
)
RETURNS TEXT AS $$
DECLARE
    digits TEXT;
BEGIN
    IF phone_number IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Extract only digits
    digits := regexp_replace(phone_number, '\D', '', 'g');
    
    -- Format based on type
    CASE format_type
        WHEN 'US' THEN
            IF char_length(digits) = 10 THEN
                RETURN format('(%s) %s-%s', 
                    substring(digits FROM 1 FOR 3),
                    substring(digits FROM 4 FOR 3),
                    substring(digits FROM 7 FOR 4));
            ELSIF char_length(digits) = 11 AND substring(digits FROM 1 FOR 1) = '1' THEN
                RETURN format('+1 (%s) %s-%s', 
                    substring(digits FROM 2 FOR 3),
                    substring(digits FROM 5 FOR 3),
                    substring(digits FROM 8 FOR 4));
            END IF;
        WHEN 'INTL' THEN
            -- Simple international format
            IF char_length(digits) >= 10 THEN
                RETURN '+' || digits;
            END IF;
        ELSE
            RETURN digits;
    END CASE;
    
    RETURN phone_number; -- Return original if no pattern matches
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION format_phone_number IS 
'Formats phone numbers according to specified format (US, INTL, etc.)';

-- Function: Mask sensitive data
CREATE OR REPLACE FUNCTION mask_sensitive_data(
    input_string TEXT,
    mask_char TEXT DEFAULT '*',
    visible_start INTEGER DEFAULT 0,
    visible_end INTEGER DEFAULT 4
)
RETURNS TEXT AS $$
DECLARE
    str_length INTEGER;
    masked_length INTEGER;
BEGIN
    IF input_string IS NULL THEN
        RETURN NULL;
    END IF;
    
    str_length := char_length(input_string);
    
    -- If string is too short, mask it completely
    IF str_length <= (visible_start + visible_end) THEN
        RETURN repeat(mask_char, str_length);
    END IF;
    
    masked_length := str_length - visible_start - visible_end;
    
    RETURN 
        CASE WHEN visible_start > 0 THEN substring(input_string FROM 1 FOR visible_start) ELSE '' END ||
        repeat(mask_char, masked_length) ||
        CASE WHEN visible_end > 0 THEN substring(input_string FROM str_length - visible_end + 1) ELSE '' END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION mask_sensitive_data IS 
'Masks sensitive data showing only specified characters at start and end';

-- Function: Word count
CREATE OR REPLACE FUNCTION word_count(
    input_string TEXT
)
RETURNS INTEGER AS $$
BEGIN
    IF input_string IS NULL OR smart_trim(input_string) = '' THEN
        RETURN 0;
    END IF;
    
    RETURN array_length(regexp_split_to_array(smart_trim(input_string, true), '\s+'), 1);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION word_count IS 
'Counts the number of words in a string';

-- Function: Reverse string safely
CREATE OR REPLACE FUNCTION safe_reverse(
    input_string TEXT
)
RETURNS TEXT AS $$
BEGIN
    IF input_string IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN reverse(input_string);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION safe_reverse IS 
'Reverses a string with NULL handling';
