// ==========================
// ACTIVITIES PRIMARY KEY SETUP
// ==========================
// Mark Activities PK field (ActivityCode) + UID label
// ==========================
MATCH (st:SumTotalField)
WHERE st.name = "ActivityCode"
  AND toLower(st.file) CONTAINS "activity"
SET st.isPrimaryKey = true,
    st.entityType = "Activities",
    st.uniqueIdentifier = "Activity_ID",
    st.businessDescription = "Unique activity identifier";

// ==========================
// ACTIVITIES FOREIGN KEY RELATIONSHIPS
// ==========================

// Session.ClassCode → Activities.ActivityCode
// ==========================
MATCH (pk:SumTotalField {entityType: "Activities"})
MATCH (fk:SumTotalField {name: "ClassCode"})
WHERE toLower(fk.file) CONTAINS "session"
  AND fk.file <> pk.file
MERGE (fk)-[:REFERENCES_PRIMARY_KEY {
  businessRule: "Session.ClassCode must reference Activities.ActivityCode",
  relationshipType: "many_to_one",
  orphanedRecordImpact: "Sessions without valid activities",
  validationPriority: "High"
}]->(pk);

// ILT(Course/Class).ILTCourseCode → Activities.ActivityCode
// ==========================
MATCH (pk:SumTotalField {entityType: "Activities"})
MATCH (fk1:SumTotalField {name: "ILTCourseCode"})
WHERE toLower(fk1.file) =~ ".*(ilt|class|course).*"
  AND fk1.file <> pk.file
MERGE (fk1)-[:REFERENCES_PRIMARY_KEY {
  businessRule: "ILTCourseCode must reference Activities.ActivityCode",
  relationshipType: "many_to_one",
  orphanedRecordImpact: "ILT courses without valid activities",
  validationPriority: "High"
}]->(pk);

// ILT Class.ILTClasscode → Activities.ActivityCode
// ==========================
MATCH (pk:SumTotalField {entityType: "Activities"})
MATCH (fk2:SumTotalField {name: "ClassCode"})
WHERE toLower(fk2.file) =~ ".*(ilt|class).*"
  AND fk2.file <> pk.file
MERGE (fk2)-[:REFERENCES_PRIMARY_KEY {
  businessRule: "ClassCode must reference Activities.ActivityCode",
  relationshipType: "many_to_one",
  orphanedRecordImpact: "ILT classes without valid activities",
  validationPriority: "High"
}]->(pk);
