-- activities_orphans.sql (v3, stateless + no temp tables + subquery approach)
SET SESSION time_zone = '+00:00';
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET SESSION innodb_lock_wait_timeout = 5;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Purge today's Activities rows (idempotent reruns) - enhanced deduplication
DELETE FROM cross_file_integrity_summary
WHERE discovered_from_neo4j = 1
  AND DATE(analysis_timestamp) = CURDATE()
  AND relationship_name LIKE 'Activities.%';

/* 1) ClassCode → Activity Code (report-only) */
-- Use INSERT IGNORE to prevent duplicates if DELETE somehow fails
INSERT IGNORE INTO cross_file_integrity_summary (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, analysis_timestamp, processing_time_ms,
  relationship_type, business_priority, discovered_from_neo4j
)
SELECT
  UUID(),
  'Activities.ClassCode → Activities.Activity Code (report-only)',
  'activity_ilt_class*','activity_curriculum*','ClassCode→Activity Code',
  x.total_fk, x.total_pk, x.orphans_fk, 0,
  CASE WHEN x.total_fk = 0 THEN 100.00
       ELSE ROUND(100.0 * (x.total_fk - x.orphans_fk) / x.total_fk, 2)
  END,
  NOW(), 0, 'many_to_one', 'Medium', 1
FROM (
  SELECT
    (SELECT COUNT(DISTINCT UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))))
       FROM activity_ilt_class
       WHERE ClassCode IS NOT NULL AND TRIM(ClassCode) <> '') AS total_fk,
    (SELECT COUNT(DISTINCT UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(`Activity Code` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))))
       FROM activity_curriculum
       WHERE `Activity Code` IS NOT NULL AND TRIM(`Activity Code`) <> '') AS total_pk,
    (SELECT COUNT(DISTINCT s.ClassCode)
       FROM activity_ilt_class s
       WHERE s.ClassCode IS NOT NULL AND TRIM(s.ClassCode) <> ''
         AND NOT EXISTS (
           SELECT 1 FROM activity_curriculum t
           WHERE UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(t.`Activity Code` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))) = 
                 UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(s.ClassCode USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')))
         )) AS orphans_fk
    LIMIT 1
) x;

/* 2) ClassCode → Child ActivityCode (report-only) */
INSERT IGNORE INTO cross_file_integrity_summary (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, analysis_timestamp, processing_time_ms,
  relationship_type, business_priority, discovered_from_neo4j
)
SELECT
  UUID(),
  'Activities.ClassCode → Activity Links.Child ActivityCode (report-only)',
  'activity_ilt_class*','activity_curriculum*','ClassCode→Child ActivityCode',
  x.total_fk, x.total_pk, x.orphans_fk, 0,
  CASE WHEN x.total_fk = 0 THEN 100.00
       ELSE ROUND(100.0 * (x.total_fk - x.orphans_fk) / x.total_fk, 2)
  END,
  NOW(), 0, 'many_to_one', 'Medium', 1
FROM (
  SELECT
    (SELECT COUNT(DISTINCT UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))))
       FROM activity_ilt_class
       WHERE ClassCode IS NOT NULL AND TRIM(ClassCode) <> '') AS total_fk,
    (SELECT COUNT(DISTINCT UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(`Child ActivityCode` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))))
       FROM activity_curriculum
       WHERE `Child ActivityCode` IS NOT NULL AND TRIM(`Child ActivityCode`) <> '') AS total_pk,
    (SELECT COUNT(DISTINCT s.ClassCode)
       FROM activity_ilt_class s
       WHERE s.ClassCode IS NOT NULL AND TRIM(s.ClassCode) <> ''
         AND NOT EXISTS (
           SELECT 1 FROM activity_curriculum t
           WHERE UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(t.`Child ActivityCode` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))) = 
                 UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(s.ClassCode USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')))
         )) AS orphans_fk
    LIMIT 1
) x;

/* 3) ILTSessions ClassCode → Child ActivityCode (report-only) */
INSERT IGNORE INTO cross_file_integrity_summary (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, analysis_timestamp, processing_time_ms,
  relationship_type, business_priority, discovered_from_neo4j
)
SELECT
  UUID(),
  'Activities.SessionParts.ClassCode → Activity Links.Child ActivityCode (report-only)',
  'activity_ilt_sessions*','activity_curriculum*','ClassCode→Child ActivityCode',
  x.total_fk, x.total_pk, x.orphans_fk, 0,
  CASE WHEN x.total_fk = 0 THEN 100.00
       ELSE ROUND(100.0 * (x.total_fk - x.orphans_fk) / x.total_fk, 2)
  END,
  NOW(), 0, 'many_to_one', 'Medium', 1
FROM (
  SELECT
    (SELECT COUNT(DISTINCT UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))))
       FROM activity_ilt_sessions
       WHERE ClassCode IS NOT NULL AND TRIM(ClassCode) <> '') AS total_fk,
    (SELECT COUNT(DISTINCT UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(`Child ActivityCode` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))))
       FROM activity_curriculum
       WHERE `Child ActivityCode` IS NOT NULL AND TRIM(`Child ActivityCode`) <> '') AS total_pk,
    (SELECT COUNT(DISTINCT s.ClassCode)
       FROM activity_ilt_sessions s
       WHERE s.ClassCode IS NOT NULL AND TRIM(s.ClassCode) <> ''
         AND NOT EXISTS (
           SELECT 1 FROM activity_curriculum t
           WHERE UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(t.`Child ActivityCode` USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' '))) = 
                 UPPER(TRIM(REPLACE(REPLACE(REPLACE(CONVERT(s.ClassCode USING utf8mb4), CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')))
         )) AS orphans_fk
    LIMIT 1
) x;
