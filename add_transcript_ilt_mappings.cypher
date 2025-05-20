// Add TranscriptILT Class mappings
MERGE (f:File {name: "TranscriptILT Class"})

// ActivityCode -> Session ID mapping
MERGE (st:SumTotalField {name: "ActivityCode"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Session ID*"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// TrainingStatus -> Transcript Status mapping
MERGE (f:File {name: "TranscriptILT Class"})
MERGE (st:SumTotalField {name: "TrainingStatus"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Transcript Status"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "10",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// RegistrationDate -> Registration Date/Time mapping
MERGE (f:File {name: "TranscriptILT Class"})
MERGE (st:SumTotalField {name: "RegistrationDate"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Registration Date/Time"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// CompletionDate -> Completion Date/Time mapping
MERGE (f:File {name: "TranscriptILT Class"})
MERGE (st:SumTotalField {name: "CompletionDate"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Completion Date/Time"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Score -> Score mapping
MERGE (f:File {name: "TranscriptILT Class"})
MERGE (st:SumTotalField {name: "Score"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Score"})
SET csod.mandatory = "Optional",
    csod.field_type = "Integer",
    csod.char_length = "Integer",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Success -> Pass/Fail mapping
MERGE (f:File {name: "TranscriptILT Class"})
MERGE (st:SumTotalField {name: "Success"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Pass/Fail"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "Pass",
    csod.accepted_values = "Fail, Pass"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// ClassName -> Part name mapping
MERGE (f:File {name: "TranscriptILT Class"})
MERGE (st:SumTotalField {name: "ClassName"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Part name"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "500",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Location -> Part Location mapping
MERGE (f:File {name: "TranscriptILT Class"})
MERGE (st:SumTotalField {name: "Location"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Part Location"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Instructor -> Part Instructor mapping
MERGE (f:File {name: "TranscriptILT Class"})
MERGE (st:SumTotalField {name: "Instructor"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Part Instructor"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// ClassStartDate -> Part Start Date/Time mapping
MERGE (f:File {name: "TranscriptILT Class"})
MERGE (st:SumTotalField {name: "ClassStartDate"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Part Start Date/Time"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// ClassEndDate -> Part End Date/Time mapping
MERGE (f:File {name: "TranscriptILT Class"})
MERGE (st:SumTotalField {name: "ClassEndDate"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Part End Date/Time"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Contact -> Training Contact mapping
MERGE (f:File {name: "TranscriptILT Class"})
MERGE (st:SumTotalField {name: "Contact"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Training Contact"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Note -> Comments mapping
MERGE (f:File {name: "TranscriptILT Class"})
MERGE (st:SumTotalField {name: "Note"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Comments"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "245",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);
