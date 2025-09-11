-- Clear all duplicate orphan detection results from today
DELETE FROM cross_file_integrity_summary 
WHERE discovered_from_neo4j = 1
  AND DATE(analysis_timestamp) = CURDATE();

-- Verify cleanup
SELECT 
  SUBSTRING_INDEX(relationship_name, '.', 1) as domain,
  COUNT(*) as total_relationships
FROM cross_file_integrity_summary 
WHERE discovered_from_neo4j = 1
  AND DATE(analysis_timestamp) = CURDATE()
GROUP BY SUBSTRING_INDEX(relationship_name, '.', 1);
