-- Ensure session charset (optional)
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ==============================
-- Parent PK cache: Activities.Activity Code (canonical anchor)
-- ==============================
DROP TEMPORARY TABLE IF EXISTS valid_activity_pk;
CREATE TEMPORARY TABLE valid_activity_pk ( pk VARCHAR(500) PRIMARY KEY ) ENGINE=InnoDB;

INSERT IGNORE INTO valid_activity_pk (pk)
SELECT DISTINCT UPPER(TRIM(
  REPLACE(REPLACE(REPLACE(CONVERT(`Activity Code` USING utf8mb4),
    CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
))
FROM activity_curriculum
WHERE `Activity Code` IS NOT NULL
  AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(`Activity Code` USING utf8mb4),
    CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> '';

-- ==============================
-- Parent summary: ILTCourseCode → Activities.Activity Code (info/mismatch)
-- ==============================
SET @total_pk = (SELECT COUNT(*) FROM valid_activity_pk);

SET @total_fk = (
  SELECT COUNT(DISTINCT UPPER(TRIM(
    REPLACE(REPLACE(REPLACE(CONVERT(ILTCourseCode USING utf8mb4),
      CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
  )))
  FROM activity_ilt_class
  WHERE ILTCourseCode IS NOT NULL
    AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ILTCourseCode USING utf8mb4),
      CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> ''
);

SET @orphans = (
  SELECT COUNT(*)
  FROM (
    SELECT DISTINCT UPPER(TRIM(
      REPLACE(REPLACE(REPLACE(CONVERT(ILTCourseCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
    )) AS fk
    FROM activity_ilt_class
    WHERE ILTCourseCode IS NOT NULL
      AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ILTCourseCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> ''
  ) s
  LEFT JOIN valid_activity_pk p ON s.fk = p.pk
  WHERE p.pk IS NULL
);

SET @integrity = CASE
  WHEN @total_fk = 0 THEN 100.00
  ELSE ROUND(100.0 * (@total_fk - @orphans) / @total_fk, 2)
END;

-- Dynamic priority calculation based on integrity percentage
SET @priority_parent = CASE
  WHEN @total_fk = 0 OR @integrity IS NULL THEN 'Info'
  WHEN @integrity < 10 THEN 'Critical'
  WHEN @integrity < 50 THEN 'High'
  WHEN @integrity < 90 THEN 'Medium'
  ELSE 'Info'
END;

SET @run = UUID();
INSERT INTO cross_file_integrity_staging (
  analysis_run_id,
  relationship_name,
  source_file_pattern,
  target_file_pattern,
  key_field,
  total_source_records,
  total_target_records,
  orphaned_source_records,
  orphaned_target_records,
  integrity_percentage,
  processing_time_ms,
  relationship_type,
  business_priority,
  discovered_from_neo4j
)
VALUES (
  @run,
  'Activity_Sessions.ILTCourseCode → Activities.Activity Code',
  'activity_ilt_class*',
  'activity_curriculum*',
  'ILTCourseCode→Activity Code',
  @total_fk,
  @total_pk,
  @orphans,
  0,
  @integrity,
  0,
  'many_to_one',
  @priority_parent,
  1
);

-- ==============================
-- Child PK cache: Activity Links.Child ActivityCode
-- ==============================
DROP TEMPORARY TABLE IF EXISTS valid_child_pk;
CREATE TEMPORARY TABLE valid_child_pk ( pk VARCHAR(500) PRIMARY KEY ) ENGINE=InnoDB;

INSERT IGNORE INTO valid_child_pk (pk)
SELECT DISTINCT UPPER(TRIM(
  REPLACE(REPLACE(REPLACE(CONVERT(`Child ActivityCode` USING utf8mb4),
    CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
))
FROM activity_curriculum
WHERE `Child ActivityCode` IS NOT NULL
  AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(`Child ActivityCode` USING utf8mb4),
    CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> '';

-- ==============================
-- Child summary: ILTCourseCode → Activity Links.Child ActivityCode (authoritative)
-- ==============================
SET @total_pk_child = (SELECT COUNT(*) FROM valid_child_pk);

SET @total_fk_child = (
  SELECT COUNT(DISTINCT UPPER(TRIM(
    REPLACE(REPLACE(REPLACE(CONVERT(ILTCourseCode USING utf8mb4),
      CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
  )))
  FROM activity_ilt_class
  WHERE ILTCourseCode IS NOT NULL
    AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ILTCourseCode USING utf8mb4),
      CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> ''
);

SET @orphans_child = (
  SELECT COUNT(*)
  FROM (
    SELECT DISTINCT UPPER(TRIM(
      REPLACE(REPLACE(REPLACE(CONVERT(ILTCourseCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
    )) AS fk
    FROM activity_ilt_class
    WHERE ILTCourseCode IS NOT NULL
      AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ILTCourseCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> ''
  ) s
  LEFT JOIN valid_child_pk p ON s.fk = p.pk
  WHERE p.pk IS NULL
);

SET @integrity_child = IF(@total_fk_child = 0, NULL,
  ROUND(100.0 * (@total_fk_child - @orphans_child) / @total_fk_child, 2)
);

-- Dynamic priority calculation for child ActivityCode
SET @priority_child = CASE
  WHEN @total_fk_child = 0 OR @integrity_child IS NULL THEN 'Info'
  WHEN @integrity_child < 10 THEN 'Critical'
  WHEN @integrity_child < 50 THEN 'High'
  WHEN @integrity_child < 90 THEN 'Medium'
  ELSE 'Info'
END;

SET @run_child = UUID();
INSERT INTO cross_file_integrity_staging (
  analysis_run_id,
  relationship_name,
  source_file_pattern,
  target_file_pattern,
  key_field,
  total_source_records,
  total_target_records,
  orphaned_source_records,
  orphaned_target_records,
  integrity_percentage,
  processing_time_ms,
  relationship_type,
  business_priority,
  discovered_from_neo4j
)
VALUES (
  @run_child,
  'Activity_Sessions.ILTCourseCode → Activity Links.Child ActivityCode',
  'activity_ilt_class*',
  'activity_curriculum*',
  'ILTCourseCode→Child ActivityCode',
  @total_fk_child,
  @total_pk_child,
  @orphans_child,
  0,
  @integrity_child,
  0,
  'many_to_one',
  @priority_child,
  1
);

-- ==============================
-- Report-only: ClassCode → Activities.Activity Code
-- ==============================
SET @total_fk_cc = (
  SELECT COUNT(DISTINCT UPPER(TRIM(
    REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
      CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
  )))
  FROM activity_ilt_class
  WHERE ClassCode IS NOT NULL
    AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
      CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> ''
);

SET @orph_cc = (
  SELECT COUNT(*)
  FROM (
    SELECT DISTINCT UPPER(TRIM(
      REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
    )) AS fk
    FROM activity_ilt_class
    WHERE ClassCode IS NOT NULL
      AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> ''
  ) s
  LEFT JOIN valid_activity_pk p ON s.fk = p.pk
  WHERE p.pk IS NULL
);

SET @integrity_cc = IF(@total_fk_cc = 0, NULL,
  ROUND(100.0 * (@total_fk_cc - @orph_cc) / @total_fk_cc, 2)
);

-- ClassCode relationships are Info-only (expected 0% - naming drift monitoring)
SET @priority_cc = 'Info';

SET @run_cc = UUID();
INSERT INTO cross_file_integrity_staging (
  analysis_run_id,
  relationship_name,
  source_file_pattern,
  target_file_pattern,
  key_field,
  total_source_records,
  total_target_records,
  orphaned_source_records,
  orphaned_target_records,
  integrity_percentage,
  processing_time_ms,
  relationship_type,
  business_priority,
  discovered_from_neo4j
)
VALUES (
  @run_cc,
  'Activity_Sessions.ClassCode → Activities.Activity Code (report-only)',
  'activity_ilt_class*',
  'activity_curriculum*',
  'ClassCode→Activity Code',
  @total_fk_cc,
  (SELECT COUNT(*) FROM valid_activity_pk),
  @orph_cc,
  0,
  @integrity_cc,
  0,
  'many_to_one',
  @priority_cc,
  1
);

-- ==============================
-- Report-only: ClassCode → Activity Links.Child ActivityCode
-- ==============================
SET @total_fk_cc_child = (
  SELECT COUNT(DISTINCT UPPER(TRIM(
    REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
      CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
  )))
  FROM activity_ilt_class
  WHERE ClassCode IS NOT NULL
    AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
      CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> ''
);

SET @orph_cc_child = (
  SELECT COUNT(*)
  FROM (
    SELECT DISTINCT UPPER(TRIM(
      REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
    )) AS fk
    FROM activity_ilt_class
    WHERE ClassCode IS NOT NULL
      AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> ''
  ) s
  LEFT JOIN valid_child_pk p ON s.fk = p.pk
  WHERE p.pk IS NULL
);

SET @integrity_cc_child = IF(@total_fk_cc_child = 0, NULL,
  ROUND(100.0 * (@total_fk_cc_child - @orph_cc_child) / @total_fk_cc_child, 2)
);

-- ClassCode relationships are Info-only (expected 0% - naming drift monitoring)
SET @priority_cc_child = 'Info';

SET @run_cc_child = UUID();
INSERT INTO cross_file_integrity_staging (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, processing_time_ms, relationship_type, business_priority, discovered_from_neo4j
)
VALUES (
  @run_cc_child,
  'Activity_Sessions.ClassCode → Activity Links.Child ActivityCode (report-only)',
  'activity_ilt_class*',
  'activity_curriculum*',
  'ClassCode→Child ActivityCode',
  @total_fk_cc_child, (SELECT COUNT(*) FROM valid_child_pk), @orph_cc_child, 0,
  @integrity_cc_child, 0, 'many_to_one', @priority_cc_child, 1
);

-- ==============================
-- Report-only: SessionParts.ClassCode → Activity Links.Child ActivityCode
-- ==============================
SET @total_fk_cc_child_sp = (
  SELECT COUNT(DISTINCT UPPER(TRIM(
    REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
      CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
  )))
  FROM activity_ilt_sessions
  WHERE ClassCode IS NOT NULL
    AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
      CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> ''
);

SET @orph_cc_child_sp = (
  SELECT COUNT(*)
  FROM (
    SELECT DISTINCT UPPER(TRIM(
      REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')
    )) AS fk
    FROM activity_ilt_sessions
    WHERE ClassCode IS NOT NULL
      AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT(ClassCode USING utf8mb4),
        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> ''
  ) s
  LEFT JOIN valid_child_pk p ON s.fk = p.pk
  WHERE p.pk IS NULL
);

SET @integrity_cc_child_sp = IF(@total_fk_cc_child_sp = 0, NULL,
  ROUND(100.0 * (@total_fk_cc_child_sp - @orph_cc_child_sp) / @total_fk_cc_child_sp, 2)
);

-- ClassCode relationships are Info-only (expected 0% - naming drift monitoring)
SET @priority_cc_child_sp = 'Info';

SET @run_cc_child_sp = UUID();
INSERT INTO cross_file_integrity_staging (
  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,
  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,
  integrity_percentage, processing_time_ms, relationship_type, business_priority, discovered_from_neo4j
)
VALUES (
  @run_cc_child_sp,
  'Activity_SessionParts.ClassCode → Activity Links.Child ActivityCode (report-only)',
  'activity_ilt_sessions*',
  'activity_curriculum*',
  'ClassCode→Child ActivityCode',
  @total_fk_cc_child_sp, (SELECT COUNT(*) FROM valid_child_pk), @orph_cc_child_sp, 0,
  @integrity_cc_child_sp, 0, 'many_to_one', @priority_cc_child_sp, 1
);
