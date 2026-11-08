DELIMITER //

CREATE PROCEDURE `ApplyDQA`()
BEGIN
-- ===============================================================
-- DQA 1
-- Create the audit tables
    CREATE TABLE tbl_household_dqa_1 LIKE tbl_household;
    CREATE TABLE tbl_person_dqa_1 LIKE tbl_person;
    CREATE TABLE tbl_hh_roster_dqa_1 LIKE tbl_hh_roster;
    CREATE TABLE tbl_beneficiary_dqa_1 LIKE tbl_beneficiary;
    CREATE TABLE tbl_grantee_dqa_1 LIKE tbl_grantee;
    
    -- Truncate audit tables
    TRUNCATE TABLE tbl_household_dqa_1;
    TRUNCATE TABLE tbl_person_dqa_1;
    TRUNCATE TABLE tbl_hh_roster_dqa_1;
    TRUNCATE TABLE tbl_beneficiary_dqa_1;
    TRUNCATE TABLE tbl_grantee_dqa_1;
    
    -- INSERT households that are archived
    INSERT INTO tbl_household_dqa_1 SELECT * FROM `tbl_household` WHERE `archived` != 0;
    
    DELETE FROM tbl_household WHERE `archived` != 0;
    
    -- INSERT ORPHANED records from 
    INSERT INTO tbl_person_dqa_1 (
      `person_id`, `first_name`, `middle_name`, `last_name`, `ext_name_id`, 
      `date_of_birth`, `sex_id`, `civil_status_id`, `phil_id`, `attending_school`, 
      `educ_facility_id`, `grade_level_id`, `is_pregnant`, `health_facility_id`, 
      `occupation_id`, `ip_group_id`, `lrn`, `photo_src`, `roster_id`, 
      `dt_inserted`, `dt_updated`, `archived`, `dt_archived`, `child_grantee`, 
      `newmember_id`, `mcct_person_id`, `validation_num`
    ) SELECT
      p.`person_id`, p.`first_name`, p.`middle_name`, p.`last_name`, p.`ext_name_id`, 
      p.`date_of_birth`, p.`sex_id`, p.`civil_status_id`, p.`phil_id`, p.`attending_school`, 
      p.`educ_facility_id`, p.`grade_level_id`, p.`is_pregnant`, p.`health_facility_id`, 
      p.`occupation_id`, p.`ip_group_id`, p.`lrn`, p.`photo_src`, p.`roster_id`, 
      p.`dt_inserted`, p.`dt_updated`, p.`archived`, p.`dt_archived`, p.`child_grantee`, 
      p.`newmember_id`, p.`mcct_person_id`, p.`validation_num`
    FROM tbl_person p INNER JOIN tbl_hh_roster r ON p.person_id = r.person_id INNER JOIN tbl_household_dqa_1 h ON h.household_id = r.household_id;
    
    DELETE FROM tbl_person WHERE person_id IN (SELECT person_id FROM tbl_person_dqa_1);
    
    INSERT INTO tbl_beneficiary_dqa_1 SELECT * FROM tbl_beneficiary WHERE household_id IN (SELECT household_id FROM tbl_household_dqa_1);
    DELETE FROM tbl_beneficiary WHERE beneficiary_id IN (SELECT beneficiary_id FROM tbl_beneficiary_dqa_1);
    
    INSERT INTO tbl_grantee_dqa_1 SELECT * FROM tbl_grantee WHERE person_id IN (SELECT person_id FROM tbl_person_dqa_1 );
    DELETE FROM tbl_grantee WHERE grantee_id IN (SELECT grantee_id FROM tbl_grantee_dqa_1);
    
    INSERT INTO tbl_hh_roster_dqa_1 SELECT * FROM tbl_hh_roster WHERE person_id IN (SELECT person_id FROM tbl_person_dqa_1);
    DELETE FROM tbl_hh_roster WHERE person_id IN (SELECT person_id FROM tbl_person_dqa_1);
    
    -- ===============================================================
    -- DQA 2
    -- Create audit tables
    CREATE TABLE tbl_household_dqa_2 LIKE tbl_household;
    CREATE TABLE tbl_person_dqa_2 LIKE tbl_person;
    CREATE TABLE tbl_hh_roster_dqa_2 LIKE tbl_hh_roster;
    CREATE TABLE tbl_beneficiary_dqa_2 LIKE tbl_beneficiary;
    CREATE TABLE tbl_grantee_dqa_2 LIKE tbl_grantee;
    
    -- Truncate audit tables
    TRUNCATE TABLE tbl_household_dqa_2;
    TRUNCATE TABLE tbl_person_dqa_2;
    TRUNCATE TABLE tbl_hh_roster_dqa_2;
    TRUNCATE TABLE tbl_beneficiary_dqa_2;
    TRUNCATE TABLE tbl_grantee_dqa_2;
    
    INSERT INTO tbl_hh_roster_dqa_2 SELECT * FROM tbl_hh_roster WHERE roster_status_id = 5;
    DELETE FROM tbl_hh_roster WHERE roster_status_id = 5;
    
    -- INSERT INTO tbl_household_dqa_2 SELECT * FROM tbl_household WHERE household_id IN (SELECT DISTINCT household_id FROM tbl_hh_roster_dqa_2);
    -- DELETE FROM tbl_household WHERE household_id IN (SELECT household_id FROM tbl_household_dqa_2);
    
    INSERT INTO tbl_person_dqa_2 (
      `person_id`, `first_name`, `middle_name`, `last_name`, `ext_name_id`, 
      `date_of_birth`, `sex_id`, `civil_status_id`, `phil_id`, `attending_school`, 
      `educ_facility_id`, `grade_level_id`, `is_pregnant`, `health_facility_id`, 
      `occupation_id`, `ip_group_id`, `lrn`, `photo_src`, `roster_id`, 
      `dt_inserted`, `dt_updated`, `archived`, `dt_archived`, `child_grantee`, 
      `newmember_id`, `mcct_person_id`, `validation_num`
    ) SELECT
      p.`person_id`, p.`first_name`, p.`middle_name`, p.`last_name`, p.`ext_name_id`, 
      p.`date_of_birth`, p.`sex_id`, p.`civil_status_id`, p.`phil_id`, p.`attending_school`, 
      p.`educ_facility_id`, p.`grade_level_id`, p.`is_pregnant`, p.`health_facility_id`, 
      p.`occupation_id`, p.`ip_group_id`, p.`lrn`, p.`photo_src`, p.`roster_id`, 
      p.`dt_inserted`, p.`dt_updated`, p.`archived`, p.`dt_archived`, p.`child_grantee`, 
      p.`newmember_id`, p.`mcct_person_id`, p.`validation_num`
    FROM tbl_person p WHERE p.person_id IN (SELECT person_id FROM tbl_hh_roster_dqa_2);
    
    DELETE FROM tbl_person WHERE person_id IN (SELECT person_id FROM tbl_person_dqa_2);
    
    -- INSERT INTO tbl_beneficiary_dqa_2 SELECT * FROM tbl_beneficiary WHERE household_id IN (SELECT DISTINCT household_id FROM tbl_hh_roster_dqa_2);
    -- DELETE FROM tbl_beneficiary WHERE beneficiary_id IN (SELECT beneficiary_id  FROM tbl_beneficiary_dqa_2);
    
    INSERT INTO tbl_grantee_dqa_2 SELECT * FROM tbl_grantee WHERE person_id IN (SELECT person_id FROM tbl_hh_roster_dqa_2);
    DELETE FROM tbl_grantee WHERE grantee_id IN (SELECT grantee_id FROM tbl_grantee_dqa_2);
    
    -- ===============================================================
    -- DQA 3
    -- Create audit tables
    CREATE TABLE tbl_household_dqa_3 LIKE tbl_household;
    CREATE TABLE tbl_person_dqa_3 LIKE tbl_person;
    CREATE TABLE tbl_hh_roster_dqa_3 LIKE tbl_hh_roster;
    CREATE TABLE tbl_beneficiary_dqa_3 LIKE tbl_beneficiary;
    CREATE TABLE tbl_grantee_dqa_3 LIKE tbl_grantee;
    
    -- Truncate audit tables
    TRUNCATE TABLE tbl_household_dqa_3;
    TRUNCATE TABLE tbl_person_dqa_3;
    TRUNCATE TABLE tbl_hh_roster_dqa_3;
    TRUNCATE TABLE tbl_beneficiary_dqa_3;
    TRUNCATE TABLE tbl_grantee_dqa_3;
    
    INSERT INTO tbl_beneficiary_dqa_3 SELECT * FROM tbl_beneficiary WHERE client_status_id NOT IN 
        (1,2,3,5,7,9,10,11,12,13,
        14,15,16,17,18,19,20,21,22,
        23,24,25,26,28,29,30,31,32,33,34);
        
    DELETE FROM tbl_beneficiary WHERE client_status_id NOT IN 
        (1,2,3,5,7,9,10,11,12,13,
        14,15,16,17,18,19,20,21,22,
        23,24,25,26,28,29,30,31,32,33,34);
        
    INSERT INTO tbl_grantee_dqa_3 SELECT * FROM tbl_grantee WHERE beneficiary_id IN (SELECT beneficiary_id FROM tbl_beneficiary_dqa_3);
    DELETE FROM tbl_grantee WHERE grantee_id IN (SELECT grantee_id FROM tbl_grantee_dqa_3);
    
    INSERT INTO tbl_hh_roster_dqa_3 SELECT * FROM tbl_hh_roster WHERE household_id IN (SELECT household_id FROM tbl_beneficiary_dqa_3);
    DELETE FROM tbl_hh_roster WHERE household_id IN (SELECT household_id FROM tbl_beneficiary_dqa_3);
    
    INSERT INTO tbl_household_dqa_3 SELECT * FROM tbl_household WHERE household_id IN (SELECT DISTINCT household_id FROM tbl_hh_roster_dqa_3);
    DELETE FROM tbl_household WHERE household_id IN (SELECT household_id FROM tbl_household_dqa_3);
    
    INSERT INTO tbl_person_dqa_3 (
      `person_id`, `first_name`, `middle_name`, `last_name`, `ext_name_id`, 
      `date_of_birth`, `sex_id`, `civil_status_id`, `phil_id`, `attending_school`, 
      `educ_facility_id`, `grade_level_id`, `is_pregnant`, `health_facility_id`, 
      `occupation_id`, `ip_group_id`, `lrn`, `photo_src`, `roster_id`, 
      `dt_inserted`, `dt_updated`, `archived`, `dt_archived`, `child_grantee`, 
      `newmember_id`, `mcct_person_id`, `validation_num`
    ) SELECT
      p.`person_id`, p.`first_name`, p.`middle_name`, p.`last_name`, p.`ext_name_id`, 
      p.`date_of_birth`, p.`sex_id`, p.`civil_status_id`, p.`phil_id`, p.`attending_school`, 
      p.`educ_facility_id`, p.`grade_level_id`, p.`is_pregnant`, p.`health_facility_id`, 
      p.`occupation_id`, p.`ip_group_id`, p.`lrn`, p.`photo_src`, p.`roster_id`, 
      p.`dt_inserted`, p.`dt_updated`, p.`archived`, p.`dt_archived`, p.`child_grantee`, 
      p.`newmember_id`, p.`mcct_person_id`, p.`validation_num`
    FROM tbl_person p WHERE p.person_id IN (SELECT person_id FROM tbl_hh_roster_dqa_3);
    
    DELETE FROM tbl_person WHERE person_id IN (SELECT person_id FROM tbl_person_dqa_3);
    
    
    -- ===============================================================
    -- DQA 1 Member
    -- Create the audit tables
    CREATE TABLE tbl_household_dqa_1p LIKE tbl_household;
    CREATE TABLE tbl_person_dqa_1p LIKE tbl_person;
    CREATE TABLE tbl_hh_roster_dqa_1p LIKE tbl_hh_roster;
    CREATE TABLE tbl_beneficiary_dqa_1p LIKE tbl_beneficiary;
    CREATE TABLE tbl_grantee_dqa_1p LIKE tbl_grantee;
    
    -- Truncate audit tables
    TRUNCATE TABLE tbl_household_dqa_1p;
    TRUNCATE TABLE tbl_person_dqa_1p;
    TRUNCATE TABLE tbl_hh_roster_dqa_1p;
    TRUNCATE TABLE tbl_beneficiary_dqa_1p;
    TRUNCATE TABLE tbl_grantee_dqa_1p;
    
    INSERT INTO tbl_person_dqa_1p (
      `person_id`, `first_name`, `middle_name`, `last_name`, `ext_name_id`, 
      `date_of_birth`, `sex_id`, `civil_status_id`, `phil_id`, `attending_school`, 
      `educ_facility_id`, `grade_level_id`, `is_pregnant`, `health_facility_id`, 
      `occupation_id`, `ip_group_id`, `lrn`, `photo_src`, `roster_id`, 
      `dt_inserted`, `dt_updated`, `archived`, `dt_archived`, `child_grantee`, 
      `newmember_id`, `mcct_person_id`, `validation_num`
    ) SELECT
      p.`person_id`, p.`first_name`, p.`middle_name`, p.`last_name`, p.`ext_name_id`, 
      p.`date_of_birth`, p.`sex_id`, p.`civil_status_id`, p.`phil_id`, p.`attending_school`, 
      p.`educ_facility_id`, p.`grade_level_id`, p.`is_pregnant`, p.`health_facility_id`, 
      p.`occupation_id`, p.`ip_group_id`, p.`lrn`, p.`photo_src`, p.`roster_id`, 
      p.`dt_inserted`, p.`dt_updated`, p.`archived`, p.`dt_archived`, p.`child_grantee`, 
      p.`newmember_id`, p.`mcct_person_id`, p.`validation_num`
    FROM tbl_person p WHERE p.`archived` != 0;
    
    DELETE FROM tbl_person WHERE `archived` != 0;
    
    INSERT INTO tbl_hh_roster_dqa_1p SELECT * FROM tbl_hh_roster WHERE person_id IN (SELECT person_id FROM tbl_person_dqa_1p);
    DELETE FROM tbl_hh_roster WHERE person_id IN (SELECT person_id FROM tbl_person_dqa_1p);
    
    -- INSERT INTO tbl_household_dqa_1p SELECT * FROM tbl_household WHERE household_id IN (SELECT DISTINCT household_id FROM tbl_hh_roster_dqa_1p);
    -- DELETE FROM tbl_household WHERE household_id IN (SELECT DISTINCT household_id FROM tbl_hh_roster_dqa_1p);
    
    -- INSERT INTO tbl_beneficiary_dqa_1p SELECT * FROM tbl_beneficiary WHERE household_id IN (SELECT household_id FROM tbl_household_dqa_1p);
    -- DELETE FROM tbl_beneficiary WHERE beneficiary_id IN (SELECT beneficiary_id  FROM tbl_beneficiary_dqa_1p);
    
    -- INSERT INTO tbl_grantee_dqa_1p SELECT * FROM tbl_grantee WHERE beneficiary_id IN (SELECT beneficiary_id FROM tbl_beneficiary_dqa_1p);
    -- DELETE FROM tbl_grantee WHERE grantee_id IN (SELECT grantee_id FROM tbl_grantee_dqa_1p);
    
    -- ===============================================================
    
    -- DQA 2 Member
    -- Create the audit tables
    CREATE TABLE tbl_household_dqa_2p LIKE tbl_household;
    CREATE TABLE tbl_person_dqa_2p LIKE tbl_person;
    CREATE TABLE tbl_hh_roster_dqa_2p LIKE tbl_hh_roster;
    CREATE TABLE tbl_beneficiary_dqa_2p LIKE tbl_beneficiary;
    CREATE TABLE tbl_grantee_dqa_2p LIKE tbl_grantee;
    
    -- Truncate audit tables
    TRUNCATE TABLE tbl_household_dqa_2p;
    TRUNCATE TABLE tbl_person_dqa_2p;
    TRUNCATE TABLE tbl_hh_roster_dqa_2p;
    TRUNCATE TABLE tbl_beneficiary_dqa_2p;
    TRUNCATE TABLE tbl_grantee_dqa_2p;
    
    INSERT INTO tbl_hh_roster_dqa_2p SELECT * FROM tbl_hh_roster WHERE roster_status_id NOT IN (1,2,3,4,6,7,8,9,10,11);
    DELETE FROM tbl_hh_roster WHERE roster_status_id NOT IN (1,2,3,4,6,7,8,9,10,11);
    
    -- INSERT INTO tbl_household_dqa_2p SELECT * FROM tbl_household WHERE household_id IN (SELECT DISTINCT household_id FROM tbl_hh_roster_dqa_2p);
    -- DELETE FROM tbl_household WHERE household_id IN (SELECT household_id FROM tbl_household_dqa_2p);
    
    INSERT INTO tbl_person_dqa_2p (
      `person_id`, `first_name`, `middle_name`, `last_name`, `ext_name_id`, 
      `date_of_birth`, `sex_id`, `civil_status_id`, `phil_id`, `attending_school`, 
      `educ_facility_id`, `grade_level_id`, `is_pregnant`, `health_facility_id`, 
      `occupation_id`, `ip_group_id`, `lrn`, `photo_src`, `roster_id`, 
      `dt_inserted`, `dt_updated`, `archived`, `dt_archived`, `child_grantee`, 
      `newmember_id`, `mcct_person_id`, `validation_num`
    ) SELECT
      p.`person_id`, p.`first_name`, p.`middle_name`, p.`last_name`, p.`ext_name_id`, 
      p.`date_of_birth`, p.`sex_id`, p.`civil_status_id`, p.`phil_id`, p.`attending_school`, 
      p.`educ_facility_id`, p.`grade_level_id`, p.`is_pregnant`, p.`health_facility_id`, 
      p.`occupation_id`, p.`ip_group_id`, p.`lrn`, p.`photo_src`, p.`roster_id`, 
      p.`dt_inserted`, p.`dt_updated`, p.`archived`, p.`dt_archived`, p.`child_grantee`, 
      p.`newmember_id`, p.`mcct_person_id`, p.`validation_num`
    FROM tbl_person p WHERE p.person_id IN (SELECT person_id FROM tbl_hh_roster_dqa_2p);
    
    DELETE FROM tbl_person WHERE person_id IN (SELECT person_id FROM tbl_person_dqa_2p);
    
    INSERT INTO tbl_beneficiary_dqa_2p SELECT * FROM tbl_beneficiary WHERE household_id IN (SELECT DISTINCT household_id FROM tbl_hh_roster_dqa_2p);
    DELETE FROM tbl_beneficiary WHERE beneficiary_id IN (SELECT beneficiary_id  FROM tbl_beneficiary_dqa_2p);
    
    INSERT INTO tbl_grantee_dqa_2p SELECT * FROM tbl_grantee WHERE beneficiary_id IN (SELECT beneficiary_id FROM tbl_beneficiary_dqa_2p);
    DELETE FROM tbl_grantee WHERE grantee_id IN (SELECT grantee_id FROM tbl_grantee_dqa_2p);
    
    -- ===============================================================
    -- DQA 3 Member (Orphaned tbl_person logic fixed to LEFT JOIN to avoid locks)
    CREATE TABLE tbl_person_dqa_3p LIKE tbl_person;
    
    TRUNCATE TABLE tbl_person_dqa_3p;
    
    INSERT INTO tbl_person_dqa_3p (
      `person_id`, `first_name`, `middle_name`, `last_name`, `ext_name_id`, 
      `date_of_birth`, `sex_id`, `civil_status_id`, `phil_id`, `attending_school`, 
      `educ_facility_id`, `grade_level_id`, `is_pregnant`, `health_facility_id`, 
      `occupation_id`, `ip_group_id`, `lrn`, `photo_src`, `roster_id`, 
      `dt_inserted`, `dt_updated`, `archived`, `dt_archived`, `child_grantee`, 
      `newmember_id`, `mcct_person_id`, `validation_num`
    ) SELECT
      p.`person_id`, p.`first_name`, p.`middle_name`, p.`last_name`, p.`ext_name_id`, 
      p.`date_of_birth`, p.`sex_id`, p.`civil_status_id`, p.`phil_id`, p.`attending_school`, 
      p.`educ_facility_id`, p.`grade_level_id`, p.`is_pregnant`, p.`health_facility_id`, 
      p.`occupation_id`, p.`ip_group_id`, p.`lrn`, p.`photo_src`, p.`roster_id`, 
      p.`dt_inserted`, p.`dt_updated`, p.`archived`, p.`dt_archived`, p.`child_grantee`, 
      p.`newmember_id`, p.`mcct_person_id`, p.`validation_num`
    FROM tbl_person p 
    LEFT JOIN tbl_hh_roster r ON p.person_id = r.person_id 
    WHERE r.person_id IS NULL;
    
    DELETE p FROM tbl_person p 
    LEFT JOIN tbl_hh_roster r ON p.person_id = r.person_id 
    WHERE r.person_id IS NULL;
    
    -- ===============================================================
    -- -- DATA CLEANING
    
    -- Clean Grantee Account Numbers
    -- Step 1: Remove tabs, carriage returns, newlines, and spaces
    UPDATE tbl_grantee 
    SET account_no = REPLACE(REPLACE(REPLACE(REPLACE(account_no, '\r', ''), '\n', ''), '\t', ''), ' ', '')
    WHERE account_no REGEXP '[\r\n\t ]';

    -- Step 2: Clear account numbers that contain any non-numeric character (letters, symbols, etc.)
    UPDATE tbl_grantee
    SET account_no = NULL
    WHERE account_no REGEXP '[^0-9]';
    
    -- Clean Person Birthdates (fixing dates before 1900)
    UPDATE tbl_person p 
    SET p.date_of_birth = DATE_ADD(p.date_of_birth, INTERVAL (1900 - YEAR(p.date_of_birth)) YEAR) 
    WHERE p.date_of_birth < '1900-01-01';
    
END
//

DELIMITER ;