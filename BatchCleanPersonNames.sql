DELIMITER //

CREATE PROCEDURE `BatchCleanPersonNames`(IN p_start_from_id INT)
BEGIN
    -- Declare variables for tracking progress
    DECLARE v_start_id INT;
    DECLARE v_end_id INT;
    DECLARE v_batch_size INT DEFAULT 100000;
    DECLARE v_max_id INT DEFAULT 0;
    DECLARE v_rows_updated INT DEFAULT 0;

    -- FIX 1: Move DDL outside of any operational or logical loops
    CREATE TABLE IF NOT EXISTS tbl_batch_log2 (
        log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        last_processed_id INT,
        rows_affected INT
    );

    -- Initialize starting point
    SET v_start_id = p_start_from_id;

    -- Get the absolute maximum ID to know when to stop the loop
    SELECT MAX(person_id) INTO v_max_id FROM tbl_person;

    -- Loop through the table in batches until the start pointer exceeds max ID
    WHILE v_start_id <= v_max_id DO
        
        -- OPTIMIZATION 1: Find the actual end of this batch by skipping gaps
        -- We get the ID that is v_batch_size rows away from our start.
        -- If this query returns NULL (meaning fewer than batch_size rows left), we use v_max_id.
        SELECT person_id INTO v_end_id 
        FROM tbl_person 
        WHERE person_id >= v_start_id 
        ORDER BY person_id ASC 
        LIMIT v_batch_size, 1;
        
        IF v_end_id IS NULL THEN
            SET v_end_id = v_max_id + 1;
        END IF;
        
        -- Run the batch update with strict, non-overlapping boundaries
        -- OPTIMIZATION 2: Only update rows where the cleaned name is actually different from the current name
        UPDATE tbl_person 
        SET first_name = clean_names(first_name), 
            middle_name = clean_names(middle_name), 
            last_name = clean_names(last_name) 
        WHERE person_id >= v_start_id 
          AND person_id < v_end_id
          AND (
               first_name <> clean_names(first_name) COLLATE utf8mb4_bin OR (first_name IS NOT NULL AND clean_names(first_name) IS NULL) OR
               middle_name <> clean_names(middle_name) COLLATE utf8mb4_bin OR (middle_name IS NOT NULL AND clean_names(middle_name) IS NULL) OR
               last_name <> clean_names(last_name) COLLATE utf8mb4_bin OR (last_name IS NOT NULL AND clean_names(last_name) IS NULL)
          );

        -- Capture how many rows were actually changed in this specific batch
        SET v_rows_updated = ROW_COUNT();

        -- Record progress using the actual upper limit of the current batch
        INSERT INTO tbl_batch_log2 (last_processed_id, rows_affected) 
        VALUES (v_end_id - 1, v_rows_updated);

        -- Move the pointer forward to the next actual batch start
        SET v_start_id = v_end_id;

    END WHILE;
END //

DELIMITER ;
