-- PostgreSQL Enhanced Numeric Functions
-- Wrapper functions that make numeric operations easier and safer

-- Function: Safe division with default value
CREATE OR REPLACE FUNCTION safe_divide(
    numerator NUMERIC,
    denominator NUMERIC,
    default_value NUMERIC DEFAULT 0
)
RETURNS NUMERIC AS $$
BEGIN
    IF numerator IS NULL OR denominator IS NULL OR denominator = 0 THEN
        RETURN default_value;
    END IF;
    
    RETURN numerator / denominator;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION safe_divide IS 
'Performs division with NULL and divide-by-zero protection';

-- Function: Safe percentage calculation
CREATE OR REPLACE FUNCTION safe_percentage(
    part NUMERIC,
    total NUMERIC,
    decimal_places INTEGER DEFAULT 2
)
RETURNS NUMERIC AS $$
BEGIN
    IF part IS NULL OR total IS NULL OR total = 0 THEN
        RETURN 0;
    END IF;
    
    RETURN ROUND(100.0 * part / total, decimal_places);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION safe_percentage IS 
'Calculates percentage with NULL and divide-by-zero protection';

-- Function: Clamp value within range
CREATE OR REPLACE FUNCTION clamp_value(
    value NUMERIC,
    min_value NUMERIC,
    max_value NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    IF value IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN GREATEST(min_value, LEAST(max_value, value));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION clamp_value IS 
'Constrains a value to be within specified minimum and maximum bounds';

-- Function: Is value in range
CREATE OR REPLACE FUNCTION is_in_range(
    value NUMERIC,
    min_value NUMERIC,
    max_value NUMERIC,
    inclusive BOOLEAN DEFAULT true
)
RETURNS BOOLEAN AS $$
BEGIN
    IF value IS NULL THEN
        RETURN NULL;
    END IF;
    
    IF inclusive THEN
        RETURN value >= min_value AND value <= max_value;
    ELSE
        RETURN value > min_value AND value < max_value;
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION is_in_range IS 
'Checks if a numeric value is within a specified range';

-- Function: Round to significant figures
CREATE OR REPLACE FUNCTION round_to_significant_figures(
    value NUMERIC,
    sig_figs INTEGER DEFAULT 3
)
RETURNS NUMERIC AS $$
DECLARE
    magnitude INTEGER;
BEGIN
    IF value IS NULL OR value = 0 THEN
        RETURN value;
    END IF;
    
    magnitude := FLOOR(LOG(ABS(value)))::INTEGER;
    
    RETURN ROUND(value, sig_figs - magnitude - 1);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION round_to_significant_figures IS 
'Rounds a number to specified significant figures';

-- Function: Format number with thousands separator
CREATE OR REPLACE FUNCTION format_number_with_separator(
    value NUMERIC,
    decimal_places INTEGER DEFAULT 2,
    thousands_sep TEXT DEFAULT ',',
    decimal_sep TEXT DEFAULT '.'
)
RETURNS TEXT AS $$
DECLARE
    formatted TEXT;
    integer_part TEXT;
    decimal_part TEXT;
BEGIN
    IF value IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Round to specified decimal places
    value := ROUND(value, decimal_places);
    
    -- Split into integer and decimal parts
    integer_part := TRUNC(value)::TEXT;
    
    IF decimal_places > 0 THEN
        decimal_part := LPAD(ABS(value - TRUNC(value))::NUMERIC(20, 10)::TEXT, decimal_places + 2, '0');
        decimal_part := substring(decimal_part FROM 3 FOR decimal_places);
    END IF;
    
    -- Add thousands separator
    integer_part := regexp_replace(integer_part, '(\d)(?=(\d{3})+$)', format('\1%s', thousands_sep), 'g');
    
    -- Combine parts
    IF decimal_places > 0 THEN
        formatted := integer_part || decimal_sep || decimal_part;
    ELSE
        formatted := integer_part;
    END IF;
    
    RETURN formatted;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION format_number_with_separator IS 
'Formats a number with thousands separators and decimal places';

-- Function: Format as currency
CREATE OR REPLACE FUNCTION format_currency(
    amount NUMERIC,
    currency_symbol TEXT DEFAULT '$',
    decimal_places INTEGER DEFAULT 2
)
RETURNS TEXT AS $$
BEGIN
    IF amount IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN currency_symbol || format_number_with_separator(ABS(amount), decimal_places) ||
           CASE WHEN amount < 0 THEN ' (negative)' ELSE '' END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION format_currency IS 
'Formats a number as currency with symbol and thousands separators';

-- Function: Calculate moving average
CREATE OR REPLACE FUNCTION moving_average(
    values NUMERIC[],
    window_size INTEGER DEFAULT 3
)
RETURNS NUMERIC[] AS $$
DECLARE
    result NUMERIC[] := ARRAY[]::NUMERIC[];
    i INTEGER;
    sum_val NUMERIC;
    count_val INTEGER;
BEGIN
    IF values IS NULL OR array_length(values, 1) IS NULL THEN
        RETURN NULL;
    END IF;
    
    FOR i IN 1..array_length(values, 1) LOOP
        sum_val := 0;
        count_val := 0;
        
        FOR j IN GREATEST(1, i - window_size + 1)..i LOOP
            IF values[j] IS NOT NULL THEN
                sum_val := sum_val + values[j];
                count_val := count_val + 1;
            END IF;
        END LOOP;
        
        IF count_val > 0 THEN
            result := array_append(result, sum_val / count_val);
        ELSE
            result := array_append(result, NULL);
        END IF;
    END LOOP;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION moving_average IS 
'Calculates moving average for an array of values with specified window size';

-- Function: Safe modulo operation
CREATE OR REPLACE FUNCTION safe_mod(
    dividend NUMERIC,
    divisor NUMERIC,
    default_value NUMERIC DEFAULT 0
)
RETURNS NUMERIC AS $$
BEGIN
    IF dividend IS NULL OR divisor IS NULL OR divisor = 0 THEN
        RETURN default_value;
    END IF;
    
    RETURN MOD(dividend, divisor);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION safe_mod IS 
'Performs modulo operation with NULL and divide-by-zero protection';

-- Function: Normalize value to 0-1 range
CREATE OR REPLACE FUNCTION normalize_value(
    value NUMERIC,
    min_value NUMERIC,
    max_value NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    IF value IS NULL OR min_value IS NULL OR max_value IS NULL THEN
        RETURN NULL;
    END IF;
    
    IF max_value = min_value THEN
        RETURN 0.5;
    END IF;
    
    RETURN (value - min_value) / (max_value - min_value);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION normalize_value IS 
'Normalizes a value to 0-1 range based on min and max values';

-- Function: Denormalize value from 0-1 range
CREATE OR REPLACE FUNCTION denormalize_value(
    normalized_value NUMERIC,
    min_value NUMERIC,
    max_value NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    IF normalized_value IS NULL OR min_value IS NULL OR max_value IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN min_value + (normalized_value * (max_value - min_value));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION denormalize_value IS 
'Converts a normalized value (0-1) back to original scale';

-- Function: Linear interpolation
CREATE OR REPLACE FUNCTION lerp(
    start_value NUMERIC,
    end_value NUMERIC,
    t NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    IF start_value IS NULL OR end_value IS NULL OR t IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN start_value + t * (end_value - start_value);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION lerp IS 
'Performs linear interpolation between two values';

-- Function: Calculate compound interest
CREATE OR REPLACE FUNCTION compound_interest(
    principal NUMERIC,
    rate NUMERIC,
    time_periods NUMERIC,
    compounds_per_period INTEGER DEFAULT 1
)
RETURNS NUMERIC AS $$
BEGIN
    IF principal IS NULL OR rate IS NULL OR time_periods IS NULL THEN
        RETURN NULL;
    END IF;
    
    IF compounds_per_period <= 0 THEN
        compounds_per_period := 1;
    END IF;
    
    RETURN principal * POWER(1 + rate / compounds_per_period, compounds_per_period * time_periods);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION compound_interest IS 
'Calculates compound interest: A = P(1 + r/n)^(nt)';

-- Function: Greatest Common Divisor (GCD)
CREATE OR REPLACE FUNCTION gcd(
    a BIGINT,
    b BIGINT
)
RETURNS BIGINT AS $$
BEGIN
    IF a IS NULL OR b IS NULL THEN
        RETURN NULL;
    END IF;
    
    a := ABS(a);
    b := ABS(b);
    
    WHILE b != 0 LOOP
        DECLARE
            temp BIGINT := b;
        BEGIN
            b := MOD(a, b);
            a := temp;
        END;
    END LOOP;
    
    RETURN a;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION gcd IS 
'Calculates the greatest common divisor of two integers';

-- Function: Least Common Multiple (LCM)
CREATE OR REPLACE FUNCTION lcm(
    a BIGINT,
    b BIGINT
)
RETURNS BIGINT AS $$
BEGIN
    IF a IS NULL OR b IS NULL OR a = 0 OR b = 0 THEN
        RETURN NULL;
    END IF;
    
    RETURN ABS(a * b) / gcd(a, b);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION lcm IS 
'Calculates the least common multiple of two integers';

-- Function: Check if number is even
CREATE OR REPLACE FUNCTION is_even(
    value BIGINT
)
RETURNS BOOLEAN AS $$
BEGIN
    IF value IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN MOD(value, 2) = 0;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION is_even IS 
'Checks if a number is even';

-- Function: Check if number is odd
CREATE OR REPLACE FUNCTION is_odd(
    value BIGINT
)
RETURNS BOOLEAN AS $$
BEGIN
    IF value IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN MOD(value, 2) != 0;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION is_odd IS 
'Checks if a number is odd';

-- Function: Factorial
CREATE OR REPLACE FUNCTION factorial(
    n INTEGER
)
RETURNS NUMERIC AS $$
DECLARE
    result NUMERIC := 1;
    i INTEGER;
BEGIN
    IF n IS NULL OR n < 0 THEN
        RETURN NULL;
    END IF;
    
    IF n = 0 OR n = 1 THEN
        RETURN 1;
    END IF;
    
    FOR i IN 2..n LOOP
        result := result * i;
    END LOOP;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION factorial IS 
'Calculates the factorial of a number (n!)';
