CREATE FUNCTION `clean_names`(IN str VARCHAR(255))
RETURNS varchar DETERMINISTIC
BEGIN 
    -- Step 1: Return NULL if input is NULL or whitespace-only 
    SET str = TRIM(str); 
    IF str IS NULL OR CHAR_LENGTH(str) = 0 THEN 
        RETURN NULL; 
    END IF; 

    -- Step 2: Convert carriage returns (\r) and newlines (\n) to spaces 
    SET str = REPLACE(str, '
', ' '); 
    SET str = REPLACE(str, '
', ' '); 

    -- Step 3: Collapse all multiple consecutive spaces (including tabs) into a single space 
    SET str = REGEXP_REPLACE(str, '\s+', ' '); 

    -- Step 4: Collapse consecutive punctuation marks 
    SET str = REGEXP_REPLACE(str, ',+', ','); 
    SET str = REGEXP_REPLACE(str, '-+', '-'); 
    SET str = REGEXP_REPLACE(str, '\.+', '.'); 
    SET str = REGEXP_REPLACE(str, "'+", "'"); 

    -- Step 5: Trim leading punctuation marks (.,-') 
    SET str = REGEXP_REPLACE(str, "^[.,\-']+", ''); 

    -- Step 6: Trim trailing spaces and final trailing punctuation cleanup if needed 
    SET str = TRIM(str); 

    -- Step 7: Return NULL if cleaning left an empty string 
    IF CHAR_LENGTH(str) = 0 THEN 
        RETURN NULL; 
    END IF; 

    -- Step 8: Apply case formatting
    RETURN UPPER(str); 
END