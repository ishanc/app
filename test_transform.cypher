// Test basic transformation rules
MERGE (f:File {name: "Test"})
MERGE (csod:CSODField {name: "Subject IDs*"})
SET csod.mandatory = "Mandatory",
    csod.transformation = toString(CASE
        WHEN Topic = 'Software Applications' THEN 532
        WHEN Topic = 'Policy and Compliance' THEN 533
        ELSE 1382
    END);

// Language mapping
MERGE (csod:CSODField {name: "Language"})
SET csod.transformation = "CASE Language WHEN 'en-US' THEN '1' WHEN 'en-GB' THEN '2' ELSE '1' END";

// Timezone mapping
MERGE (csod:CSODField {name: "Time Zone"})
SET csod.transformation = "CASE Timezone WHEN 'MIT' THEN '1' WHEN 'HST' THEN '3' ELSE '9' END";
