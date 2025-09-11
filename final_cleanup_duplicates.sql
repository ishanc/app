-- Final cleanup script to remove all duplicates from orphan detection results
-- Run this periodically or after orphan detection to keep the database clean

-- 1. Remove duplicate Activities relationships (keep the latest one)
DELETE t1 FROM cross_file_integrity_summary t1
INNER JOIN cross_file_integrity_summary t2 
WHERE t1.id < t2.id 
  AND t1.relationship_name = t2.relationship_name
  AND DATE(t1.analysis_timestamp) = DATE(t2.analysis_timestamp)
  AND t1.discovered_from_neo4j = 1
  AND t2.discovered_from_neo4j = 1
  AND t1.relationship_name LIKE 'Activities.%';

-- 2. Remove duplicate Organizations relationships (keep the latest one)
DELETE t1 FROM cross_file_integrity_summary t1
INNER JOIN cross_file_integrity_summary t2 
WHERE t1.id < t2.id 
  AND t1.relationship_name = t2.relationship_name
  AND DATE(t1.analysis_timestamp) = DATE(t2.analysis_timestamp)
  AND t1.discovered_from_neo4j = 1
  AND t2.discovered_from_neo4j = 1
  AND t1.relationship_name LIKE 'Orgs.%';

-- 3. Remove duplicate Employees relationships (keep the latest one) 
DELETE t1 FROM cross_file_integrity_summary t1
INNER JOIN cross_file_integrity_summary t2 
WHERE t1.id < t2.id 
  AND t1.relationship_name = t2.relationship_name
  AND DATE(t1.analysis_timestamp) = DATE(t2.analysis_timestamp)
  AND t1.discovered_from_neo4j = 1
  AND t2.discovered_from_neo4j = 1
  AND t1.relationship_name LIKE 'Employees.%';

-- 4. Verify no duplicates remain
SELECT 
  SUBSTRING_INDEX(relationship_name, '.', 1) as domain,
  relationship_name,
  COUNT(*) as duplicate_count,
  DATE(analysis_timestamp) as analysis_date
FROM cross_file_integrity_summary 
WHERE discovered_from_neo4j = 1 
  AND DATE(analysis_timestamp) = CURDATE()
GROUP BY SUBSTRING_INDEX(relationship_name, '.', 1), relationship_name, DATE(analysis_timestamp)
HAVING COUNT(*) > 1
ORDER BY domain, relationship_name;

-- 5. Summary of today's clean data
SELECT 
  SUBSTRING_INDEX(relationship_name, '.', 1) as domain,
  COUNT(*) as total_relationships
FROM cross_file_integrity_summary 
WHERE discovered_from_neo4j = 1 
  AND DATE(analysis_timestamp) = CURDATE()
GROUP BY SUBSTRING_INDEX(relationship_name, '.', 1)
ORDER BY domain;
