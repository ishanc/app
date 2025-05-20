// First, clean up existing TranscriptCurriculum mappings
MATCH (f:File {name: "TranscriptCurriculum"})
OPTIONAL MATCH (f)-[:HAS_FIELD]->(st:SumTotalField)
OPTIONAL MATCH (f)-[:OUTPUTS_FIELD]->(csod:CSODField)
DETACH DELETE f, st, csod;

// Add TranscriptCurriculum mappings with file scoping
MERGE (f:File {name: "TranscriptCurriculum"})

// User ID mapping
MERGE (st:SumTotalField {name: "EmployeeID", file: "TranscriptCurriculum"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "User ID*", file: "TranscriptCurriculum"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Curriculum ID mapping
MERGE (st:SumTotalField {name: "ActivityCode", file: "TranscriptCurriculum"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Curriculum ID*", file: "TranscriptCurriculum"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Transcript Status mapping
MERGE (st:SumTotalField {name: "Training Status", file: "TranscriptCurriculum"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Transcript Status*", file: "TranscriptCurriculum"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Request Date/Time mapping
MERGE (st:SumTotalField {name: "RegistrationDate", file: "TranscriptCurriculum"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Request Date/Time*", file: "TranscriptCurriculum"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Registration Date/Time mapping
MERGE (st:SumTotalField {name: "RegistrationDate", file: "TranscriptCurriculum"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Registration Date/Time*", file: "TranscriptCurriculum"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Transcript Action mapping
MERGE (csod:CSODField {name: "Transcript Action", file: "TranscriptCurriculum"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Create, Update"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Completion Date/Time mapping
MERGE (st:SumTotalField {name: "CompletionDate", file: "TranscriptCurriculum"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Completion Date/Time", file: "TranscriptCurriculum"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Due Date/Time mapping
MERGE (st:SumTotalField {name: "DueDate", file: "TranscriptCurriculum"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Due Date/Time‡", file: "TranscriptCurriculum"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Archived mapping
MERGE (csod:CSODField {name: "Archived", file: "TranscriptCurriculum"})
SET csod.mandatory = "Optional",
    csod.field_type = "Boolean",
    csod.char_length = "",
    csod.default_value = "false",
    csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// User Exempt Reason mapping
MERGE (csod:CSODField {name: "User Exempt Reason", file: "TranscriptCurriculum"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Approver Exempt Reason mapping
MERGE (csod:CSODField {name: "Approver Exempt Reason", file: "TranscriptCurriculum"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// User's Exemption Comments mapping
MERGE (csod:CSODField {name: "User's Exemption Comments", file: "TranscriptCurriculum"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Approver's Exemption Comments mapping
MERGE (csod:CSODField {name: "Approver's Exemption Comments", file: "TranscriptCurriculum"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Exempt By mapping
MERGE (csod:CSODField {name: "Exempt By", file: "TranscriptCurriculum"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Comments mapping
MERGE (st:SumTotalField {name: "Note", file: "TranscriptCurriculum"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Comments", file: "TranscriptCurriculum"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "245",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Training Points mapping
MERGE (csod:CSODField {name: "Training Points", file: "TranscriptCurriculum"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Apply, Delete"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

// Training Badge mapping
MERGE (csod:CSODField {name: "Training Badge", file: "TranscriptCurriculum"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Apply, Delete"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);
