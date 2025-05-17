// Topic to SubjectID transformation
MERGE (csod:CSODField {name: "Subject IDs*"})
SET csod.transformation = "CASE Topic 
    WHEN 'Software Applications' THEN '532'
    WHEN 'Policy and Compliance' THEN '533'
    WHEN 'Cornerstone Product Training' THEN '534'
    ELSE '1382'
END";

// Language transformation 
MERGE (csod:CSODField {name: "Language"})
SET csod.transformation = "CASE Language
    WHEN 'en-US' THEN '1'
    WHEN 'en-GB' THEN '2'
    WHEN 'fr-FR' THEN '13'
    WHEN 'es-MX' THEN '14'
    ELSE '1'
END";

// Timezone transformation
MERGE (csod:CSODField {name: "Time Zone"})
SET csod.transformation = "CASE Timezone
    WHEN 'MIT' THEN '1'
    WHEN 'HST' THEN '3'
    WHEN 'AKST' THEN '4'
    WHEN 'PST' THEN '5'
    WHEN 'MST' THEN '6'
    WHEN 'CST' THEN '7'
    WHEN 'EST' THEN '8'
    ELSE '9'
END";