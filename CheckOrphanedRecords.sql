-- ===============================================================
-- DQA QUERIES: ORPHANED RECORDS CHECK
-- ===============================================================

-- 1. ORPHANED PERSONS
-- Person records that do not have an associated household roster entry.
SELECT p.person_id, p.first_name, p.last_name 
FROM tbl_person p 
LEFT JOIN tbl_hh_roster r ON p.person_id = r.person_id 
WHERE r.person_id IS NULL;

-- 2. ORPHANED HOUSEHOLD ROSTERS (Missing Person)
-- Roster records pointing to a person_id that no longer exists in tbl_person.
SELECT r.hh_roster_id, r.household_id, r.person_id 
FROM tbl_hh_roster r 
LEFT JOIN tbl_person p ON r.person_id = p.person_id 
WHERE p.person_id IS NULL;

-- 3. ORPHANED HOUSEHOLD ROSTERS (Missing Household)
-- Roster records pointing to a household_id that no longer exists in tbl_household.
SELECT r.hh_roster_id, r.household_id, r.person_id 
FROM tbl_hh_roster r 
LEFT JOIN tbl_household h ON r.household_id = h.household_id 
WHERE h.household_id IS NULL;

-- 4. ORPHANED BENEFICIARIES
-- Beneficiary records pointing to a household_id that no longer exists in tbl_household.
SELECT b.beneficiary_id, b.household_id 
FROM tbl_beneficiary b 
LEFT JOIN tbl_household h ON b.household_id = h.household_id 
WHERE h.household_id IS NULL;

-- 5. ORPHANED GRANTEES (Missing Beneficiary)
-- Grantee records pointing to a beneficiary_id that no longer exists in tbl_beneficiary.
SELECT g.grantee_id, g.beneficiary_id 
FROM tbl_grantee g 
LEFT JOIN tbl_beneficiary b ON g.beneficiary_id = b.beneficiary_id 
WHERE b.beneficiary_id IS NULL;

-- 6. ORPHANED GRANTEES (Missing Person)
-- Grantee records pointing to a person_id that no longer exists in tbl_person.
SELECT g.grantee_id, g.person_id 
FROM tbl_grantee g 
LEFT JOIN tbl_person p ON g.person_id = p.person_id 
WHERE p.person_id IS NULL;
