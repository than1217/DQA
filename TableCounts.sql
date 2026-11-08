SELECT 'tbl_person' AS `table`, (SELECT COUNT(*) FROM tbl_person) AS `count_of_table`
UNION ALL
SELECT 'tbl_hh_roster', (SELECT COUNT(*) FROM tbl_hh_roster)
UNION ALL
SELECT 'tbl_household', (SELECT COUNT(*) FROM tbl_household)
UNION ALL
SELECT 'tbl_beneficiary', (SELECT COUNT(*) FROM tbl_beneficiary)
UNION ALL
SELECT 'tbl_grantee', (SELECT COUNT(*) FROM tbl_grantee)
UNION ALL
SELECT 'tbl_family_selected', (SELECT COUNT(*) FROM tbl_family_selected)
UNION ALL
SELECT 'tbl_family_assoc_ops', (SELECT COUNT(*) FROM tbl_family_assoc_ops);