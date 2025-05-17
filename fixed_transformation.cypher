// Simple Topic to SubjectID transformation
MERGE (csod:CSODField {name: "Subject IDs*"})
SET csod.transformation = 'CASE Topic 
    WHEN "Software Applications" THEN "532"
    WHEN "Policy and Compliance" THEN "533"
    WHEN "Cornerstone Product Training" THEN "534"
    WHEN "Management Skills" THEN "535"
    ELSE "1382"
END';
