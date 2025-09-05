-- activities_orphans.sql (v2, stateless + UTC + sargable "today")
SET SESSION time_zone = '+00:00';
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET SESSION innodb_lock_wait_timeout = 5;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Purge today's Activities rows (idempotent reruns)
DELETE FROM cross_file_integrity_summary
WHERE discovered_from_neo4j = 1
  AND analysis_timestamp >= CURRENT_DATE()
  AND analysis_timestamp <  CURRENT_DATE() + INTERVAL 1 DAY
  AND relationship_name LIKE 'Activities.%';

-- =========================================
-- 1) Canonical Activity PK cache (Activity Code)
-- =========================================
DROP TEMPORARY TABLE IF EXISTS valid_activity_pk;
CREATE TEMPORARY TABLE valid_activity_pk ( pk VARCHAR(500) PRIMARY KEY ) ENGINE=InnoDB;

INSERT IGNORE INTO valid_activity_pk (pk)
SELECT DISTINCT
  UPPER(
    TRIM(
      REPLACE(
        REPLACE(
          REPLACE(
            CONVERT(`Activity Code` USING utf8mb4),
            CHAR(194,160), ' '      -- NBSP
          ),
          CHAR(226,128,175), ' '    -- figure dash
        ),
        CHAR(226,128,135), ' '      -- hyphen (U+0087 in some exports)
      )
    )
  ) AS pk
FROM activity_curriculum
WHERE `Activity Code` IS NOT NULL
  AND TRIM(
        REPLACE(
          REPLACE(
            REPLACE(
              CONVERT(`Activity Code` USING utf8mb4),
              CHAR(194,160), ' '
            ),
            CHAR(226,128,175), ' '
          ),
          CHAR(226,128,135), ' '
        )
      ) <> '';

-- =========================================
-- 2) DISABLED: ILTCourseCode → Activity Code relationship
-- =========================================
-- REASON: Data format incompatibility between ILT titles and Activity codes
-- ILTCourseCode contains descriptive titles like "11th Annual Steel Markets..."
-- Activity Code contains structured codes like "5S_5S Workplace Productivity..."
-- Will re-enable when ETL corrects ILTCourseCode to contain actual Activity Code tokens

-- =========================================
-- 3) Child Activity PK cache (Child ActivityCode)
-- =========================================
DROP TEMPORARY TABLE IF EXISTS valid_child_pk;
CREATE TEMPORARY TABLE valid_child_pk ( pk VARCHAR(500) PRIMARY KEY ) ENGINE=InnoDB;

INSERT IGNORE INTO valid_child_pk (pk)
SELECT DISTINCT
  UPPER(
    TRIM(
      REPLACE(
        REPLACE(
          REPLACE(
            CONVERT(`Child ActivityCode` USING utf8mb4),
            CHAR(194,160), ' '
          ),
          CHAR(226,128,175), ' '
        ),
        CHAR(226,128,135), ' '
      )
    )
  ) AS pk
FROM activity_curriculum
WHERE `Child ActivityCode` IS NOT NULL
  AND TRIM(
        REPLACE(
          REPLACE(
            REPLACE(
              CONVERT(`Child ActivityCode` USING utf8mb4),
              CHAR(194,160), ' '
            ),
            CHAR(226,128,175), ' '
          ),
          CHAR(226,128,135), ' '
        )
      ) <> '';

-- 3a) ILTCourseCode → Child ActivityCode (report-only)
INSERT INTO cross_file_integrity_summary (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, processing_time_ms, relationship_type, business_priority, discovered_from_neo4j
)
SELECT
  UUID(),
  'Activities.ILTCourseCode → Activity Links.Child ActivityCode (report-only)',
  'activity_ilt_class*','activity_curriculum*','ILTCourseCode→Child ActivityCode',
  src.total_src,
  tgt.total_tgt,
  (src.total_src - src.matched),
  0,
  CASE WHEN src.total_src = 0 THEN NULL
       ELSE ROUND(100.0 * src.matched / src.total_src, 2) END,
  NULL, 'many_to_one','Medium',1
FROM (
  SELECT
    COUNT(*) AS total_src,
    SUM(CASE WHEN p.pk IS NOT NULL THEN 1 ELSE 0 END) AS matched
  FROM (
    SELECT DISTINCT UPPER(TRIM(
      REPLACE(REPLACE(REPLACE(CONVERT(ILTCourseCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
    ))))) AS fk
    FROM activity_ilt_class
    WHERE ILTCourseCode IS NOT NULL
      AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ILTCourseCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
      )) <> ''
  ) s
  LEFT JOIN valid_child_pk p ON s.fk = p.pk
) src
CROSS JOIN (
  SELECT COUNT(*) AS total_tgt FROM valid_child_pk
) tgt;

-- =========================================
-- 4) ClassCode → Activity Code (report-only)
-- =========================================
INSERT INTO cross_file_integrity_summary (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, processing_time_ms, relationship_type, business_priority, discovered_from_neo4j
)
SELECT
  UUID(),
  'Activities.ClassCode → Activities.Activity Code (report-only)',
  'activity_ilt_class*','activity_curriculum*','ClassCode→Activity Code',
  src.total_src,
  tgt.total_tgt,
  (src.total_src - src.matched),
  0,
  CASE WHEN src.total_src = 0 THEN NULL
       ELSE ROUND(100.0 * src.matched / src.total_src, 2) END,
  NULL, 'many_to_one','Medium',1
FROM (
  SELECT
    COUNT(*) AS total_src,
    SUM(CASE WHEN p.pk IS NOT NULL THEN 1 ELSE 0 END) AS matched
  FROM (
    SELECT DISTINCT UPPER(TRIM(
      REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
    ))))) AS fk
    FROM activity_ilt_class
    WHERE ClassCode IS NOT NULL
      AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
      )) <> ''
  ) s
  LEFT JOIN valid_activity_pk p ON s.fk = p.pk
) src
CROSS JOIN (
  SELECT COUNT(*) AS total_tgt FROM valid_activity_pk
) tgt;

-- =========================================
-- 5a) ClassCode (ILT Class) → Child ActivityCode (report-only)
-- =========================================
INSERT INTO cross_file_integrity_summary (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, processing_time_ms, relationship_type, business_priority, discovered_from_neo4j
)
SELECT
  UUID(),
  'Activities.ClassCode → Activity Links.Child ActivityCode (report-only)',
  'activity_ilt_class*','activity_curriculum*','ClassCode→Child ActivityCode',
  src.total_src,
  tgt.total_tgt,
  (src.total_src - src.matched),
  0,
  CASE WHEN src.total_src = 0 THEN NULL
       ELSE ROUND(100.0 * src.matched / src.total_src, 2) END,
  NULL, 'many_to_one','Medium',1
FROM (
  SELECT
    COUNT(*) AS total_src,
    SUM(CASE WHEN p.pk IS NOT NULL THEN 1 ELSE 0 END) AS matched
  FROM (
    SELECT DISTINCT UPPER(TRIM(
      REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
    ))))) AS fk
    FROM activity_ilt_class
    WHERE ClassCode IS NOT NULL
      AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
      )) <> ''
  ) s
  LEFT JOIN valid_child_pk p ON s.fk = p.pk
) src
CROSS JOIN (
  SELECT COUNT(*) AS total_tgt FROM valid_child_pk
) tgt;

-- =========================================
-- 5b) ClassCode (ILT Sessions) → Child ActivityCode (report-only)
-- =========================================
INSERT INTO cross_file_integrity_summary (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, processing_time_ms, relationship_type, business_priority, discovered_from_neo4j
)
SELECT
  UUID(),
  'Activities.SessionParts.ClassCode → Activity Links.Child ActivityCode (report-only)',
  'activity_ilt_sessions*','activity_curriculum*','ClassCode→Child ActivityCode',
  src.total_src,
  tgt.total_tgt,
  (src.total_src - src.matched),
  0,
  CASE WHEN src.total_src = 0 THEN NULL
       ELSE ROUND(100.0 * src.matched / src.total_src, 2) END,
  NULL, 'many_to_one','Medium',1
FROM (
  SELECT
    COUNT(*) AS total_src,
    SUM(CASE WHEN p.pk IS NOT NULL THEN 1 ELSE 0 END) AS matched
  FROM (
    SELECT DISTINCT UPPER(TRIM(
      REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
    ))))) AS fk
    FROM activity_ilt_sessions
    WHERE ClassCode IS NOT NULL
      AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
      )) <> ''
  ) s
  LEFT JOIN valid_child_pk p ON s.fk = p.pk
) src
CROSS JOIN (
  SELECT COUNT(*) AS total_tgt FROM valid_child_pk
) tgt;
