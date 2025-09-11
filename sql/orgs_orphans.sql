-- orgs_orphans.sql (stateless, today-only)
-- PK=Organization Code, FKs=Primary Domain Name / Primary Organization Name via name
SET SESSION time_zone = '+00:00';
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Clear today's Orgs rows - enhanced deduplication
DELETE FROM cross_file_integrity_summary
WHERE relationship_name LIKE 'Orgs.%'
  AND DATE(analysis_timestamp) = CURDATE();

/* 1) Employees.Primary Domain Name → Organizations.Organization Code (via name) */
INSERT IGNORE INTO cross_file_integrity_summary (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, processing_time_ms, relationship_type, business_priority, discovered_from_neo4j, analysis_timestamp
)
SELECT
  UUID(),
  'Orgs.Employees.Primary Domain Name → Organizations.Organization Code',
  'core_employee','core_organization|core_domain','Primary Domain Name→Organization Code (via name)',
  x.total_fk, x.total_pk, x.orphans_fk, 0,
  CASE WHEN x.total_fk = 0 THEN 100.00
       ELSE ROUND(100.0 * (x.total_fk - x.orphans_fk) / x.total_fk, 2)
  END,
  0, 'many_to_one', 'High', 1, NOW()
FROM (
  SELECT
    (SELECT COUNT(DISTINCT UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(`Primary Domain Name` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))))
       FROM core_employee
       WHERE `Primary Domain Name` IS NOT NULL AND TRIM(`Primary Domain Name`) <> '') AS total_fk,
    (SELECT COUNT(DISTINCT UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(`Organization Code` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))))
       FROM (
         SELECT `Organization Code` FROM core_organization WHERE `Organization Code` IS NOT NULL AND TRIM(`Organization Code`) <> ''
         UNION
         SELECT `Organization Code` FROM core_domain WHERE `Organization Code` IS NOT NULL AND TRIM(`Organization Code`) <> ''
       ) org_codes) AS total_pk,
    (SELECT COUNT(DISTINCT e.`Primary Domain Name`)
       FROM core_employee e
       WHERE e.`Primary Domain Name` IS NOT NULL AND TRIM(e.`Primary Domain Name`) <> ''
         AND NOT EXISTS (
           SELECT 1 FROM core_organization o
           WHERE UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(o.`Organization Name` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))) = 
                 UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(e.`Primary Domain Name` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')))
         )
         AND NOT EXISTS (
           SELECT 1 FROM core_domain d
           WHERE UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(d.`Organization Name` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))) = 
                 UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(e.`Primary Domain Name` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')))
         )) AS orphans_fk
    LIMIT 1
) x;

/* 2) Employees.Primary Organization Name → Organizations.Organization Code (via name) */
INSERT IGNORE INTO cross_file_integrity_summary (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, processing_time_ms, relationship_type, business_priority, discovered_from_neo4j, analysis_timestamp
)
SELECT
  UUID(),
  'Orgs.Employees.Primary Organization Name → Organizations.Organization Code',
  'core_employee','core_organization|core_domain','Primary Organization Name→Organization Code (via name)',
  x.total_fk, x.total_pk, x.orphans_fk, 0,
  CASE WHEN x.total_fk = 0 THEN 100.00
       ELSE ROUND(100.0 * (x.total_fk - x.orphans_fk) / x.total_fk, 2)
  END,
  0, 'many_to_one', 'High', 1, NOW()
FROM (
  SELECT
    (SELECT COUNT(DISTINCT UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(`Primary Organization Name` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))))
       FROM core_employee
       WHERE `Primary Organization Name` IS NOT NULL AND TRIM(`Primary Organization Name`) <> '') AS total_fk,
    (SELECT COUNT(DISTINCT UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(`Organization Code` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))))
       FROM (
         SELECT `Organization Code` FROM core_organization WHERE `Organization Code` IS NOT NULL AND TRIM(`Organization Code`) <> ''
         UNION
         SELECT `Organization Code` FROM core_domain WHERE `Organization Code` IS NOT NULL AND TRIM(`Organization Code`) <> ''
       ) org_codes) AS total_pk,
    (SELECT COUNT(DISTINCT e.`Primary Organization Name`)
       FROM core_employee e
       WHERE e.`Primary Organization Name` IS NOT NULL AND TRIM(e.`Primary Organization Name`) <> ''
         AND NOT EXISTS (
           SELECT 1 FROM core_organization o
           WHERE UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(o.`Organization Name` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))) = 
                 UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(e.`Primary Organization Name` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')))
         )
         AND NOT EXISTS (
           SELECT 1 FROM core_domain d
           WHERE UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(d.`Organization Name` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))) = 
                 UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(e.`Primary Organization Name` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')))
         )) AS orphans_fk
    LIMIT 1
) x;