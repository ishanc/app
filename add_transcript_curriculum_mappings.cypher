// Add TranscriptCurriculum mappings
MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (st:SumTotalField {name: "EmployeeID"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "User ID*"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (st:SumTotalField {name: "ActivityCode"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Curriculum ID*"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (st:SumTotalField {name: "Training Status"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Transcript Status*"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (st:SumTotalField {name: "RegistrationDate"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Request Date/Time*"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (st:SumTotalField {name: "RegistrationDate"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Registration Date/Time*"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (csod:CSODField {name: "Transcript Action"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Create, Update"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
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

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (st:SumTotalField {name: "DueDate"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Due Date/Time‡"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (csod:CSODField {name: "Archived"})
SET csod.mandatory = "Optional",
    csod.field_type = "Boolean",
    csod.char_length = "",
    csod.default_value = "false",
    csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (csod:CSODField {name: "User Exempt Reason"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (csod:CSODField {name: "Approver Exempt Reason"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (csod:CSODField {name: "User's Exemption Comments"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (csod:CSODField {name: "Approver's Exemption Comments"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (csod:CSODField {name: "Exempt By"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
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

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (csod:CSODField {name: "Training Points"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Apply, Delete"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "TranscriptCurriculum"})
MERGE (csod:CSODField {name: "Training Badge"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Apply, Delete"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);
