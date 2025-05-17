// Test Topic to SubjectID transformation
MERGE (csod:CSODField {name: "Subject IDs*"})
SET csod.transformation = "CASE Topic WHEN 'Software Applications' THEN '532' WHEN 'Policy and Compliance' THEN '533' ELSE '1382' END";

// Test Language transformation
MERGE (csod:CSODField {name: "Language"})
SET csod.transformation = "CASE Language WHEN 'en-US' THEN '1' WHEN 'en-GB' THEN '2' ELSE '1' END";

// Test Timezone transformation
MERGE (csod:CSODField {name: "Time Zone"})
SET csod.transformation = "CASE Timezone WHEN 'MIT' THEN '1' WHEN 'HST' THEN '3' ELSE '9' END";