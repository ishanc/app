-- Charset + safe session settings
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET SESSION innodb_lock_wait_timeout = 60;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Optional: align time math
SET SESSION time_zone = 'SYSTEM';

-- Create freshness tracking table
CREATE TABLE IF NOT EXISTS file_ingest_log (
  table_name      VARCHAR(128) PRIMARY KEY,
  last_loaded_at  DATETIME NOT NULL,
  last_row_count  BIGINT UNSIGNED NULL,
  last_source     VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* Bootstrap/update sources we intend to consider "fresh" today */
REPLACE INTO file_ingest_log (table_name, last_loaded_at, last_row_count, last_source)
VALUES
  ('core_employee',         NOW(), (SELECT COUNT(*) FROM core_employee),         'job:employees_orphans'),
  ('transcript_curriculum', NOW(), (SELECT COUNT(*) FROM transcript_curriculum), 'job:employees_orphans'),
  ('prerequisites_instructor', NOW(), (SELECT COUNT(*) FROM prerequisites_instructor), 'job:employees_orphans'),
  ('activity_curriculum',   NOW(), (SELECT COUNT(*) FROM activity_curriculum),   'job:employees_orphans');

-- Purge today's Employees rows (commented out - using deduplication instead)
-- DELETE FROM cross_file_integrity_summary
-- WHERE discovered_from_neo4j = 1
--   AND analysis_timestamp >= CURRENT_DATE()
--   AND analysis_timestamp <  CURRENT_DATE() + INTERVAL 1 DAY
--   AND relationship_name IN (
--     'Employees.Transcript.*.EmployeeID → Employees.PersonNumber',
--     'Employees.Prerequisites_Instructor.EmployeeId → Employees.PersonNumber',
--     'Employees.Activity_Curriculum.Owner → Employees.PersonNumber (report-only)'
--   );

/* ========= 1) Transcript.*.EmployeeID → Employees.PersonNumber ========= */
INSERT INTO cross_file_integrity_summary (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, processing_time_ms, relationship_type, business_priority, discovered_from_neo4j, analysis_timestamp
)
SELECT
  UUID(),
  'Employees.Transcript.*.EmployeeID → Employees.PersonNumber',
  'transcript_*', 'core_employee*', 'EmployeeID→PersonNumber',
  x.total_fk, x.total_pk, x.orphans_fk, 0,
  CASE WHEN x.total_fk = 0 THEN 100.00
       ELSE ROUND(100.0 * (x.total_fk - x.orphans_fk) / x.total_fk, 2)
  END,
  0, 'many_to_one', 'High', 1, NOW()
FROM (
  SELECT
    (SELECT COUNT(DISTINCT EmployeeID)
       FROM transcript_curriculum
       WHERE EmployeeID IS NOT NULL) AS total_fk,
    (SELECT COUNT(DISTINCT PersonNumber)
       FROM core_employee
       WHERE PersonNumber IS NOT NULL) AS total_pk,
    (SELECT COUNT(DISTINCT t.EmployeeID)
       FROM transcript_curriculum t
       LEFT JOIN core_employee e ON t.EmployeeID = e.PersonNumber
       WHERE t.EmployeeID IS NOT NULL
         AND e.PersonNumber IS NULL) AS orphans_fk
) AS x
WHERE EXISTS (
  SELECT 1 FROM file_ingest_log
  WHERE table_name='transcript_curriculum'
    AND last_loaded_at >= CURRENT_DATE()
    AND last_loaded_at <  CURRENT_DATE() + INTERVAL 1 DAY
)
AND NOT EXISTS (
  SELECT 1
  FROM cross_file_integrity_summary s
  WHERE s.discovered_from_neo4j = 1
    AND s.relationship_name = 'Employees.Transcript.*.EmployeeID → Employees.PersonNumber'
    AND s.analysis_timestamp >= CURRENT_DATE()
    AND s.analysis_timestamp <  CURRENT_DATE() + INTERVAL 1 DAY
);

/* ======== 2) Prerequisites_Instructor.EmployeeId → Employees.PersonNumber ======== */
INSERT INTO cross_file_integrity_summary (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, processing_time_ms, relationship_type, business_priority, discovered_from_neo4j, analysis_timestamp
)
SELECT
  UUID(),
  'Employees.Prerequisites_Instructor.EmployeeId → Employees.PersonNumber',
  'prerequisites_instructor*', 'core_employee*', 'EmployeeId→PersonNumber',
  x.total_fk, x.total_pk, x.orphans_fk, 0,
  CASE WHEN x.total_fk = 0 THEN 100.00
       ELSE ROUND(100.0 * (x.total_fk - x.orphans_fk) / x.total_fk, 2)
  END,
  0, 'many_to_one', 'High', 1, NOW()
FROM (
  SELECT
    (SELECT COUNT(DISTINCT EmployeeId)
       FROM prerequisites_instructor
       WHERE EmployeeId IS NOT NULL) AS total_fk,
    (SELECT COUNT(DISTINCT PersonNumber)
       FROM core_employee
       WHERE PersonNumber IS NOT NULL) AS total_pk,
    (SELECT COUNT(DISTINCT p.EmployeeId)
       FROM prerequisites_instructor p
       LEFT JOIN core_employee e ON p.EmployeeId = e.PersonNumber
       WHERE p.EmployeeId IS NOT NULL
         AND e.PersonNumber IS NULL) AS orphans_fk
) AS x
WHERE EXISTS (
  SELECT 1 FROM file_ingest_log
  WHERE table_name='prerequisites_instructor'
    AND last_loaded_at >= CURRENT_DATE()
    AND last_loaded_at <  CURRENT_DATE() + INTERVAL 1 DAY
)
AND NOT EXISTS (
  SELECT 1
  FROM cross_file_integrity_summary s
  WHERE s.discovered_from_neo4j = 1
    AND s.relationship_name = 'Employees.Prerequisites_Instructor.EmployeeId → Employees.PersonNumber'
    AND s.analysis_timestamp >= CURRENT_DATE()
    AND s.analysis_timestamp <  CURRENT_DATE() + INTERVAL 1 DAY
);

/* === 3) Activity_Curriculum.Owner → Employees.PersonNumber (report-only) === */
INSERT INTO cross_file_integrity_summary (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, processing_time_ms, relationship_type, business_priority, discovered_from_neo4j, analysis_timestamp
)
SELECT
  UUID(),
  'Employees.Activity_Curriculum.Owner → Employees.PersonNumber (report-only)',
  'activity_curriculum*', 'core_employee*', 'Owner→PersonNumber',
  x.total_fk, x.total_pk, x.orphans_fk, 0,
  CASE WHEN x.total_fk = 0 THEN NULL
       ELSE ROUND(100.0 * (x.total_fk - x.orphans_fk) / x.total_fk, 2)
  END,
  0, 'many_to_one', 'Info', 1, NOW()
FROM (
  SELECT
    (SELECT COUNT(DISTINCT Owner)
       FROM activity_curriculum
       WHERE Owner IS NOT NULL) AS total_fk,
    (SELECT COUNT(DISTINCT PersonNumber)
       FROM core_employee
       WHERE PersonNumber IS NOT NULL) AS total_pk,
    (SELECT COUNT(DISTINCT a.Owner)
       FROM activity_curriculum a
       LEFT JOIN core_employee e ON a.Owner = e.PersonNumber
       WHERE a.Owner IS NOT NULL
         AND e.PersonNumber IS NULL) AS orphans_fk
) AS x
WHERE EXISTS (
  SELECT 1 FROM file_ingest_log
  WHERE table_name='activity_curriculum'
    AND last_loaded_at >= CURRENT_DATE()
    AND last_loaded_at <  CURRENT_DATE() + INTERVAL 1 DAY
)
AND NOT EXISTS (
  SELECT 1
  FROM cross_file_integrity_summary s
  WHERE s.discovered_from_neo4j = 1
    AND s.relationship_name = 'Employees.Activity_Curriculum.Owner → Employees.PersonNumber (report-only)'
    AND s.analysis_timestamp >= CURRENT_DATE()
    AND s.analysis_timestamp <  CURRENT_DATE() + INTERVAL 1 DAY
);
