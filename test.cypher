MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (st:SumTotalField {name: "Activity Code", file: "Activity_Curriculum"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Curriculum ID*", file: "Activity_Curriculum" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (st:SumTotalField {name: "SectionName", file: "Activity_Curriculum"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Section Name", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (st:SumTotalField {name: "Child ActivityCode", file: "Activity_Curriculum"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Child LO ID", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (st:SumTotalField {name: "ActivityName", file: "Activity_Curriculum"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Curriculum Title*", file: "Activity_Curriculum" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (st:SumTotalField {name: "Provider", file: "Activity_Curriculum"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Vendor/Provider*", file: "Activity_Curriculum" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Provider type*", file: "Activity_Curriculum" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "ONLINE,ILT",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (st:SumTotalField {name: "Active", file: "Activity_Curriculum"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Active", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive",  csod.output_document = "Activity_Curriculum"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Default Language", file: "Activity_Curriculum"})
SET csod.mandatory = "Optional", 
    csod.field_type = "Integer",
    csod.char_length = "",
    csod.default_value = "1",
    csod.accepted_values = "",  csod.output_document = "Activity_Curriculum",
    csod.transformation = "CASE WHEN input_value = 'en-US' THEN 1 WHEN input_value = 'English (US)' THEN 1 WHEN input_value = 'en-GB' THEN 2 WHEN input_value = 'English (UK)' THEN 2 WHEN input_value = 'fr-FR' THEN 13 WHEN input_value = 'French (France)' THEN 13 WHEN input_value = 'es-MX' THEN 14 WHEN input_value = 'Spanish (Latin America)' THEN 14 ELSE 1 END"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);


MERGE (f:File {name: "Activity_Curriculum"})
MERGE (st:SumTotalField {name: "Topic", file: "Activity_Curriculum"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Subject IDs*", file: "Activity_Curriculum"})
SET csod.mandatory = "Mandatory", 
    csod.field_type = "subjectType",              
    csod.char_length = "",                    
    csod.default_value = "",             
    csod.accepted_values = "",  csod.output_document = "Activity_Curriculum",
    csod.transformation = "CASE WHEN input_value = 'Production Preparation Process' THEN 1000 WHEN input_value = 'Programming Languages' THEN 1001 WHEN input_value = 'QC Circle' THEN 1002 WHEN input_value = 'Quality' THEN 1003 WHEN input_value = 'Quick Changeover' THEN 1004 WHEN input_value = 'Reference' THEN 1005 WHEN input_value = 'Safety' THEN 1006 WHEN input_value = 'SCP Resources' THEN 1007 WHEN input_value = 'Secure Programming' THEN 1008 WHEN input_value = 'Six Sigma' THEN 1009 WHEN input_value = 'Skillsoft' THEN 1010 WHEN input_value = 'Productivity Tools forDevOps Automated Testers' THEN 1011 WHEN input_value = 'Productivity Tools for SecOps Engineers' THEN 1012 WHEN input_value = 'Business & Leadership for Apprentice Programmers' THEN 1013 WHEN input_value = 'Productivity Tools for Apprentice Programmers' THEN 1014 WHEN input_value = 'Productivity Tools for Cloud Architects' THEN 1015 WHEN input_value = 'Productivity Tools for CloudOps Engineers' THEN 1016 WHEN input_value = 'Productivity Tools for Business Analyst to Data Analysts' THEN 1017 WHEN input_value = 'Efficiency & Productivity in the New Normal' THEN 1018 WHEN input_value = 'Managing & Leading through Unexpected Disruption' THEN 1019 WHEN input_value = 'Productivity Tools for Data Visualization' THEN 1020 WHEN input_value = 'Business & Leadership for Data Analysis with R' THEN 1021 WHEN input_value = 'Productivity Tools for Data Analysis with R' THEN 1022 WHEN input_value = 'Productivity Tools with Agile for Software Development' THEN 1023 WHEN input_value = 'Productivity Tools for Web App Vulnerability Analyst' THEN 1024 WHEN input_value = 'Productivity Tools for 5G Technologies and Practices' THEN 1025 WHEN input_value = 'Business & Leadership for Enriched Web Development with Angular 11' THEN 1026 WHEN input_value = 'Business & Leadership for Pythonista' THEN 1027 WHEN input_value = 'Business & Leadership for Javanista to Java Master' THEN 1028 WHEN input_value = 'Business & Leadership for Developer Fundamentals' THEN 1029 WHEN input_value = 'Business & Leadership for Programming Python in Action' THEN 1030 WHEN input_value = 'Business & Leadership for Software Product Management' THEN 1031 WHEN input_value = 'Productivity Tools for senior Software Project Managers' THEN 1032 WHEN input_value = 'Productivity Tools for Security Architects' THEN 1033 WHEN input_value = 'Business & Leadership for Enterprise Development to Full Stack Developers' THEN 1034 WHEN input_value = 'Productivity Tools for Full Stack Developer' THEN 1035 WHEN input_value = 'Productivity Tools for DevOps Engineer' THEN 1036 WHEN input_value = 'Skype 2016' THEN 1037 WHEN input_value = 'Standard Work' THEN 1038 WHEN input_value = 'Standard Work - Leader' THEN 1039 WHEN input_value = 'T1' THEN 1040 WHEN input_value = 'TACTIS' THEN 1041 WHEN input_value = 'Total Productive Maintenance' THEN 1042 WHEN input_value = 'TQM (Total Quality Management)' THEN 1043 WHEN input_value = 'TWI for Facilitators' THEN 1044 WHEN input_value = 'TWI for Learners' THEN 1045 WHEN input_value = 'US Federal Government Compliance (US Edition)' THEN 1046 WHEN input_value = 'Value Stream' THEN 1047 WHEN input_value = 'Visual Management' THEN 1048 WHEN input_value = 'Web Development' THEN 1049 WHEN input_value = 'Workplace Compliance Essentials (Brazilian Portuguese Edition)' THEN 1050 WHEN input_value = 'Workplace Compliance Essentials (UK English Edition)' THEN 1051 WHEN input_value = 'Workplace Compliance Essentials (Canadian Edition)' THEN 1052 WHEN input_value = 'Workplace Compliance Essentials (Castilian Spanish Edition)' THEN 1053 WHEN input_value = 'Workplace Compliance Essentials (Turkish Edition)' THEN 1054 WHEN input_value = 'Workplace Compliance Essentials (Australian Edition)' THEN 1055 WHEN input_value = 'Workplace Compliance Essentials (Thai Edition)' THEN 1056 WHEN input_value = 'Workplace Compliance Essentials (Swedish Edition)' THEN 1057 WHEN input_value = 'Workplace Compliance Essentials (Bahasa Malay Edition)' THEN 1058 WHEN input_value = 'Workplace Compliance Essentials (Vietnamese Edition)' THEN 1059 WHEN input_value = 'Workplace Compliance Essentials (Dutch Edition)' THEN 1060 WHEN input_value = 'Workplace Compliance Essentials (Norwegian Edition)' THEN 1061 WHEN input_value = 'Workplace Compliance Essentials (New Zealand Edition)' THEN 1062 WHEN input_value = 'Workplace Compliance Essentials (French Edition)' THEN 1063 WHEN input_value = 'Workplace Compliance Essentials (German Edition)' THEN 1064 WHEN input_value = 'Workplace Compliance Essentials (Italian Edition)' THEN 1065 WHEN input_value = 'Workplace Compliance Essentials (Japanese Edition)' THEN 1066 WHEN input_value = 'XML' THEN 1067 WHEN input_value = 'Communicating Tactfully and Diplomatically' THEN 1068 WHEN input_value = 'Leading Virtual Teams' THEN 1069 WHEN input_value = 'Thinking Strategically and Managing Risk' THEN 1070 WHEN input_value = 'Virtual Teams' THEN 1071 WHEN input_value = 'Communication' THEN 1072 WHEN input_value = 'Microsoft 365: Teams' THEN 1073 WHEN input_value = 'EHS Impacts (US Edition)' THEN 1074 WHEN input_value = 'Environmental (Latin American Spanish Edition)' THEN 1075 WHEN input_value = 'Environmental (US Edition)' THEN 1076 WHEN input_value = 'Environmental (Canadian Edition)' THEN 1077 WHEN input_value = 'Environmental (Canadian French Edition)' THEN 1078 WHEN input_value = 'Harassment (Australian Edition)' THEN 1079 WHEN input_value = 'Harassment (Bahasa Indonesian Edition)' THEN 1080 WHEN input_value = 'Harassment (Bahasa Malay Edition)' THEN 1081 WHEN input_value = 'Harassment (Brazilian Portuguese Edition)' THEN 1082 WHEN input_value = 'Harassment (Canadian Edition)' THEN 1083 WHEN input_value = 'Harassment (Czech Edition)' THEN 1084 WHEN input_value = 'Harassment (French Edition)' THEN 1085 WHEN input_value = 'Harassment (German Edition)' THEN 1086 WHEN input_value = 'Harassment (Hindi Edition)' THEN 1087 WHEN input_value = 'Harassment (Indian Edition)' THEN 1088 WHEN input_value = 'Harassment (Italian Edition)' THEN 1089 WHEN input_value = 'Harassment (Japanese Edition)' THEN 1090 WHEN input_value = 'Harassment (Korean Edition)' THEN 1091 WHEN input_value = 'Harassment (Latin American Spanish Edition)' THEN 1092 WHEN input_value = 'Harassment (New Zealand Edition)' THEN 1093 WHEN input_value = 'Harassment (Polish Edition)' THEN 1094 WHEN input_value = 'Harassment (Thai Edition)' THEN 1095 WHEN input_value = 'Harassment (Vietnamese Edition)' THEN 1096 WHEN input_value = 'Health, Safety and Security (Canadian Edition)' THEN 1097 WHEN input_value = 'Health, Safety and Security (Canadian French Edition)' THEN 1098 WHEN input_value = 'Health, Safety and Security (Castilian Spanish Edition)' THEN 1099 WHEN input_value = 'Health, Safety and Security (Dutch Edition)' THEN 1100 WHEN input_value = 'Health, Safety and Security (Korean Edition)' THEN 1101 WHEN input_value = 'Health, Safety and Security (Australian Edition)' THEN 1102 WHEN input_value = 'Health, Safety and Security (New Zealand Edition)' THEN 1103 WHEN input_value = 'Health, Safety and Security (Chinese Edition)' THEN 1104 WHEN input_value = 'Health, Safety and Security (German Edition)' THEN 1105 WHEN input_value = 'Health, Safety and Security (Latin American Spanish Edition)' THEN 1106 WHEN input_value = 'Health, Safety and Security (US Edition)' THEN 1107 WHEN input_value = 'Health, Safety and Security (UK Edition)' THEN 1108 WHEN input_value = 'Health, Safety and Security (Portuguese Brazilian Edition)' THEN 1109 WHEN input_value = 'Health, Safety and Security (French Edition)' THEN 1110 WHEN input_value = 'Health, Safety and Security (ltalian Edition)' THEN 1111 WHEN input_value = 'Legal Impacts (French Edition)' THEN 1112 WHEN input_value = 'Legal Impacts (Latin American Spanish Edition)' THEN 1113 WHEN input_value = 'Legal Impacts (UK English Edition)' THEN 1114 WHEN input_value = 'Meetings' THEN 1115 WHEN input_value = 'Navigating through Organizational Change' THEN 1116 WHEN input_value = 'Productivity Tools for Advanced Scrum Masters' THEN 1117 WHEN input_value = 'Productivity Tools for CloudOps Security Architect' THEN 1118 WHEN input_value = 'Business & Leadership for Journeyman Developers' THEN 1119 WHEN input_value = 'Productivity Tools for Journeyman Developers' THEN 1120 WHEN input_value = 'Business & Leadership for AI Architects' THEN 1121 WHEN input_value = 'Productivity Tools for AI Architects' THEN 1122 WHEN input_value = 'Business & Leadership for API Developers' THEN 1123 WHEN input_value = 'Productivity Tools for API Developers' THEN 1124 WHEN input_value = 'Business & Leadership for Software Architects' THEN 1125 WHEN input_value = 'Productivity Tools for Software Architects' THEN 1126 WHEN input_value = 'Business & Leadership for Site Reliability Engineers' THEN 1127 WHEN input_value = 'Productivity Tools for Site Reliability Engineers' THEN 1128 WHEN input_value = 'Business & Leadership for Python Master' THEN 1129 WHEN input_value = 'Productivity Tools for Python Master' THEN 1130 WHEN input_value = 'Productivity Tools for Decision-makers and Leaders' THEN 1131 WHEN input_value = 'Business & Leadership with Serverless Deployments for Developers' THEN 1132 WHEN input_value = 'Productivity Tools with Serverless Deployments for Developers' THEN 1133 WHEN input_value = 'Business & Leadership for Javanista' THEN 1134 WHEN input_value = 'Productivity Tools for Javanista' THEN 1135 WHEN input_value = 'Business & Leadership for Go Programming Essentials' THEN 1136 WHEN input_value = 'Business & Leadership for Engineering Lead' THEN 1137 WHEN input_value = 'Business & Leadership for AI and ML for Decision-makers' THEN 1138 WHEN input_value = 'Productivity Tools for Secure Agile Programmers' THEN 1139 WHEN input_value = 'Transportation (Latin American Spanish Edition)' THEN 1140 WHEN input_value = 'Transportation (US Edition)' THEN 1141 WHEN input_value = 'Transportation (Italian Edition)' THEN 1142 WHEN input_value = 'Transportation (Canadian Edition)' THEN 1143 WHEN input_value = 'Transportation (Canadian French Edition)' THEN 1144 WHEN input_value = 'Transportation (UK Edition)' THEN 1145 WHEN input_value = 'Transportation (Chinese Edition)' THEN 1146 WHEN input_value = 'Transportation (Portuguese Brazilian Edition)' THEN 1147 WHEN input_value = 'Transportation (German Edition)' THEN 1148 WHEN input_value = 'Transportation (Castilian Spanish Edition)' THEN 1149 WHEN input_value = 'Transportation (Korean Edition)' THEN 1150 WHEN input_value = 'Transportation (Dutch Edition)' THEN 1151 WHEN input_value = 'Transportation (French Edition)' THEN 1152 WHEN input_value = 'Workplace Compliance Essentials (Canadian French Edition)' THEN 1153 WHEN input_value = 'Workplace Compliance Essentials (Russian Edition)' THEN 1154 WHEN input_value = 'Workplace Compliance Essentials (US Edition)' THEN 1155 WHEN input_value = 'Workplace Compliance Essentials (Korean Edition)' THEN 1156 WHEN input_value = 'Workplace Compliance Essentials (Czech Edition)' THEN 1157 WHEN input_value = 'Workplace Compliance Essentials (Chinese Edition)' THEN 1158 WHEN input_value = 'Workplace Compliance Essentials (Hindi Edition)' THEN 1159 WHEN input_value = 'Workplace Compliance Essentials (Bahasa Indonesian Edition)' THEN 1160 WHEN input_value = 'Workplace Compliance Essentials (Hungarian Edition)' THEN 1161 WHEN input_value = 'Workplace Compliance Essentials (Romanian Edition)' THEN 1162 WHEN input_value = 'Workplace Compliance Essentials (Finnish Edition)' THEN 1163 WHEN input_value = 'Workplace Compliance Essentials (Danish Edition)' THEN 1164 WHEN input_value = 'Workplace Compliance Essentials (Chinese Traditional Edition)' THEN 1165 WHEN input_value = 'Workplace Compliance Essentials (Latin American Spanish Edition)' THEN 1166 WHEN input_value = 'Workplace Compliance Essentials (Polish Edition)' THEN 1167 WHEN input_value = 'Food Allergies And Intolerance' THEN 1168 WHEN input_value = 'Industry Specific' THEN 1169 WHEN input_value = 'Cal/OSHA Latin American Spanish' THEN 1170 WHEN input_value = 'Technology' THEN 1171 WHEN input_value = 'Disability Discrimination Awareness' THEN 1172 WHEN input_value = 'Cisco WebEx Teams' THEN 1173 WHEN input_value = 'Equality and Diversity Awareness' THEN 1174 WHEN input_value = 'Cisco WebEx for Web' THEN 1175 WHEN input_value = 'Portuguese' THEN 1176 WHEN input_value = 'French Canadian' THEN 1177 WHEN input_value = 'Japanese' THEN 1178 WHEN input_value = 'Cal/OSHA' THEN 1179 WHEN input_value = 'Coordinators' THEN 1180 WHEN input_value = 'Managers' THEN 1181 WHEN input_value = 'Skype for Business 2016 (No Assessments)' THEN 1182 WHEN input_value = 'First Aid Awareness' THEN 1183 WHEN input_value = 'Fire Safety Awareness' THEN 1184 WHEN input_value = 'Join.me for Windows (No Assessments)' THEN 1185 WHEN input_value = 'LogMeIn GoToMeeting (No Assessments)' THEN 1186 WHEN input_value = 'Presentation Skills' THEN 1187 WHEN input_value = 'Project Sheets' THEN 1188 WHEN input_value = '5S' THEN 1189 WHEN input_value = 'Label Templates' THEN 1190 WHEN input_value = 'Final Presentation' THEN 1191 WHEN input_value = 'Kaizen' THEN 1192 WHEN input_value = 'Engineering' THEN 1193 WHEN input_value = 'Lifelong Learn' THEN 1194 WHEN input_value = 'Cloud Services' THEN 1195 WHEN input_value = 'Business Operations' THEN 1196 WHEN input_value = 'Welcome to Percipio' THEN 1197 WHEN input_value = 'Aspire Journeys for Leadership' THEN 1198 WHEN input_value = 'Cybersecurity Career Journey' THEN 1199 WHEN input_value = 'Skillsoft Live Events' THEN 1200 WHEN input_value = 'Sample Content' THEN 1201 WHEN input_value = 'Customer Service' THEN 1202 WHEN input_value = 'Browse Partner Content' THEN 1203 WHEN input_value = 'Aspire Journeys' THEN 1204 WHEN input_value = 'Infrastructure & Operations' THEN 1205 WHEN input_value = 'Sales & Marketing' THEN 1206 WHEN input_value = 'Skillsoft Bootcamps' THEN 1207 WHEN input_value = 'Digital Transformation' THEN 1208 WHEN input_value = 'Professional Improvement' THEN 1209 WHEN input_value = 'Diversity, Equity, & Inclusion' THEN 1210 WHEN input_value = 'NICE Framework' THEN 1211 WHEN input_value = 'Certifications' THEN 1212 WHEN input_value = 'Skillsoft Leadercamps' THEN 1213 WHEN input_value = 'Software Craft' THEN 1214 WHEN input_value = 'Cloud Career Journey' THEN 1215 WHEN input_value = 'Codecademy' THEN 1216 WHEN input_value = 'Project Management' THEN 1217 WHEN input_value = 'Mainframe' THEN 1218 WHEN input_value = 'Perspectives' THEN 1219 WHEN input_value = 'Agile Career Journey' THEN 1220 WHEN input_value = 'Product Management' THEN 1221 WHEN input_value = 'Data' THEN 1222 WHEN input_value = 'Corporate Marketing' THEN 1223 WHEN input_value = 'Customer Success' THEN 1224 WHEN input_value = 'Product Marketing' THEN 1225 WHEN input_value = 'Corporate Communications' THEN 1226 WHEN input_value = 'Selling Skills' THEN 1227 WHEN input_value = 'Internet of Things' THEN 1228 WHEN input_value = 'Cloud Basics' THEN 1229 WHEN input_value = 'Cloud Development' THEN 1230 WHEN input_value = 'Cloud Platforms' THEN 1231 WHEN input_value = 'NEW - Azure' THEN 1232 WHEN input_value = 'Pursue an Agile Certification' THEN 1233 WHEN input_value = 'Pursue an Agile Job Role' THEN 1234 WHEN input_value = 'Pursue an Azure Cloud Job Role' THEN 1235 WHEN input_value = 'Pursue an AWS Cloud Job Role' THEN 1236 WHEN input_value = 'Pursue a GCP Cloud Job Role' THEN 1237 WHEN input_value = 'Pursue a Foundation in Cloud' THEN 1238 WHEN input_value = 'Pursue a Cloud Skill' THEN 1239 WHEN input_value = 'Pursue a Cybersecurity Skill' THEN 1240 WHEN input_value = 'Database Development' THEN 1241 WHEN input_value = 'Data Visualization & Reporting' THEN 1242 WHEN input_value = 'Big Data' THEN 1243 WHEN input_value = 'Data Architectures' THEN 1244 WHEN input_value = 'Data Core Concepts' THEN 1245 WHEN input_value = 'Data Analytics' THEN 1246 WHEN input_value = 'Data Science' THEN 1247 WHEN input_value = 'Data Platforms' THEN 1248 WHEN input_value = 'Business Intelligence' THEN 1249 WHEN input_value = 'Data Security' THEN 1250 WHEN input_value = 'Diversity, Equity & Inclusion' THEN 1251 WHEN input_value = 'DevOps IT' THEN 1252 WHEN input_value = 'Client & Server Administration' THEN 1253 WHEN input_value = 'IT Services' THEN 1254 WHEN input_value = 'Network Operations' THEN 1255 WHEN input_value = 'IT Trends' THEN 1256 WHEN input_value = '2020 Mainstage Keynotes' THEN 1257 WHEN input_value = '2020 Product Sessions' THEN 1258 WHEN input_value = '2020 Case Studies' THEN 1259 WHEN input_value = 'Leadership & Business' THEN 1260 WHEN input_value = 'NICE Work Roles' THEN 1261 WHEN input_value = 'Product Management Skills' THEN 1262 WHEN input_value = 'Software Developer Bootcamps' THEN 1263 WHEN input_value = 'Virtual Training' THEN 1264 WHEN input_value = 'Security Bootcamps' THEN 1265 WHEN input_value = 'Project Management Bootcamps' THEN 1266 WHEN input_value = 'Cloud Services Bootcamps' THEN 1267 WHEN input_value = 'Data Bootcamps' THEN 1268 WHEN input_value = 'In Pursuit of Re-engagement' THEN 1269 WHEN input_value = 'Leading HR' THEN 1270 WHEN input_value = 'Productivity & Wellness' THEN 1271 WHEN input_value = 'Art of Great Consulting' THEN 1272 WHEN input_value = 'Leading in the New Normal' THEN 1273 WHEN input_value = 'Artificial Intelligence' THEN 1274 WHEN input_value = 'Software' THEN 1275 WHEN input_value = 'Machine Learning' THEN 1276 WHEN input_value = 'Data Management' THEN 1277 WHEN input_value = 'Leadership Mindsets' THEN 1278 WHEN input_value = 'Leadership Transitions' THEN 1279 WHEN input_value = 'Espanol' THEN 1280 WHEN input_value = 'English' THEN 1281 WHEN input_value = 'Codecademy Languages' THEN 1282 WHEN input_value = 'Codecademy Subjects' THEN 1283 WHEN input_value = 'Finance' THEN 1284 WHEN input_value = 'Process Improvement' THEN 1285 WHEN input_value = 'Business Planning & Analysis' THEN 1286 WHEN input_value = 'Human Resources' THEN 1287 WHEN input_value = 'Banking' THEN 1288 WHEN input_value = 'Microsoft Office' THEN 1289 WHEN input_value = 'CompTIA' THEN 1290 WHEN input_value = 'Oracle' THEN 1291 WHEN input_value = 'VMware' THEN 1292 WHEN input_value = 'Isograd' THEN 1293 WHEN input_value = 'Cisco' THEN 1294 WHEN input_value = 'SAS' THEN 1295 WHEN input_value = 'Digital Marketing Institute' THEN 1296 WHEN input_value = 'Red Hat' THEN 1297 WHEN input_value = 'Kubernetes' THEN 1298 WHEN input_value = 'Microsoft' THEN 1299 WHEN input_value = 'Google' THEN 1300 WHEN input_value = '(ISC)2' THEN 1301 WHEN input_value = 'EC-Council' THEN 1302 WHEN input_value = 'AWS' THEN 1303 WHEN input_value = 'Virtual Work' THEN 1304 WHEN input_value = 'Digital Experiences' THEN 1305 WHEN input_value = 'Civil' THEN 1306 WHEN input_value = 'Energy' THEN 1307 WHEN input_value = 'Chemical' THEN 1308 WHEN input_value = 'Industrial' THEN 1309 WHEN input_value = 'Aerospace & Mechanical' THEN 1310 WHEN input_value = 'Electrical' THEN 1311 WHEN input_value = 'Test Channels' THEN 1312 WHEN input_value = 'Engineering Resources' THEN 1313 WHEN input_value = 'Personal Productivity' THEN 1314 WHEN input_value = 'Personal Accountability' THEN 1315 WHEN input_value = 'Well-Being' THEN 1316 WHEN input_value = 'Business Communication' THEN 1317 WHEN input_value = 'Self-Discovery' THEN 1318 WHEN input_value = 'Mainframe Security' THEN 1319 WHEN input_value = 'Mainframe Services' THEN 1320 WHEN input_value = 'Project Management Methods' THEN 1321 WHEN input_value = 'Live Events' THEN 1322 WHEN input_value = 'Emerging Tech' THEN 1323 WHEN input_value = 'Software Architectures' THEN 1324 WHEN input_value = 'Software Dev Practices' THEN 1325 WHEN input_value = 'Getting Started with Percipio' THEN 1326 WHEN input_value = 'Expert' THEN 1327 WHEN input_value = 'Associate (MTA)' THEN 1328 WHEN input_value = 'Microsoft 365 Certified Expert' THEN 1329 WHEN input_value = 'Microsoft Certified Associate' THEN 1330 WHEN input_value = 'Professional' THEN 1331 WHEN input_value = 'Entry' THEN 1332 WHEN input_value = 'Associate' THEN 1333 WHEN input_value = 'TOSA Desktop' THEN 1334 WHEN input_value = 'TOSA Digital' THEN 1335 WHEN input_value = 'Cloud Security' THEN 1336 WHEN input_value = 'Software Development' THEN 1337 WHEN input_value = 'Information Security' THEN 1338 WHEN input_value = 'Systems Security' THEN 1339 WHEN input_value = 'Cybersecurity' THEN 1340 WHEN input_value = 'Bloodborne Pathogens' THEN 1341 WHEN input_value = 'Excel' THEN 1342 WHEN input_value = 'Access' THEN 1343 WHEN input_value = 'TWI - Job Instruction' THEN 1344 WHEN input_value = 'Filehold' THEN 1345 WHEN input_value = 'Engineer Resources' THEN 1346 WHEN input_value = 'Security Skills' THEN 1347 WHEN input_value = 'Outlook' THEN 1348 WHEN input_value = 'Concur' THEN 1349 WHEN input_value = 'Teams' THEN 1350 WHEN input_value = 'TWI - Job Methods' THEN 1351 WHEN input_value = 'ADP' THEN 1352 WHEN input_value = 'Docusign' THEN 1353 WHEN input_value = 'TWI - Job Relations' THEN 1354 WHEN input_value = 'Word' THEN 1355 WHEN input_value = 'PowerPoint' THEN 1356 WHEN input_value = 'Infrastructure' THEN 1357 WHEN input_value = 'Data and Analytics' THEN 1358 WHEN input_value = 'Additional Professional' THEN 1359 WHEN input_value = 'Core' THEN 1360 WHEN input_value = 'VMware Certified Professional' THEN 1361 WHEN input_value = 'Data Analysis' THEN 1362 WHEN input_value = 'Digital Marketing Associate' THEN 1363 WHEN input_value = 'Google Workspace' THEN 1364 WHEN input_value = 'Specialty' THEN 1365 WHEN input_value = 'Architecting' THEN 1366 WHEN input_value = 'Operations' THEN 1367 WHEN input_value = 'Cloud Practitioner' THEN 1368 WHEN input_value = 'Developing' THEN 1369 WHEN input_value = 'Base Programmer' THEN 1370 WHEN input_value = 'Administrator' THEN 1371 WHEN input_value = 'Kubernetes Administrator' THEN 1372 WHEN input_value = 'Spreadsheet Software' THEN 1373 WHEN input_value = 'Microsoft Office/Office 365' THEN 1374 WHEN input_value = 'Email' THEN 1375 WHEN input_value = 'Presentation Software' THEN 1376 WHEN input_value = 'Microsoft Outlook' THEN 1377 WHEN input_value = 'Microsoft Excel' THEN 1378 WHEN input_value = 'Microsoft Powerpoint' THEN 1379 WHEN input_value = 'Google Hangouts Meet' THEN 1380 WHEN input_value = 'Google Hangouts Meet (No Assessments)' THEN 1381 WHEN input_value = 'Software Applications' THEN 532 WHEN input_value = 'Policy and Compliance' THEN 533 WHEN input_value = 'Cornerstone Product Training' THEN 534 WHEN input_value = 'Management Skills' THEN 535 WHEN input_value = 'Communication & Teamwork' THEN 536 WHEN input_value = 'Technical Skills' THEN 537 WHEN input_value = 'Business Skills' THEN 538 WHEN input_value = 'Compliance' THEN 539 WHEN input_value = 'IT Skills' THEN 540 WHEN input_value = 'Certification' THEN 541 WHEN input_value = 'Collections' THEN 542 WHEN input_value = 'Skillsoft Aspire' THEN 543 WHEN input_value = 'Productivity & Collaboration Tools' THEN 544 WHEN input_value = 'Business Continuity' THEN 545 WHEN input_value = 'Skillsoft Aspire L&B' THEN 546 WHEN input_value = 'Change' THEN 547 WHEN input_value = 'Communications Skills' THEN 548 WHEN input_value = 'Finance and Accounting' THEN 549 WHEN input_value = 'Human Resources' THEN 550 WHEN input_value = 'Industry Overviews' THEN 551 WHEN input_value = 'Leadership' THEN 552 WHEN input_value = 'Management' THEN 553 WHEN input_value = 'Operations Management' THEN 554 WHEN input_value = 'Professional Effectiveness' THEN 555 WHEN input_value = 'Project Management' THEN 556 WHEN input_value = 'Strategy and Innovation' THEN 557 WHEN input_value = 'Business Skills' THEN 558 WHEN input_value = 'Business Skills' THEN 559 WHEN input_value = 'Business Skills' THEN 560 WHEN input_value = 'Business Skills' THEN 561 WHEN input_value = 'Business Skills' THEN 562 WHEN input_value = 'Sumtotal344' THEN 563 WHEN input_value = 'ILT Events' THEN 565 WHEN input_value = 'SumTotal2' THEN 566 WHEN input_value = 'SumTotal' THEN 567 WHEN input_value = 'Materials' THEN 568 WHEN input_value = 'Videos' THEN 569 WHEN input_value = 'Curriculum' THEN 570 WHEN input_value = 'Curriculums' THEN 571 WHEN input_value = 'ILT Events' THEN 572 WHEN input_value = 'Scorm' THEN 573 WHEN input_value = 'Finance' THEN 574 WHEN input_value = 'SIAM TEAM' THEN 575 WHEN input_value = 'New Employee Training' THEN 576 WHEN input_value = 'Exercise' THEN 577 WHEN input_value = 'Leadership Development' THEN 578 WHEN input_value = 'Medicine' THEN 579 WHEN input_value = 'Teaching' THEN 580 WHEN input_value = 'Course Details' THEN 581 WHEN input_value = 'Pravir test' THEN 582 WHEN input_value = 'Tests' THEN 583 WHEN input_value = 'Online Courses' THEN 584 WHEN input_value = 'Topics' THEN 585 WHEN input_value = 'PESV2_topic' THEN 586 WHEN input_value = '1234' THEN 587 WHEN input_value = '208_Cloud Services' THEN 588 WHEN input_value = '210_Customer Service' THEN 589 WHEN input_value = '211_Developer' THEN 590 WHEN input_value = '212_Digital Transformation' THEN 591 WHEN input_value = '213_IT Operations' THEN 592 WHEN input_value = '215_Leadership Development Program' THEN 593 WHEN input_value = '216_Management' THEN 594 WHEN input_value = '58_Certifications' THEN 595 WHEN input_value = 'Aspire Journeys' THEN 596 WHEN input_value = 'Business Operations' THEN 597 WHEN input_value = '66_Cloud Services' THEN 598 WHEN input_value = '68_Customer Service' THEN 599 WHEN input_value = 'Data' THEN 600 WHEN input_value = '70_Developer' THEN 601 WHEN input_value = '71_Digital Transformation' THEN 602 WHEN input_value = '74_IT Operations' THEN 603 WHEN input_value = '82_Management' THEN 604 WHEN input_value = 'Productivity & Collaboration Tools' THEN 605 WHEN input_value = 'Professional Improvement' THEN 606 WHEN input_value = '89_Project Management' THEN 607 WHEN input_value = 'Sales & Marketing' THEN 608 WHEN input_value = '121_Customer Service: Core Concepts & Methods' THEN 609 WHEN input_value = 'Data Visualization & Reporting' THEN 610 WHEN input_value = 'Big Data' THEN 611 WHEN input_value = 'Data Security' THEN 612 WHEN input_value = 'Data Analytics' THEN 613 WHEN input_value = 'Data Core Concepts' THEN 614 WHEN input_value = 'Database Development' THEN 615 WHEN input_value = 'Data Platforms' THEN 616 WHEN input_value = 'Business Intelligence' THEN 617 WHEN input_value = '130_Data Science' THEN 618 WHEN input_value = '141_Data Science' THEN 619 WHEN input_value = '146_Digital Marketing & Communications' THEN 620 WHEN input_value = '151_Information Security' THEN 621 WHEN input_value = '152_IT Services' THEN 622 WHEN input_value = '153_DevOps' THEN 623 WHEN input_value = 'IT Trends' THEN 624 WHEN input_value = '155_Network Operations' THEN 625 WHEN input_value = '156_Client & Server Administration' THEN 626 WHEN input_value = 'Design' THEN 627 WHEN input_value = 'Productivity Tools' THEN 628 WHEN input_value = 'Collaboration' THEN 629 WHEN input_value = 'Browsers & Operating Systems' THEN 630 WHEN input_value = '186_Microsoft Office' THEN 631 WHEN input_value = 'Personal Productivity' THEN 632 WHEN input_value = 'Well-Being' THEN 633 WHEN input_value = 'Business Communication' THEN 634 WHEN input_value = 'Self-Discovery' THEN 635 WHEN input_value = 'Personal Accountability' THEN 636 WHEN input_value = 'Individual Professional Performance' THEN 637 WHEN input_value = 'Project Management Methods' THEN 638 WHEN input_value = 'Project Management Core Concepts' THEN 639 WHEN input_value = 'Product Marketing' THEN 640 WHEN input_value = 'Selling Skills' THEN 641 WHEN input_value = 'Salesforce & Channel Management' THEN 642 WHEN input_value = 'Corporate Communications' THEN 643 WHEN input_value = 'Corporate Marketing' THEN 644 WHEN input_value = '205_(ISC)2' THEN 645 WHEN input_value = '206_Amazon' THEN 646 WHEN input_value = '207_Cisco' THEN 647 WHEN input_value = '209_CompTIA' THEN 648 WHEN input_value = '214_Information Systems Audit and Control Association' THEN 649 WHEN input_value = '217_Microsoft' THEN 650 WHEN input_value = '228_Cloud Platforms' THEN 651 WHEN input_value = '229_Cloud Development' THEN 652 WHEN input_value = '245_Information Security' THEN 653 WHEN input_value = '246_IT Services' THEN 654 WHEN input_value = '247_Network Operations' THEN 655 WHEN input_value = '248_Client & Server Administration' THEN 656 WHEN input_value = '250_Leading the Business' THEN 657 WHEN input_value = '251_Leading Your Team' THEN 658 WHEN input_value = '252_Leading Yourself' THEN 659 WHEN input_value = '253_Management Essentials' THEN 660 WHEN input_value = '59_(ISC)2' THEN 661 WHEN input_value = '60_Amazon' THEN 662 WHEN input_value = 'American Society for Quality (ASQ)' THEN 663 WHEN input_value = 'BCS Professional Institute' THEN 664 WHEN input_value = '65_Cisco' THEN 665 WHEN input_value = '67_CompTIA' THEN 666 WHEN input_value = 'EC-Council' THEN 667 WHEN input_value = 'Google' THEN 668 WHEN input_value = 'ITIL®' THEN 669 WHEN input_value = '76_Information Systems Audit and Control Association' THEN 670 WHEN input_value = 'International Institute of Business Analysis (IIBA)' THEN 671 WHEN input_value = 'International Software Testing Qualification Board' THEN 672 WHEN input_value = 'Isograd' THEN 673 WHEN input_value = 'Juniper' THEN 674 WHEN input_value = 'Linux Professional Institute' THEN 675 WHEN input_value = '83_Microsoft' THEN 676 WHEN input_value = '84_Microsoft Office' THEN 677 WHEN input_value = 'Oracle' THEN 678 WHEN input_value = 'PRINCE2®' THEN 679 WHEN input_value = 'Project Management Institute (PMI)®' THEN 680 WHEN input_value = 'Red Hat' THEN 681 WHEN input_value = 'SAS' THEN 682 WHEN input_value = 'TOGAF®' THEN 683 WHEN input_value = '10_Developer' THEN 684 WHEN input_value = 'Data Analyst to Data Scientist' THEN 685 WHEN input_value = 'Business Planning & Analysis' THEN 686 WHEN input_value = 'Finance' THEN 687 WHEN input_value = 'Human Resources' THEN 688 WHEN input_value = 'Process Improvement' THEN 689 WHEN input_value = '11_Digital Transformation' THEN 690 WHEN input_value = '112_Cloud Platforms' THEN 691 WHEN input_value = 'Cloud Basics' THEN 692 WHEN input_value = 'Internet of Things' THEN 693 WHEN input_value = '115_Cloud Development' THEN 694 WHEN input_value = '116_Cloud Security' THEN 695 WHEN input_value = '12_IT Operations' THEN 696 WHEN input_value = 'Developer Trends' THEN 697 WHEN input_value = 'Web Development' THEN 698 WHEN input_value = 'Mobile Development' THEN 699 WHEN input_value = '134_DevOps' THEN 700 WHEN input_value = '135_Secure Programming' THEN 701 WHEN input_value = 'Data Modelling' THEN 702 WHEN input_value = '137_Developer Concepts & Methodologies' THEN 703 WHEN input_value = '138_Developer Tools' THEN 704 WHEN input_value = '139_Programming Languages' THEN 705 WHEN input_value = '14_Leadership Development Program' THEN 706 WHEN input_value = 'Microservices' THEN 707 WHEN input_value = '142_Essentials of Digital Transformation' THEN 708 WHEN input_value = '143_Virtual Work' THEN 709 WHEN input_value = '144_Digital Soft Skills Competencies' THEN 710 WHEN input_value = '145_Agility for Digital Transformation' THEN 711 WHEN input_value = '147_Digital Experiences' THEN 712 WHEN input_value = '15_Management' THEN 713 WHEN input_value = 'Leadership Essentials' THEN 714 WHEN input_value = '166_Management Essentials' THEN 715 WHEN input_value = 'Team Management' THEN 716 WHEN input_value = 'Business Execution' THEN 717 WHEN input_value = 'Business Strategy' THEN 718 WHEN input_value = '233_Customer Service: Core Concepts & Methods' THEN 719 WHEN input_value = '234_Secure Programming' THEN 720 WHEN input_value = '235_Developer Concepts & Methodologies' THEN 721 WHEN input_value = '236_Developer Tools' THEN 722 WHEN input_value = '237_Programming Languages' THEN 723 WHEN input_value = '238_Data Science' THEN 724 WHEN input_value = '239_Essentials of Digital Transformation' THEN 725 WHEN input_value = '240_Virtual Work' THEN 726 WHEN input_value = '241_Digital Soft Skills Competencies' THEN 727 WHEN input_value = '242_Agility for Digital Transformation' THEN 728 WHEN input_value = '243_Digital Marketing & Communications' THEN 729 WHEN input_value = '244_Digital Experiences' THEN 730 WHEN input_value = '3_Certifications' THEN 731 WHEN input_value = '7_Cloud Services' THEN 732 WHEN input_value = '9_Customer Service' THEN 733 WHEN input_value = 'ASQ (American Society for Quality)' THEN 734 WHEN input_value = '104_Foundation' THEN 735 WHEN input_value = '109_Professional' THEN 736 WHEN input_value = '110_Entry' THEN 737 WHEN input_value = '111_Associate' THEN 738 WHEN input_value = '13_Information Systems Audit and Control Association' THEN 739 WHEN input_value = '148_Core' THEN 740 WHEN input_value = '16_Microsoft' THEN 741 WHEN input_value = '161_Foundation' THEN 742 WHEN input_value = '164_Administrator' THEN 743 WHEN input_value = 'Microsoft Certified Associate' THEN 744 WHEN input_value = '171_Specialist' THEN 745 WHEN input_value = '172_Microsoft Certified Solutions Developer (MCSD)' THEN 746 WHEN input_value = '173_Microsoft Certified Solutions Associate (MCSA)' THEN 747 WHEN input_value = '174_Microsoft Certified Solutions Expert (MCSE)' THEN 748 WHEN input_value = '175_Associate (MTA)' THEN 749 WHEN input_value = 'Microsoft Certified Fundamentals' THEN 750 WHEN input_value = 'Microsoft Office Specialist (MOS)' THEN 751 WHEN input_value = '178_Professional' THEN 752 WHEN input_value = 'Expert' THEN 753 WHEN input_value = '180_Associate' THEN 754 WHEN input_value = '181_Foundation' THEN 755 WHEN input_value = '196_Administrator' THEN 756 WHEN input_value = 'Base Programmer' THEN 757 WHEN input_value = '218_Cloud Security' THEN 758 WHEN input_value = '219_Systems Security' THEN 759 WHEN input_value = '220_Software Development' THEN 760 WHEN input_value = '221_Information Security' THEN 761 WHEN input_value = '249_Auditor' THEN 762 WHEN input_value = '27_Cloud Platforms' THEN 763 WHEN input_value = '28_Cloud Development' THEN 764 WHEN input_value = '4_(ISC)2' THEN 765 WHEN input_value = '44_Information Security' THEN 766 WHEN input_value = '45_IT Services' THEN 767 WHEN input_value = '46_Network Operations' THEN 768 WHEN input_value = '47_Client & Server Administration' THEN 769 WHEN input_value = '49_Leading the Business' THEN 770 WHEN input_value = '5_Amazon' THEN 771 WHEN input_value = '50_Leading Your Team' THEN 772 WHEN input_value = '51_Leading Yourself' THEN 773 WHEN input_value = '52_Management Essentials' THEN 774 WHEN input_value = '6_Cisco' THEN 775 WHEN input_value = '8_CompTIA' THEN 776 WHEN input_value = '100_Architecting' THEN 777 WHEN input_value = '101_Operations' THEN 778 WHEN input_value = 'Additional Professional' THEN 779 WHEN input_value = '118_Cybersecurity' THEN 780 WHEN input_value = '119_Infrastructure' THEN 781 WHEN input_value = '120_Core' THEN 782 WHEN input_value = '149_Associate' THEN 783 WHEN input_value = '150_Professional' THEN 784 WHEN input_value = '157_Foundation' THEN 785 WHEN input_value = '158_Auditor' THEN 786 WHEN input_value = 'Security Manager' THEN 787 WHEN input_value = 'Level 3 - CBAP' THEN 788 WHEN input_value = 'TOSA Desktop' THEN 789 WHEN input_value = '163_Associate' THEN 790 WHEN input_value = '195_Project Management' THEN 791 WHEN input_value = 'TOGAF® 9' THEN 792 WHEN input_value = '222_Developing' THEN 793 WHEN input_value = '223_Architecting' THEN 794 WHEN input_value = '224_Operations' THEN 795 WHEN input_value = '225_Professional' THEN 796 WHEN input_value = '226_Entry' THEN 797 WHEN input_value = '227_Associate' THEN 798 WHEN input_value = '230_Cybersecurity' THEN 799 WHEN input_value = '231_Infrastructure' THEN 800 WHEN input_value = '232_Core' THEN 801 WHEN input_value = '254_Specialist' THEN 802 WHEN input_value = '255_Microsoft Certified Solutions Developer (MCSD)' THEN 803 WHEN input_value = '256_Microsoft Certified Solutions Associate (MCSA)' THEN 804 WHEN input_value = '257_Microsoft Certified Solutions Expert (MCSE)' THEN 805 WHEN input_value = '258_Associate (MTA)' THEN 806 WHEN input_value = '32_Customer Service: Core Concepts & Methods' THEN 807 WHEN input_value = '33_Secure Programming' THEN 808 WHEN input_value = '34_Developer Concepts & Methodologies' THEN 809 WHEN input_value = '35_Developer Tools' THEN 810 WHEN input_value = '36_Programming Languages' THEN 811 WHEN input_value = '37_Data Science' THEN 812 WHEN input_value = '38_Essentials of Digital Transformation' THEN 813 WHEN input_value = '39_Virtual Work' THEN 814 WHEN input_value = '40_Digital Soft Skills Competencies' THEN 815 WHEN input_value = '41_Agility for Digital Transformation' THEN 816 WHEN input_value = '42_Digital Marketing & Communications' THEN 817 WHEN input_value = '43_Digital Experiences' THEN 818 WHEN input_value = '95_Cloud Security' THEN 819 WHEN input_value = '96_Systems Security' THEN 820 WHEN input_value = '97_Software Development' THEN 821 WHEN input_value = '98_Information Security' THEN 822 WHEN input_value = '99_Developing' THEN 823 WHEN input_value = '17_Cloud Security' THEN 824 WHEN input_value = '18_Systems Security' THEN 825 WHEN input_value = '19_Software Development' THEN 826 WHEN input_value = '20_Information Security' THEN 827 WHEN input_value = '29_Cybersecurity' THEN 828 WHEN input_value = '30_Infrastructure' THEN 829 WHEN input_value = '31_Core' THEN 830 WHEN input_value = '48_Auditor' THEN 831 WHEN input_value = '21_Developing' THEN 832 WHEN input_value = '22_Architecting' THEN 833 WHEN input_value = '23_Operations' THEN 834 WHEN input_value = '24_Professional' THEN 835 WHEN input_value = '25_Entry' THEN 836 WHEN input_value = '26_Associate' THEN 837 WHEN input_value = '53_Specialist' THEN 838 WHEN input_value = '54_Microsoft Certified Solutions Developer (MCSD)' THEN 839 WHEN input_value = '55_Microsoft Certified Solutions Associate (MCSA)' THEN 840 WHEN input_value = '56_Microsoft Certified Solutions Expert (MCSE)' THEN 841 WHEN input_value = '57_Associate (MTA)' THEN 842 WHEN input_value = 'Java' THEN 843 WHEN input_value = 'oops' THEN 844 WHEN input_value = 'python' THEN 845 WHEN input_value = 'Auditor' THEN 846 WHEN input_value = 'Browsers & Operating Systems' THEN 847 WHEN input_value = 'Business Skills' THEN 848 WHEN input_value = 'Cloud' THEN 849 WHEN input_value = 'Cloud Computing' THEN 850 WHEN input_value = 'Collaboration' THEN 851 WHEN input_value = 'Data / ML / AI' THEN 852 WHEN input_value = 'Decision-makers and Leaders' THEN 853 WHEN input_value = 'Design' THEN 854 WHEN input_value = 'DevOps' THEN 855 WHEN input_value = 'Foundation' THEN 856 WHEN input_value = 'Get Started' THEN 857 WHEN input_value = 'IT Ops' THEN 858 WHEN input_value = 'Leading the Business' THEN 859 WHEN input_value = 'Leading Your Team' THEN 860 WHEN input_value = 'Leading Yourself' THEN 861 WHEN input_value = 'Level 3 - CBAP' THEN 862 WHEN input_value = 'PM' THEN 863 WHEN input_value = 'Productivity Tools' THEN 864 WHEN input_value = 'Programming' THEN 865 WHEN input_value = 'Adapting to Change' THEN 866 WHEN input_value = 'Business Execution' THEN 867 WHEN input_value = 'Business Strategy' THEN 868 WHEN input_value = 'Business Continuity Planning' THEN 869 WHEN input_value = 'Collaboration Tools' THEN 870 WHEN input_value = 'Communication Essentials' THEN 871 WHEN input_value = 'Crisis Management' THEN 872 WHEN input_value = 'Environmental, Health and Safety (EHS) Compliance' THEN 873 WHEN input_value = 'Food and Alcohol Safety' THEN 874 WHEN input_value = 'Leadership Essentials' THEN 875 WHEN input_value = 'Leading Teams' THEN 876 WHEN input_value = 'Legal Compliance' THEN 877 WHEN input_value = 'Professional Essentials' THEN 878 WHEN input_value = 'Software Tester to DevOps Automated Tester' THEN 879 WHEN input_value = 'Penetration Tester to SecOps Engineer' THEN 880 WHEN input_value = 'Web Programmer to Apprentice Programmer' THEN 881 WHEN input_value = 'Software Project Lead to Advanced Scrum Master' THEN 882 WHEN input_value = 'Network Security Specialist to CloudOps Security Architect' THEN 883 WHEN input_value = 'DevOps Engineer to Cloud Architect' THEN 884 WHEN input_value = 'Apprentice Developer to Journeyman Developer' THEN 885 WHEN input_value = 'AI Apprentice to AI Architect' THEN 886 WHEN input_value = 'Programmer to API Developer' THEN 887 WHEN input_value = 'Developer to Software Architect' THEN 888 WHEN input_value = 'Network Admin to Site Reliability Engineer' THEN 889 WHEN input_value = 'Infrastructure Support Engineer to CloudOps Engineer' THEN 890 WHEN input_value = 'Business Analyst to Data Analyst' THEN 891 WHEN input_value = 'Data Visualization' THEN 892 WHEN input_value = 'Pythonista to Python Master' THEN 893 WHEN input_value = 'Management Essentials' THEN 894 WHEN input_value = 'Microsoft Office 2016' THEN 895 WHEN input_value = 'Microsoft Office 365' THEN 896 WHEN input_value = 'Data Analysis with R' THEN 897 WHEN input_value = 'Security Essentials for Decision-makers and Leaders' THEN 898 WHEN input_value = 'Agile for Software Development' THEN 899 WHEN input_value = 'Serverless Deployments for Developers' THEN 900 WHEN input_value = 'Java Novice to Javanista' THEN 901 WHEN input_value = 'Web App Vulnerability Analyst' THEN 902 WHEN input_value = '5G Technologies and Practices' THEN 903 WHEN input_value = 'Go Programming Essentials' THEN 904 WHEN input_value = 'Enriched Web Development with Angular 11' THEN 905 WHEN input_value = 'Novice Developer to Pythonista' THEN 906 WHEN input_value = 'Javanista to Java Master' THEN 907 WHEN input_value = 'Developer Fundamentals' THEN 908 WHEN input_value = 'Programming Python in Action' THEN 909 WHEN input_value = 'Enterprise Development to DevOps Engineer' THEN 910 WHEN input_value = 'Web App Vulnerability Analyst - 2022 Update' THEN 911 WHEN input_value = 'Enterprise Development to Full Stack Developer' THEN 912 WHEN input_value = 'Software Product Management Proficiency' THEN 913 WHEN input_value = 'Engineering Lead' THEN 914 WHEN input_value = 'AI and ML for Decision-makers' THEN 915 WHEN input_value = 'Software Project Analyst to Senior Software Project Manager' THEN 916 WHEN input_value = 'Security Analyst to Security Architect' THEN 917 WHEN input_value = 'Programmer to Secure Agile Programmer' THEN 918 WHEN input_value = 'Virtual Work in the New Normal' THEN 919 WHEN input_value = 'Manage Myself' THEN 920 WHEN input_value = 'Manage Others' THEN 921 WHEN input_value = 'Security' THEN 922 WHEN input_value = 'Security Manager' THEN 923 WHEN input_value = 'Server Technology' THEN 924 WHEN input_value = 'Six Sigma Certification' THEN 925 WHEN input_value = 'Software Craftsmanship' THEN 926 WHEN input_value = 'Topics' THEN 927 WHEN input_value = 'Strategic Thinking' THEN 928 WHEN input_value = 'Team Management' THEN 929 WHEN input_value = 'Time Management and Productivity' THEN 930 WHEN input_value = 'Working on a Team' THEN 931 WHEN input_value = 'Working Remotely' THEN 932 WHEN input_value = 'Work-Life Balance' THEN 933 WHEN input_value = 'Accounting' THEN 934 WHEN input_value = 'AGG Leadership' THEN 935 WHEN input_value = 'Diversity on the Job' THEN 936 WHEN input_value = 'Time Management' THEN 937 WHEN input_value = 'Unconscious Bias' THEN 938 WHEN input_value = 'Diversity, Equity, and Inclusion' THEN 939 WHEN input_value = 'Building DEI Leadership Skills' THEN 940 WHEN input_value = 'Psychological Safety' THEN 941 WHEN input_value = 'Skills for Effective Collaboration' THEN 942 WHEN input_value = 'Managing a Crisis' THEN 943 WHEN input_value = 'Business' THEN 944 WHEN input_value = 'C#' THEN 945 WHEN input_value = 'Cisco Teams' THEN 946 WHEN input_value = 'Cisco WebEx' THEN 947 WHEN input_value = 'Computer Skills' THEN 948 WHEN input_value = 'Core Knowledge' THEN 949 WHEN input_value = 'Developer Tools' THEN 950 WHEN input_value = 'dot NET' THEN 951 WHEN input_value = 'Food and Alcohol Safety (Latin American Spanish Edition)' THEN 952 WHEN input_value = 'Food and Alcohol Safety (UK Edition)' THEN 953 WHEN input_value = 'Food and Alcohol Safety (US Edition)' THEN 954 WHEN input_value = 'Forms & Lists' THEN 955 WHEN input_value = 'Gemba' THEN 956 WHEN input_value = 'Hansei' THEN 957 WHEN input_value = 'Harassment (Canadian French Edition)' THEN 958 WHEN input_value = 'Harassment (Chinese Edition)' THEN 959 WHEN input_value = 'Harassment (Danish Edition)' THEN 960 WHEN input_value = 'Harassment (Dutch Edition)' THEN 961 WHEN input_value = 'Harassment (Finnish Edition)' THEN 962 WHEN input_value = 'Harassment (Hungarian Edition)' THEN 963 WHEN input_value = 'Harassment (Norwegian Edition)' THEN 964 WHEN input_value = 'Harassment (Romanian Edition)' THEN 965 WHEN input_value = 'Harassment (Russian Edition)' THEN 966 WHEN input_value = 'Harassment (Castilian Spanish Edition)' THEN 967 WHEN input_value = 'Harassment (Swedish Edition)' THEN 968 WHEN input_value = 'Harassment (Turkish Edition)' THEN 969 WHEN input_value = 'Harassment (UK English Edition)' THEN 970 WHEN input_value = 'Harassment (US Edition)' THEN 971 WHEN input_value = 'Health Insurance Portability and Accountability Act (HIPAA) (Latin American Spanish Edition)' THEN 972 WHEN input_value = 'Health Insurance Portability and Accountability Act (HIPAA) (US Edition)' THEN 973 WHEN input_value = 'Health and Wellness' THEN 974 WHEN input_value = 'Hoshin' THEN 975 WHEN input_value = 'Introductory Topics' THEN 976 WHEN input_value = 'JDE' THEN 977 WHEN input_value = 'Joinme' THEN 978 WHEN input_value = 'Just In Time' THEN 979 WHEN input_value = 'Kaizen Leadership' THEN 980 WHEN input_value = 'Kanban' THEN 981 WHEN input_value = 'Leadership & Teamwork' THEN 982 WHEN input_value = 'Additional Content' THEN 983 WHEN input_value = 'Legal Impacts (US Edition)' THEN 984 WHEN input_value = 'Legal Impacts (Brazilian Portuguese Edition)' THEN 985 WHEN input_value = 'Legal Impacts (Chinese Edition)' THEN 986 WHEN input_value = 'Legal Impacts (German Edition)' THEN 987 WHEN input_value = 'LMS Instructions' THEN 988 WHEN input_value = 'LogMeIn' THEN 989 WHEN input_value = 'Microservices' THEN 990 WHEN input_value = 'Mobile Development' THEN 991 WHEN input_value = 'Muda' THEN 992 WHEN input_value = 'Open Sesame' THEN 993 WHEN input_value = 'Improving Your Work/Life Balance' THEN 994 WHEN input_value = 'Improving Your Personal Productivity' THEN 995 WHEN input_value = 'Perseverance at Work' THEN 996 WHEN input_value = 'Percipio' THEN 997 WHEN input_value = 'Policies & Procedures' THEN 998 WHEN input_value = 'Problem Solving' THEN 999 ELSE END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (st:SumTotalField {name: "Activity Description", file: "Activity_Curriculum"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Description", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "5000", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (st:SumTotalField {name: "Owner", file: "Activity_Curriculum"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Owners*", file: "Activity_Curriculum" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Created/Modified By", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "User performing the load", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Keywords", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Available Languages", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Availability to All Users", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Availability to Specific Users", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Availability to OU‡", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Availability OU Type", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Register Upon Approval", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Pre-Approved", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Includes Subordinates", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Curriculum Player", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "Curriculum Player", csod.accepted_values = "Training Details, 0, n, no, f, FALSE, off, inactive, Curriculum Player, 1, y, yes, t, TRUE, on, active, Curriculum Player 2.0, 2",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Recurrence", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "0", csod.accepted_values = "0, 1, 2, 3, 5, 6, 7",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Thumbnail", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "Portal Default Thumbnail", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Exclude from Course Recommendations", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Training Purpose", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "テスト",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Points", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Text", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod); 


MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Badge", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Text", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Onboarded, Onboarded (1), Presentation Expert, Curriculum Leader, Safety First, Video Master, NEW HIRE ONBOARDING SUCCESSFULLY DONE, voohoo, Above and Beyond, Great Work, DELETE",  csod.output_document = "Activity_Curriculum" 
MERGE (f)-[:OUTPUTS_FIELD]->(csod); 


MERGE ( f:File {name: "Activity_Curriculum"})
MERGE (csod:CSODField {name: "Emails", file: "Activity_Curriculum" })
SET csod.mandatory = "Optional", csod.field_type = "Enum", csod.char_length = "", csod.default_value = "No Email", csod.accepted_values = "System Default, No Email",  csod.output_document = "Activity_Curriculum"
MERGE (f)-[:OUTPUTS_FIELD]->(csod); 


MERGE ( f:File {name: "Activity_CurriculumStructure"})
MERGE (st:SumTotalField {name: "ActivityCode", file: "Activity_CurriculumStructure"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Curriculum ID*", file: "Activity_CurriculumStructure" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_CurriculumStructure"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_CurriculumStructure"})
MERGE (csod:CSODField {name: "Section #*", file: "Activity_CurriculumStructure" })
SET csod.mandatory = "Mandatory", csod.field_type = "Integer", csod.max_value = "999", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_CurriculumStructure"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_CurriculumStructure"})
MERGE (st:SumTotalField {name: "SectionName", file: "Activity_CurriculumStructure"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Section Name*", file: "Activity_CurriculumStructure" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_CurriculumStructure"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_CurriculumStructure"})
MERGE (st:SumTotalField {name: "Child ActivityCode", file: "Activity_CurriculumStructure"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Child LO ID*", file: "Activity_CurriculumStructure" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = "",  csod.output_document = "Activity_CurriculumStructure"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_CurriculumStructure"})
MERGE (csod:CSODField {name: "Course Play Order", file: "Activity_CurriculumStructure" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "999", csod.default_value = "1", csod.accepted_values = "",  csod.output_document = "Activity_CurriculumStructure"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_CurriculumStructure"})
MERGE (csod:CSODField {name: "Pay Upfront", file: "Activity_CurriculumStructure" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive",  csod.output_document = "Activity_CurriculumStructure"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_CurriculumStructure"})
MERGE (csod:CSODField {name: "Pre Approve", file: "Activity_CurriculumStructure" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive",csod.input_document = "Activity_Curriculum",  csod.output_document = "Activity_CurriculumStructure"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_CurriculumStructure"})
MERGE (csod:CSODField {name: "Auto Register", file: "Activity_CurriculumStructure" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive",  csod.output_document = "Activity_CurriculumStructure"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_CurriculumStructure"})
MERGE (csod:CSODField {name: "Auto Launch", file: "Activity_CurriculumStructure" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive",  csod.output_document = "Activity_CurriculumStructure"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_CurriculumStructure"})
MERGE (csod:CSODField {name: "Modified By", file: "Activity_CurriculumStructure" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "User performing the load", csod.accepted_values = "",  csod.output_document = "Activity_CurriculumStructure"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "ActivityCode", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Event ID*", file: "Activity_Events" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "ActivityName", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Event Name*", file: "Activity_Events" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "Active", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Active", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "TRUE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "Provider", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Vendor/Provider*", file: "Activity_Events" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Secondary Vendor/Provider", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "Topic", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Subject IDs*", file: "Activity_Events"})
SET csod.mandatory = "Mandatory", 
    csod.field_type = "subjectType",              
    csod.char_length = "",                    
    csod.default_value = "",             
    csod.accepted_values = "",
    csod.transformation = "CASE WHEN input_value = 'Production Preparation Process' THEN 1000 WHEN input_value = 'Programming Languages' THEN 1001 WHEN input_value = 'QC Circle' THEN 1002 WHEN input_value = 'Quality' THEN 1003 WHEN input_value = 'Quick Changeover' THEN 1004 WHEN input_value = 'Reference' THEN 1005 WHEN input_value = 'Safety' THEN 1006 WHEN input_value = 'SCP Resources' THEN 1007 WHEN input_value = 'Secure Programming' THEN 1008 WHEN input_value = 'Six Sigma' THEN 1009 WHEN input_value = 'Skillsoft' THEN 1010 WHEN input_value = 'Productivity Tools forDevOps Automated Testers' THEN 1011 WHEN input_value = 'Productivity Tools for SecOps Engineers' THEN 1012 WHEN input_value = 'Business & Leadership for Apprentice Programmers' THEN 1013 WHEN input_value = 'Productivity Tools for Apprentice Programmers' THEN 1014 WHEN input_value = 'Productivity Tools for Cloud Architects' THEN 1015 WHEN input_value = 'Productivity Tools for CloudOps Engineers' THEN 1016 WHEN input_value = 'Productivity Tools for Business Analyst to Data Analysts' THEN 1017 WHEN input_value = 'Efficiency & Productivity in the New Normal' THEN 1018 WHEN input_value = 'Managing & Leading through Unexpected Disruption' THEN 1019 WHEN input_value = 'Productivity Tools for Data Visualization' THEN 1020 WHEN input_value = 'Business & Leadership for Data Analysis with R' THEN 1021 WHEN input_value = 'Productivity Tools for Data Analysis with R' THEN 1022 WHEN input_value = 'Productivity Tools with Agile for Software Development' THEN 1023 WHEN input_value = 'Productivity Tools for Web App Vulnerability Analyst' THEN 1024 WHEN input_value = 'Productivity Tools for 5G Technologies and Practices' THEN 1025 WHEN input_value = 'Business & Leadership for Enriched Web Development with Angular 11' THEN 1026 WHEN input_value = 'Business & Leadership for Pythonista' THEN 1027 WHEN input_value = 'Business & Leadership for Javanista to Java Master' THEN 1028 WHEN input_value = 'Business & Leadership for Developer Fundamentals' THEN 1029 WHEN input_value = 'Business & Leadership for Programming Python in Action' THEN 1030 WHEN input_value = 'Business & Leadership for Software Product Management' THEN 1031 WHEN input_value = 'Productivity Tools for senior Software Project Managers' THEN 1032 WHEN input_value = 'Productivity Tools for Security Architects' THEN 1033 WHEN input_value = 'Business & Leadership for Enterprise Development to Full Stack Developers' THEN 1034 WHEN input_value = 'Productivity Tools for Full Stack Developer' THEN 1035 WHEN input_value = 'Productivity Tools for DevOps Engineer' THEN 1036 WHEN input_value = 'Skype 2016' THEN 1037 WHEN input_value = 'Standard Work' THEN 1038 WHEN input_value = 'Standard Work - Leader' THEN 1039 WHEN input_value = 'T1' THEN 1040 WHEN input_value = 'TACTIS' THEN 1041 WHEN input_value = 'Total Productive Maintenance' THEN 1042 WHEN input_value = 'TQM (Total Quality Management)' THEN 1043 WHEN input_value = 'TWI for Facilitators' THEN 1044 WHEN input_value = 'TWI for Learners' THEN 1045 WHEN input_value = 'US Federal Government Compliance (US Edition)' THEN 1046 WHEN input_value = 'Value Stream' THEN 1047 WHEN input_value = 'Visual Management' THEN 1048 WHEN input_value = 'Web Development' THEN 1049 WHEN input_value = 'Workplace Compliance Essentials (Brazilian Portuguese Edition)' THEN 1050 WHEN input_value = 'Workplace Compliance Essentials (UK English Edition)' THEN 1051 WHEN input_value = 'Workplace Compliance Essentials (Canadian Edition)' THEN 1052 WHEN input_value = 'Workplace Compliance Essentials (Castilian Spanish Edition)' THEN 1053 WHEN input_value = 'Workplace Compliance Essentials (Turkish Edition)' THEN 1054 WHEN input_value = 'Workplace Compliance Essentials (Australian Edition)' THEN 1055 WHEN input_value = 'Workplace Compliance Essentials (Thai Edition)' THEN 1056 WHEN input_value = 'Workplace Compliance Essentials (Swedish Edition)' THEN 1057 WHEN input_value = 'Workplace Compliance Essentials (Bahasa Malay Edition)' THEN 1058 WHEN input_value = 'Workplace Compliance Essentials (Vietnamese Edition)' THEN 1059 WHEN input_value = 'Workplace Compliance Essentials (Dutch Edition)' THEN 1060 WHEN input_value = 'Workplace Compliance Essentials (Norwegian Edition)' THEN 1061 WHEN input_value = 'Workplace Compliance Essentials (New Zealand Edition)' THEN 1062 WHEN input_value = 'Workplace Compliance Essentials (French Edition)' THEN 1063 WHEN input_value = 'Workplace Compliance Essentials (German Edition)' THEN 1064 WHEN input_value = 'Workplace Compliance Essentials (Italian Edition)' THEN 1065 WHEN input_value = 'Workplace Compliance Essentials (Japanese Edition)' THEN 1066 WHEN input_value = 'XML' THEN 1067 WHEN input_value = 'Communicating Tactfully and Diplomatically' THEN 1068 WHEN input_value = 'Leading Virtual Teams' THEN 1069 WHEN input_value = 'Thinking Strategically and Managing Risk' THEN 1070 WHEN input_value = 'Virtual Teams' THEN 1071 WHEN input_value = 'Communication' THEN 1072 WHEN input_value = 'Microsoft 365: Teams' THEN 1073 WHEN input_value = 'EHS Impacts (US Edition)' THEN 1074 WHEN input_value = 'Environmental (Latin American Spanish Edition)' THEN 1075 WHEN input_value = 'Environmental (US Edition)' THEN 1076 WHEN input_value = 'Environmental (Canadian Edition)' THEN 1077 WHEN input_value = 'Environmental (Canadian French Edition)' THEN 1078 WHEN input_value = 'Harassment (Australian Edition)' THEN 1079 WHEN input_value = 'Harassment (Bahasa Indonesian Edition)' THEN 1080 WHEN input_value = 'Harassment (Bahasa Malay Edition)' THEN 1081 WHEN input_value = 'Harassment (Brazilian Portuguese Edition)' THEN 1082 WHEN input_value = 'Harassment (Canadian Edition)' THEN 1083 WHEN input_value = 'Harassment (Czech Edition)' THEN 1084 WHEN input_value = 'Harassment (French Edition)' THEN 1085 WHEN input_value = 'Harassment (German Edition)' THEN 1086 WHEN input_value = 'Harassment (Hindi Edition)' THEN 1087 WHEN input_value = 'Harassment (Indian Edition)' THEN 1088 WHEN input_value = 'Harassment (Italian Edition)' THEN 1089 WHEN input_value = 'Harassment (Japanese Edition)' THEN 1090 WHEN input_value = 'Harassment (Korean Edition)' THEN 1091 WHEN input_value = 'Harassment (Latin American Spanish Edition)' THEN 1092 WHEN input_value = 'Harassment (New Zealand Edition)' THEN 1093 WHEN input_value = 'Harassment (Polish Edition)' THEN 1094 WHEN input_value = 'Harassment (Thai Edition)' THEN 1095 WHEN input_value = 'Harassment (Vietnamese Edition)' THEN 1096 WHEN input_value = 'Health, Safety and Security (Canadian Edition)' THEN 1097 WHEN input_value = 'Health, Safety and Security (Canadian French Edition)' THEN 1098 WHEN input_value = 'Health, Safety and Security (Castilian Spanish Edition)' THEN 1099 WHEN input_value = 'Health, Safety and Security (Dutch Edition)' THEN 1100 WHEN input_value = 'Health, Safety and Security (Korean Edition)' THEN 1101 WHEN input_value = 'Health, Safety and Security (Australian Edition)' THEN 1102 WHEN input_value = 'Health, Safety and Security (New Zealand Edition)' THEN 1103 WHEN input_value = 'Health, Safety and Security (Chinese Edition)' THEN 1104 WHEN input_value = 'Health, Safety and Security (German Edition)' THEN 1105 WHEN input_value = 'Health, Safety and Security (Latin American Spanish Edition)' THEN 1106 WHEN input_value = 'Health, Safety and Security (US Edition)' THEN 1107 WHEN input_value = 'Health, Safety and Security (UK Edition)' THEN 1108 WHEN input_value = 'Health, Safety and Security (Portuguese Brazilian Edition)' THEN 1109 WHEN input_value = 'Health, Safety and Security (French Edition)' THEN 1110 WHEN input_value = 'Health, Safety and Security (ltalian Edition)' THEN 1111 WHEN input_value = 'Legal Impacts (French Edition)' THEN 1112 WHEN input_value = 'Legal Impacts (Latin American Spanish Edition)' THEN 1113 WHEN input_value = 'Legal Impacts (UK English Edition)' THEN 1114 WHEN input_value = 'Meetings' THEN 1115 WHEN input_value = 'Navigating through Organizational Change' THEN 1116 WHEN input_value = 'Productivity Tools for Advanced Scrum Masters' THEN 1117 WHEN input_value = 'Productivity Tools for CloudOps Security Architect' THEN 1118 WHEN input_value = 'Business & Leadership for Journeyman Developers' THEN 1119 WHEN input_value = 'Productivity Tools for Journeyman Developers' THEN 1120 WHEN input_value = 'Business & Leadership for AI Architects' THEN 1121 WHEN input_value = 'Productivity Tools for AI Architects' THEN 1122 WHEN input_value = 'Business & Leadership for API Developers' THEN 1123 WHEN input_value = 'Productivity Tools for API Developers' THEN 1124 WHEN input_value = 'Business & Leadership for Software Architects' THEN 1125 WHEN input_value = 'Productivity Tools for Software Architects' THEN 1126 WHEN input_value = 'Business & Leadership for Site Reliability Engineers' THEN 1127 WHEN input_value = 'Productivity Tools for Site Reliability Engineers' THEN 1128 WHEN input_value = 'Business & Leadership for Python Master' THEN 1129 WHEN input_value = 'Productivity Tools for Python Master' THEN 1130 WHEN input_value = 'Productivity Tools for Decision-makers and Leaders' THEN 1131 WHEN input_value = 'Business & Leadership with Serverless Deployments for Developers' THEN 1132 WHEN input_value = 'Productivity Tools with Serverless Deployments for Developers' THEN 1133 WHEN input_value = 'Business & Leadership for Javanista' THEN 1134 WHEN input_value = 'Productivity Tools for Javanista' THEN 1135 WHEN input_value = 'Business & Leadership for Go Programming Essentials' THEN 1136 WHEN input_value = 'Business & Leadership for Engineering Lead' THEN 1137 WHEN input_value = 'Business & Leadership for AI and ML for Decision-makers' THEN 1138 WHEN input_value = 'Productivity Tools for Secure Agile Programmers' THEN 1139 WHEN input_value = 'Transportation (Latin American Spanish Edition)' THEN 1140 WHEN input_value = 'Transportation (US Edition)' THEN 1141 WHEN input_value = 'Transportation (Italian Edition)' THEN 1142 WHEN input_value = 'Transportation (Canadian Edition)' THEN 1143 WHEN input_value = 'Transportation (Canadian French Edition)' THEN 1144 WHEN input_value = 'Transportation (UK Edition)' THEN 1145 WHEN input_value = 'Transportation (Chinese Edition)' THEN 1146 WHEN input_value = 'Transportation (Portuguese Brazilian Edition)' THEN 1147 WHEN input_value = 'Transportation (German Edition)' THEN 1148 WHEN input_value = 'Transportation (Castilian Spanish Edition)' THEN 1149 WHEN input_value = 'Transportation (Korean Edition)' THEN 1150 WHEN input_value = 'Transportation (Dutch Edition)' THEN 1151 WHEN input_value = 'Transportation (French Edition)' THEN 1152 WHEN input_value = 'Workplace Compliance Essentials (Canadian French Edition)' THEN 1153 WHEN input_value = 'Workplace Compliance Essentials (Russian Edition)' THEN 1154 WHEN input_value = 'Workplace Compliance Essentials (US Edition)' THEN 1155 WHEN input_value = 'Workplace Compliance Essentials (Korean Edition)' THEN 1156 WHEN input_value = 'Workplace Compliance Essentials (Czech Edition)' THEN 1157 WHEN input_value = 'Workplace Compliance Essentials (Chinese Edition)' THEN 1158 WHEN input_value = 'Workplace Compliance Essentials (Hindi Edition)' THEN 1159 WHEN input_value = 'Workplace Compliance Essentials (Bahasa Indonesian Edition)' THEN 1160 WHEN input_value = 'Workplace Compliance Essentials (Hungarian Edition)' THEN 1161 WHEN input_value = 'Workplace Compliance Essentials (Romanian Edition)' THEN 1162 WHEN input_value = 'Workplace Compliance Essentials (Finnish Edition)' THEN 1163 WHEN input_value = 'Workplace Compliance Essentials (Danish Edition)' THEN 1164 WHEN input_value = 'Workplace Compliance Essentials (Chinese Traditional Edition)' THEN 1165 WHEN input_value = 'Workplace Compliance Essentials (Latin American Spanish Edition)' THEN 1166 WHEN input_value = 'Workplace Compliance Essentials (Polish Edition)' THEN 1167 WHEN input_value = 'Food Allergies And Intolerance' THEN 1168 WHEN input_value = 'Industry Specific' THEN 1169 WHEN input_value = 'Cal/OSHA Latin American Spanish' THEN 1170 WHEN input_value = 'Technology' THEN 1171 WHEN input_value = 'Disability Discrimination Awareness' THEN 1172 WHEN input_value = 'Cisco WebEx Teams' THEN 1173 WHEN input_value = 'Equality and Diversity Awareness' THEN 1174 WHEN input_value = 'Cisco WebEx for Web' THEN 1175 WHEN input_value = 'Portuguese' THEN 1176 WHEN input_value = 'French Canadian' THEN 1177 WHEN input_value = 'Japanese' THEN 1178 WHEN input_value = 'Cal/OSHA' THEN 1179 WHEN input_value = 'Coordinators' THEN 1180 WHEN input_value = 'Managers' THEN 1181 WHEN input_value = 'Skype for Business 2016 (No Assessments)' THEN 1182 WHEN input_value = 'First Aid Awareness' THEN 1183 WHEN input_value = 'Fire Safety Awareness' THEN 1184 WHEN input_value = 'Join.me for Windows (No Assessments)' THEN 1185 WHEN input_value = 'LogMeIn GoToMeeting (No Assessments)' THEN 1186 WHEN input_value = 'Presentation Skills' THEN 1187 WHEN input_value = 'Project Sheets' THEN 1188 WHEN input_value = '5S' THEN 1189 WHEN input_value = 'Label Templates' THEN 1190 WHEN input_value = 'Final Presentation' THEN 1191 WHEN input_value = 'Kaizen' THEN 1192 WHEN input_value = 'Engineering' THEN 1193 WHEN input_value = 'Lifelong Learn' THEN 1194 WHEN input_value = 'Cloud Services' THEN 1195 WHEN input_value = 'Business Operations' THEN 1196 WHEN input_value = 'Welcome to Percipio' THEN 1197 WHEN input_value = 'Aspire Journeys for Leadership' THEN 1198 WHEN input_value = 'Cybersecurity Career Journey' THEN 1199 WHEN input_value = 'Skillsoft Live Events' THEN 1200 WHEN input_value = 'Sample Content' THEN 1201 WHEN input_value = 'Customer Service' THEN 1202 WHEN input_value = 'Browse Partner Content' THEN 1203 WHEN input_value = 'Aspire Journeys' THEN 1204 WHEN input_value = 'Infrastructure & Operations' THEN 1205 WHEN input_value = 'Sales & Marketing' THEN 1206 WHEN input_value = 'Skillsoft Bootcamps' THEN 1207 WHEN input_value = 'Digital Transformation' THEN 1208 WHEN input_value = 'Professional Improvement' THEN 1209 WHEN input_value = 'Diversity, Equity, & Inclusion' THEN 1210 WHEN input_value = 'NICE Framework' THEN 1211 WHEN input_value = 'Certifications' THEN 1212 WHEN input_value = 'Skillsoft Leadercamps' THEN 1213 WHEN input_value = 'Software Craft' THEN 1214 WHEN input_value = 'Cloud Career Journey' THEN 1215 WHEN input_value = 'Codecademy' THEN 1216 WHEN input_value = 'Project Management' THEN 1217 WHEN input_value = 'Mainframe' THEN 1218 WHEN input_value = 'Perspectives' THEN 1219 WHEN input_value = 'Agile Career Journey' THEN 1220 WHEN input_value = 'Product Management' THEN 1221 WHEN input_value = 'Data' THEN 1222 WHEN input_value = 'Corporate Marketing' THEN 1223 WHEN input_value = 'Customer Success' THEN 1224 WHEN input_value = 'Product Marketing' THEN 1225 WHEN input_value = 'Corporate Communications' THEN 1226 WHEN input_value = 'Selling Skills' THEN 1227 WHEN input_value = 'Internet of Things' THEN 1228 WHEN input_value = 'Cloud Basics' THEN 1229 WHEN input_value = 'Cloud Development' THEN 1230 WHEN input_value = 'Cloud Platforms' THEN 1231 WHEN input_value = 'NEW - Azure' THEN 1232 WHEN input_value = 'Pursue an Agile Certification' THEN 1233 WHEN input_value = 'Pursue an Agile Job Role' THEN 1234 WHEN input_value = 'Pursue an Azure Cloud Job Role' THEN 1235 WHEN input_value = 'Pursue an AWS Cloud Job Role' THEN 1236 WHEN input_value = 'Pursue a GCP Cloud Job Role' THEN 1237 WHEN input_value = 'Pursue a Foundation in Cloud' THEN 1238 WHEN input_value = 'Pursue a Cloud Skill' THEN 1239 WHEN input_value = 'Pursue a Cybersecurity Skill' THEN 1240 WHEN input_value = 'Database Development' THEN 1241 WHEN input_value = 'Data Visualization & Reporting' THEN 1242 WHEN input_value = 'Big Data' THEN 1243 WHEN input_value = 'Data Architectures' THEN 1244 WHEN input_value = 'Data Core Concepts' THEN 1245 WHEN input_value = 'Data Analytics' THEN 1246 WHEN input_value = 'Data Science' THEN 1247 WHEN input_value = 'Data Platforms' THEN 1248 WHEN input_value = 'Business Intelligence' THEN 1249 WHEN input_value = 'Data Security' THEN 1250 WHEN input_value = 'Diversity, Equity & Inclusion' THEN 1251 WHEN input_value = 'DevOps IT' THEN 1252 WHEN input_value = 'Client & Server Administration' THEN 1253 WHEN input_value = 'IT Services' THEN 1254 WHEN input_value = 'Network Operations' THEN 1255 WHEN input_value = 'IT Trends' THEN 1256 WHEN input_value = '2020 Mainstage Keynotes' THEN 1257 WHEN input_value = '2020 Product Sessions' THEN 1258 WHEN input_value = '2020 Case Studies' THEN 1259 WHEN input_value = 'Leadership & Business' THEN 1260 WHEN input_value = 'NICE Work Roles' THEN 1261 WHEN input_value = 'Product Management Skills' THEN 1262 WHEN input_value = 'Software Developer Bootcamps' THEN 1263 WHEN input_value = 'Virtual Training' THEN 1264 WHEN input_value = 'Security Bootcamps' THEN 1265 WHEN input_value = 'Project Management Bootcamps' THEN 1266 WHEN input_value = 'Cloud Services Bootcamps' THEN 1267 WHEN input_value = 'Data Bootcamps' THEN 1268 WHEN input_value = 'In Pursuit of Re-engagement' THEN 1269 WHEN input_value = 'Leading HR' THEN 1270 WHEN input_value = 'Productivity & Wellness' THEN 1271 WHEN input_value = 'Art of Great Consulting' THEN 1272 WHEN input_value = 'Leading in the New Normal' THEN 1273 WHEN input_value = 'Artificial Intelligence' THEN 1274 WHEN input_value = 'Software' THEN 1275 WHEN input_value = 'Machine Learning' THEN 1276 WHEN input_value = 'Data Management' THEN 1277 WHEN input_value = 'Leadership Mindsets' THEN 1278 WHEN input_value = 'Leadership Transitions' THEN 1279 WHEN input_value = 'Espanol' THEN 1280 WHEN input_value = 'English' THEN 1281 WHEN input_value = 'Codecademy Languages' THEN 1282 WHEN input_value = 'Codecademy Subjects' THEN 1283 WHEN input_value = 'Finance' THEN 1284 WHEN input_value = 'Process Improvement' THEN 1285 WHEN input_value = 'Business Planning & Analysis' THEN 1286 WHEN input_value = 'Human Resources' THEN 1287 WHEN input_value = 'Banking' THEN 1288 WHEN input_value = 'Microsoft Office' THEN 1289 WHEN input_value = 'CompTIA' THEN 1290 WHEN input_value = 'Oracle' THEN 1291 WHEN input_value = 'VMware' THEN 1292 WHEN input_value = 'Isograd' THEN 1293 WHEN input_value = 'Cisco' THEN 1294 WHEN input_value = 'SAS' THEN 1295 WHEN input_value = 'Digital Marketing Institute' THEN 1296 WHEN input_value = 'Red Hat' THEN 1297 WHEN input_value = 'Kubernetes' THEN 1298 WHEN input_value = 'Microsoft' THEN 1299 WHEN input_value = 'Google' THEN 1300 WHEN input_value = '(ISC)2' THEN 1301 WHEN input_value = 'EC-Council' THEN 1302 WHEN input_value = 'AWS' THEN 1303 WHEN input_value = 'Virtual Work' THEN 1304 WHEN input_value = 'Digital Experiences' THEN 1305 WHEN input_value = 'Civil' THEN 1306 WHEN input_value = 'Energy' THEN 1307 WHEN input_value = 'Chemical' THEN 1308 WHEN input_value = 'Industrial' THEN 1309 WHEN input_value = 'Aerospace & Mechanical' THEN 1310 WHEN input_value = 'Electrical' THEN 1311 WHEN input_value = 'Test Channels' THEN 1312 WHEN input_value = 'Engineering Resources' THEN 1313 WHEN input_value = 'Personal Productivity' THEN 1314 WHEN input_value = 'Personal Accountability' THEN 1315 WHEN input_value = 'Well-Being' THEN 1316 WHEN input_value = 'Business Communication' THEN 1317 WHEN input_value = 'Self-Discovery' THEN 1318 WHEN input_value = 'Mainframe Security' THEN 1319 WHEN input_value = 'Mainframe Services' THEN 1320 WHEN input_value = 'Project Management Methods' THEN 1321 WHEN input_value = 'Live Events' THEN 1322 WHEN input_value = 'Emerging Tech' THEN 1323 WHEN input_value = 'Software Architectures' THEN 1324 WHEN input_value = 'Software Dev Practices' THEN 1325 WHEN input_value = 'Getting Started with Percipio' THEN 1326 WHEN input_value = 'Expert' THEN 1327 WHEN input_value = 'Associate (MTA)' THEN 1328 WHEN input_value = 'Microsoft 365 Certified Expert' THEN 1329 WHEN input_value = 'Microsoft Certified Associate' THEN 1330 WHEN input_value = 'Professional' THEN 1331 WHEN input_value = 'Entry' THEN 1332 WHEN input_value = 'Associate' THEN 1333 WHEN input_value = 'TOSA Desktop' THEN 1334 WHEN input_value = 'TOSA Digital' THEN 1335 WHEN input_value = 'Cloud Security' THEN 1336 WHEN input_value = 'Software Development' THEN 1337 WHEN input_value = 'Information Security' THEN 1338 WHEN input_value = 'Systems Security' THEN 1339 WHEN input_value = 'Cybersecurity' THEN 1340 WHEN input_value = 'Bloodborne Pathogens' THEN 1341 WHEN input_value = 'Excel' THEN 1342 WHEN input_value = 'Access' THEN 1343 WHEN input_value = 'TWI - Job Instruction' THEN 1344 WHEN input_value = 'Filehold' THEN 1345 WHEN input_value = 'Engineer Resources' THEN 1346 WHEN input_value = 'Security Skills' THEN 1347 WHEN input_value = 'Outlook' THEN 1348 WHEN input_value = 'Concur' THEN 1349 WHEN input_value = 'Teams' THEN 1350 WHEN input_value = 'TWI - Job Methods' THEN 1351 WHEN input_value = 'ADP' THEN 1352 WHEN input_value = 'Docusign' THEN 1353 WHEN input_value = 'TWI - Job Relations' THEN 1354 WHEN input_value = 'Word' THEN 1355 WHEN input_value = 'PowerPoint' THEN 1356 WHEN input_value = 'Infrastructure' THEN 1357 WHEN input_value = 'Data and Analytics' THEN 1358 WHEN input_value = 'Additional Professional' THEN 1359 WHEN input_value = 'Core' THEN 1360 WHEN input_value = 'VMware Certified Professional' THEN 1361 WHEN input_value = 'Data Analysis' THEN 1362 WHEN input_value = 'Digital Marketing Associate' THEN 1363 WHEN input_value = 'Google Workspace' THEN 1364 WHEN input_value = 'Specialty' THEN 1365 WHEN input_value = 'Architecting' THEN 1366 WHEN input_value = 'Operations' THEN 1367 WHEN input_value = 'Cloud Practitioner' THEN 1368 WHEN input_value = 'Developing' THEN 1369 WHEN input_value = 'Base Programmer' THEN 1370 WHEN input_value = 'Administrator' THEN 1371 WHEN input_value = 'Kubernetes Administrator' THEN 1372 WHEN input_value = 'Spreadsheet Software' THEN 1373 WHEN input_value = 'Microsoft Office/Office 365' THEN 1374 WHEN input_value = 'Email' THEN 1375 WHEN input_value = 'Presentation Software' THEN 1376 WHEN input_value = 'Microsoft Outlook' THEN 1377 WHEN input_value = 'Microsoft Excel' THEN 1378 WHEN input_value = 'Microsoft Powerpoint' THEN 1379 WHEN input_value = 'Google Hangouts Meet' THEN 1380 WHEN input_value = 'Google Hangouts Meet (No Assessments)' THEN 1381 WHEN input_value = 'Software Applications' THEN 532 WHEN input_value = 'Policy and Compliance' THEN 533 WHEN input_value = 'Cornerstone Product Training' THEN 534 WHEN input_value = 'Management Skills' THEN 535 WHEN input_value = 'Communication & Teamwork' THEN 536 WHEN input_value = 'Technical Skills' THEN 537 WHEN input_value = 'Business Skills' THEN 538 WHEN input_value = 'Compliance' THEN 539 WHEN input_value = 'IT Skills' THEN 540 WHEN input_value = 'Certification' THEN 541 WHEN input_value = 'Collections' THEN 542 WHEN input_value = 'Skillsoft Aspire' THEN 543 WHEN input_value = 'Productivity & Collaboration Tools' THEN 544 WHEN input_value = 'Business Continuity' THEN 545 WHEN input_value = 'Skillsoft Aspire L&B' THEN 546 WHEN input_value = 'Change' THEN 547 WHEN input_value = 'Communications Skills' THEN 548 WHEN input_value = 'Finance and Accounting' THEN 549 WHEN input_value = 'Human Resources' THEN 550 WHEN input_value = 'Industry Overviews' THEN 551 WHEN input_value = 'Leadership' THEN 552 WHEN input_value = 'Management' THEN 553 WHEN input_value = 'Operations Management' THEN 554 WHEN input_value = 'Professional Effectiveness' THEN 555 WHEN input_value = 'Project Management' THEN 556 WHEN input_value = 'Strategy and Innovation' THEN 557 WHEN input_value = 'Business Skills' THEN 558 WHEN input_value = 'Business Skills' THEN 559 WHEN input_value = 'Business Skills' THEN 560 WHEN input_value = 'Business Skills' THEN 561 WHEN input_value = 'Business Skills' THEN 562 WHEN input_value = 'Sumtotal344' THEN 563 WHEN input_value = 'ILT Events' THEN 565 WHEN input_value = 'SumTotal2' THEN 566 WHEN input_value = 'SumTotal' THEN 567 WHEN input_value = 'Materials' THEN 568 WHEN input_value = 'Videos' THEN 569 WHEN input_value = 'Curriculum' THEN 570 WHEN input_value = 'Curriculums' THEN 571 WHEN input_value = 'ILT Events' THEN 572 WHEN input_value = 'Scorm' THEN 573 WHEN input_value = 'Finance' THEN 574 WHEN input_value = 'SIAM TEAM' THEN 575 WHEN input_value = 'New Employee Training' THEN 576 WHEN input_value = 'Exercise' THEN 577 WHEN input_value = 'Leadership Development' THEN 578 WHEN input_value = 'Medicine' THEN 579 WHEN input_value = 'Teaching' THEN 580 WHEN input_value = 'Course Details' THEN 581 WHEN input_value = 'Pravir test' THEN 582 WHEN input_value = 'Tests' THEN 583 WHEN input_value = 'Online Courses' THEN 584 WHEN input_value = 'Topics' THEN 585 WHEN input_value = 'PESV2_topic' THEN 586 WHEN input_value = '1234' THEN 587 WHEN input_value = '208_Cloud Services' THEN 588 WHEN input_value = '210_Customer Service' THEN 589 WHEN input_value = '211_Developer' THEN 590 WHEN input_value = '212_Digital Transformation' THEN 591 WHEN input_value = '213_IT Operations' THEN 592 WHEN input_value = '215_Leadership Development Program' THEN 593 WHEN input_value = '216_Management' THEN 594 WHEN input_value = '58_Certifications' THEN 595 WHEN input_value = 'Aspire Journeys' THEN 596 WHEN input_value = 'Business Operations' THEN 597 WHEN input_value = '66_Cloud Services' THEN 598 WHEN input_value = '68_Customer Service' THEN 599 WHEN input_value = 'Data' THEN 600 WHEN input_value = '70_Developer' THEN 601 WHEN input_value = '71_Digital Transformation' THEN 602 WHEN input_value = '74_IT Operations' THEN 603 WHEN input_value = '82_Management' THEN 604 WHEN input_value = 'Productivity & Collaboration Tools' THEN 605 WHEN input_value = 'Professional Improvement' THEN 606 WHEN input_value = '89_Project Management' THEN 607 WHEN input_value = 'Sales & Marketing' THEN 608 WHEN input_value = '121_Customer Service: Core Concepts & Methods' THEN 609 WHEN input_value = 'Data Visualization & Reporting' THEN 610 WHEN input_value = 'Big Data' THEN 611 WHEN input_value = 'Data Security' THEN 612 WHEN input_value = 'Data Analytics' THEN 613 WHEN input_value = 'Data Core Concepts' THEN 614 WHEN input_value = 'Database Development' THEN 615 WHEN input_value = 'Data Platforms' THEN 616 WHEN input_value = 'Business Intelligence' THEN 617 WHEN input_value = '130_Data Science' THEN 618 WHEN input_value = '141_Data Science' THEN 619 WHEN input_value = '146_Digital Marketing & Communications' THEN 620 WHEN input_value = '151_Information Security' THEN 621 WHEN input_value = '152_IT Services' THEN 622 WHEN input_value = '153_DevOps' THEN 623 WHEN input_value = 'IT Trends' THEN 624 WHEN input_value = '155_Network Operations' THEN 625 WHEN input_value = '156_Client & Server Administration' THEN 626 WHEN input_value = 'Design' THEN 627 WHEN input_value = 'Productivity Tools' THEN 628 WHEN input_value = 'Collaboration' THEN 629 WHEN input_value = 'Browsers & Operating Systems' THEN 630 WHEN input_value = '186_Microsoft Office' THEN 631 WHEN input_value = 'Personal Productivity' THEN 632 WHEN input_value = 'Well-Being' THEN 633 WHEN input_value = 'Business Communication' THEN 634 WHEN input_value = 'Self-Discovery' THEN 635 WHEN input_value = 'Personal Accountability' THEN 636 WHEN input_value = 'Individual Professional Performance' THEN 637 WHEN input_value = 'Project Management Methods' THEN 638 WHEN input_value = 'Project Management Core Concepts' THEN 639 WHEN input_value = 'Product Marketing' THEN 640 WHEN input_value = 'Selling Skills' THEN 641 WHEN input_value = 'Salesforce & Channel Management' THEN 642 WHEN input_value = 'Corporate Communications' THEN 643 WHEN input_value = 'Corporate Marketing' THEN 644 WHEN input_value = '205_(ISC)2' THEN 645 WHEN input_value = '206_Amazon' THEN 646 WHEN input_value = '207_Cisco' THEN 647 WHEN input_value = '209_CompTIA' THEN 648 WHEN input_value = '214_Information Systems Audit and Control Association' THEN 649 WHEN input_value = '217_Microsoft' THEN 650 WHEN input_value = '228_Cloud Platforms' THEN 651 WHEN input_value = '229_Cloud Development' THEN 652 WHEN input_value = '245_Information Security' THEN 653 WHEN input_value = '246_IT Services' THEN 654 WHEN input_value = '247_Network Operations' THEN 655 WHEN input_value = '248_Client & Server Administration' THEN 656 WHEN input_value = '250_Leading the Business' THEN 657 WHEN input_value = '251_Leading Your Team' THEN 658 WHEN input_value = '252_Leading Yourself' THEN 659 WHEN input_value = '253_Management Essentials' THEN 660 WHEN input_value = '59_(ISC)2' THEN 661 WHEN input_value = '60_Amazon' THEN 662 WHEN input_value = 'American Society for Quality (ASQ)' THEN 663 WHEN input_value = 'BCS Professional Institute' THEN 664 WHEN input_value = '65_Cisco' THEN 665 WHEN input_value = '67_CompTIA' THEN 666 WHEN input_value = 'EC-Council' THEN 667 WHEN input_value = 'Google' THEN 668 WHEN input_value = 'ITIL®' THEN 669 WHEN input_value = '76_Information Systems Audit and Control Association' THEN 670 WHEN input_value = 'International Institute of Business Analysis (IIBA)' THEN 671 WHEN input_value = 'International Software Testing Qualification Board' THEN 672 WHEN input_value = 'Isograd' THEN 673 WHEN input_value = 'Juniper' THEN 674 WHEN input_value = 'Linux Professional Institute' THEN 675 WHEN input_value = '83_Microsoft' THEN 676 WHEN input_value = '84_Microsoft Office' THEN 677 WHEN input_value = 'Oracle' THEN 678 WHEN input_value = 'PRINCE2®' THEN 679 WHEN input_value = 'Project Management Institute (PMI)®' THEN 680 WHEN input_value = 'Red Hat' THEN 681 WHEN input_value = 'SAS' THEN 682 WHEN input_value = 'TOGAF®' THEN 683 WHEN input_value = '10_Developer' THEN 684 WHEN input_value = 'Data Analyst to Data Scientist' THEN 685 WHEN input_value = 'Business Planning & Analysis' THEN 686 WHEN input_value = 'Finance' THEN 687 WHEN input_value = 'Human Resources' THEN 688 WHEN input_value = 'Process Improvement' THEN 689 WHEN input_value = '11_Digital Transformation' THEN 690 WHEN input_value = '112_Cloud Platforms' THEN 691 WHEN input_value = 'Cloud Basics' THEN 692 WHEN input_value = 'Internet of Things' THEN 693 WHEN input_value = '115_Cloud Development' THEN 694 WHEN input_value = '116_Cloud Security' THEN 695 WHEN input_value = '12_IT Operations' THEN 696 WHEN input_value = 'Developer Trends' THEN 697 WHEN input_value = 'Web Development' THEN 698 WHEN input_value = 'Mobile Development' THEN 699 WHEN input_value = '134_DevOps' THEN 700 WHEN input_value = '135_Secure Programming' THEN 701 WHEN input_value = 'Data Modelling' THEN 702 WHEN input_value = '137_Developer Concepts & Methodologies' THEN 703 WHEN input_value = '138_Developer Tools' THEN 704 WHEN input_value = '139_Programming Languages' THEN 705 WHEN input_value = '14_Leadership Development Program' THEN 706 WHEN input_value = 'Microservices' THEN 707 WHEN input_value = '142_Essentials of Digital Transformation' THEN 708 WHEN input_value = '143_Virtual Work' THEN 709 WHEN input_value = '144_Digital Soft Skills Competencies' THEN 710 WHEN input_value = '145_Agility for Digital Transformation' THEN 711 WHEN input_value = '147_Digital Experiences' THEN 712 WHEN input_value = '15_Management' THEN 713 WHEN input_value = 'Leadership Essentials' THEN 714 WHEN input_value = '166_Management Essentials' THEN 715 WHEN input_value = 'Team Management' THEN 716 WHEN input_value = 'Business Execution' THEN 717 WHEN input_value = 'Business Strategy' THEN 718 WHEN input_value = '233_Customer Service: Core Concepts & Methods' THEN 719 WHEN input_value = '234_Secure Programming' THEN 720 WHEN input_value = '235_Developer Concepts & Methodologies' THEN 721 WHEN input_value = '236_Developer Tools' THEN 722 WHEN input_value = '237_Programming Languages' THEN 723 WHEN input_value = '238_Data Science' THEN 724 WHEN input_value = '239_Essentials of Digital Transformation' THEN 725 WHEN input_value = '240_Virtual Work' THEN 726 WHEN input_value = '241_Digital Soft Skills Competencies' THEN 727 WHEN input_value = '242_Agility for Digital Transformation' THEN 728 WHEN input_value = '243_Digital Marketing & Communications' THEN 729 WHEN input_value = '244_Digital Experiences' THEN 730 WHEN input_value = '3_Certifications' THEN 731 WHEN input_value = '7_Cloud Services' THEN 732 WHEN input_value = '9_Customer Service' THEN 733 WHEN input_value = 'ASQ (American Society for Quality)' THEN 734 WHEN input_value = '104_Foundation' THEN 735 WHEN input_value = '109_Professional' THEN 736 WHEN input_value = '110_Entry' THEN 737 WHEN input_value = '111_Associate' THEN 738 WHEN input_value = '13_Information Systems Audit and Control Association' THEN 739 WHEN input_value = '148_Core' THEN 740 WHEN input_value = '16_Microsoft' THEN 741 WHEN input_value = '161_Foundation' THEN 742 WHEN input_value = '164_Administrator' THEN 743 WHEN input_value = 'Microsoft Certified Associate' THEN 744 WHEN input_value = '171_Specialist' THEN 745 WHEN input_value = '172_Microsoft Certified Solutions Developer (MCSD)' THEN 746 WHEN input_value = '173_Microsoft Certified Solutions Associate (MCSA)' THEN 747 WHEN input_value = '174_Microsoft Certified Solutions Expert (MCSE)' THEN 748 WHEN input_value = '175_Associate (MTA)' THEN 749 WHEN input_value = 'Microsoft Certified Fundamentals' THEN 750 WHEN input_value = 'Microsoft Office Specialist (MOS)' THEN 751 WHEN input_value = '178_Professional' THEN 752 WHEN input_value = 'Expert' THEN 753 WHEN input_value = '180_Associate' THEN 754 WHEN input_value = '181_Foundation' THEN 755 WHEN input_value = '196_Administrator' THEN 756 WHEN input_value = 'Base Programmer' THEN 757 WHEN input_value = '218_Cloud Security' THEN 758 WHEN input_value = '219_Systems Security' THEN 759 WHEN input_value = '220_Software Development' THEN 760 WHEN input_value = '221_Information Security' THEN 761 WHEN input_value = '249_Auditor' THEN 762 WHEN input_value = '27_Cloud Platforms' THEN 763 WHEN input_value = '28_Cloud Development' THEN 764 WHEN input_value = '4_(ISC)2' THEN 765 WHEN input_value = '44_Information Security' THEN 766 WHEN input_value = '45_IT Services' THEN 767 WHEN input_value = '46_Network Operations' THEN 768 WHEN input_value = '47_Client & Server Administration' THEN 769 WHEN input_value = '49_Leading the Business' THEN 770 WHEN input_value = '5_Amazon' THEN 771 WHEN input_value = '50_Leading Your Team' THEN 772 WHEN input_value = '51_Leading Yourself' THEN 773 WHEN input_value = '52_Management Essentials' THEN 774 WHEN input_value = '6_Cisco' THEN 775 WHEN input_value = '8_CompTIA' THEN 776 WHEN input_value = '100_Architecting' THEN 777 WHEN input_value = '101_Operations' THEN 778 WHEN input_value = 'Additional Professional' THEN 779 WHEN input_value = '118_Cybersecurity' THEN 780 WHEN input_value = '119_Infrastructure' THEN 781 WHEN input_value = '120_Core' THEN 782 WHEN input_value = '149_Associate' THEN 783 WHEN input_value = '150_Professional' THEN 784 WHEN input_value = '157_Foundation' THEN 785 WHEN input_value = '158_Auditor' THEN 786 WHEN input_value = 'Security Manager' THEN 787 WHEN input_value = 'Level 3 - CBAP' THEN 788 WHEN input_value = 'TOSA Desktop' THEN 789 WHEN input_value = '163_Associate' THEN 790 WHEN input_value = '195_Project Management' THEN 791 WHEN input_value = 'TOGAF® 9' THEN 792 WHEN input_value = '222_Developing' THEN 793 WHEN input_value = '223_Architecting' THEN 794 WHEN input_value = '224_Operations' THEN 795 WHEN input_value = '225_Professional' THEN 796 WHEN input_value = '226_Entry' THEN 797 WHEN input_value = '227_Associate' THEN 798 WHEN input_value = '230_Cybersecurity' THEN 799 WHEN input_value = '231_Infrastructure' THEN 800 WHEN input_value = '232_Core' THEN 801 WHEN input_value = '254_Specialist' THEN 802 WHEN input_value = '255_Microsoft Certified Solutions Developer (MCSD)' THEN 803 WHEN input_value = '256_Microsoft Certified Solutions Associate (MCSA)' THEN 804 WHEN input_value = '257_Microsoft Certified Solutions Expert (MCSE)' THEN 805 WHEN input_value = '258_Associate (MTA)' THEN 806 WHEN input_value = '32_Customer Service: Core Concepts & Methods' THEN 807 WHEN input_value = '33_Secure Programming' THEN 808 WHEN input_value = '34_Developer Concepts & Methodologies' THEN 809 WHEN input_value = '35_Developer Tools' THEN 810 WHEN input_value = '36_Programming Languages' THEN 811 WHEN input_value = '37_Data Science' THEN 812 WHEN input_value = '38_Essentials of Digital Transformation' THEN 813 WHEN input_value = '39_Virtual Work' THEN 814 WHEN input_value = '40_Digital Soft Skills Competencies' THEN 815 WHEN input_value = '41_Agility for Digital Transformation' THEN 816 WHEN input_value = '42_Digital Marketing & Communications' THEN 817 WHEN input_value = '43_Digital Experiences' THEN 818 WHEN input_value = '95_Cloud Security' THEN 819 WHEN input_value = '96_Systems Security' THEN 820 WHEN input_value = '97_Software Development' THEN 821 WHEN input_value = '98_Information Security' THEN 822 WHEN input_value = '99_Developing' THEN 823 WHEN input_value = '17_Cloud Security' THEN 824 WHEN input_value = '18_Systems Security' THEN 825 WHEN input_value = '19_Software Development' THEN 826 WHEN input_value = '20_Information Security' THEN 827 WHEN input_value = '29_Cybersecurity' THEN 828 WHEN input_value = '30_Infrastructure' THEN 829 WHEN input_value = '31_Core' THEN 830 WHEN input_value = '48_Auditor' THEN 831 WHEN input_value = '21_Developing' THEN 832 WHEN input_value = '22_Architecting' THEN 833 WHEN input_value = '23_Operations' THEN 834 WHEN input_value = '24_Professional' THEN 835 WHEN input_value = '25_Entry' THEN 836 WHEN input_value = '26_Associate' THEN 837 WHEN input_value = '53_Specialist' THEN 838 WHEN input_value = '54_Microsoft Certified Solutions Developer (MCSD)' THEN 839 WHEN input_value = '55_Microsoft Certified Solutions Associate (MCSA)' THEN 840 WHEN input_value = '56_Microsoft Certified Solutions Expert (MCSE)' THEN 841 WHEN input_value = '57_Associate (MTA)' THEN 842 WHEN input_value = 'Java' THEN 843 WHEN input_value = 'oops' THEN 844 WHEN input_value = 'python' THEN 845 WHEN input_value = 'Auditor' THEN 846 WHEN input_value = 'Browsers & Operating Systems' THEN 847 WHEN input_value = 'Business Skills' THEN 848 WHEN input_value = 'Cloud' THEN 849 WHEN input_value = 'Cloud Computing' THEN 850 WHEN input_value = 'Collaboration' THEN 851 WHEN input_value = 'Data / ML / AI' THEN 852 WHEN input_value = 'Decision-makers and Leaders' THEN 853 WHEN input_value = 'Design' THEN 854 WHEN input_value = 'DevOps' THEN 855 WHEN input_value = 'Foundation' THEN 856 WHEN input_value = 'Get Started' THEN 857 WHEN input_value = 'IT Ops' THEN 858 WHEN input_value = 'Leading the Business' THEN 859 WHEN input_value = 'Leading Your Team' THEN 860 WHEN input_value = 'Leading Yourself' THEN 861 WHEN input_value = 'Level 3 - CBAP' THEN 862 WHEN input_value = 'PM' THEN 863 WHEN input_value = 'Productivity Tools' THEN 864 WHEN input_value = 'Programming' THEN 865 WHEN input_value = 'Adapting to Change' THEN 866 WHEN input_value = 'Business Execution' THEN 867 WHEN input_value = 'Business Strategy' THEN 868 WHEN input_value = 'Business Continuity Planning' THEN 869 WHEN input_value = 'Collaboration Tools' THEN 870 WHEN input_value = 'Communication Essentials' THEN 871 WHEN input_value = 'Crisis Management' THEN 872 WHEN input_value = 'Environmental, Health and Safety (EHS) Compliance' THEN 873 WHEN input_value = 'Food and Alcohol Safety' THEN 874 WHEN input_value = 'Leadership Essentials' THEN 875 WHEN input_value = 'Leading Teams' THEN 876 WHEN input_value = 'Legal Compliance' THEN 877 WHEN input_value = 'Professional Essentials' THEN 878 WHEN input_value = 'Software Tester to DevOps Automated Tester' THEN 879 WHEN input_value = 'Penetration Tester to SecOps Engineer' THEN 880 WHEN input_value = 'Web Programmer to Apprentice Programmer' THEN 881 WHEN input_value = 'Software Project Lead to Advanced Scrum Master' THEN 882 WHEN input_value = 'Network Security Specialist to CloudOps Security Architect' THEN 883 WHEN input_value = 'DevOps Engineer to Cloud Architect' THEN 884 WHEN input_value = 'Apprentice Developer to Journeyman Developer' THEN 885 WHEN input_value = 'AI Apprentice to AI Architect' THEN 886 WHEN input_value = 'Programmer to API Developer' THEN 887 WHEN input_value = 'Developer to Software Architect' THEN 888 WHEN input_value = 'Network Admin to Site Reliability Engineer' THEN 889 WHEN input_value = 'Infrastructure Support Engineer to CloudOps Engineer' THEN 890 WHEN input_value = 'Business Analyst to Data Analyst' THEN 891 WHEN input_value = 'Data Visualization' THEN 892 WHEN input_value = 'Pythonista to Python Master' THEN 893 WHEN input_value = 'Management Essentials' THEN 894 WHEN input_value = 'Microsoft Office 2016' THEN 895 WHEN input_value = 'Microsoft Office 365' THEN 896 WHEN input_value = 'Data Analysis with R' THEN 897 WHEN input_value = 'Security Essentials for Decision-makers and Leaders' THEN 898 WHEN input_value = 'Agile for Software Development' THEN 899 WHEN input_value = 'Serverless Deployments for Developers' THEN 900 WHEN input_value = 'Java Novice to Javanista' THEN 901 WHEN input_value = 'Web App Vulnerability Analyst' THEN 902 WHEN input_value = '5G Technologies and Practices' THEN 903 WHEN input_value = 'Go Programming Essentials' THEN 904 WHEN input_value = 'Enriched Web Development with Angular 11' THEN 905 WHEN input_value = 'Novice Developer to Pythonista' THEN 906 WHEN input_value = 'Javanista to Java Master' THEN 907 WHEN input_value = 'Developer Fundamentals' THEN 908 WHEN input_value = 'Programming Python in Action' THEN 909 WHEN input_value = 'Enterprise Development to DevOps Engineer' THEN 910 WHEN input_value = 'Web App Vulnerability Analyst - 2022 Update' THEN 911 WHEN input_value = 'Enterprise Development to Full Stack Developer' THEN 912 WHEN input_value = 'Software Product Management Proficiency' THEN 913 WHEN input_value = 'Engineering Lead' THEN 914 WHEN input_value = 'AI and ML for Decision-makers' THEN 915 WHEN input_value = 'Software Project Analyst to Senior Software Project Manager' THEN 916 WHEN input_value = 'Security Analyst to Security Architect' THEN 917 WHEN input_value = 'Programmer to Secure Agile Programmer' THEN 918 WHEN input_value = 'Virtual Work in the New Normal' THEN 919 WHEN input_value = 'Manage Myself' THEN 920 WHEN input_value = 'Manage Others' THEN 921 WHEN input_value = 'Security' THEN 922 WHEN input_value = 'Security Manager' THEN 923 WHEN input_value = 'Server Technology' THEN 924 WHEN input_value = 'Six Sigma Certification' THEN 925 WHEN input_value = 'Software Craftsmanship' THEN 926 WHEN input_value = 'Topics' THEN 927 WHEN input_value = 'Strategic Thinking' THEN 928 WHEN input_value = 'Team Management' THEN 929 WHEN input_value = 'Time Management and Productivity' THEN 930 WHEN input_value = 'Working on a Team' THEN 931 WHEN input_value = 'Working Remotely' THEN 932 WHEN input_value = 'Work-Life Balance' THEN 933 WHEN input_value = 'Accounting' THEN 934 WHEN input_value = 'AGG Leadership' THEN 935 WHEN input_value = 'Diversity on the Job' THEN 936 WHEN input_value = 'Time Management' THEN 937 WHEN input_value = 'Unconscious Bias' THEN 938 WHEN input_value = 'Diversity, Equity, and Inclusion' THEN 939 WHEN input_value = 'Building DEI Leadership Skills' THEN 940 WHEN input_value = 'Psychological Safety' THEN 941 WHEN input_value = 'Skills for Effective Collaboration' THEN 942 WHEN input_value = 'Managing a Crisis' THEN 943 WHEN input_value = 'Business' THEN 944 WHEN input_value = 'C#' THEN 945 WHEN input_value = 'Cisco Teams' THEN 946 WHEN input_value = 'Cisco WebEx' THEN 947 WHEN input_value = 'Computer Skills' THEN 948 WHEN input_value = 'Core Knowledge' THEN 949 WHEN input_value = 'Developer Tools' THEN 950 WHEN input_value = 'dot NET' THEN 951 WHEN input_value = 'Food and Alcohol Safety (Latin American Spanish Edition)' THEN 952 WHEN input_value = 'Food and Alcohol Safety (UK Edition)' THEN 953 WHEN input_value = 'Food and Alcohol Safety (US Edition)' THEN 954 WHEN input_value = 'Forms & Lists' THEN 955 WHEN input_value = 'Gemba' THEN 956 WHEN input_value = 'Hansei' THEN 957 WHEN input_value = 'Harassment (Canadian French Edition)' THEN 958 WHEN input_value = 'Harassment (Chinese Edition)' THEN 959 WHEN input_value = 'Harassment (Danish Edition)' THEN 960 WHEN input_value = 'Harassment (Dutch Edition)' THEN 961 WHEN input_value = 'Harassment (Finnish Edition)' THEN 962 WHEN input_value = 'Harassment (Hungarian Edition)' THEN 963 WHEN input_value = 'Harassment (Norwegian Edition)' THEN 964 WHEN input_value = 'Harassment (Romanian Edition)' THEN 965 WHEN input_value = 'Harassment (Russian Edition)' THEN 966 WHEN input_value = 'Harassment (Castilian Spanish Edition)' THEN 967 WHEN input_value = 'Harassment (Swedish Edition)' THEN 968 WHEN input_value = 'Harassment (Turkish Edition)' THEN 969 WHEN input_value = 'Harassment (UK English Edition)' THEN 970 WHEN input_value = 'Harassment (US Edition)' THEN 971 WHEN input_value = 'Health Insurance Portability and Accountability Act (HIPAA) (Latin American Spanish Edition)' THEN 972 WHEN input_value = 'Health Insurance Portability and Accountability Act (HIPAA) (US Edition)' THEN 973 WHEN input_value = 'Health and Wellness' THEN 974 WHEN input_value = 'Hoshin' THEN 975 WHEN input_value = 'Introductory Topics' THEN 976 WHEN input_value = 'JDE' THEN 977 WHEN input_value = 'Joinme' THEN 978 WHEN input_value = 'Just In Time' THEN 979 WHEN input_value = 'Kaizen Leadership' THEN 980 WHEN input_value = 'Kanban' THEN 981 WHEN input_value = 'Leadership & Teamwork' THEN 982 WHEN input_value = 'Additional Content' THEN 983 WHEN input_value = 'Legal Impacts (US Edition)' THEN 984 WHEN input_value = 'Legal Impacts (Brazilian Portuguese Edition)' THEN 985 WHEN input_value = 'Legal Impacts (Chinese Edition)' THEN 986 WHEN input_value = 'Legal Impacts (German Edition)' THEN 987 WHEN input_value = 'LMS Instructions' THEN 988 WHEN input_value = 'LogMeIn' THEN 989 WHEN input_value = 'Microservices' THEN 990 WHEN input_value = 'Mobile Development' THEN 991 WHEN input_value = 'Muda' THEN 992 WHEN input_value = 'Open Sesame' THEN 993 WHEN input_value = 'Improving Your Work/Life Balance' THEN 994 WHEN input_value = 'Improving Your Personal Productivity' THEN 995 WHEN input_value = 'Perseverance at Work' THEN 996 WHEN input_value = 'Percipio' THEN 997 WHEN input_value = 'Policies & Procedures' THEN 998 WHEN input_value = 'Problem Solving' THEN 999 ELSE  END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);


MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Allow waitlist for sessions*", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "TRUE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Allow Auto-Management of Waitlist‡", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "Time based", csod.accepted_values = "First come first served, Off, Time based"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Auto-Register User upon Granting Waitlist‡", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "TRUE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "EstimatedDuration", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Training Hours", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Time", csod.char_length = "", csod.default_value = "0000:00:00", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "ActivityDescription", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Event Description", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "5000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Objectives", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "3500", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "Language", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Default Language", file: "Activity_Events"})
SET csod.mandatory = "Optional", 
    csod.field_type = "Integer",
    csod.char_length = "",
    csod.default_value = "1",
    csod.accepted_values = "",
    csod.transformation = "CASE WHEN input_value = 'en-US' THEN 1 WHEN input_value = 'English (US)' THEN 1 WHEN input_value = 'en-GB' THEN 2 WHEN input_value = 'English (UK)' THEN 2 WHEN input_value = 'fr-FR' THEN 13 WHEN input_value = 'French (France)' THEN 13 WHEN input_value = 'es-MX' THEN 14 WHEN input_value = 'Spanish (Latin America)' THEN 14 ELSE 1 END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "Competency", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Competency IDs", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "Skills", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Skills", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Available Languages", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "Contact", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Training Contact", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "User performing the load", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Created/Modified By", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "User performing the load", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Allow Users to Attend Multiple Sessions", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "TRUE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "ExpressIntrest", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Allow Interest Tracking", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "TRUE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Keywords", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Provide cost of Event", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "0", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Currency Code", file: "Activity_Events"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "", csod.default_value = "USD", csod.accepted_values = "", csod.transformation = "CASE WHEN input_value = 'USD' THEN 1 WHEN input_value = 'United States Dollar' THEN 1 WHEN input_value = 'GBP' THEN 2 WHEN input_value = 'United Kingdoms Pound' THEN 2 WHEN input_value = 'Euro' THEN 3 WHEN input_value = 'EUR' THEN 3 WHEN input_value = 'Mexico Peso' THEN 17 WHEN input_value = 'MXN' THEN 17 WHEN input_value = 'TND' THEN 78 WHEN input_value = 'Tunisian Dinar' THEN 78 ELSE 1 END"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Copy Availability to New Sessions", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "TRUE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Availability to All Users", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Availability to Specific Users", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Availability to OU‡*", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Availability OU Type", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Register Upon Approval", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Pre-Approved", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Include Subordinates", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Registration Deadline", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "26000", csod.default_value = "0", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Registration Deadline - Before/After", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "Before", csod.accepted_values = "After, Before"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "Minimum", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Minimum Users", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "9999", csod.default_value = "0", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "Maximum", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Maximum Users", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "9999", csod.default_value = "75", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "Instructor", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Preferred Instructors", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "4000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "No-show Penalty – Monetary", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "9999999999", csod.default_value = "0", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "No-show Penalty – Training Units", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "999999999", csod.default_value = "0", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Restrict Withdraw from Session", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Refund Type", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Monetary, Training unit"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Refund Percentage‡", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "100", csod.default_value = "", csod.accepted_values = "Monetary, Training unit"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Refund Amount‡", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Refund Number of Days prior to start‡", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "9999", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Withdrawal Penalty Percentage", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Withdrawal Penalty Amount", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Penalty Number of Days prior to start", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (st:SumTotalField {name: "Estimatedcredits", file: "Activity_Events"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Credits", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Float", csod.max_value = "999.99", csod.default_value = "0", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Limit Users To One Waitlist Per Event", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Display Session Time In User Time", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Ability To Select Session", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "1", csod.accepted_values = "End User, Admin and manger, Both selected"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Training Units", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "Conversion Rate by Monetary Value", csod.accepted_values = "Allow conversion rate, by monetary value, Disassociate pricing, Do not allow payment"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Default Training Unit Price", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "999999999", csod.default_value = "0", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Thumbnail", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "Portal Default Thumbnail", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Exclude from Course Recommendations", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "0, 1, active, false, f, inactive, n, no, on, off, t, true, y, yes"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Training Purpose", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "テスト"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Points", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Badge", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Onboarded, Onboarded (1), Presentation Expert, Curriculum Leader, Safety First, Video Master, NEW HIRE ONBOARDING SUCCESSFULLY DONE, voohoo, Above and Beyond, Great Work, DELETE"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Events"})
MERGE (csod:CSODField {name: "Emails", file: "Activity_Events" })
SET csod.mandatory = "Optional", csod.field_type = "Enum", csod.char_length = "", csod.default_value = "No Email", csod.accepted_values = "No Email, System Default"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);


MERGE ( f:File {name: "Activity_Material"})
MERGE (st:SumTotalField {name: "ActivityCode", file: "Activity_Material"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Material ID*", file: "Activity_Material" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Material"})
MERGE (st:SumTotalField {name: "ActivityName", file: "Activity_Material"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Material Title*", file: "Activity_Material" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Material"})
MERGE (st:SumTotalField {name: "Provider", file: "Activity_Material"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Vendor/Provider*", file: "Activity_Material" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Provider Type*", file: "Activity_Material"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "ONLINE,ILT"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Material"})
MERGE (st:SumTotalField {name: "ActivityType", file: "Activity_Material"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Material Type ID*", file: "Activity_Material" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "-99, Express Class, 1, Book, 2, Communities, 3, Required Reading, 4, Document, 5, Website, 6, Observation Checklist, 7, Learning, 8, PPT"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Material"})
MERGE (st:SumTotalField {name: "Active", file: "Activity_Material"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Active", file: "Activity_Material" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (st:SumTotalField {name: "Language", file: "Activity_Material"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Default Language", file: "Activity_Material"})
SET csod.mandatory = "Optional", 
    csod.field_type = "Integer",
    csod.char_length = "",
    csod.default_value = "1",
    csod.accepted_values = "",
    csod.transformation = "CASE WHEN input_value = 'en-US' THEN 1 WHEN input_value = 'English (US)' THEN 1 WHEN input_value = 'en-GB' THEN 2 WHEN input_value = 'English (UK)' THEN 2 WHEN input_value = 'fr-FR' THEN 13 WHEN input_value = 'French (France)' THEN 13 WHEN input_value = 'es-MX' THEN 14 WHEN input_value = 'Spanish (Latin America)' THEN 14 ELSE 1 END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Material"})
MERGE (st:SumTotalField {name: "EstimatedDuration", file: "Activity_Material"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Training Hours*", file: "Activity_Material" })
SET csod.mandatory = "Optional", csod.field_type = "Time", csod.char_length = "", csod.default_value = "0000:00:00", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Material"})
MERGE (st:SumTotalField {name: "ActivityDescription", file: "Activity_Material"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Material Description", file: "Activity_Material" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "5000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "File Name", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Material"})
MERGE (st:SumTotalField {name: "LaunchURL", file: "Activity_Material"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "URL", file: "Activity_Material" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "File Localization", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "en-US", csod.accepted_values = "en-US, en-GB, fr-FR, es-MX"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Available Languages", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Keywords", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Created/Modified By", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "User performing the load", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (st:SumTotalField {name: "Topic", file: "Activity_Material"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Subject IDs", file: "Activity_Material"})
SET csod.mandatory = "Optional", 
    csod.field_type = "Integer",              
    csod.char_length = "",                    
    csod.default_value = "",             
    csod.accepted_values = "",
    csod.transformation = "CASE WHEN input_value = 'Production Preparation Process' THEN 1000 WHEN input_value = 'Programming Languages' THEN 1001 WHEN input_value = 'QC Circle' THEN 1002 WHEN input_value = 'Quality' THEN 1003 WHEN input_value = 'Quick Changeover' THEN 1004 WHEN input_value = 'Reference' THEN 1005 WHEN input_value = 'Safety' THEN 1006 WHEN input_value = 'SCP Resources' THEN 1007 WHEN input_value = 'Secure Programming' THEN 1008 WHEN input_value = 'Six Sigma' THEN 1009 WHEN input_value = 'Skillsoft' THEN 1010 WHEN input_value = 'Productivity Tools forDevOps Automated Testers' THEN 1011 WHEN input_value = 'Productivity Tools for SecOps Engineers' THEN 1012 WHEN input_value = 'Business & Leadership for Apprentice Programmers' THEN 1013 WHEN input_value = 'Productivity Tools for Apprentice Programmers' THEN 1014 WHEN input_value = 'Productivity Tools for Cloud Architects' THEN 1015 WHEN input_value = 'Productivity Tools for CloudOps Engineers' THEN 1016 WHEN input_value = 'Productivity Tools for Business Analyst to Data Analysts' THEN 1017 WHEN input_value = 'Efficiency & Productivity in the New Normal' THEN 1018 WHEN input_value = 'Managing & Leading through Unexpected Disruption' THEN 1019 WHEN input_value = 'Productivity Tools for Data Visualization' THEN 1020 WHEN input_value = 'Business & Leadership for Data Analysis with R' THEN 1021 WHEN input_value = 'Productivity Tools for Data Analysis with R' THEN 1022 WHEN input_value = 'Productivity Tools with Agile for Software Development' THEN 1023 WHEN input_value = 'Productivity Tools for Web App Vulnerability Analyst' THEN 1024 WHEN input_value = 'Productivity Tools for 5G Technologies and Practices' THEN 1025 WHEN input_value = 'Business & Leadership for Enriched Web Development with Angular 11' THEN 1026 WHEN input_value = 'Business & Leadership for Pythonista' THEN 1027 WHEN input_value = 'Business & Leadership for Javanista to Java Master' THEN 1028 WHEN input_value = 'Business & Leadership for Developer Fundamentals' THEN 1029 WHEN input_value = 'Business & Leadership for Programming Python in Action' THEN 1030 WHEN input_value = 'Business & Leadership for Software Product Management' THEN 1031 WHEN input_value = 'Productivity Tools for senior Software Project Managers' THEN 1032 WHEN input_value = 'Productivity Tools for Security Architects' THEN 1033 WHEN input_value = 'Business & Leadership for Enterprise Development to Full Stack Developers' THEN 1034 WHEN input_value = 'Productivity Tools for Full Stack Developer' THEN 1035 WHEN input_value = 'Productivity Tools for DevOps Engineer' THEN 1036 WHEN input_value = 'Skype 2016' THEN 1037 WHEN input_value = 'Standard Work' THEN 1038 WHEN input_value = 'Standard Work - Leader' THEN 1039 WHEN input_value = 'T1' THEN 1040 WHEN input_value = 'TACTIS' THEN 1041 WHEN input_value = 'Total Productive Maintenance' THEN 1042 WHEN input_value = 'TQM (Total Quality Management)' THEN 1043 WHEN input_value = 'TWI for Facilitators' THEN 1044 WHEN input_value = 'TWI for Learners' THEN 1045 WHEN input_value = 'US Federal Government Compliance (US Edition)' THEN 1046 WHEN input_value = 'Value Stream' THEN 1047 WHEN input_value = 'Visual Management' THEN 1048 WHEN input_value = 'Web Development' THEN 1049 WHEN input_value = 'Workplace Compliance Essentials (Brazilian Portuguese Edition)' THEN 1050 WHEN input_value = 'Workplace Compliance Essentials (UK English Edition)' THEN 1051 WHEN input_value = 'Workplace Compliance Essentials (Canadian Edition)' THEN 1052 WHEN input_value = 'Workplace Compliance Essentials (Castilian Spanish Edition)' THEN 1053 WHEN input_value = 'Workplace Compliance Essentials (Turkish Edition)' THEN 1054 WHEN input_value = 'Workplace Compliance Essentials (Australian Edition)' THEN 1055 WHEN input_value = 'Workplace Compliance Essentials (Thai Edition)' THEN 1056 WHEN input_value = 'Workplace Compliance Essentials (Swedish Edition)' THEN 1057 WHEN input_value = 'Workplace Compliance Essentials (Bahasa Malay Edition)' THEN 1058 WHEN input_value = 'Workplace Compliance Essentials (Vietnamese Edition)' THEN 1059 WHEN input_value = 'Workplace Compliance Essentials (Dutch Edition)' THEN 1060 WHEN input_value = 'Workplace Compliance Essentials (Norwegian Edition)' THEN 1061 WHEN input_value = 'Workplace Compliance Essentials (New Zealand Edition)' THEN 1062 WHEN input_value = 'Workplace Compliance Essentials (French Edition)' THEN 1063 WHEN input_value = 'Workplace Compliance Essentials (German Edition)' THEN 1064 WHEN input_value = 'Workplace Compliance Essentials (Italian Edition)' THEN 1065 WHEN input_value = 'Workplace Compliance Essentials (Japanese Edition)' THEN 1066 WHEN input_value = 'XML' THEN 1067 WHEN input_value = 'Communicating Tactfully and Diplomatically' THEN 1068 WHEN input_value = 'Leading Virtual Teams' THEN 1069 WHEN input_value = 'Thinking Strategically and Managing Risk' THEN 1070 WHEN input_value = 'Virtual Teams' THEN 1071 WHEN input_value = 'Communication' THEN 1072 WHEN input_value = 'Microsoft 365: Teams' THEN 1073 WHEN input_value = 'EHS Impacts (US Edition)' THEN 1074 WHEN input_value = 'Environmental (Latin American Spanish Edition)' THEN 1075 WHEN input_value = 'Environmental (US Edition)' THEN 1076 WHEN input_value = 'Environmental (Canadian Edition)' THEN 1077 WHEN input_value = 'Environmental (Canadian French Edition)' THEN 1078 WHEN input_value = 'Harassment (Australian Edition)' THEN 1079 WHEN input_value = 'Harassment (Bahasa Indonesian Edition)' THEN 1080 WHEN input_value = 'Harassment (Bahasa Malay Edition)' THEN 1081 WHEN input_value = 'Harassment (Brazilian Portuguese Edition)' THEN 1082 WHEN input_value = 'Harassment (Canadian Edition)' THEN 1083 WHEN input_value = 'Harassment (Czech Edition)' THEN 1084 WHEN input_value = 'Harassment (French Edition)' THEN 1085 WHEN input_value = 'Harassment (German Edition)' THEN 1086 WHEN input_value = 'Harassment (Hindi Edition)' THEN 1087 WHEN input_value = 'Harassment (Indian Edition)' THEN 1088 WHEN input_value = 'Harassment (Italian Edition)' THEN 1089 WHEN input_value = 'Harassment (Japanese Edition)' THEN 1090 WHEN input_value = 'Harassment (Korean Edition)' THEN 1091 WHEN input_value = 'Harassment (Latin American Spanish Edition)' THEN 1092 WHEN input_value = 'Harassment (New Zealand Edition)' THEN 1093 WHEN input_value = 'Harassment (Polish Edition)' THEN 1094 WHEN input_value = 'Harassment (Thai Edition)' THEN 1095 WHEN input_value = 'Harassment (Vietnamese Edition)' THEN 1096 WHEN input_value = 'Health, Safety and Security (Canadian Edition)' THEN 1097 WHEN input_value = 'Health, Safety and Security (Canadian French Edition)' THEN 1098 WHEN input_value = 'Health, Safety and Security (Castilian Spanish Edition)' THEN 1099 WHEN input_value = 'Health, Safety and Security (Dutch Edition)' THEN 1100 WHEN input_value = 'Health, Safety and Security (Korean Edition)' THEN 1101 WHEN input_value = 'Health, Safety and Security (Australian Edition)' THEN 1102 WHEN input_value = 'Health, Safety and Security (New Zealand Edition)' THEN 1103 WHEN input_value = 'Health, Safety and Security (Chinese Edition)' THEN 1104 WHEN input_value = 'Health, Safety and Security (German Edition)' THEN 1105 WHEN input_value = 'Health, Safety and Security (Latin American Spanish Edition)' THEN 1106 WHEN input_value = 'Health, Safety and Security (US Edition)' THEN 1107 WHEN input_value = 'Health, Safety and Security (UK Edition)' THEN 1108 WHEN input_value = 'Health, Safety and Security (Portuguese Brazilian Edition)' THEN 1109 WHEN input_value = 'Health, Safety and Security (French Edition)' THEN 1110 WHEN input_value = 'Health, Safety and Security (ltalian Edition)' THEN 1111 WHEN input_value = 'Legal Impacts (French Edition)' THEN 1112 WHEN input_value = 'Legal Impacts (Latin American Spanish Edition)' THEN 1113 WHEN input_value = 'Legal Impacts (UK English Edition)' THEN 1114 WHEN input_value = 'Meetings' THEN 1115 WHEN input_value = 'Navigating through Organizational Change' THEN 1116 WHEN input_value = 'Productivity Tools for Advanced Scrum Masters' THEN 1117 WHEN input_value = 'Productivity Tools for CloudOps Security Architect' THEN 1118 WHEN input_value = 'Business & Leadership for Journeyman Developers' THEN 1119 WHEN input_value = 'Productivity Tools for Journeyman Developers' THEN 1120 WHEN input_value = 'Business & Leadership for AI Architects' THEN 1121 WHEN input_value = 'Productivity Tools for AI Architects' THEN 1122 WHEN input_value = 'Business & Leadership for API Developers' THEN 1123 WHEN input_value = 'Productivity Tools for API Developers' THEN 1124 WHEN input_value = 'Business & Leadership for Software Architects' THEN 1125 WHEN input_value = 'Productivity Tools for Software Architects' THEN 1126 WHEN input_value = 'Business & Leadership for Site Reliability Engineers' THEN 1127 WHEN input_value = 'Productivity Tools for Site Reliability Engineers' THEN 1128 WHEN input_value = 'Business & Leadership for Python Master' THEN 1129 WHEN input_value = 'Productivity Tools for Python Master' THEN 1130 WHEN input_value = 'Productivity Tools for Decision-makers and Leaders' THEN 1131 WHEN input_value = 'Business & Leadership with Serverless Deployments for Developers' THEN 1132 WHEN input_value = 'Productivity Tools with Serverless Deployments for Developers' THEN 1133 WHEN input_value = 'Business & Leadership for Javanista' THEN 1134 WHEN input_value = 'Productivity Tools for Javanista' THEN 1135 WHEN input_value = 'Business & Leadership for Go Programming Essentials' THEN 1136 WHEN input_value = 'Business & Leadership for Engineering Lead' THEN 1137 WHEN input_value = 'Business & Leadership for AI and ML for Decision-makers' THEN 1138 WHEN input_value = 'Productivity Tools for Secure Agile Programmers' THEN 1139 WHEN input_value = 'Transportation (Latin American Spanish Edition)' THEN 1140 WHEN input_value = 'Transportation (US Edition)' THEN 1141 WHEN input_value = 'Transportation (Italian Edition)' THEN 1142 WHEN input_value = 'Transportation (Canadian Edition)' THEN 1143 WHEN input_value = 'Transportation (Canadian French Edition)' THEN 1144 WHEN input_value = 'Transportation (UK Edition)' THEN 1145 WHEN input_value = 'Transportation (Chinese Edition)' THEN 1146 WHEN input_value = 'Transportation (Portuguese Brazilian Edition)' THEN 1147 WHEN input_value = 'Transportation (German Edition)' THEN 1148 WHEN input_value = 'Transportation (Castilian Spanish Edition)' THEN 1149 WHEN input_value = 'Transportation (Korean Edition)' THEN 1150 WHEN input_value = 'Transportation (Dutch Edition)' THEN 1151 WHEN input_value = 'Transportation (French Edition)' THEN 1152 WHEN input_value = 'Workplace Compliance Essentials (Canadian French Edition)' THEN 1153 WHEN input_value = 'Workplace Compliance Essentials (Russian Edition)' THEN 1154 WHEN input_value = 'Workplace Compliance Essentials (US Edition)' THEN 1155 WHEN input_value = 'Workplace Compliance Essentials (Korean Edition)' THEN 1156 WHEN input_value = 'Workplace Compliance Essentials (Czech Edition)' THEN 1157 WHEN input_value = 'Workplace Compliance Essentials (Chinese Edition)' THEN 1158 WHEN input_value = 'Workplace Compliance Essentials (Hindi Edition)' THEN 1159 WHEN input_value = 'Workplace Compliance Essentials (Bahasa Indonesian Edition)' THEN 1160 WHEN input_value = 'Workplace Compliance Essentials (Hungarian Edition)' THEN 1161 WHEN input_value = 'Workplace Compliance Essentials (Romanian Edition)' THEN 1162 WHEN input_value = 'Workplace Compliance Essentials (Finnish Edition)' THEN 1163 WHEN input_value = 'Workplace Compliance Essentials (Danish Edition)' THEN 1164 WHEN input_value = 'Workplace Compliance Essentials (Chinese Traditional Edition)' THEN 1165 WHEN input_value = 'Workplace Compliance Essentials (Latin American Spanish Edition)' THEN 1166 WHEN input_value = 'Workplace Compliance Essentials (Polish Edition)' THEN 1167 WHEN input_value = 'Food Allergies And Intolerance' THEN 1168 WHEN input_value = 'Industry Specific' THEN 1169 WHEN input_value = 'Cal/OSHA Latin American Spanish' THEN 1170 WHEN input_value = 'Technology' THEN 1171 WHEN input_value = 'Disability Discrimination Awareness' THEN 1172 WHEN input_value = 'Cisco WebEx Teams' THEN 1173 WHEN input_value = 'Equality and Diversity Awareness' THEN 1174 WHEN input_value = 'Cisco WebEx for Web' THEN 1175 WHEN input_value = 'Portuguese' THEN 1176 WHEN input_value = 'French Canadian' THEN 1177 WHEN input_value = 'Japanese' THEN 1178 WHEN input_value = 'Cal/OSHA' THEN 1179 WHEN input_value = 'Coordinators' THEN 1180 WHEN input_value = 'Managers' THEN 1181 WHEN input_value = 'Skype for Business 2016 (No Assessments)' THEN 1182 WHEN input_value = 'First Aid Awareness' THEN 1183 WHEN input_value = 'Fire Safety Awareness' THEN 1184 WHEN input_value = 'Join.me for Windows (No Assessments)' THEN 1185 WHEN input_value = 'LogMeIn GoToMeeting (No Assessments)' THEN 1186 WHEN input_value = 'Presentation Skills' THEN 1187 WHEN input_value = 'Project Sheets' THEN 1188 WHEN input_value = '5S' THEN 1189 WHEN input_value = 'Label Templates' THEN 1190 WHEN input_value = 'Final Presentation' THEN 1191 WHEN input_value = 'Kaizen' THEN 1192 WHEN input_value = 'Engineering' THEN 1193 WHEN input_value = 'Lifelong Learn' THEN 1194 WHEN input_value = 'Cloud Services' THEN 1195 WHEN input_value = 'Business Operations' THEN 1196 WHEN input_value = 'Welcome to Percipio' THEN 1197 WHEN input_value = 'Aspire Journeys for Leadership' THEN 1198 WHEN input_value = 'Cybersecurity Career Journey' THEN 1199 WHEN input_value = 'Skillsoft Live Events' THEN 1200 WHEN input_value = 'Sample Content' THEN 1201 WHEN input_value = 'Customer Service' THEN 1202 WHEN input_value = 'Browse Partner Content' THEN 1203 WHEN input_value = 'Aspire Journeys' THEN 1204 WHEN input_value = 'Infrastructure & Operations' THEN 1205 WHEN input_value = 'Sales & Marketing' THEN 1206 WHEN input_value = 'Skillsoft Bootcamps' THEN 1207 WHEN input_value = 'Digital Transformation' THEN 1208 WHEN input_value = 'Professional Improvement' THEN 1209 WHEN input_value = 'Diversity, Equity, & Inclusion' THEN 1210 WHEN input_value = 'NICE Framework' THEN 1211 WHEN input_value = 'Certifications' THEN 1212 WHEN input_value = 'Skillsoft Leadercamps' THEN 1213 WHEN input_value = 'Software Craft' THEN 1214 WHEN input_value = 'Cloud Career Journey' THEN 1215 WHEN input_value = 'Codecademy' THEN 1216 WHEN input_value = 'Project Management' THEN 1217 WHEN input_value = 'Mainframe' THEN 1218 WHEN input_value = 'Perspectives' THEN 1219 WHEN input_value = 'Agile Career Journey' THEN 1220 WHEN input_value = 'Product Management' THEN 1221 WHEN input_value = 'Data' THEN 1222 WHEN input_value = 'Corporate Marketing' THEN 1223 WHEN input_value = 'Customer Success' THEN 1224 WHEN input_value = 'Product Marketing' THEN 1225 WHEN input_value = 'Corporate Communications' THEN 1226 WHEN input_value = 'Selling Skills' THEN 1227 WHEN input_value = 'Internet of Things' THEN 1228 WHEN input_value = 'Cloud Basics' THEN 1229 WHEN input_value = 'Cloud Development' THEN 1230 WHEN input_value = 'Cloud Platforms' THEN 1231 WHEN input_value = 'NEW - Azure' THEN 1232 WHEN input_value = 'Pursue an Agile Certification' THEN 1233 WHEN input_value = 'Pursue an Agile Job Role' THEN 1234 WHEN input_value = 'Pursue an Azure Cloud Job Role' THEN 1235 WHEN input_value = 'Pursue an AWS Cloud Job Role' THEN 1236 WHEN input_value = 'Pursue a GCP Cloud Job Role' THEN 1237 WHEN input_value = 'Pursue a Foundation in Cloud' THEN 1238 WHEN input_value = 'Pursue a Cloud Skill' THEN 1239 WHEN input_value = 'Pursue a Cybersecurity Skill' THEN 1240 WHEN input_value = 'Database Development' THEN 1241 WHEN input_value = 'Data Visualization & Reporting' THEN 1242 WHEN input_value = 'Big Data' THEN 1243 WHEN input_value = 'Data Architectures' THEN 1244 WHEN input_value = 'Data Core Concepts' THEN 1245 WHEN input_value = 'Data Analytics' THEN 1246 WHEN input_value = 'Data Science' THEN 1247 WHEN input_value = 'Data Platforms' THEN 1248 WHEN input_value = 'Business Intelligence' THEN 1249 WHEN input_value = 'Data Security' THEN 1250 WHEN input_value = 'Diversity, Equity & Inclusion' THEN 1251 WHEN input_value = 'DevOps IT' THEN 1252 WHEN input_value = 'Client & Server Administration' THEN 1253 WHEN input_value = 'IT Services' THEN 1254 WHEN input_value = 'Network Operations' THEN 1255 WHEN input_value = 'IT Trends' THEN 1256 WHEN input_value = '2020 Mainstage Keynotes' THEN 1257 WHEN input_value = '2020 Product Sessions' THEN 1258 WHEN input_value = '2020 Case Studies' THEN 1259 WHEN input_value = 'Leadership & Business' THEN 1260 WHEN input_value = 'NICE Work Roles' THEN 1261 WHEN input_value = 'Product Management Skills' THEN 1262 WHEN input_value = 'Software Developer Bootcamps' THEN 1263 WHEN input_value = 'Virtual Training' THEN 1264 WHEN input_value = 'Security Bootcamps' THEN 1265 WHEN input_value = 'Project Management Bootcamps' THEN 1266 WHEN input_value = 'Cloud Services Bootcamps' THEN 1267 WHEN input_value = 'Data Bootcamps' THEN 1268 WHEN input_value = 'In Pursuit of Re-engagement' THEN 1269 WHEN input_value = 'Leading HR' THEN 1270 WHEN input_value = 'Productivity & Wellness' THEN 1271 WHEN input_value = 'Art of Great Consulting' THEN 1272 WHEN input_value = 'Leading in the New Normal' THEN 1273 WHEN input_value = 'Artificial Intelligence' THEN 1274 WHEN input_value = 'Software' THEN 1275 WHEN input_value = 'Machine Learning' THEN 1276 WHEN input_value = 'Data Management' THEN 1277 WHEN input_value = 'Leadership Mindsets' THEN 1278 WHEN input_value = 'Leadership Transitions' THEN 1279 WHEN input_value = 'Espanol' THEN 1280 WHEN input_value = 'English' THEN 1281 WHEN input_value = 'Codecademy Languages' THEN 1282 WHEN input_value = 'Codecademy Subjects' THEN 1283 WHEN input_value = 'Finance' THEN 1284 WHEN input_value = 'Process Improvement' THEN 1285 WHEN input_value = 'Business Planning & Analysis' THEN 1286 WHEN input_value = 'Human Resources' THEN 1287 WHEN input_value = 'Banking' THEN 1288 WHEN input_value = 'Microsoft Office' THEN 1289 WHEN input_value = 'CompTIA' THEN 1290 WHEN input_value = 'Oracle' THEN 1291 WHEN input_value = 'VMware' THEN 1292 WHEN input_value = 'Isograd' THEN 1293 WHEN input_value = 'Cisco' THEN 1294 WHEN input_value = 'SAS' THEN 1295 WHEN input_value = 'Digital Marketing Institute' THEN 1296 WHEN input_value = 'Red Hat' THEN 1297 WHEN input_value = 'Kubernetes' THEN 1298 WHEN input_value = 'Microsoft' THEN 1299 WHEN input_value = 'Google' THEN 1300 WHEN input_value = '(ISC)2' THEN 1301 WHEN input_value = 'EC-Council' THEN 1302 WHEN input_value = 'AWS' THEN 1303 WHEN input_value = 'Virtual Work' THEN 1304 WHEN input_value = 'Digital Experiences' THEN 1305 WHEN input_value = 'Civil' THEN 1306 WHEN input_value = 'Energy' THEN 1307 WHEN input_value = 'Chemical' THEN 1308 WHEN input_value = 'Industrial' THEN 1309 WHEN input_value = 'Aerospace & Mechanical' THEN 1310 WHEN input_value = 'Electrical' THEN 1311 WHEN input_value = 'Test Channels' THEN 1312 WHEN input_value = 'Engineering Resources' THEN 1313 WHEN input_value = 'Personal Productivity' THEN 1314 WHEN input_value = 'Personal Accountability' THEN 1315 WHEN input_value = 'Well-Being' THEN 1316 WHEN input_value = 'Business Communication' THEN 1317 WHEN input_value = 'Self-Discovery' THEN 1318 WHEN input_value = 'Mainframe Security' THEN 1319 WHEN input_value = 'Mainframe Services' THEN 1320 WHEN input_value = 'Project Management Methods' THEN 1321 WHEN input_value = 'Live Events' THEN 1322 WHEN input_value = 'Emerging Tech' THEN 1323 WHEN input_value = 'Software Architectures' THEN 1324 WHEN input_value = 'Software Dev Practices' THEN 1325 WHEN input_value = 'Getting Started with Percipio' THEN 1326 WHEN input_value = 'Expert' THEN 1327 WHEN input_value = 'Associate (MTA)' THEN 1328 WHEN input_value = 'Microsoft 365 Certified Expert' THEN 1329 WHEN input_value = 'Microsoft Certified Associate' THEN 1330 WHEN input_value = 'Professional' THEN 1331 WHEN input_value = 'Entry' THEN 1332 WHEN input_value = 'Associate' THEN 1333 WHEN input_value = 'TOSA Desktop' THEN 1334 WHEN input_value = 'TOSA Digital' THEN 1335 WHEN input_value = 'Cloud Security' THEN 1336 WHEN input_value = 'Software Development' THEN 1337 WHEN input_value = 'Information Security' THEN 1338 WHEN input_value = 'Systems Security' THEN 1339 WHEN input_value = 'Cybersecurity' THEN 1340 WHEN input_value = 'Bloodborne Pathogens' THEN 1341 WHEN input_value = 'Excel' THEN 1342 WHEN input_value = 'Access' THEN 1343 WHEN input_value = 'TWI - Job Instruction' THEN 1344 WHEN input_value = 'Filehold' THEN 1345 WHEN input_value = 'Engineer Resources' THEN 1346 WHEN input_value = 'Security Skills' THEN 1347 WHEN input_value = 'Outlook' THEN 1348 WHEN input_value = 'Concur' THEN 1349 WHEN input_value = 'Teams' THEN 1350 WHEN input_value = 'TWI - Job Methods' THEN 1351 WHEN input_value = 'ADP' THEN 1352 WHEN input_value = 'Docusign' THEN 1353 WHEN input_value = 'TWI - Job Relations' THEN 1354 WHEN input_value = 'Word' THEN 1355 WHEN input_value = 'PowerPoint' THEN 1356 WHEN input_value = 'Infrastructure' THEN 1357 WHEN input_value = 'Data and Analytics' THEN 1358 WHEN input_value = 'Additional Professional' THEN 1359 WHEN input_value = 'Core' THEN 1360 WHEN input_value = 'VMware Certified Professional' THEN 1361 WHEN input_value = 'Data Analysis' THEN 1362 WHEN input_value = 'Digital Marketing Associate' THEN 1363 WHEN input_value = 'Google Workspace' THEN 1364 WHEN input_value = 'Specialty' THEN 1365 WHEN input_value = 'Architecting' THEN 1366 WHEN input_value = 'Operations' THEN 1367 WHEN input_value = 'Cloud Practitioner' THEN 1368 WHEN input_value = 'Developing' THEN 1369 WHEN input_value = 'Base Programmer' THEN 1370 WHEN input_value = 'Administrator' THEN 1371 WHEN input_value = 'Kubernetes Administrator' THEN 1372 WHEN input_value = 'Spreadsheet Software' THEN 1373 WHEN input_value = 'Microsoft Office/Office 365' THEN 1374 WHEN input_value = 'Email' THEN 1375 WHEN input_value = 'Presentation Software' THEN 1376 WHEN input_value = 'Microsoft Outlook' THEN 1377 WHEN input_value = 'Microsoft Excel' THEN 1378 WHEN input_value = 'Microsoft Powerpoint' THEN 1379 WHEN input_value = 'Google Hangouts Meet' THEN 1380 WHEN input_value = 'Google Hangouts Meet (No Assessments)' THEN 1381 WHEN input_value = 'Software Applications' THEN 532 WHEN input_value = 'Policy and Compliance' THEN 533 WHEN input_value = 'Cornerstone Product Training' THEN 534 WHEN input_value = 'Management Skills' THEN 535 WHEN input_value = 'Communication & Teamwork' THEN 536 WHEN input_value = 'Technical Skills' THEN 537 WHEN input_value = 'Business Skills' THEN 538 WHEN input_value = 'Compliance' THEN 539 WHEN input_value = 'IT Skills' THEN 540 WHEN input_value = 'Certification' THEN 541 WHEN input_value = 'Collections' THEN 542 WHEN input_value = 'Skillsoft Aspire' THEN 543 WHEN input_value = 'Productivity & Collaboration Tools' THEN 544 WHEN input_value = 'Business Continuity' THEN 545 WHEN input_value = 'Skillsoft Aspire L&B' THEN 546 WHEN input_value = 'Change' THEN 547 WHEN input_value = 'Communications Skills' THEN 548 WHEN input_value = 'Finance and Accounting' THEN 549 WHEN input_value = 'Human Resources' THEN 550 WHEN input_value = 'Industry Overviews' THEN 551 WHEN input_value = 'Leadership' THEN 552 WHEN input_value = 'Management' THEN 553 WHEN input_value = 'Operations Management' THEN 554 WHEN input_value = 'Professional Effectiveness' THEN 555 WHEN input_value = 'Project Management' THEN 556 WHEN input_value = 'Strategy and Innovation' THEN 557 WHEN input_value = 'Business Skills' THEN 558 WHEN input_value = 'Business Skills' THEN 559 WHEN input_value = 'Business Skills' THEN 560 WHEN input_value = 'Business Skills' THEN 561 WHEN input_value = 'Business Skills' THEN 562 WHEN input_value = 'Sumtotal344' THEN 563 WHEN input_value = 'ILT Events' THEN 565 WHEN input_value = 'SumTotal2' THEN 566 WHEN input_value = 'SumTotal' THEN 567 WHEN input_value = 'Materials' THEN 568 WHEN input_value = 'Videos' THEN 569 WHEN input_value = 'Curriculum' THEN 570 WHEN input_value = 'Curriculums' THEN 571 WHEN input_value = 'ILT Events' THEN 572 WHEN input_value = 'Scorm' THEN 573 WHEN input_value = 'Finance' THEN 574 WHEN input_value = 'SIAM TEAM' THEN 575 WHEN input_value = 'New Employee Training' THEN 576 WHEN input_value = 'Exercise' THEN 577 WHEN input_value = 'Leadership Development' THEN 578 WHEN input_value = 'Medicine' THEN 579 WHEN input_value = 'Teaching' THEN 580 WHEN input_value = 'Course Details' THEN 581 WHEN input_value = 'Pravir test' THEN 582 WHEN input_value = 'Tests' THEN 583 WHEN input_value = 'Online Courses' THEN 584 WHEN input_value = 'Topics' THEN 585 WHEN input_value = 'PESV2_topic' THEN 586 WHEN input_value = '1234' THEN 587 WHEN input_value = '208_Cloud Services' THEN 588 WHEN input_value = '210_Customer Service' THEN 589 WHEN input_value = '211_Developer' THEN 590 WHEN input_value = '212_Digital Transformation' THEN 591 WHEN input_value = '213_IT Operations' THEN 592 WHEN input_value = '215_Leadership Development Program' THEN 593 WHEN input_value = '216_Management' THEN 594 WHEN input_value = '58_Certifications' THEN 595 WHEN input_value = 'Aspire Journeys' THEN 596 WHEN input_value = 'Business Operations' THEN 597 WHEN input_value = '66_Cloud Services' THEN 598 WHEN input_value = '68_Customer Service' THEN 599 WHEN input_value = 'Data' THEN 600 WHEN input_value = '70_Developer' THEN 601 WHEN input_value = '71_Digital Transformation' THEN 602 WHEN input_value = '74_IT Operations' THEN 603 WHEN input_value = '82_Management' THEN 604 WHEN input_value = 'Productivity & Collaboration Tools' THEN 605 WHEN input_value = 'Professional Improvement' THEN 606 WHEN input_value = '89_Project Management' THEN 607 WHEN input_value = 'Sales & Marketing' THEN 608 WHEN input_value = '121_Customer Service: Core Concepts & Methods' THEN 609 WHEN input_value = 'Data Visualization & Reporting' THEN 610 WHEN input_value = 'Big Data' THEN 611 WHEN input_value = 'Data Security' THEN 612 WHEN input_value = 'Data Analytics' THEN 613 WHEN input_value = 'Data Core Concepts' THEN 614 WHEN input_value = 'Database Development' THEN 615 WHEN input_value = 'Data Platforms' THEN 616 WHEN input_value = 'Business Intelligence' THEN 617 WHEN input_value = '130_Data Science' THEN 618 WHEN input_value = '141_Data Science' THEN 619 WHEN input_value = '146_Digital Marketing & Communications' THEN 620 WHEN input_value = '151_Information Security' THEN 621 WHEN input_value = '152_IT Services' THEN 622 WHEN input_value = '153_DevOps' THEN 623 WHEN input_value = 'IT Trends' THEN 624 WHEN input_value = '155_Network Operations' THEN 625 WHEN input_value = '156_Client & Server Administration' THEN 626 WHEN input_value = 'Design' THEN 627 WHEN input_value = 'Productivity Tools' THEN 628 WHEN input_value = 'Collaboration' THEN 629 WHEN input_value = 'Browsers & Operating Systems' THEN 630 WHEN input_value = '186_Microsoft Office' THEN 631 WHEN input_value = 'Personal Productivity' THEN 632 WHEN input_value = 'Well-Being' THEN 633 WHEN input_value = 'Business Communication' THEN 634 WHEN input_value = 'Self-Discovery' THEN 635 WHEN input_value = 'Personal Accountability' THEN 636 WHEN input_value = 'Individual Professional Performance' THEN 637 WHEN input_value = 'Project Management Methods' THEN 638 WHEN input_value = 'Project Management Core Concepts' THEN 639 WHEN input_value = 'Product Marketing' THEN 640 WHEN input_value = 'Selling Skills' THEN 641 WHEN input_value = 'Salesforce & Channel Management' THEN 642 WHEN input_value = 'Corporate Communications' THEN 643 WHEN input_value = 'Corporate Marketing' THEN 644 WHEN input_value = '205_(ISC)2' THEN 645 WHEN input_value = '206_Amazon' THEN 646 WHEN input_value = '207_Cisco' THEN 647 WHEN input_value = '209_CompTIA' THEN 648 WHEN input_value = '214_Information Systems Audit and Control Association' THEN 649 WHEN input_value = '217_Microsoft' THEN 650 WHEN input_value = '228_Cloud Platforms' THEN 651 WHEN input_value = '229_Cloud Development' THEN 652 WHEN input_value = '245_Information Security' THEN 653 WHEN input_value = '246_IT Services' THEN 654 WHEN input_value = '247_Network Operations' THEN 655 WHEN input_value = '248_Client & Server Administration' THEN 656 WHEN input_value = '250_Leading the Business' THEN 657 WHEN input_value = '251_Leading Your Team' THEN 658 WHEN input_value = '252_Leading Yourself' THEN 659 WHEN input_value = '253_Management Essentials' THEN 660 WHEN input_value = '59_(ISC)2' THEN 661 WHEN input_value = '60_Amazon' THEN 662 WHEN input_value = 'American Society for Quality (ASQ)' THEN 663 WHEN input_value = 'BCS Professional Institute' THEN 664 WHEN input_value = '65_Cisco' THEN 665 WHEN input_value = '67_CompTIA' THEN 666 WHEN input_value = 'EC-Council' THEN 667 WHEN input_value = 'Google' THEN 668 WHEN input_value = 'ITIL®' THEN 669 WHEN input_value = '76_Information Systems Audit and Control Association' THEN 670 WHEN input_value = 'International Institute of Business Analysis (IIBA)' THEN 671 WHEN input_value = 'International Software Testing Qualification Board' THEN 672 WHEN input_value = 'Isograd' THEN 673 WHEN input_value = 'Juniper' THEN 674 WHEN input_value = 'Linux Professional Institute' THEN 675 WHEN input_value = '83_Microsoft' THEN 676 WHEN input_value = '84_Microsoft Office' THEN 677 WHEN input_value = 'Oracle' THEN 678 WHEN input_value = 'PRINCE2®' THEN 679 WHEN input_value = 'Project Management Institute (PMI)®' THEN 680 WHEN input_value = 'Red Hat' THEN 681 WHEN input_value = 'SAS' THEN 682 WHEN input_value = 'TOGAF®' THEN 683 WHEN input_value = '10_Developer' THEN 684 WHEN input_value = 'Data Analyst to Data Scientist' THEN 685 WHEN input_value = 'Business Planning & Analysis' THEN 686 WHEN input_value = 'Finance' THEN 687 WHEN input_value = 'Human Resources' THEN 688 WHEN input_value = 'Process Improvement' THEN 689 WHEN input_value = '11_Digital Transformation' THEN 690 WHEN input_value = '112_Cloud Platforms' THEN 691 WHEN input_value = 'Cloud Basics' THEN 692 WHEN input_value = 'Internet of Things' THEN 693 WHEN input_value = '115_Cloud Development' THEN 694 WHEN input_value = '116_Cloud Security' THEN 695 WHEN input_value = '12_IT Operations' THEN 696 WHEN input_value = 'Developer Trends' THEN 697 WHEN input_value = 'Web Development' THEN 698 WHEN input_value = 'Mobile Development' THEN 699 WHEN input_value = '134_DevOps' THEN 700 WHEN input_value = '135_Secure Programming' THEN 701 WHEN input_value = 'Data Modelling' THEN 702 WHEN input_value = '137_Developer Concepts & Methodologies' THEN 703 WHEN input_value = '138_Developer Tools' THEN 704 WHEN input_value = '139_Programming Languages' THEN 705 WHEN input_value = '14_Leadership Development Program' THEN 706 WHEN input_value = 'Microservices' THEN 707 WHEN input_value = '142_Essentials of Digital Transformation' THEN 708 WHEN input_value = '143_Virtual Work' THEN 709 WHEN input_value = '144_Digital Soft Skills Competencies' THEN 710 WHEN input_value = '145_Agility for Digital Transformation' THEN 711 WHEN input_value = '147_Digital Experiences' THEN 712 WHEN input_value = '15_Management' THEN 713 WHEN input_value = 'Leadership Essentials' THEN 714 WHEN input_value = '166_Management Essentials' THEN 715 WHEN input_value = 'Team Management' THEN 716 WHEN input_value = 'Business Execution' THEN 717 WHEN input_value = 'Business Strategy' THEN 718 WHEN input_value = '233_Customer Service: Core Concepts & Methods' THEN 719 WHEN input_value = '234_Secure Programming' THEN 720 WHEN input_value = '235_Developer Concepts & Methodologies' THEN 721 WHEN input_value = '236_Developer Tools' THEN 722 WHEN input_value = '237_Programming Languages' THEN 723 WHEN input_value = '238_Data Science' THEN 724 WHEN input_value = '239_Essentials of Digital Transformation' THEN 725 WHEN input_value = '240_Virtual Work' THEN 726 WHEN input_value = '241_Digital Soft Skills Competencies' THEN 727 WHEN input_value = '242_Agility for Digital Transformation' THEN 728 WHEN input_value = '243_Digital Marketing & Communications' THEN 729 WHEN input_value = '244_Digital Experiences' THEN 730 WHEN input_value = '3_Certifications' THEN 731 WHEN input_value = '7_Cloud Services' THEN 732 WHEN input_value = '9_Customer Service' THEN 733 WHEN input_value = 'ASQ (American Society for Quality)' THEN 734 WHEN input_value = '104_Foundation' THEN 735 WHEN input_value = '109_Professional' THEN 736 WHEN input_value = '110_Entry' THEN 737 WHEN input_value = '111_Associate' THEN 738 WHEN input_value = '13_Information Systems Audit and Control Association' THEN 739 WHEN input_value = '148_Core' THEN 740 WHEN input_value = '16_Microsoft' THEN 741 WHEN input_value = '161_Foundation' THEN 742 WHEN input_value = '164_Administrator' THEN 743 WHEN input_value = 'Microsoft Certified Associate' THEN 744 WHEN input_value = '171_Specialist' THEN 745 WHEN input_value = '172_Microsoft Certified Solutions Developer (MCSD)' THEN 746 WHEN input_value = '173_Microsoft Certified Solutions Associate (MCSA)' THEN 747 WHEN input_value = '174_Microsoft Certified Solutions Expert (MCSE)' THEN 748 WHEN input_value = '175_Associate (MTA)' THEN 749 WHEN input_value = 'Microsoft Certified Fundamentals' THEN 750 WHEN input_value = 'Microsoft Office Specialist (MOS)' THEN 751 WHEN input_value = '178_Professional' THEN 752 WHEN input_value = 'Expert' THEN 753 WHEN input_value = '180_Associate' THEN 754 WHEN input_value = '181_Foundation' THEN 755 WHEN input_value = '196_Administrator' THEN 756 WHEN input_value = 'Base Programmer' THEN 757 WHEN input_value = '218_Cloud Security' THEN 758 WHEN input_value = '219_Systems Security' THEN 759 WHEN input_value = '220_Software Development' THEN 760 WHEN input_value = '221_Information Security' THEN 761 WHEN input_value = '249_Auditor' THEN 762 WHEN input_value = '27_Cloud Platforms' THEN 763 WHEN input_value = '28_Cloud Development' THEN 764 WHEN input_value = '4_(ISC)2' THEN 765 WHEN input_value = '44_Information Security' THEN 766 WHEN input_value = '45_IT Services' THEN 767 WHEN input_value = '46_Network Operations' THEN 768 WHEN input_value = '47_Client & Server Administration' THEN 769 WHEN input_value = '49_Leading the Business' THEN 770 WHEN input_value = '5_Amazon' THEN 771 WHEN input_value = '50_Leading Your Team' THEN 772 WHEN input_value = '51_Leading Yourself' THEN 773 WHEN input_value = '52_Management Essentials' THEN 774 WHEN input_value = '6_Cisco' THEN 775 WHEN input_value = '8_CompTIA' THEN 776 WHEN input_value = '100_Architecting' THEN 777 WHEN input_value = '101_Operations' THEN 778 WHEN input_value = 'Additional Professional' THEN 779 WHEN input_value = '118_Cybersecurity' THEN 780 WHEN input_value = '119_Infrastructure' THEN 781 WHEN input_value = '120_Core' THEN 782 WHEN input_value = '149_Associate' THEN 783 WHEN input_value = '150_Professional' THEN 784 WHEN input_value = '157_Foundation' THEN 785 WHEN input_value = '158_Auditor' THEN 786 WHEN input_value = 'Security Manager' THEN 787 WHEN input_value = 'Level 3 - CBAP' THEN 788 WHEN input_value = 'TOSA Desktop' THEN 789 WHEN input_value = '163_Associate' THEN 790 WHEN input_value = '195_Project Management' THEN 791 WHEN input_value = 'TOGAF® 9' THEN 792 WHEN input_value = '222_Developing' THEN 793 WHEN input_value = '223_Architecting' THEN 794 WHEN input_value = '224_Operations' THEN 795 WHEN input_value = '225_Professional' THEN 796 WHEN input_value = '226_Entry' THEN 797 WHEN input_value = '227_Associate' THEN 798 WHEN input_value = '230_Cybersecurity' THEN 799 WHEN input_value = '231_Infrastructure' THEN 800 WHEN input_value = '232_Core' THEN 801 WHEN input_value = '254_Specialist' THEN 802 WHEN input_value = '255_Microsoft Certified Solutions Developer (MCSD)' THEN 803 WHEN input_value = '256_Microsoft Certified Solutions Associate (MCSA)' THEN 804 WHEN input_value = '257_Microsoft Certified Solutions Expert (MCSE)' THEN 805 WHEN input_value = '258_Associate (MTA)' THEN 806 WHEN input_value = '32_Customer Service: Core Concepts & Methods' THEN 807 WHEN input_value = '33_Secure Programming' THEN 808 WHEN input_value = '34_Developer Concepts & Methodologies' THEN 809 WHEN input_value = '35_Developer Tools' THEN 810 WHEN input_value = '36_Programming Languages' THEN 811 WHEN input_value = '37_Data Science' THEN 812 WHEN input_value = '38_Essentials of Digital Transformation' THEN 813 WHEN input_value = '39_Virtual Work' THEN 814 WHEN input_value = '40_Digital Soft Skills Competencies' THEN 815 WHEN input_value = '41_Agility for Digital Transformation' THEN 816 WHEN input_value = '42_Digital Marketing & Communications' THEN 817 WHEN input_value = '43_Digital Experiences' THEN 818 WHEN input_value = '95_Cloud Security' THEN 819 WHEN input_value = '96_Systems Security' THEN 820 WHEN input_value = '97_Software Development' THEN 821 WHEN input_value = '98_Information Security' THEN 822 WHEN input_value = '99_Developing' THEN 823 WHEN input_value = '17_Cloud Security' THEN 824 WHEN input_value = '18_Systems Security' THEN 825 WHEN input_value = '19_Software Development' THEN 826 WHEN input_value = '20_Information Security' THEN 827 WHEN input_value = '29_Cybersecurity' THEN 828 WHEN input_value = '30_Infrastructure' THEN 829 WHEN input_value = '31_Core' THEN 830 WHEN input_value = '48_Auditor' THEN 831 WHEN input_value = '21_Developing' THEN 832 WHEN input_value = '22_Architecting' THEN 833 WHEN input_value = '23_Operations' THEN 834 WHEN input_value = '24_Professional' THEN 835 WHEN input_value = '25_Entry' THEN 836 WHEN input_value = '26_Associate' THEN 837 WHEN input_value = '53_Specialist' THEN 838 WHEN input_value = '54_Microsoft Certified Solutions Developer (MCSD)' THEN 839 WHEN input_value = '55_Microsoft Certified Solutions Associate (MCSA)' THEN 840 WHEN input_value = '56_Microsoft Certified Solutions Expert (MCSE)' THEN 841 WHEN input_value = '57_Associate (MTA)' THEN 842 WHEN input_value = 'Java' THEN 843 WHEN input_value = 'oops' THEN 844 WHEN input_value = 'python' THEN 845 WHEN input_value = 'Auditor' THEN 846 WHEN input_value = 'Browsers & Operating Systems' THEN 847 WHEN input_value = 'Business Skills' THEN 848 WHEN input_value = 'Cloud' THEN 849 WHEN input_value = 'Cloud Computing' THEN 850 WHEN input_value = 'Collaboration' THEN 851 WHEN input_value = 'Data / ML / AI' THEN 852 WHEN input_value = 'Decision-makers and Leaders' THEN 853 WHEN input_value = 'Design' THEN 854 WHEN input_value = 'DevOps' THEN 855 WHEN input_value = 'Foundation' THEN 856 WHEN input_value = 'Get Started' THEN 857 WHEN input_value = 'IT Ops' THEN 858 WHEN input_value = 'Leading the Business' THEN 859 WHEN input_value = 'Leading Your Team' THEN 860 WHEN input_value = 'Leading Yourself' THEN 861 WHEN input_value = 'Level 3 - CBAP' THEN 862 WHEN input_value = 'PM' THEN 863 WHEN input_value = 'Productivity Tools' THEN 864 WHEN input_value = 'Programming' THEN 865 WHEN input_value = 'Adapting to Change' THEN 866 WHEN input_value = 'Business Execution' THEN 867 WHEN input_value = 'Business Strategy' THEN 868 WHEN input_value = 'Business Continuity Planning' THEN 869 WHEN input_value = 'Collaboration Tools' THEN 870 WHEN input_value = 'Communication Essentials' THEN 871 WHEN input_value = 'Crisis Management' THEN 872 WHEN input_value = 'Environmental, Health and Safety (EHS) Compliance' THEN 873 WHEN input_value = 'Food and Alcohol Safety' THEN 874 WHEN input_value = 'Leadership Essentials' THEN 875 WHEN input_value = 'Leading Teams' THEN 876 WHEN input_value = 'Legal Compliance' THEN 877 WHEN input_value = 'Professional Essentials' THEN 878 WHEN input_value = 'Software Tester to DevOps Automated Tester' THEN 879 WHEN input_value = 'Penetration Tester to SecOps Engineer' THEN 880 WHEN input_value = 'Web Programmer to Apprentice Programmer' THEN 881 WHEN input_value = 'Software Project Lead to Advanced Scrum Master' THEN 882 WHEN input_value = 'Network Security Specialist to CloudOps Security Architect' THEN 883 WHEN input_value = 'DevOps Engineer to Cloud Architect' THEN 884 WHEN input_value = 'Apprentice Developer to Journeyman Developer' THEN 885 WHEN input_value = 'AI Apprentice to AI Architect' THEN 886 WHEN input_value = 'Programmer to API Developer' THEN 887 WHEN input_value = 'Developer to Software Architect' THEN 888 WHEN input_value = 'Network Admin to Site Reliability Engineer' THEN 889 WHEN input_value = 'Infrastructure Support Engineer to CloudOps Engineer' THEN 890 WHEN input_value = 'Business Analyst to Data Analyst' THEN 891 WHEN input_value = 'Data Visualization' THEN 892 WHEN input_value = 'Pythonista to Python Master' THEN 893 WHEN input_value = 'Management Essentials' THEN 894 WHEN input_value = 'Microsoft Office 2016' THEN 895 WHEN input_value = 'Microsoft Office 365' THEN 896 WHEN input_value = 'Data Analysis with R' THEN 897 WHEN input_value = 'Security Essentials for Decision-makers and Leaders' THEN 898 WHEN input_value = 'Agile for Software Development' THEN 899 WHEN input_value = 'Serverless Deployments for Developers' THEN 900 WHEN input_value = 'Java Novice to Javanista' THEN 901 WHEN input_value = 'Web App Vulnerability Analyst' THEN 902 WHEN input_value = '5G Technologies and Practices' THEN 903 WHEN input_value = 'Go Programming Essentials' THEN 904 WHEN input_value = 'Enriched Web Development with Angular 11' THEN 905 WHEN input_value = 'Novice Developer to Pythonista' THEN 906 WHEN input_value = 'Javanista to Java Master' THEN 907 WHEN input_value = 'Developer Fundamentals' THEN 908 WHEN input_value = 'Programming Python in Action' THEN 909 WHEN input_value = 'Enterprise Development to DevOps Engineer' THEN 910 WHEN input_value = 'Web App Vulnerability Analyst - 2022 Update' THEN 911 WHEN input_value = 'Enterprise Development to Full Stack Developer' THEN 912 WHEN input_value = 'Software Product Management Proficiency' THEN 913 WHEN input_value = 'Engineering Lead' THEN 914 WHEN input_value = 'AI and ML for Decision-makers' THEN 915 WHEN input_value = 'Software Project Analyst to Senior Software Project Manager' THEN 916 WHEN input_value = 'Security Analyst to Security Architect' THEN 917 WHEN input_value = 'Programmer to Secure Agile Programmer' THEN 918 WHEN input_value = 'Virtual Work in the New Normal' THEN 919 WHEN input_value = 'Manage Myself' THEN 920 WHEN input_value = 'Manage Others' THEN 921 WHEN input_value = 'Security' THEN 922 WHEN input_value = 'Security Manager' THEN 923 WHEN input_value = 'Server Technology' THEN 924 WHEN input_value = 'Six Sigma Certification' THEN 925 WHEN input_value = 'Software Craftsmanship' THEN 926 WHEN input_value = 'Topics' THEN 927 WHEN input_value = 'Strategic Thinking' THEN 928 WHEN input_value = 'Team Management' THEN 929 WHEN input_value = 'Time Management and Productivity' THEN 930 WHEN input_value = 'Working on a Team' THEN 931 WHEN input_value = 'Working Remotely' THEN 932 WHEN input_value = 'Work-Life Balance' THEN 933 WHEN input_value = 'Accounting' THEN 934 WHEN input_value = 'AGG Leadership' THEN 935 WHEN input_value = 'Diversity on the Job' THEN 936 WHEN input_value = 'Time Management' THEN 937 WHEN input_value = 'Unconscious Bias' THEN 938 WHEN input_value = 'Diversity, Equity, and Inclusion' THEN 939 WHEN input_value = 'Building DEI Leadership Skills' THEN 940 WHEN input_value = 'Psychological Safety' THEN 941 WHEN input_value = 'Skills for Effective Collaboration' THEN 942 WHEN input_value = 'Managing a Crisis' THEN 943 WHEN input_value = 'Business' THEN 944 WHEN input_value = 'C#' THEN 945 WHEN input_value = 'Cisco Teams' THEN 946 WHEN input_value = 'Cisco WebEx' THEN 947 WHEN input_value = 'Computer Skills' THEN 948 WHEN input_value = 'Core Knowledge' THEN 949 WHEN input_value = 'Developer Tools' THEN 950 WHEN input_value = 'dot NET' THEN 951 WHEN input_value = 'Food and Alcohol Safety (Latin American Spanish Edition)' THEN 952 WHEN input_value = 'Food and Alcohol Safety (UK Edition)' THEN 953 WHEN input_value = 'Food and Alcohol Safety (US Edition)' THEN 954 WHEN input_value = 'Forms & Lists' THEN 955 WHEN input_value = 'Gemba' THEN 956 WHEN input_value = 'Hansei' THEN 957 WHEN input_value = 'Harassment (Canadian French Edition)' THEN 958 WHEN input_value = 'Harassment (Chinese Edition)' THEN 959 WHEN input_value = 'Harassment (Danish Edition)' THEN 960 WHEN input_value = 'Harassment (Dutch Edition)' THEN 961 WHEN input_value = 'Harassment (Finnish Edition)' THEN 962 WHEN input_value = 'Harassment (Hungarian Edition)' THEN 963 WHEN input_value = 'Harassment (Norwegian Edition)' THEN 964 WHEN input_value = 'Harassment (Romanian Edition)' THEN 965 WHEN input_value = 'Harassment (Russian Edition)' THEN 966 WHEN input_value = 'Harassment (Castilian Spanish Edition)' THEN 967 WHEN input_value = 'Harassment (Swedish Edition)' THEN 968 WHEN input_value = 'Harassment (Turkish Edition)' THEN 969 WHEN input_value = 'Harassment (UK English Edition)' THEN 970 WHEN input_value = 'Harassment (US Edition)' THEN 971 WHEN input_value = 'Health Insurance Portability and Accountability Act (HIPAA) (Latin American Spanish Edition)' THEN 972 WHEN input_value = 'Health Insurance Portability and Accountability Act (HIPAA) (US Edition)' THEN 973 WHEN input_value = 'Health and Wellness' THEN 974 WHEN input_value = 'Hoshin' THEN 975 WHEN input_value = 'Introductory Topics' THEN 976 WHEN input_value = 'JDE' THEN 977 WHEN input_value = 'Joinme' THEN 978 WHEN input_value = 'Just In Time' THEN 979 WHEN input_value = 'Kaizen Leadership' THEN 980 WHEN input_value = 'Kanban' THEN 981 WHEN input_value = 'Leadership & Teamwork' THEN 982 WHEN input_value = 'Additional Content' THEN 983 WHEN input_value = 'Legal Impacts (US Edition)' THEN 984 WHEN input_value = 'Legal Impacts (Brazilian Portuguese Edition)' THEN 985 WHEN input_value = 'Legal Impacts (Chinese Edition)' THEN 986 WHEN input_value = 'Legal Impacts (German Edition)' THEN 987 WHEN input_value = 'LMS Instructions' THEN 988 WHEN input_value = 'LogMeIn' THEN 989 WHEN input_value = 'Microservices' THEN 990 WHEN input_value = 'Mobile Development' THEN 991 WHEN input_value = 'Muda' THEN 992 WHEN input_value = 'Open Sesame' THEN 993 WHEN input_value = 'Improving Your Work/Life Balance' THEN 994 WHEN input_value = 'Improving Your Personal Productivity' THEN 995 WHEN input_value = 'Perseverance at Work' THEN 996 WHEN input_value = 'Percipio' THEN 997 WHEN input_value = 'Policies & Procedures' THEN 998 WHEN input_value = 'Problem Solving' THEN 999 ELSE  END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Availability to All Users", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Availability to Specific Users", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Availability to OU‡", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Availability OU Type", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Register Upon Approval", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Pre-Approved", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Include Subordinates", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Recurrence", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "0", csod.accepted_values = "0, 1, 2, 3, 5, 6, 7"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Mobile", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Material"})
MERGE (st:SumTotalField {name: "EstimatedCredits", file: "Activity_Material"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Credits", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Float", csod.max_value = "999.99", csod.default_value = "0", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Thumbnail", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "Portal Default Thumbnail", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Exclude from Course Recommendations", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Training Purpose", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "テスト"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Points", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Integre", csod.max_value = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Badge", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Onboarded, Onboarded (1), Presentation Expert, Curriculum Leader, Safety First, Video Master, NEW HIRE ONBOARDING SUCCESSFULLY DONE, voohoo, Above and Beyond, Great Work, DELETE"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Material"})
MERGE (csod:CSODField {name: "Emails", file: "Activity_Material"})
SET csod.mandatory = "Optional", csod.field_type = "Enum", csod.char_length = "", csod.default_value = "No Email", csod.accepted_values = "System Default, No Email"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (st:SumTotalField {name: "CourseCode", file: "Activity_OnlineCourse"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Online Course ID*", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (st:SumTotalField {name: "CourseName", file: "Activity_OnlineCourse"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Online Course Name*", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (st:SumTotalField {name: "Provider", file: "Activity_OnlineCourse"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Vendor/Provider*", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "Online Content", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Provider type*", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "", csod.default_value = "ONLINE", csod.accepted_values = "ONLINE,ILT"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);




MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (st:SumTotalField {name: "Active", file: "Activity_OnlineCourse"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Active*", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_OnlineCourse"})
MERGE (st:SumTotalField {name: "Language", file: "Activity_OnlineCourse"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Default Language", file: "Activity_OnlineCourse"})
SET csod.mandatory = "Optional", 
    csod.field_type = "Integer",
    csod.char_length = "",
    csod.default_value = "1",
    csod.accepted_values = "",
    csod.transformation = "CASE WHEN input_value = 'en-US' THEN 1 WHEN input_value = 'English (US)' THEN 1 WHEN input_value = 'en-GB' THEN 2 WHEN input_value = 'English (UK)' THEN 2 WHEN input_value = 'fr-FR' THEN 13 WHEN input_value = 'French (France)' THEN 13 WHEN input_value = 'es-MX' THEN 14 WHEN input_value = 'Spanish (Latin America)' THEN 14 ELSE 1 END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (st:SumTotalField {name: "CourseDescription", file: "Activity_OnlineCourse"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Online Course Description*", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "5000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "File Name*", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Created/Modified By*", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (st:SumTotalField {name: "EstimatedDuration", file: "Activity_OnlineCourse"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Training Hours", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Time(0000:00:00)(HHHHHH:MM:SS)", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Available Languages", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Keywords", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_OnlineCourse"})
MERGE (st:SumTotalField {name: "Topic", file: "Activity_OnlineCourse"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Subject IDs*", file: "Activity_OnlineCourse"})
SET csod.mandatory = "Mandatory", 
    csod.field_type = "subjectType",              
    csod.char_length = "",                    
    csod.default_value = "",             
    csod.accepted_values = "",
    csod.transformation = "CASE WHEN input_value = 'Production Preparation Process' THEN 1000 WHEN input_value = 'Programming Languages' THEN 1001 WHEN input_value = 'QC Circle' THEN 1002 WHEN input_value = 'Quality' THEN 1003 WHEN input_value = 'Quick Changeover' THEN 1004 WHEN input_value = 'Reference' THEN 1005 WHEN input_value = 'Safety' THEN 1006 WHEN input_value = 'SCP Resources' THEN 1007 WHEN input_value = 'Secure Programming' THEN 1008 WHEN input_value = 'Six Sigma' THEN 1009 WHEN input_value = 'Skillsoft' THEN 1010 WHEN input_value = 'Productivity Tools forDevOps Automated Testers' THEN 1011 WHEN input_value = 'Productivity Tools for SecOps Engineers' THEN 1012 WHEN input_value = 'Business & Leadership for Apprentice Programmers' THEN 1013 WHEN input_value = 'Productivity Tools for Apprentice Programmers' THEN 1014 WHEN input_value = 'Productivity Tools for Cloud Architects' THEN 1015 WHEN input_value = 'Productivity Tools for CloudOps Engineers' THEN 1016 WHEN input_value = 'Productivity Tools for Business Analyst to Data Analysts' THEN 1017 WHEN input_value = 'Efficiency & Productivity in the New Normal' THEN 1018 WHEN input_value = 'Managing & Leading through Unexpected Disruption' THEN 1019 WHEN input_value = 'Productivity Tools for Data Visualization' THEN 1020 WHEN input_value = 'Business & Leadership for Data Analysis with R' THEN 1021 WHEN input_value = 'Productivity Tools for Data Analysis with R' THEN 1022 WHEN input_value = 'Productivity Tools with Agile for Software Development' THEN 1023 WHEN input_value = 'Productivity Tools for Web App Vulnerability Analyst' THEN 1024 WHEN input_value = 'Productivity Tools for 5G Technologies and Practices' THEN 1025 WHEN input_value = 'Business & Leadership for Enriched Web Development with Angular 11' THEN 1026 WHEN input_value = 'Business & Leadership for Pythonista' THEN 1027 WHEN input_value = 'Business & Leadership for Javanista to Java Master' THEN 1028 WHEN input_value = 'Business & Leadership for Developer Fundamentals' THEN 1029 WHEN input_value = 'Business & Leadership for Programming Python in Action' THEN 1030 WHEN input_value = 'Business & Leadership for Software Product Management' THEN 1031 WHEN input_value = 'Productivity Tools for senior Software Project Managers' THEN 1032 WHEN input_value = 'Productivity Tools for Security Architects' THEN 1033 WHEN input_value = 'Business & Leadership for Enterprise Development to Full Stack Developers' THEN 1034 WHEN input_value = 'Productivity Tools for Full Stack Developer' THEN 1035 WHEN input_value = 'Productivity Tools for DevOps Engineer' THEN 1036 WHEN input_value = 'Skype 2016' THEN 1037 WHEN input_value = 'Standard Work' THEN 1038 WHEN input_value = 'Standard Work - Leader' THEN 1039 WHEN input_value = 'T1' THEN 1040 WHEN input_value = 'TACTIS' THEN 1041 WHEN input_value = 'Total Productive Maintenance' THEN 1042 WHEN input_value = 'TQM (Total Quality Management)' THEN 1043 WHEN input_value = 'TWI for Facilitators' THEN 1044 WHEN input_value = 'TWI for Learners' THEN 1045 WHEN input_value = 'US Federal Government Compliance (US Edition)' THEN 1046 WHEN input_value = 'Value Stream' THEN 1047 WHEN input_value = 'Visual Management' THEN 1048 WHEN input_value = 'Web Development' THEN 1049 WHEN input_value = 'Workplace Compliance Essentials (Brazilian Portuguese Edition)' THEN 1050 WHEN input_value = 'Workplace Compliance Essentials (UK English Edition)' THEN 1051 WHEN input_value = 'Workplace Compliance Essentials (Canadian Edition)' THEN 1052 WHEN input_value = 'Workplace Compliance Essentials (Castilian Spanish Edition)' THEN 1053 WHEN input_value = 'Workplace Compliance Essentials (Turkish Edition)' THEN 1054 WHEN input_value = 'Workplace Compliance Essentials (Australian Edition)' THEN 1055 WHEN input_value = 'Workplace Compliance Essentials (Thai Edition)' THEN 1056 WHEN input_value = 'Workplace Compliance Essentials (Swedish Edition)' THEN 1057 WHEN input_value = 'Workplace Compliance Essentials (Bahasa Malay Edition)' THEN 1058 WHEN input_value = 'Workplace Compliance Essentials (Vietnamese Edition)' THEN 1059 WHEN input_value = 'Workplace Compliance Essentials (Dutch Edition)' THEN 1060 WHEN input_value = 'Workplace Compliance Essentials (Norwegian Edition)' THEN 1061 WHEN input_value = 'Workplace Compliance Essentials (New Zealand Edition)' THEN 1062 WHEN input_value = 'Workplace Compliance Essentials (French Edition)' THEN 1063 WHEN input_value = 'Workplace Compliance Essentials (German Edition)' THEN 1064 WHEN input_value = 'Workplace Compliance Essentials (Italian Edition)' THEN 1065 WHEN input_value = 'Workplace Compliance Essentials (Japanese Edition)' THEN 1066 WHEN input_value = 'XML' THEN 1067 WHEN input_value = 'Communicating Tactfully and Diplomatically' THEN 1068 WHEN input_value = 'Leading Virtual Teams' THEN 1069 WHEN input_value = 'Thinking Strategically and Managing Risk' THEN 1070 WHEN input_value = 'Virtual Teams' THEN 1071 WHEN input_value = 'Communication' THEN 1072 WHEN input_value = 'Microsoft 365: Teams' THEN 1073 WHEN input_value = 'EHS Impacts (US Edition)' THEN 1074 WHEN input_value = 'Environmental (Latin American Spanish Edition)' THEN 1075 WHEN input_value = 'Environmental (US Edition)' THEN 1076 WHEN input_value = 'Environmental (Canadian Edition)' THEN 1077 WHEN input_value = 'Environmental (Canadian French Edition)' THEN 1078 WHEN input_value = 'Harassment (Australian Edition)' THEN 1079 WHEN input_value = 'Harassment (Bahasa Indonesian Edition)' THEN 1080 WHEN input_value = 'Harassment (Bahasa Malay Edition)' THEN 1081 WHEN input_value = 'Harassment (Brazilian Portuguese Edition)' THEN 1082 WHEN input_value = 'Harassment (Canadian Edition)' THEN 1083 WHEN input_value = 'Harassment (Czech Edition)' THEN 1084 WHEN input_value = 'Harassment (French Edition)' THEN 1085 WHEN input_value = 'Harassment (German Edition)' THEN 1086 WHEN input_value = 'Harassment (Hindi Edition)' THEN 1087 WHEN input_value = 'Harassment (Indian Edition)' THEN 1088 WHEN input_value = 'Harassment (Italian Edition)' THEN 1089 WHEN input_value = 'Harassment (Japanese Edition)' THEN 1090 WHEN input_value = 'Harassment (Korean Edition)' THEN 1091 WHEN input_value = 'Harassment (Latin American Spanish Edition)' THEN 1092 WHEN input_value = 'Harassment (New Zealand Edition)' THEN 1093 WHEN input_value = 'Harassment (Polish Edition)' THEN 1094 WHEN input_value = 'Harassment (Thai Edition)' THEN 1095 WHEN input_value = 'Harassment (Vietnamese Edition)' THEN 1096 WHEN input_value = 'Health, Safety and Security (Canadian Edition)' THEN 1097 WHEN input_value = 'Health, Safety and Security (Canadian French Edition)' THEN 1098 WHEN input_value = 'Health, Safety and Security (Castilian Spanish Edition)' THEN 1099 WHEN input_value = 'Health, Safety and Security (Dutch Edition)' THEN 1100 WHEN input_value = 'Health, Safety and Security (Korean Edition)' THEN 1101 WHEN input_value = 'Health, Safety and Security (Australian Edition)' THEN 1102 WHEN input_value = 'Health, Safety and Security (New Zealand Edition)' THEN 1103 WHEN input_value = 'Health, Safety and Security (Chinese Edition)' THEN 1104 WHEN input_value = 'Health, Safety and Security (German Edition)' THEN 1105 WHEN input_value = 'Health, Safety and Security (Latin American Spanish Edition)' THEN 1106 WHEN input_value = 'Health, Safety and Security (US Edition)' THEN 1107 WHEN input_value = 'Health, Safety and Security (UK Edition)' THEN 1108 WHEN input_value = 'Health, Safety and Security (Portuguese Brazilian Edition)' THEN 1109 WHEN input_value = 'Health, Safety and Security (French Edition)' THEN 1110 WHEN input_value = 'Health, Safety and Security (ltalian Edition)' THEN 1111 WHEN input_value = 'Legal Impacts (French Edition)' THEN 1112 WHEN input_value = 'Legal Impacts (Latin American Spanish Edition)' THEN 1113 WHEN input_value = 'Legal Impacts (UK English Edition)' THEN 1114 WHEN input_value = 'Meetings' THEN 1115 WHEN input_value = 'Navigating through Organizational Change' THEN 1116 WHEN input_value = 'Productivity Tools for Advanced Scrum Masters' THEN 1117 WHEN input_value = 'Productivity Tools for CloudOps Security Architect' THEN 1118 WHEN input_value = 'Business & Leadership for Journeyman Developers' THEN 1119 WHEN input_value = 'Productivity Tools for Journeyman Developers' THEN 1120 WHEN input_value = 'Business & Leadership for AI Architects' THEN 1121 WHEN input_value = 'Productivity Tools for AI Architects' THEN 1122 WHEN input_value = 'Business & Leadership for API Developers' THEN 1123 WHEN input_value = 'Productivity Tools for API Developers' THEN 1124 WHEN input_value = 'Business & Leadership for Software Architects' THEN 1125 WHEN input_value = 'Productivity Tools for Software Architects' THEN 1126 WHEN input_value = 'Business & Leadership for Site Reliability Engineers' THEN 1127 WHEN input_value = 'Productivity Tools for Site Reliability Engineers' THEN 1128 WHEN input_value = 'Business & Leadership for Python Master' THEN 1129 WHEN input_value = 'Productivity Tools for Python Master' THEN 1130 WHEN input_value = 'Productivity Tools for Decision-makers and Leaders' THEN 1131 WHEN input_value = 'Business & Leadership with Serverless Deployments for Developers' THEN 1132 WHEN input_value = 'Productivity Tools with Serverless Deployments for Developers' THEN 1133 WHEN input_value = 'Business & Leadership for Javanista' THEN 1134 WHEN input_value = 'Productivity Tools for Javanista' THEN 1135 WHEN input_value = 'Business & Leadership for Go Programming Essentials' THEN 1136 WHEN input_value = 'Business & Leadership for Engineering Lead' THEN 1137 WHEN input_value = 'Business & Leadership for AI and ML for Decision-makers' THEN 1138 WHEN input_value = 'Productivity Tools for Secure Agile Programmers' THEN 1139 WHEN input_value = 'Transportation (Latin American Spanish Edition)' THEN 1140 WHEN input_value = 'Transportation (US Edition)' THEN 1141 WHEN input_value = 'Transportation (Italian Edition)' THEN 1142 WHEN input_value = 'Transportation (Canadian Edition)' THEN 1143 WHEN input_value = 'Transportation (Canadian French Edition)' THEN 1144 WHEN input_value = 'Transportation (UK Edition)' THEN 1145 WHEN input_value = 'Transportation (Chinese Edition)' THEN 1146 WHEN input_value = 'Transportation (Portuguese Brazilian Edition)' THEN 1147 WHEN input_value = 'Transportation (German Edition)' THEN 1148 WHEN input_value = 'Transportation (Castilian Spanish Edition)' THEN 1149 WHEN input_value = 'Transportation (Korean Edition)' THEN 1150 WHEN input_value = 'Transportation (Dutch Edition)' THEN 1151 WHEN input_value = 'Transportation (French Edition)' THEN 1152 WHEN input_value = 'Workplace Compliance Essentials (Canadian French Edition)' THEN 1153 WHEN input_value = 'Workplace Compliance Essentials (Russian Edition)' THEN 1154 WHEN input_value = 'Workplace Compliance Essentials (US Edition)' THEN 1155 WHEN input_value = 'Workplace Compliance Essentials (Korean Edition)' THEN 1156 WHEN input_value = 'Workplace Compliance Essentials (Czech Edition)' THEN 1157 WHEN input_value = 'Workplace Compliance Essentials (Chinese Edition)' THEN 1158 WHEN input_value = 'Workplace Compliance Essentials (Hindi Edition)' THEN 1159 WHEN input_value = 'Workplace Compliance Essentials (Bahasa Indonesian Edition)' THEN 1160 WHEN input_value = 'Workplace Compliance Essentials (Hungarian Edition)' THEN 1161 WHEN input_value = 'Workplace Compliance Essentials (Romanian Edition)' THEN 1162 WHEN input_value = 'Workplace Compliance Essentials (Finnish Edition)' THEN 1163 WHEN input_value = 'Workplace Compliance Essentials (Danish Edition)' THEN 1164 WHEN input_value = 'Workplace Compliance Essentials (Chinese Traditional Edition)' THEN 1165 WHEN input_value = 'Workplace Compliance Essentials (Latin American Spanish Edition)' THEN 1166 WHEN input_value = 'Workplace Compliance Essentials (Polish Edition)' THEN 1167 WHEN input_value = 'Food Allergies And Intolerance' THEN 1168 WHEN input_value = 'Industry Specific' THEN 1169 WHEN input_value = 'Cal/OSHA Latin American Spanish' THEN 1170 WHEN input_value = 'Technology' THEN 1171 WHEN input_value = 'Disability Discrimination Awareness' THEN 1172 WHEN input_value = 'Cisco WebEx Teams' THEN 1173 WHEN input_value = 'Equality and Diversity Awareness' THEN 1174 WHEN input_value = 'Cisco WebEx for Web' THEN 1175 WHEN input_value = 'Portuguese' THEN 1176 WHEN input_value = 'French Canadian' THEN 1177 WHEN input_value = 'Japanese' THEN 1178 WHEN input_value = 'Cal/OSHA' THEN 1179 WHEN input_value = 'Coordinators' THEN 1180 WHEN input_value = 'Managers' THEN 1181 WHEN input_value = 'Skype for Business 2016 (No Assessments)' THEN 1182 WHEN input_value = 'First Aid Awareness' THEN 1183 WHEN input_value = 'Fire Safety Awareness' THEN 1184 WHEN input_value = 'Join.me for Windows (No Assessments)' THEN 1185 WHEN input_value = 'LogMeIn GoToMeeting (No Assessments)' THEN 1186 WHEN input_value = 'Presentation Skills' THEN 1187 WHEN input_value = 'Project Sheets' THEN 1188 WHEN input_value = '5S' THEN 1189 WHEN input_value = 'Label Templates' THEN 1190 WHEN input_value = 'Final Presentation' THEN 1191 WHEN input_value = 'Kaizen' THEN 1192 WHEN input_value = 'Engineering' THEN 1193 WHEN input_value = 'Lifelong Learn' THEN 1194 WHEN input_value = 'Cloud Services' THEN 1195 WHEN input_value = 'Business Operations' THEN 1196 WHEN input_value = 'Welcome to Percipio' THEN 1197 WHEN input_value = 'Aspire Journeys for Leadership' THEN 1198 WHEN input_value = 'Cybersecurity Career Journey' THEN 1199 WHEN input_value = 'Skillsoft Live Events' THEN 1200 WHEN input_value = 'Sample Content' THEN 1201 WHEN input_value = 'Customer Service' THEN 1202 WHEN input_value = 'Browse Partner Content' THEN 1203 WHEN input_value = 'Aspire Journeys' THEN 1204 WHEN input_value = 'Infrastructure & Operations' THEN 1205 WHEN input_value = 'Sales & Marketing' THEN 1206 WHEN input_value = 'Skillsoft Bootcamps' THEN 1207 WHEN input_value = 'Digital Transformation' THEN 1208 WHEN input_value = 'Professional Improvement' THEN 1209 WHEN input_value = 'Diversity, Equity, & Inclusion' THEN 1210 WHEN input_value = 'NICE Framework' THEN 1211 WHEN input_value = 'Certifications' THEN 1212 WHEN input_value = 'Skillsoft Leadercamps' THEN 1213 WHEN input_value = 'Software Craft' THEN 1214 WHEN input_value = 'Cloud Career Journey' THEN 1215 WHEN input_value = 'Codecademy' THEN 1216 WHEN input_value = 'Project Management' THEN 1217 WHEN input_value = 'Mainframe' THEN 1218 WHEN input_value = 'Perspectives' THEN 1219 WHEN input_value = 'Agile Career Journey' THEN 1220 WHEN input_value = 'Product Management' THEN 1221 WHEN input_value = 'Data' THEN 1222 WHEN input_value = 'Corporate Marketing' THEN 1223 WHEN input_value = 'Customer Success' THEN 1224 WHEN input_value = 'Product Marketing' THEN 1225 WHEN input_value = 'Corporate Communications' THEN 1226 WHEN input_value = 'Selling Skills' THEN 1227 WHEN input_value = 'Internet of Things' THEN 1228 WHEN input_value = 'Cloud Basics' THEN 1229 WHEN input_value = 'Cloud Development' THEN 1230 WHEN input_value = 'Cloud Platforms' THEN 1231 WHEN input_value = 'NEW - Azure' THEN 1232 WHEN input_value = 'Pursue an Agile Certification' THEN 1233 WHEN input_value = 'Pursue an Agile Job Role' THEN 1234 WHEN input_value = 'Pursue an Azure Cloud Job Role' THEN 1235 WHEN input_value = 'Pursue an AWS Cloud Job Role' THEN 1236 WHEN input_value = 'Pursue a GCP Cloud Job Role' THEN 1237 WHEN input_value = 'Pursue a Foundation in Cloud' THEN 1238 WHEN input_value = 'Pursue a Cloud Skill' THEN 1239 WHEN input_value = 'Pursue a Cybersecurity Skill' THEN 1240 WHEN input_value = 'Database Development' THEN 1241 WHEN input_value = 'Data Visualization & Reporting' THEN 1242 WHEN input_value = 'Big Data' THEN 1243 WHEN input_value = 'Data Architectures' THEN 1244 WHEN input_value = 'Data Core Concepts' THEN 1245 WHEN input_value = 'Data Analytics' THEN 1246 WHEN input_value = 'Data Science' THEN 1247 WHEN input_value = 'Data Platforms' THEN 1248 WHEN input_value = 'Business Intelligence' THEN 1249 WHEN input_value = 'Data Security' THEN 1250 WHEN input_value = 'Diversity, Equity & Inclusion' THEN 1251 WHEN input_value = 'DevOps IT' THEN 1252 WHEN input_value = 'Client & Server Administration' THEN 1253 WHEN input_value = 'IT Services' THEN 1254 WHEN input_value = 'Network Operations' THEN 1255 WHEN input_value = 'IT Trends' THEN 1256 WHEN input_value = '2020 Mainstage Keynotes' THEN 1257 WHEN input_value = '2020 Product Sessions' THEN 1258 WHEN input_value = '2020 Case Studies' THEN 1259 WHEN input_value = 'Leadership & Business' THEN 1260 WHEN input_value = 'NICE Work Roles' THEN 1261 WHEN input_value = 'Product Management Skills' THEN 1262 WHEN input_value = 'Software Developer Bootcamps' THEN 1263 WHEN input_value = 'Virtual Training' THEN 1264 WHEN input_value = 'Security Bootcamps' THEN 1265 WHEN input_value = 'Project Management Bootcamps' THEN 1266 WHEN input_value = 'Cloud Services Bootcamps' THEN 1267 WHEN input_value = 'Data Bootcamps' THEN 1268 WHEN input_value = 'In Pursuit of Re-engagement' THEN 1269 WHEN input_value = 'Leading HR' THEN 1270 WHEN input_value = 'Productivity & Wellness' THEN 1271 WHEN input_value = 'Art of Great Consulting' THEN 1272 WHEN input_value = 'Leading in the New Normal' THEN 1273 WHEN input_value = 'Artificial Intelligence' THEN 1274 WHEN input_value = 'Software' THEN 1275 WHEN input_value = 'Machine Learning' THEN 1276 WHEN input_value = 'Data Management' THEN 1277 WHEN input_value = 'Leadership Mindsets' THEN 1278 WHEN input_value = 'Leadership Transitions' THEN 1279 WHEN input_value = 'Espanol' THEN 1280 WHEN input_value = 'English' THEN 1281 WHEN input_value = 'Codecademy Languages' THEN 1282 WHEN input_value = 'Codecademy Subjects' THEN 1283 WHEN input_value = 'Finance' THEN 1284 WHEN input_value = 'Process Improvement' THEN 1285 WHEN input_value = 'Business Planning & Analysis' THEN 1286 WHEN input_value = 'Human Resources' THEN 1287 WHEN input_value = 'Banking' THEN 1288 WHEN input_value = 'Microsoft Office' THEN 1289 WHEN input_value = 'CompTIA' THEN 1290 WHEN input_value = 'Oracle' THEN 1291 WHEN input_value = 'VMware' THEN 1292 WHEN input_value = 'Isograd' THEN 1293 WHEN input_value = 'Cisco' THEN 1294 WHEN input_value = 'SAS' THEN 1295 WHEN input_value = 'Digital Marketing Institute' THEN 1296 WHEN input_value = 'Red Hat' THEN 1297 WHEN input_value = 'Kubernetes' THEN 1298 WHEN input_value = 'Microsoft' THEN 1299 WHEN input_value = 'Google' THEN 1300 WHEN input_value = '(ISC)2' THEN 1301 WHEN input_value = 'EC-Council' THEN 1302 WHEN input_value = 'AWS' THEN 1303 WHEN input_value = 'Virtual Work' THEN 1304 WHEN input_value = 'Digital Experiences' THEN 1305 WHEN input_value = 'Civil' THEN 1306 WHEN input_value = 'Energy' THEN 1307 WHEN input_value = 'Chemical' THEN 1308 WHEN input_value = 'Industrial' THEN 1309 WHEN input_value = 'Aerospace & Mechanical' THEN 1310 WHEN input_value = 'Electrical' THEN 1311 WHEN input_value = 'Test Channels' THEN 1312 WHEN input_value = 'Engineering Resources' THEN 1313 WHEN input_value = 'Personal Productivity' THEN 1314 WHEN input_value = 'Personal Accountability' THEN 1315 WHEN input_value = 'Well-Being' THEN 1316 WHEN input_value = 'Business Communication' THEN 1317 WHEN input_value = 'Self-Discovery' THEN 1318 WHEN input_value = 'Mainframe Security' THEN 1319 WHEN input_value = 'Mainframe Services' THEN 1320 WHEN input_value = 'Project Management Methods' THEN 1321 WHEN input_value = 'Live Events' THEN 1322 WHEN input_value = 'Emerging Tech' THEN 1323 WHEN input_value = 'Software Architectures' THEN 1324 WHEN input_value = 'Software Dev Practices' THEN 1325 WHEN input_value = 'Getting Started with Percipio' THEN 1326 WHEN input_value = 'Expert' THEN 1327 WHEN input_value = 'Associate (MTA)' THEN 1328 WHEN input_value = 'Microsoft 365 Certified Expert' THEN 1329 WHEN input_value = 'Microsoft Certified Associate' THEN 1330 WHEN input_value = 'Professional' THEN 1331 WHEN input_value = 'Entry' THEN 1332 WHEN input_value = 'Associate' THEN 1333 WHEN input_value = 'TOSA Desktop' THEN 1334 WHEN input_value = 'TOSA Digital' THEN 1335 WHEN input_value = 'Cloud Security' THEN 1336 WHEN input_value = 'Software Development' THEN 1337 WHEN input_value = 'Information Security' THEN 1338 WHEN input_value = 'Systems Security' THEN 1339 WHEN input_value = 'Cybersecurity' THEN 1340 WHEN input_value = 'Bloodborne Pathogens' THEN 1341 WHEN input_value = 'Excel' THEN 1342 WHEN input_value = 'Access' THEN 1343 WHEN input_value = 'TWI - Job Instruction' THEN 1344 WHEN input_value = 'Filehold' THEN 1345 WHEN input_value = 'Engineer Resources' THEN 1346 WHEN input_value = 'Security Skills' THEN 1347 WHEN input_value = 'Outlook' THEN 1348 WHEN input_value = 'Concur' THEN 1349 WHEN input_value = 'Teams' THEN 1350 WHEN input_value = 'TWI - Job Methods' THEN 1351 WHEN input_value = 'ADP' THEN 1352 WHEN input_value = 'Docusign' THEN 1353 WHEN input_value = 'TWI - Job Relations' THEN 1354 WHEN input_value = 'Word' THEN 1355 WHEN input_value = 'PowerPoint' THEN 1356 WHEN input_value = 'Infrastructure' THEN 1357 WHEN input_value = 'Data and Analytics' THEN 1358 WHEN input_value = 'Additional Professional' THEN 1359 WHEN input_value = 'Core' THEN 1360 WHEN input_value = 'VMware Certified Professional' THEN 1361 WHEN input_value = 'Data Analysis' THEN 1362 WHEN input_value = 'Digital Marketing Associate' THEN 1363 WHEN input_value = 'Google Workspace' THEN 1364 WHEN input_value = 'Specialty' THEN 1365 WHEN input_value = 'Architecting' THEN 1366 WHEN input_value = 'Operations' THEN 1367 WHEN input_value = 'Cloud Practitioner' THEN 1368 WHEN input_value = 'Developing' THEN 1369 WHEN input_value = 'Base Programmer' THEN 1370 WHEN input_value = 'Administrator' THEN 1371 WHEN input_value = 'Kubernetes Administrator' THEN 1372 WHEN input_value = 'Spreadsheet Software' THEN 1373 WHEN input_value = 'Microsoft Office/Office 365' THEN 1374 WHEN input_value = 'Email' THEN 1375 WHEN input_value = 'Presentation Software' THEN 1376 WHEN input_value = 'Microsoft Outlook' THEN 1377 WHEN input_value = 'Microsoft Excel' THEN 1378 WHEN input_value = 'Microsoft Powerpoint' THEN 1379 WHEN input_value = 'Google Hangouts Meet' THEN 1380 WHEN input_value = 'Google Hangouts Meet (No Assessments)' THEN 1381 WHEN input_value = 'Software Applications' THEN 532 WHEN input_value = 'Policy and Compliance' THEN 533 WHEN input_value = 'Cornerstone Product Training' THEN 534 WHEN input_value = 'Management Skills' THEN 535 WHEN input_value = 'Communication & Teamwork' THEN 536 WHEN input_value = 'Technical Skills' THEN 537 WHEN input_value = 'Business Skills' THEN 538 WHEN input_value = 'Compliance' THEN 539 WHEN input_value = 'IT Skills' THEN 540 WHEN input_value = 'Certification' THEN 541 WHEN input_value = 'Collections' THEN 542 WHEN input_value = 'Skillsoft Aspire' THEN 543 WHEN input_value = 'Productivity & Collaboration Tools' THEN 544 WHEN input_value = 'Business Continuity' THEN 545 WHEN input_value = 'Skillsoft Aspire L&B' THEN 546 WHEN input_value = 'Change' THEN 547 WHEN input_value = 'Communications Skills' THEN 548 WHEN input_value = 'Finance and Accounting' THEN 549 WHEN input_value = 'Human Resources' THEN 550 WHEN input_value = 'Industry Overviews' THEN 551 WHEN input_value = 'Leadership' THEN 552 WHEN input_value = 'Management' THEN 553 WHEN input_value = 'Operations Management' THEN 554 WHEN input_value = 'Professional Effectiveness' THEN 555 WHEN input_value = 'Project Management' THEN 556 WHEN input_value = 'Strategy and Innovation' THEN 557 WHEN input_value = 'Business Skills' THEN 558 WHEN input_value = 'Business Skills' THEN 559 WHEN input_value = 'Business Skills' THEN 560 WHEN input_value = 'Business Skills' THEN 561 WHEN input_value = 'Business Skills' THEN 562 WHEN input_value = 'Sumtotal344' THEN 563 WHEN input_value = 'ILT Events' THEN 565 WHEN input_value = 'SumTotal2' THEN 566 WHEN input_value = 'SumTotal' THEN 567 WHEN input_value = 'Materials' THEN 568 WHEN input_value = 'Videos' THEN 569 WHEN input_value = 'Curriculum' THEN 570 WHEN input_value = 'Curriculums' THEN 571 WHEN input_value = 'ILT Events' THEN 572 WHEN input_value = 'Scorm' THEN 573 WHEN input_value = 'Finance' THEN 574 WHEN input_value = 'SIAM TEAM' THEN 575 WHEN input_value = 'New Employee Training' THEN 576 WHEN input_value = 'Exercise' THEN 577 WHEN input_value = 'Leadership Development' THEN 578 WHEN input_value = 'Medicine' THEN 579 WHEN input_value = 'Teaching' THEN 580 WHEN input_value = 'Course Details' THEN 581 WHEN input_value = 'Pravir test' THEN 582 WHEN input_value = 'Tests' THEN 583 WHEN input_value = 'Online Courses' THEN 584 WHEN input_value = 'Topics' THEN 585 WHEN input_value = 'PESV2_topic' THEN 586 WHEN input_value = '1234' THEN 587 WHEN input_value = '208_Cloud Services' THEN 588 WHEN input_value = '210_Customer Service' THEN 589 WHEN input_value = '211_Developer' THEN 590 WHEN input_value = '212_Digital Transformation' THEN 591 WHEN input_value = '213_IT Operations' THEN 592 WHEN input_value = '215_Leadership Development Program' THEN 593 WHEN input_value = '216_Management' THEN 594 WHEN input_value = '58_Certifications' THEN 595 WHEN input_value = 'Aspire Journeys' THEN 596 WHEN input_value = 'Business Operations' THEN 597 WHEN input_value = '66_Cloud Services' THEN 598 WHEN input_value = '68_Customer Service' THEN 599 WHEN input_value = 'Data' THEN 600 WHEN input_value = '70_Developer' THEN 601 WHEN input_value = '71_Digital Transformation' THEN 602 WHEN input_value = '74_IT Operations' THEN 603 WHEN input_value = '82_Management' THEN 604 WHEN input_value = 'Productivity & Collaboration Tools' THEN 605 WHEN input_value = 'Professional Improvement' THEN 606 WHEN input_value = '89_Project Management' THEN 607 WHEN input_value = 'Sales & Marketing' THEN 608 WHEN input_value = '121_Customer Service: Core Concepts & Methods' THEN 609 WHEN input_value = 'Data Visualization & Reporting' THEN 610 WHEN input_value = 'Big Data' THEN 611 WHEN input_value = 'Data Security' THEN 612 WHEN input_value = 'Data Analytics' THEN 613 WHEN input_value = 'Data Core Concepts' THEN 614 WHEN input_value = 'Database Development' THEN 615 WHEN input_value = 'Data Platforms' THEN 616 WHEN input_value = 'Business Intelligence' THEN 617 WHEN input_value = '130_Data Science' THEN 618 WHEN input_value = '141_Data Science' THEN 619 WHEN input_value = '146_Digital Marketing & Communications' THEN 620 WHEN input_value = '151_Information Security' THEN 621 WHEN input_value = '152_IT Services' THEN 622 WHEN input_value = '153_DevOps' THEN 623 WHEN input_value = 'IT Trends' THEN 624 WHEN input_value = '155_Network Operations' THEN 625 WHEN input_value = '156_Client & Server Administration' THEN 626 WHEN input_value = 'Design' THEN 627 WHEN input_value = 'Productivity Tools' THEN 628 WHEN input_value = 'Collaboration' THEN 629 WHEN input_value = 'Browsers & Operating Systems' THEN 630 WHEN input_value = '186_Microsoft Office' THEN 631 WHEN input_value = 'Personal Productivity' THEN 632 WHEN input_value = 'Well-Being' THEN 633 WHEN input_value = 'Business Communication' THEN 634 WHEN input_value = 'Self-Discovery' THEN 635 WHEN input_value = 'Personal Accountability' THEN 636 WHEN input_value = 'Individual Professional Performance' THEN 637 WHEN input_value = 'Project Management Methods' THEN 638 WHEN input_value = 'Project Management Core Concepts' THEN 639 WHEN input_value = 'Product Marketing' THEN 640 WHEN input_value = 'Selling Skills' THEN 641 WHEN input_value = 'Salesforce & Channel Management' THEN 642 WHEN input_value = 'Corporate Communications' THEN 643 WHEN input_value = 'Corporate Marketing' THEN 644 WHEN input_value = '205_(ISC)2' THEN 645 WHEN input_value = '206_Amazon' THEN 646 WHEN input_value = '207_Cisco' THEN 647 WHEN input_value = '209_CompTIA' THEN 648 WHEN input_value = '214_Information Systems Audit and Control Association' THEN 649 WHEN input_value = '217_Microsoft' THEN 650 WHEN input_value = '228_Cloud Platforms' THEN 651 WHEN input_value = '229_Cloud Development' THEN 652 WHEN input_value = '245_Information Security' THEN 653 WHEN input_value = '246_IT Services' THEN 654 WHEN input_value = '247_Network Operations' THEN 655 WHEN input_value = '248_Client & Server Administration' THEN 656 WHEN input_value = '250_Leading the Business' THEN 657 WHEN input_value = '251_Leading Your Team' THEN 658 WHEN input_value = '252_Leading Yourself' THEN 659 WHEN input_value = '253_Management Essentials' THEN 660 WHEN input_value = '59_(ISC)2' THEN 661 WHEN input_value = '60_Amazon' THEN 662 WHEN input_value = 'American Society for Quality (ASQ)' THEN 663 WHEN input_value = 'BCS Professional Institute' THEN 664 WHEN input_value = '65_Cisco' THEN 665 WHEN input_value = '67_CompTIA' THEN 666 WHEN input_value = 'EC-Council' THEN 667 WHEN input_value = 'Google' THEN 668 WHEN input_value = 'ITIL®' THEN 669 WHEN input_value = '76_Information Systems Audit and Control Association' THEN 670 WHEN input_value = 'International Institute of Business Analysis (IIBA)' THEN 671 WHEN input_value = 'International Software Testing Qualification Board' THEN 672 WHEN input_value = 'Isograd' THEN 673 WHEN input_value = 'Juniper' THEN 674 WHEN input_value = 'Linux Professional Institute' THEN 675 WHEN input_value = '83_Microsoft' THEN 676 WHEN input_value = '84_Microsoft Office' THEN 677 WHEN input_value = 'Oracle' THEN 678 WHEN input_value = 'PRINCE2®' THEN 679 WHEN input_value = 'Project Management Institute (PMI)®' THEN 680 WHEN input_value = 'Red Hat' THEN 681 WHEN input_value = 'SAS' THEN 682 WHEN input_value = 'TOGAF®' THEN 683 WHEN input_value = '10_Developer' THEN 684 WHEN input_value = 'Data Analyst to Data Scientist' THEN 685 WHEN input_value = 'Business Planning & Analysis' THEN 686 WHEN input_value = 'Finance' THEN 687 WHEN input_value = 'Human Resources' THEN 688 WHEN input_value = 'Process Improvement' THEN 689 WHEN input_value = '11_Digital Transformation' THEN 690 WHEN input_value = '112_Cloud Platforms' THEN 691 WHEN input_value = 'Cloud Basics' THEN 692 WHEN input_value = 'Internet of Things' THEN 693 WHEN input_value = '115_Cloud Development' THEN 694 WHEN input_value = '116_Cloud Security' THEN 695 WHEN input_value = '12_IT Operations' THEN 696 WHEN input_value = 'Developer Trends' THEN 697 WHEN input_value = 'Web Development' THEN 698 WHEN input_value = 'Mobile Development' THEN 699 WHEN input_value = '134_DevOps' THEN 700 WHEN input_value = '135_Secure Programming' THEN 701 WHEN input_value = 'Data Modelling' THEN 702 WHEN input_value = '137_Developer Concepts & Methodologies' THEN 703 WHEN input_value = '138_Developer Tools' THEN 704 WHEN input_value = '139_Programming Languages' THEN 705 WHEN input_value = '14_Leadership Development Program' THEN 706 WHEN input_value = 'Microservices' THEN 707 WHEN input_value = '142_Essentials of Digital Transformation' THEN 708 WHEN input_value = '143_Virtual Work' THEN 709 WHEN input_value = '144_Digital Soft Skills Competencies' THEN 710 WHEN input_value = '145_Agility for Digital Transformation' THEN 711 WHEN input_value = '147_Digital Experiences' THEN 712 WHEN input_value = '15_Management' THEN 713 WHEN input_value = 'Leadership Essentials' THEN 714 WHEN input_value = '166_Management Essentials' THEN 715 WHEN input_value = 'Team Management' THEN 716 WHEN input_value = 'Business Execution' THEN 717 WHEN input_value = 'Business Strategy' THEN 718 WHEN input_value = '233_Customer Service: Core Concepts & Methods' THEN 719 WHEN input_value = '234_Secure Programming' THEN 720 WHEN input_value = '235_Developer Concepts & Methodologies' THEN 721 WHEN input_value = '236_Developer Tools' THEN 722 WHEN input_value = '237_Programming Languages' THEN 723 WHEN input_value = '238_Data Science' THEN 724 WHEN input_value = '239_Essentials of Digital Transformation' THEN 725 WHEN input_value = '240_Virtual Work' THEN 726 WHEN input_value = '241_Digital Soft Skills Competencies' THEN 727 WHEN input_value = '242_Agility for Digital Transformation' THEN 728 WHEN input_value = '243_Digital Marketing & Communications' THEN 729 WHEN input_value = '244_Digital Experiences' THEN 730 WHEN input_value = '3_Certifications' THEN 731 WHEN input_value = '7_Cloud Services' THEN 732 WHEN input_value = '9_Customer Service' THEN 733 WHEN input_value = 'ASQ (American Society for Quality)' THEN 734 WHEN input_value = '104_Foundation' THEN 735 WHEN input_value = '109_Professional' THEN 736 WHEN input_value = '110_Entry' THEN 737 WHEN input_value = '111_Associate' THEN 738 WHEN input_value = '13_Information Systems Audit and Control Association' THEN 739 WHEN input_value = '148_Core' THEN 740 WHEN input_value = '16_Microsoft' THEN 741 WHEN input_value = '161_Foundation' THEN 742 WHEN input_value = '164_Administrator' THEN 743 WHEN input_value = 'Microsoft Certified Associate' THEN 744 WHEN input_value = '171_Specialist' THEN 745 WHEN input_value = '172_Microsoft Certified Solutions Developer (MCSD)' THEN 746 WHEN input_value = '173_Microsoft Certified Solutions Associate (MCSA)' THEN 747 WHEN input_value = '174_Microsoft Certified Solutions Expert (MCSE)' THEN 748 WHEN input_value = '175_Associate (MTA)' THEN 749 WHEN input_value = 'Microsoft Certified Fundamentals' THEN 750 WHEN input_value = 'Microsoft Office Specialist (MOS)' THEN 751 WHEN input_value = '178_Professional' THEN 752 WHEN input_value = 'Expert' THEN 753 WHEN input_value = '180_Associate' THEN 754 WHEN input_value = '181_Foundation' THEN 755 WHEN input_value = '196_Administrator' THEN 756 WHEN input_value = 'Base Programmer' THEN 757 WHEN input_value = '218_Cloud Security' THEN 758 WHEN input_value = '219_Systems Security' THEN 759 WHEN input_value = '220_Software Development' THEN 760 WHEN input_value = '221_Information Security' THEN 761 WHEN input_value = '249_Auditor' THEN 762 WHEN input_value = '27_Cloud Platforms' THEN 763 WHEN input_value = '28_Cloud Development' THEN 764 WHEN input_value = '4_(ISC)2' THEN 765 WHEN input_value = '44_Information Security' THEN 766 WHEN input_value = '45_IT Services' THEN 767 WHEN input_value = '46_Network Operations' THEN 768 WHEN input_value = '47_Client & Server Administration' THEN 769 WHEN input_value = '49_Leading the Business' THEN 770 WHEN input_value = '5_Amazon' THEN 771 WHEN input_value = '50_Leading Your Team' THEN 772 WHEN input_value = '51_Leading Yourself' THEN 773 WHEN input_value = '52_Management Essentials' THEN 774 WHEN input_value = '6_Cisco' THEN 775 WHEN input_value = '8_CompTIA' THEN 776 WHEN input_value = '100_Architecting' THEN 777 WHEN input_value = '101_Operations' THEN 778 WHEN input_value = 'Additional Professional' THEN 779 WHEN input_value = '118_Cybersecurity' THEN 780 WHEN input_value = '119_Infrastructure' THEN 781 WHEN input_value = '120_Core' THEN 782 WHEN input_value = '149_Associate' THEN 783 WHEN input_value = '150_Professional' THEN 784 WHEN input_value = '157_Foundation' THEN 785 WHEN input_value = '158_Auditor' THEN 786 WHEN input_value = 'Security Manager' THEN 787 WHEN input_value = 'Level 3 - CBAP' THEN 788 WHEN input_value = 'TOSA Desktop' THEN 789 WHEN input_value = '163_Associate' THEN 790 WHEN input_value = '195_Project Management' THEN 791 WHEN input_value = 'TOGAF® 9' THEN 792 WHEN input_value = '222_Developing' THEN 793 WHEN input_value = '223_Architecting' THEN 794 WHEN input_value = '224_Operations' THEN 795 WHEN input_value = '225_Professional' THEN 796 WHEN input_value = '226_Entry' THEN 797 WHEN input_value = '227_Associate' THEN 798 WHEN input_value = '230_Cybersecurity' THEN 799 WHEN input_value = '231_Infrastructure' THEN 800 WHEN input_value = '232_Core' THEN 801 WHEN input_value = '254_Specialist' THEN 802 WHEN input_value = '255_Microsoft Certified Solutions Developer (MCSD)' THEN 803 WHEN input_value = '256_Microsoft Certified Solutions Associate (MCSA)' THEN 804 WHEN input_value = '257_Microsoft Certified Solutions Expert (MCSE)' THEN 805 WHEN input_value = '258_Associate (MTA)' THEN 806 WHEN input_value = '32_Customer Service: Core Concepts & Methods' THEN 807 WHEN input_value = '33_Secure Programming' THEN 808 WHEN input_value = '34_Developer Concepts & Methodologies' THEN 809 WHEN input_value = '35_Developer Tools' THEN 810 WHEN input_value = '36_Programming Languages' THEN 811 WHEN input_value = '37_Data Science' THEN 812 WHEN input_value = '38_Essentials of Digital Transformation' THEN 813 WHEN input_value = '39_Virtual Work' THEN 814 WHEN input_value = '40_Digital Soft Skills Competencies' THEN 815 WHEN input_value = '41_Agility for Digital Transformation' THEN 816 WHEN input_value = '42_Digital Marketing & Communications' THEN 817 WHEN input_value = '43_Digital Experiences' THEN 818 WHEN input_value = '95_Cloud Security' THEN 819 WHEN input_value = '96_Systems Security' THEN 820 WHEN input_value = '97_Software Development' THEN 821 WHEN input_value = '98_Information Security' THEN 822 WHEN input_value = '99_Developing' THEN 823 WHEN input_value = '17_Cloud Security' THEN 824 WHEN input_value = '18_Systems Security' THEN 825 WHEN input_value = '19_Software Development' THEN 826 WHEN input_value = '20_Information Security' THEN 827 WHEN input_value = '29_Cybersecurity' THEN 828 WHEN input_value = '30_Infrastructure' THEN 829 WHEN input_value = '31_Core' THEN 830 WHEN input_value = '48_Auditor' THEN 831 WHEN input_value = '21_Developing' THEN 832 WHEN input_value = '22_Architecting' THEN 833 WHEN input_value = '23_Operations' THEN 834 WHEN input_value = '24_Professional' THEN 835 WHEN input_value = '25_Entry' THEN 836 WHEN input_value = '26_Associate' THEN 837 WHEN input_value = '53_Specialist' THEN 838 WHEN input_value = '54_Microsoft Certified Solutions Developer (MCSD)' THEN 839 WHEN input_value = '55_Microsoft Certified Solutions Associate (MCSA)' THEN 840 WHEN input_value = '56_Microsoft Certified Solutions Expert (MCSE)' THEN 841 WHEN input_value = '57_Associate (MTA)' THEN 842 WHEN input_value = 'Java' THEN 843 WHEN input_value = 'oops' THEN 844 WHEN input_value = 'python' THEN 845 WHEN input_value = 'Auditor' THEN 846 WHEN input_value = 'Browsers & Operating Systems' THEN 847 WHEN input_value = 'Business Skills' THEN 848 WHEN input_value = 'Cloud' THEN 849 WHEN input_value = 'Cloud Computing' THEN 850 WHEN input_value = 'Collaboration' THEN 851 WHEN input_value = 'Data / ML / AI' THEN 852 WHEN input_value = 'Decision-makers and Leaders' THEN 853 WHEN input_value = 'Design' THEN 854 WHEN input_value = 'DevOps' THEN 855 WHEN input_value = 'Foundation' THEN 856 WHEN input_value = 'Get Started' THEN 857 WHEN input_value = 'IT Ops' THEN 858 WHEN input_value = 'Leading the Business' THEN 859 WHEN input_value = 'Leading Your Team' THEN 860 WHEN input_value = 'Leading Yourself' THEN 861 WHEN input_value = 'Level 3 - CBAP' THEN 862 WHEN input_value = 'PM' THEN 863 WHEN input_value = 'Productivity Tools' THEN 864 WHEN input_value = 'Programming' THEN 865 WHEN input_value = 'Adapting to Change' THEN 866 WHEN input_value = 'Business Execution' THEN 867 WHEN input_value = 'Business Strategy' THEN 868 WHEN input_value = 'Business Continuity Planning' THEN 869 WHEN input_value = 'Collaboration Tools' THEN 870 WHEN input_value = 'Communication Essentials' THEN 871 WHEN input_value = 'Crisis Management' THEN 872 WHEN input_value = 'Environmental, Health and Safety (EHS) Compliance' THEN 873 WHEN input_value = 'Food and Alcohol Safety' THEN 874 WHEN input_value = 'Leadership Essentials' THEN 875 WHEN input_value = 'Leading Teams' THEN 876 WHEN input_value = 'Legal Compliance' THEN 877 WHEN input_value = 'Professional Essentials' THEN 878 WHEN input_value = 'Software Tester to DevOps Automated Tester' THEN 879 WHEN input_value = 'Penetration Tester to SecOps Engineer' THEN 880 WHEN input_value = 'Web Programmer to Apprentice Programmer' THEN 881 WHEN input_value = 'Software Project Lead to Advanced Scrum Master' THEN 882 WHEN input_value = 'Network Security Specialist to CloudOps Security Architect' THEN 883 WHEN input_value = 'DevOps Engineer to Cloud Architect' THEN 884 WHEN input_value = 'Apprentice Developer to Journeyman Developer' THEN 885 WHEN input_value = 'AI Apprentice to AI Architect' THEN 886 WHEN input_value = 'Programmer to API Developer' THEN 887 WHEN input_value = 'Developer to Software Architect' THEN 888 WHEN input_value = 'Network Admin to Site Reliability Engineer' THEN 889 WHEN input_value = 'Infrastructure Support Engineer to CloudOps Engineer' THEN 890 WHEN input_value = 'Business Analyst to Data Analyst' THEN 891 WHEN input_value = 'Data Visualization' THEN 892 WHEN input_value = 'Pythonista to Python Master' THEN 893 WHEN input_value = 'Management Essentials' THEN 894 WHEN input_value = 'Microsoft Office 2016' THEN 895 WHEN input_value = 'Microsoft Office 365' THEN 896 WHEN input_value = 'Data Analysis with R' THEN 897 WHEN input_value = 'Security Essentials for Decision-makers and Leaders' THEN 898 WHEN input_value = 'Agile for Software Development' THEN 899 WHEN input_value = 'Serverless Deployments for Developers' THEN 900 WHEN input_value = 'Java Novice to Javanista' THEN 901 WHEN input_value = 'Web App Vulnerability Analyst' THEN 902 WHEN input_value = '5G Technologies and Practices' THEN 903 WHEN input_value = 'Go Programming Essentials' THEN 904 WHEN input_value = 'Enriched Web Development with Angular 11' THEN 905 WHEN input_value = 'Novice Developer to Pythonista' THEN 906 WHEN input_value = 'Javanista to Java Master' THEN 907 WHEN input_value = 'Developer Fundamentals' THEN 908 WHEN input_value = 'Programming Python in Action' THEN 909 WHEN input_value = 'Enterprise Development to DevOps Engineer' THEN 910 WHEN input_value = 'Web App Vulnerability Analyst - 2022 Update' THEN 911 WHEN input_value = 'Enterprise Development to Full Stack Developer' THEN 912 WHEN input_value = 'Software Product Management Proficiency' THEN 913 WHEN input_value = 'Engineering Lead' THEN 914 WHEN input_value = 'AI and ML for Decision-makers' THEN 915 WHEN input_value = 'Software Project Analyst to Senior Software Project Manager' THEN 916 WHEN input_value = 'Security Analyst to Security Architect' THEN 917 WHEN input_value = 'Programmer to Secure Agile Programmer' THEN 918 WHEN input_value = 'Virtual Work in the New Normal' THEN 919 WHEN input_value = 'Manage Myself' THEN 920 WHEN input_value = 'Manage Others' THEN 921 WHEN input_value = 'Security' THEN 922 WHEN input_value = 'Security Manager' THEN 923 WHEN input_value = 'Server Technology' THEN 924 WHEN input_value = 'Six Sigma Certification' THEN 925 WHEN input_value = 'Software Craftsmanship' THEN 926 WHEN input_value = 'Topics' THEN 927 WHEN input_value = 'Strategic Thinking' THEN 928 WHEN input_value = 'Team Management' THEN 929 WHEN input_value = 'Time Management and Productivity' THEN 930 WHEN input_value = 'Working on a Team' THEN 931 WHEN input_value = 'Working Remotely' THEN 932 WHEN input_value = 'Work-Life Balance' THEN 933 WHEN input_value = 'Accounting' THEN 934 WHEN input_value = 'AGG Leadership' THEN 935 WHEN input_value = 'Diversity on the Job' THEN 936 WHEN input_value = 'Time Management' THEN 937 WHEN input_value = 'Unconscious Bias' THEN 938 WHEN input_value = 'Diversity, Equity, and Inclusion' THEN 939 WHEN input_value = 'Building DEI Leadership Skills' THEN 940 WHEN input_value = 'Psychological Safety' THEN 941 WHEN input_value = 'Skills for Effective Collaboration' THEN 942 WHEN input_value = 'Managing a Crisis' THEN 943 WHEN input_value = 'Business' THEN 944 WHEN input_value = 'C#' THEN 945 WHEN input_value = 'Cisco Teams' THEN 946 WHEN input_value = 'Cisco WebEx' THEN 947 WHEN input_value = 'Computer Skills' THEN 948 WHEN input_value = 'Core Knowledge' THEN 949 WHEN input_value = 'Developer Tools' THEN 950 WHEN input_value = 'dot NET' THEN 951 WHEN input_value = 'Food and Alcohol Safety (Latin American Spanish Edition)' THEN 952 WHEN input_value = 'Food and Alcohol Safety (UK Edition)' THEN 953 WHEN input_value = 'Food and Alcohol Safety (US Edition)' THEN 954 WHEN input_value = 'Forms & Lists' THEN 955 WHEN input_value = 'Gemba' THEN 956 WHEN input_value = 'Hansei' THEN 957 WHEN input_value = 'Harassment (Canadian French Edition)' THEN 958 WHEN input_value = 'Harassment (Chinese Edition)' THEN 959 WHEN input_value = 'Harassment (Danish Edition)' THEN 960 WHEN input_value = 'Harassment (Dutch Edition)' THEN 961 WHEN input_value = 'Harassment (Finnish Edition)' THEN 962 WHEN input_value = 'Harassment (Hungarian Edition)' THEN 963 WHEN input_value = 'Harassment (Norwegian Edition)' THEN 964 WHEN input_value = 'Harassment (Romanian Edition)' THEN 965 WHEN input_value = 'Harassment (Russian Edition)' THEN 966 WHEN input_value = 'Harassment (Castilian Spanish Edition)' THEN 967 WHEN input_value = 'Harassment (Swedish Edition)' THEN 968 WHEN input_value = 'Harassment (Turkish Edition)' THEN 969 WHEN input_value = 'Harassment (UK English Edition)' THEN 970 WHEN input_value = 'Harassment (US Edition)' THEN 971 WHEN input_value = 'Health Insurance Portability and Accountability Act (HIPAA) (Latin American Spanish Edition)' THEN 972 WHEN input_value = 'Health Insurance Portability and Accountability Act (HIPAA) (US Edition)' THEN 973 WHEN input_value = 'Health and Wellness' THEN 974 WHEN input_value = 'Hoshin' THEN 975 WHEN input_value = 'Introductory Topics' THEN 976 WHEN input_value = 'JDE' THEN 977 WHEN input_value = 'Joinme' THEN 978 WHEN input_value = 'Just In Time' THEN 979 WHEN input_value = 'Kaizen Leadership' THEN 980 WHEN input_value = 'Kanban' THEN 981 WHEN input_value = 'Leadership & Teamwork' THEN 982 WHEN input_value = 'Additional Content' THEN 983 WHEN input_value = 'Legal Impacts (US Edition)' THEN 984 WHEN input_value = 'Legal Impacts (Brazilian Portuguese Edition)' THEN 985 WHEN input_value = 'Legal Impacts (Chinese Edition)' THEN 986 WHEN input_value = 'Legal Impacts (German Edition)' THEN 987 WHEN input_value = 'LMS Instructions' THEN 988 WHEN input_value = 'LogMeIn' THEN 989 WHEN input_value = 'Microservices' THEN 990 WHEN input_value = 'Mobile Development' THEN 991 WHEN input_value = 'Muda' THEN 992 WHEN input_value = 'Open Sesame' THEN 993 WHEN input_value = 'Improving Your Work/Life Balance' THEN 994 WHEN input_value = 'Improving Your Personal Productivity' THEN 995 WHEN input_value = 'Perseverance at Work' THEN 996 WHEN input_value = 'Percipio' THEN 997 WHEN input_value = 'Policies & Procedures' THEN 998 WHEN input_value = 'Problem Solving' THEN 999 ELSE 1382 END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Competency IDs", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Availability to All Users", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Availability to Specific Users", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Availability to OU", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Availability OU Type", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Register Upon Approval", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Pre-Approved", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Include Subordinates", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Recurrence", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "0", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Mobile", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (st:SumTotalField {name: "Skills", file: "Activity_OnlineCourse"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Skills", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (st:SumTotalField {name: "Estimatedcredits", file: "Activity_OnlineCourse"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Credits", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "999", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Height Screen Resolution", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Width Screen Resolution", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Available Offline - Allow download for offline consumption", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Available Offline - Allow launch from offline network location‡", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_OnlineCourse"})
MERGE (csod:CSODField {name: "Allow Download", file: "Activity_OnlineCourse" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);



MERGE ( f:File {name: "Activity_SessionParts"})
MERGE (st:SumTotalField {name: "ClassCode", file: "Activity_SessionParts"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Session ID*", file: "Activity_SessionParts" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_SessionParts"})
MERGE (st:SumTotalField {name: "SessionStartDate", file: "Activity_SessionParts"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Start Date/Time*", file: "Activity_SessionParts" })
SET csod.mandatory = "Mandatory", csod.field_type = "DateTime", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_SessionParts"})
MERGE (st:SumTotalField {name: "SessionEndDate", file: "Activity_SessionParts"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "End Date/Time", file: "Activity_SessionParts" })
SET csod.mandatory = "Optional", csod.field_type = "DateTime", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_SessionParts"})
MERGE (csod:CSODField {name: "Part Break", file: "Activity_SessionParts" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.min_value = "1", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_SessionParts"})
MERGE (st:SumTotalField {name: "Time Zone", file: "Activity_SessionParts"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Time Zone ID", file: "Activity_SessionParts"})
SET csod.mandatory = "Optional",
    csod.field_type = "Integer",
    csod.char_length = "",
    csod.default_value = "9",
    csod.accepted_values = "",
    csod.transformation = "CASE WHEN input_value = 'America/New_York' THEN 14 WHEN input_value = 'America/Chicago' THEN 9 WHEN input_value = 'America/Los_Angeles' THEN 5 WHEN input_value = 'America/Denver' THEN 8 WHEN input_value = 'America/Phoenix' THEN 8 WHEN input_value = 'America/Anchorage' THEN 4 WHEN input_value = 'America/Juneau' THEN 4 WHEN input_value = 'Pacific/Honolulu' THEN 3 WHEN input_value = 'America/Honolulu' THEN 3 WHEN input_value = 'America/Toronto' THEN 14 WHEN input_value = 'America/Montreal' THEN 14 WHEN input_value = 'America/Vancouver' THEN 5 WHEN input_value = 'America/Seattle' THEN 5 WHEN input_value = 'America/Calgary' THEN 8 WHEN input_value = 'America/Edmonton' THEN 8 WHEN input_value = 'America/Winnipeg' THEN 9 WHEN input_value = 'America/Regina' THEN 9 WHEN input_value = 'America/Saskatoon' THEN 9 WHEN input_value = 'America/Halifax' THEN 16 WHEN input_value = 'America/Moncton' THEN 16 WHEN input_value = 'America/St_Johns' THEN 74 WHEN input_value = 'Europe/London' THEN 26 WHEN input_value = 'Europe/Dublin' THEN 26 WHEN input_value = 'Europe/Lisbon' THEN 26 WHEN input_value = 'Europe/Amsterdam' THEN 28 WHEN input_value = 'Europe/Berlin' THEN 28 WHEN input_value = 'Europe/Rome' THEN 28 WHEN input_value = 'Europe/Vienna' THEN 28 WHEN input_value = 'Europe/Stockholm' THEN 28 WHEN input_value = 'Europe/Belgrade' THEN 29 WHEN input_value = 'Europe/Bratislava' THEN 29 WHEN input_value = 'Europe/Budapest' THEN 29 WHEN input_value = 'Europe/Ljubljana' THEN 29 WHEN input_value = 'Europe/Prague' THEN 29 WHEN input_value = 'Europe/Brussels' THEN 30 WHEN input_value = 'Europe/Copenhagen' THEN 30 WHEN input_value = 'Europe/Madrid' THEN 30 WHEN input_value = 'Europe/Paris' THEN 30 WHEN input_value = 'Europe/Sarajevo' THEN 31 WHEN input_value = 'Europe/Skopje' THEN 31 WHEN input_value = 'Europe/Warsaw' THEN 31 WHEN input_value = 'Europe/Zagreb' THEN 31 WHEN input_value = 'Europe/Athens' THEN 33 WHEN input_value = 'Europe/Bucharest' THEN 33 WHEN input_value = 'Europe/Helsinki' THEN 34 WHEN input_value = 'Europe/Kiev' THEN 34 WHEN input_value = 'Europe/Riga' THEN 34 WHEN input_value = 'Asia/Jerusalem' THEN 35 WHEN input_value = 'Asia/Baghdad' THEN 36 WHEN input_value = 'Asia/Kuwait' THEN 37 WHEN input_value = 'Asia/Riyadh' THEN 37 WHEN input_value = 'Asia/Tehran' THEN 38 WHEN input_value = 'Asia/Muscat' THEN 39 WHEN input_value = 'Asia/Baku' THEN 40 WHEN input_value = 'Asia/Tbilisi' THEN 41 WHEN input_value = 'Asia/Yerevan' THEN 42 WHEN input_value = 'Asia/Kabul' THEN 43 WHEN input_value = 'Asia/Yekaterinburg' THEN 47 WHEN input_value = 'Asia/Tashkent' THEN 48 WHEN input_value = 'Asia/Kolkata' THEN 49 WHEN input_value = 'Asia/Kathmandu' THEN 50 WHEN input_value = 'Asia/Novosibirsk' THEN 51 WHEN input_value = 'Asia/Almaty' THEN 52 WHEN input_value = 'Asia/Dhaka' THEN 53 WHEN input_value = 'Asia/Rangoon' THEN 54 WHEN input_value = 'Asia/Bangkok' THEN 55 WHEN input_value = 'Asia/Krasnoyarsk' THEN 56 WHEN input_value = 'Asia/Shanghai' THEN 57 WHEN input_value = 'Asia/Irkutsk' THEN 58 WHEN input_value = 'Asia/Kuala_Lumpur' THEN 59 WHEN input_value = 'Asia/Perth' THEN 60 WHEN input_value = 'Asia/Tokyo' THEN 62 WHEN input_value = 'Asia/Seoul' THEN 63 WHEN input_value = 'Asia/Yakutsk' THEN 64 WHEN input_value = 'Asia/Adelaide' THEN 65 WHEN input_value = 'Australia/Darwin' THEN 66 WHEN input_value = 'Australia/Brisbane' THEN 67 WHEN input_value = 'Australia/Sydney' THEN 68 WHEN input_value = 'Australia/Melbourne' THEN 68 WHEN input_value = 'Australia/Hobart' THEN 68 WHEN input_value = 'Pacific/Guam' THEN 69 WHEN input_value = 'Australia/Adelaide' THEN 70 WHEN input_value = 'Australia/Perth' THEN 71 WHEN input_value = 'Pacific/Auckland' THEN 73 WHEN input_value = 'Pacific/Fiji' THEN 74 WHEN input_value = 'Pacific/Midway' THEN 76 WHEN input_value = 'Pacific/Samoa' THEN 77 WHEN input_value = 'Pacific/Guadalcanal' THEN 78 WHEN input_value = 'Pacific/Port_Moresby' THEN 79 WHEN input_value = 'Pacific/Noumea' THEN 80 WHEN input_value = 'Pacific/Kiritimati' THEN 81 WHEN input_value = 'Pacific/Kwajalein' THEN 82 WHEN input_value = 'Pacific/Apia' THEN 83 WHEN input_value = 'Pacific/Chatham' THEN 84 WHEN input_value = 'Pacific/Easter' THEN 85 WHEN input_value = 'Pacific/Galapagos' THEN 86 WHEN input_value = 'Pacific/Marquesas' THEN 87 WHEN input_value = 'Pacific/Gambier' THEN 88 WHEN input_value = 'Pacific/Pitcairn' THEN 89 WHEN input_value = 'Pacific/Niue' THEN 90 WHEN input_value = 'Pacific/Pago_Pago' THEN 91 WHEN input_value = 'Pacific/Rarotonga' THEN 92 WHEN input_value = 'Pacific/Tahiti' THEN 93 WHEN input_value = 'Pacific/Tarawa' THEN 94 WHEN input_value = 'Pacific/Wake' THEN 95 WHEN input_value = 'Pacific/Wallis' THEN 96 WHEN input_value = 'Pacific/Tongatapu' THEN 97 WHEN input_value = 'Pacific/Fakaofo' THEN 98 WHEN input_value = 'Pacific/Chuuk' THEN 99 WHEN input_value = 'Pacific/Pohnpei' THEN 100 WHEN input_value = 'Pacific/Kosrae' THEN 101 WHEN input_value = 'Pacific/Majuro' THEN 102 WHEN input_value = 'Pacific/Kwajalein' THEN 103 WHEN input_value = 'Pacific/Nauru' THEN 104 WHEN input_value = 'Pacific/Funafuti' THEN 105 WHEN input_value = 'Pacific/Wallis' THEN 106 WHEN input_value = 'Pacific/Tokelau' THEN 107 WHEN input_value = 'Pacific/Kanton' THEN 108 WHEN input_value = 'Pacific/Fakaofo' THEN 109 WHEN input_value = 'Pacific/Chatham' THEN 110 WHEN input_value = 'Pacific/Easter' THEN 111 WHEN input_value = 'Pacific/Galapagos' THEN 112 WHEN input_value = 'Pacific/Marquesas' THEN 113 WHEN input_value = 'EST' THEN 14 WHEN input_value = 'CST' THEN 9 WHEN input_value = 'MST' THEN 8 WHEN input_value = 'PST' THEN 5 WHEN input_value = 'HST' THEN 3 WHEN input_value = 'AKST' THEN 4 WHEN input_value = 'GMT' THEN 26 WHEN input_value = 'UTC' THEN 28 ELSE 9 END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_SessionParts"})
MERGE (csod:CSODField {name: "Display Times in TimeZone of User", file: "Activity_SessionParts" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "USE SESSION SETTING", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_SessionParts"})
MERGE (st:SumTotalField {name: "SessionName", file: "Activity_SessionParts"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Part name", file: "Activity_SessionParts" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "Historical Data", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_SessionParts"})
MERGE (st:SumTotalField {name: "SessionDescription", file: "Activity_SessionParts"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Description", file: "Activity_SessionParts" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "4000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_SessionParts"})
MERGE (st:SumTotalField {name: "SessionLocation", file: "Activity_SessionParts"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Location", file: "Activity_SessionParts" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);



MERGE ( f:File {name: "Activity_SessionParts"})
MERGE (st:SumTotalField {name: "SessionInstructor", file: "Activity_SessionParts"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Instructor", file: "Activity_SessionParts" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_SessionParts"})
MERGE (csod:CSODField {name: "Created/ModifiedBy", file: "Activity_SessionParts" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "User performing the load", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_SessionParts"})
MERGE (csod:CSODField {name: "New Start Date/Time", file: "Activity_SessionParts" })
SET csod.mandatory = "Optional", csod.field_type = "DateTime", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "ILTCourseCode", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Event ID", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "ClassCode", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Session ID*", file: "Activity_Sessions"})
SET csod.mandatory = "Mandatory", csod.field_type= "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "ClassStartDate", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Part Start Date/Time", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "DateTime", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "ClassEndDate", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Part End Date/Time", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "DateTime", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Part Break Duration", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "1", csod.default_value = "", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE (f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "TimeZone", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Part Timezone", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", 
    csod.field_type = "Integer",
    csod.char_length = "",
    csod.default_value = "9",
    csod.accepted_values = "",
    csod.transformation = "CASE  WHEN input_value = 'MIT' THEN 1
  WHEN input_value = '(UTC-12:00) International Date Line West' THEN 1
  WHEN input_value = '(UTC+13:00) Samoa' THEN 2
  WHEN input_value = 'HST' THEN 3
  WHEN input_value = '(UTC-10:00) Hawaii' THEN 3
  WHEN input_value = 'AKST' THEN 4
  WHEN input_value = '(UTC-09:00) Alaska' THEN 4
  WHEN input_value = 'PST' THEN 5
  WHEN input_value = '(UTC-08:00) Pacific Time (US & Canada)' THEN 5
  WHEN input_value = 'PNT' THEN 6
  WHEN input_value = '(UTC-07:00) Arizona' THEN 6
  WHEN input_value = 'MST' THEN 8
  WHEN input_value = '(UTC-07:00) Mountain Time (US & Canada)' THEN 8
  WHEN input_value = 'CST' THEN 9
  WHEN input_value = '(UTC-06:00) Central America' THEN 9
  WHEN input_value = '(UTC-06:00) Central Time (US & Canada)' THEN 10
  WHEN input_value = '(UTC-06:00) Saskatchewan' THEN 12
  WHEN input_value = 'COT' THEN 13
  WHEN input_value = '(UTC-05:00) Bogota, Lima, Quito' THEN 13
  WHEN input_value = 'EST' THEN 14
  WHEN input_value = '(UTC-05:00) Eastern Time (US & Canada)' THEN 14
  WHEN input_value = 'IET' THEN 15
  WHEN input_value = '(UTC-05:00) Indiana (East)' THEN 15
  WHEN input_value = 'AST' THEN 16
  WHEN input_value = '(UTC-04:00) Atlantic Time (Canada)' THEN 16
  WHEN input_value = 'PRT' THEN 17
  WHEN input_value = '(UTC-04:00) Georgetown, La Paz, Manaus, San Juan' THEN 17
  WHEN input_value = '(UTC-04:00) Santiago' THEN 18
  WHEN input_value = 'CNT' THEN 19
  WHEN input_value = '(UTC-03:30) Newfoundland' THEN 19
  WHEN input_value = 'BRT-BRST' THEN 20
  WHEN input_value = '(UTC-03:00) Brasilia' THEN 20
  WHEN input_value = 'AGT' THEN 21
  WHEN input_value = '(UTC-03:00) Cayenne, Fortaleza' THEN 21
  WHEN input_value = '(UTC-03:00) Greenland' THEN 22
  WHEN input_value = '(UTC-02:00) Mid-Atlantic' THEN 23
  WHEN input_value = 'AZOT' THEN 24
  WHEN input_value = '(UTC-01:00) Azores' THEN 24
  WHEN input_value = 'CVT' THEN 25
  WHEN input_value = '(UTC-01:00) Cabo Verde Is.' THEN 25
  WHEN input_value = 'GMT' THEN 26
  WHEN input_value = '(UTC) Monrovia, Reykjavik' THEN 26
  WHEN input_value = '(GMT) Edinburgh, Lisbon, London' THEN 27
  WHEN input_value = 'CET' THEN 28
  WHEN input_value = '(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna' THEN 28
  WHEN input_value = '(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague' THEN 29
  WHEN input_value = '(UTC+01:00) Brussels, Copenhagen, Madrid, Paris' THEN 30
  WHEN input_value = '(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb' THEN 31
  WHEN input_value = '(UTC+01:00) West Central Africa' THEN 32
  WHEN input_value = '(UTC+02:00) Athens, Bucharest' THEN 33
  WHEN input_value = '(UTC+02:00) E. Europe' THEN 34
  WHEN input_value = '(UTC+02:00) Cairo' THEN 35
  WHEN input_value = 'SAST' THEN 36
  WHEN input_value = '(UTC+02:00) Harare, Pretoria' THEN 36
  WHEN input_value = '(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius' THEN 37
  WHEN input_value = 'IsraelST' THEN 38
  WHEN input_value = '(UTC+02:00) Jerusalem' THEN 38
  WHEN input_value = 'EAT' THEN 39
  WHEN input_value = '(UTC+03:00) Baghdad' THEN 39
  WHEN input_value = '(UTC+03:00) Kuwait, Riyadh' THEN 40
  WHEN input_value = 'MSK' THEN 41
  WHEN input_value = '(UTC+03:00) Moscow, St. Petersburg, Volgograd (RTZ 2)' THEN 41
  WHEN input_value = '(UTC+03:00) Nairobi' THEN 42
  WHEN input_value = 'MET' THEN 43
  WHEN input_value = '(UTC+03:30) Tehran' THEN 43
  WHEN input_value = 'GST' THEN 44
  WHEN input_value = '(UTC+04:00) Abu Dhabi, Muscat' THEN 44
  WHEN input_value = 'NET' THEN 45
  WHEN input_value = '(UTC+04:00) Yerevan' THEN 45
  WHEN input_value = '(UTC+04:30) Kabul' THEN 46
  WHEN input_value = 'YEKT' THEN 47
  WHEN input_value = '(UTC+05:00) Ekaterinburg (RTZ 4)' THEN 47
  WHEN input_value = 'WAST' THEN 48
  WHEN input_value = '(UTC+05:00) Tashkent' THEN 48
  WHEN input_value = 'IST' THEN 49
  WHEN input_value = '(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi' THEN 49
  WHEN input_value = 'NPT' THEN 50
  WHEN input_value = '(UTC+05:45) Kathmandu' THEN 50
  WHEN input_value = 'NOVT' THEN 51
  WHEN input_value = '(UTC+07:00) Novosibirsk' THEN 51
  WHEN input_value = 'ALMT' THEN 52
  WHEN input_value = '(UTC+05:00) Astana' THEN 52
  WHEN input_value = '(UTC+05:30) Sri Jayawardenepura' THEN 53
  WHEN input_value = 'MMT' THEN 54
  WHEN input_value = '(UTC+06:30) Yangon (Rangoon)' THEN 54
  WHEN input_value = 'UTC+7' THEN 55
  WHEN input_value = '(UTC+07:00) Bangkok, Hanoi, Jakarta' THEN 55
  WHEN input_value = 'KRAT' THEN 56
  WHEN input_value = '(UTC+07:00) Krasnoyarsk (RTZ 6)' THEN 56
  WHEN input_value = 'CTT' THEN 57
  WHEN input_value = '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi' THEN 57
  WHEN input_value = 'IRKT' THEN 58
  WHEN input_value = '(UTC+08:00) Irkutsk (RTZ 7)' THEN 58
  WHEN input_value = 'MYT' THEN 59
  WHEN input_value = '(UTC+08:00) Kuala Lumpur, Singapore' THEN 59
  WHEN input_value = 'AWST' THEN 60
  WHEN input_value = '(UTC+08:00) Perth' THEN 60
  WHEN input_value = '(UTC+08:00) Taipei' THEN 61
  WHEN input_value = 'JST' THEN 62
  WHEN input_value = '(UTC+09:00) Osaka, Sapporo, Tokyo' THEN 62
  WHEN input_value = 'KST' THEN 63
  WHEN input_value = '(UTC+09:00) Seoul' THEN 63
  WHEN input_value = 'YAKT' THEN 64
  WHEN input_value = '(UTC+09:00) Yakutsk (RTZ 8)' THEN 64
  WHEN input_value = 'ACST' THEN 65
  WHEN input_value = '(UTC+09:30) Adelaide' THEN 65
  WHEN input_value = 'ACT' THEN 66
  WHEN input_value = '(UTC+09:30) Darwin' THEN 66
  WHEN input_value = 'AEST' THEN 67
  WHEN input_value = '(UTC+10:00) Brisbane' THEN 67
  WHEN input_value = 'AET' THEN 68
    WHEN input_value = '(UTC+10:00) Canberra, Melbourne, Sydney' THEN 68
  WHEN input_value = 'ChST' THEN 69
  WHEN input_value = '(UTC+10:00) Guam, Port Moresby' THEN 69
  WHEN input_value = '(UTC+10:00) Hobart' THEN 70
  WHEN input_value = 'AET' THEN 71
  WHEN input_value = 'SST' THEN 72
  WHEN input_value = '(UTC+11:00) Solomon Is., New Caledonia' THEN 72
  WHEN input_value = 'NZST' THEN 73
  WHEN input_value = '(UTC+12:00) Auckland, Wellington' THEN 73
  WHEN input_value = 'NST' THEN 74
  WHEN input_value = '(UTC+12:00) Fiji' THEN 74
  WHEN input_value = '(UTC+13:00) Nuku\'alofa' THEN 75
  WHEN input_value = 'UTC-11' THEN 76
  WHEN input_value = '(UTC-11:00) Coordinated Universal Time-11' THEN 76
  WHEN input_value = '(UTC-08:00) Baja California' THEN 77
  WHEN input_value = '(UTC-07:00) Chihuahua, La Paz, Mazatlan' THEN 78
  WHEN input_value = 'CDT' THEN 79
  WHEN input_value = '(UTC-06:00) Guadalajara, Mexico City, Monterrey' THEN 79
  WHEN input_value = 'VET' THEN 80
  WHEN input_value = '(UTC-04:00) Caracas' THEN 80
  WHEN input_value = 'PYT' THEN 81
  WHEN input_value = '(UTC-04:00) Asuncion' THEN 81
  WHEN input_value = 'AMT' THEN 82
  WHEN input_value = '(UTC-04:00) Cuiaba' THEN 82
  WHEN input_value = 'ART' THEN 83
  WHEN input_value = '(UTC-03:00) Buenos Aires' THEN 83
  WHEN input_value = 'UYT' THEN 84
  WHEN input_value = '(UTC-03:00) Montevideo' THEN 84
  WHEN input_value = 'UTC-02' THEN 85
  WHEN input_value = '(UTC-02:00) Coordinated Universal Time-02' THEN 85
  WHEN input_value = 'WET' THEN 86
  WHEN input_value = '(UTC+01:00) Casablanca' THEN 86
  WHEN input_value = 'UTC' THEN 87
  WHEN input_value = '(UTC) Coordinated Universal Time' THEN 87
  WHEN input_value = '(UTC+03:00) Amman' THEN 88
  WHEN input_value = 'EEST' THEN 89
  WHEN input_value = '(UTC+02:00) Beirut' THEN 89
  WHEN input_value = '(UTC+02:00) Damascus' THEN 90
  WHEN input_value = 'WAT' THEN 92
  WHEN input_value = '(UTC+02:00) Windhoek' THEN 92
  WHEN input_value = 'AZT' THEN 93
  WHEN input_value = '(UTC+04:00) Baku' THEN 93
  WHEN input_value = 'MUT' THEN 94
  WHEN input_value = '(UTC+04:00) Port Louis' THEN 94
  WHEN input_value = 'GET' THEN 95
  WHEN input_value = '(UTC+04:00) Tbilisi' THEN 95
  WHEN input_value = 'PKT' THEN 97
  WHEN input_value = '(UTC+05:00) Islamabad, Karachi' THEN 97
  WHEN input_value = 'BST' THEN 98
  WHEN input_value = '(UTC+06:00) Dhaka' THEN 98
  WHEN input_value = 'ULAT' THEN 100
  WHEN input_value = '(UTC+08:00) Ulaanbaatar' THEN 100
  WHEN input_value = 'UTC+12' THEN 101
  WHEN input_value = '(UTC+12:00) Coordinated Universal Time+12' THEN 101
  WHEN input_value = 'PETT' THEN 102
  WHEN input_value = '(UTC+12:00) Petropavlovsk-Kamchatsky' THEN 102
  WHEN input_value = 'BRT' THEN 103
  WHEN input_value = '(UTC-03:00) Salvador' THEN 103
  WHEN input_value = '(UTC+03:00) Istanbul' THEN 104
  WHEN input_value = '(UTC+02:00) Kaliningrad (RTZ 1)' THEN 105
  WHEN input_value = 'VLAT' THEN 106
  WHEN input_value = '(UTC+10:00) Vladivostok, Magadan (RTZ 9)' THEN 106
  WHEN input_value = 'SAMT' THEN 107
  WHEN input_value = '(UTC+04:00) Izhevsk, Samara (RTZ 3)' THEN 107
  WHEN input_value = 'SRET' THEN 108
  WHEN input_value = '(UTC+11:00) Chokurdakh (RTZ 10)' THEN 108
  WHEN input_value = 'AST' THEN 109
  WHEN input_value = '(UTC+08:45) Eucla' THEN 109
  WHEN input_value = '(UTC+01:00) Lagos, Nigeria' THEN 110
  WHEN input_value = '(UTC+00:00) Dublin' THEN 111
  WHEN input_value = 'SST' THEN 112
  WHEN input_value = '(UTC-11:00) American Samoa, Midway' THEN 112
  WHEN input_value = 'OMST' THEN 113
  WHEN input_value = '(UTC+06:00) Omsk' THEN 113
  ELSE 9 END"
    MERGE (st)-[:MAPS_TO]-> (csod)
    MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Display Times in TimeZone of User", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Boolean", csod.char_length = "", csod.default_value = "1", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "ClassName", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Part name", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "500", csod.default_value = "Historical Data", csod.accepted_values = ""
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "Location", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Part Location", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "Instructor", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Part Instructor*", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "128", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Session Status", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Approved, Cancelled, Completed"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Cancellation Reason", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Other, Low Enrollment, Timeline Shift, Senior Management Choice, Trainer Unavailable, Inclement Weather, Systems Unavailable"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Cancellation Comment", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "300", csod.default_value = "", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Available Languages", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "Provider", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Vendor/Provider", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "100", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Registration Deadline", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "0", csod.max_value = "26000", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Registration Deadline - Before/After", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "", csod.default_value = "USE EVENT SETTING", csod.accepted_values = "Before, After"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "Waitlist", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Allow waitlist for sessions", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Boolean", csod.char_length = "", csod.default_value = "USE EVENT SETTING", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Allow Auto-Management of Waitlist‡", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "", csod.default_value = "USE EVENT SETTING", csod.accepted_values = "Time based, First come first served, Off"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: " Auto-Register User upon Granting Waitlist‡", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Boolean", csod.char_length = "", csod.default_value = "USE EVENT SETTING", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "Minimum", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Minimum Users", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "0", csod.max_value = "9999", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "Maximum", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Maximum Users", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "0", csod.max_value = "9999", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "EstimatedCredits", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Credits", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Float", csod.min_value = "0", csod.max_value = "999.99", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Attendance Parts", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "0", csod.default_value = "1", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Emails", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Enum", csod.char_length = "", csod.default_value = "No Email", csod.accepted_values = "System Default, No Email, Event Setting"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Currency Code", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "3", csod.default_value = "1", csod.accepted_values = "", csod.transformation = "CASE WHEN input_value = 'USD' THEN 1 WHEN input_value = 'United States Dollar' THEN 1 WHEN input_value = 'GBP' THEN 2 WHEN input_value = 'United Kingdoms Pound' THEN 2 WHEN input_value = 'Euro' THEN 3 WHEN input_value = 'EUR' THEN 3 WHEN input_value = 'Mexico Peso' THEN 17 WHEN input_value = 'MXN' THEN 17 WHEN input_value = 'TND' THEN 78 WHEN input_value = 'Tunisian Dinar' THEN 78 ELSE 1 END"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Price Per Session", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "0", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "No-show Penalty – Monetary", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "0", csod.max_value = "9999999999", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "No-show Penalty – Training Units", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "0", csod.max_value = "999999999", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Restrict Withdraw from Session", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Boolean", csod.char_length = "", csod.default_value = "USE EVENT SETTING", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Refund Type", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "", csod.default_value = "USE EVENT SETTING", csod.accepted_values = "Monetary, Training unit"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Refund Percentage‡", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "0", csod.max_value = "100", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Refund Amount‡", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Float", csod.min_value = "0", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Refund Number of Days prior to start‡", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "0", csod.max_value = "9999", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Withdrawal Penalty Percentage", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Float", csod.min_value = "0", csod.max_value = "100", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Withdrawal Penalty Amount", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Float", csod.min_value = "0", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Penalty Number of Days prior to start", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "0", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Created/Modified By", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "128", csod.default_value = "User performing the load", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Do not allow exception request", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Boolean", csod.char_length = "", csod.default_value = "false", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Copy Availability from its Event", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Boolean", csod.char_length = "", csod.default_value = "false", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Availability to All Users", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Availability to Specific Users", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Availability to OU‡", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Availability OU Type", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Register Upon Approval", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Boolean", csod.char_length = "", csod.default_value = "false", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Pre-Approved", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Boolean", csod.char_length = "", csod.default_value = "false", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Includes Subordinates", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Boolean", csod.char_length = "", csod.default_value = "false", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (st:SumTotalField {name: "Contact", file: "Activity_Sessions"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Training Contact", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "128", csod.default_value = "", csod.accepted_values = ""
MERGE (st) -[:MAPS_TO] -> (csod)
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Training Units", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Decimal", csod.char_length = "", csod.default_value = "USE EVENT SETTING", csod.accepted_values = "Allow conversion rate by monetary value, Disassociate pricing, Do not allow payment"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Default Training Unit Price", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Float", csod.min_value = "0", csod.max_value = "999999999", csod.default_value = "USE EVENT SETTING", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Required Training Approvals", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "0", csod.max_value = "999", csod.default_value = "0", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Required Completion Approvals", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Integer", csod.min_value = "0", csod.max_value = "999", csod.default_value = "0", csod.accepted_values = ""
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Sessions"})
MERGE (csod:CSODField {name: "Request Form", file: "Activity_Sessions"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = "Leadership 101 T-Shirts, Travel Request Form, Preliminary Survey, Confirmation,マネージャー申請,セッション申込フォーム"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "ActivityCode", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Test ID*", file: "Activity_Test" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "ActivityName", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Test Title*", file: "Activity_Test" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "Provider", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Vendor/Provider*", file: "Activity_Test" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Provider Type*", file: "Activity_Test" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "ONLINE,ILT", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "Active", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Active", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Default Language", file: "Activity_Test"})
SET csod.mandatory = "Optional", 
    csod.field_type = "Integer",
    csod.char_length = "",
    csod.default_value = "1",
    csod.accepted_values = "",
    csod.output_document = "Activity_Test",
    csod.transformation = "CASE WHEN input_value = 'en-US' THEN 1 WHEN input_value = 'English (US)' THEN 1 WHEN input_value = 'en-GB' THEN 2 WHEN input_value = 'English (UK)' THEN 2 WHEN input_value = 'fr-FR' THEN 13 WHEN input_value = 'French (France)' THEN 13 WHEN input_value = 'es-MX' THEN 14 WHEN input_value = 'Spanish (Latin America)' THEN 14 ELSE 1 END"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);


MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "ActivityDescription", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Test Description", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "5000", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Keywords", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Available Languages", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "EstimatedDuration", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Training Hours", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Time", csod.char_length = "", csod.default_value = "0000:00:00", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "EstimatedCredits", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Credits", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Float", csod.min_value = "0", csod.max_value = "999.99", csod.default_value = "0", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Created/Modified By", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "User performing the load", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "Topic", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Subject IDs", file: "Activity_Test"})
SET csod.mandatory = "Optional", 
    csod.field_type = "subjectType",              
    csod.char_length = "",                    
    csod.default_value = "",             
    csod.accepted_values = "",
    csod.output_document = "Activity_Test",
    csod.transformation = "CASE WHEN input_value = 'Production Preparation Process' THEN 1000 WHEN input_value = 'Programming Languages' THEN 1001 WHEN input_value = 'QC Circle' THEN 1002 WHEN input_value = 'Quality' THEN 1003 WHEN input_value = 'Quick Changeover' THEN 1004 WHEN input_value = 'Reference' THEN 1005 WHEN input_value = 'Safety' THEN 1006 WHEN input_value = 'SCP Resources' THEN 1007 WHEN input_value = 'Secure Programming' THEN 1008 WHEN input_value = 'Six Sigma' THEN 1009 WHEN input_value = 'Skillsoft' THEN 1010 WHEN input_value = 'Productivity Tools forDevOps Automated Testers' THEN 1011 WHEN input_value = 'Productivity Tools for SecOps Engineers' THEN 1012 WHEN input_value = 'Business & Leadership for Apprentice Programmers' THEN 1013 WHEN input_value = 'Productivity Tools for Apprentice Programmers' THEN 1014 WHEN input_value = 'Productivity Tools for Cloud Architects' THEN 1015 WHEN input_value = 'Productivity Tools for CloudOps Engineers' THEN 1016 WHEN input_value = 'Productivity Tools for Business Analyst to Data Analysts' THEN 1017 WHEN input_value = 'Efficiency & Productivity in the New Normal' THEN 1018 WHEN input_value = 'Managing & Leading through Unexpected Disruption' THEN 1019 WHEN input_value = 'Productivity Tools for Data Visualization' THEN 1020 WHEN input_value = 'Business & Leadership for Data Analysis with R' THEN 1021 WHEN input_value = 'Productivity Tools for Data Analysis with R' THEN 1022 WHEN input_value = 'Productivity Tools with Agile for Software Development' THEN 1023 WHEN input_value = 'Productivity Tools for Web App Vulnerability Analyst' THEN 1024 WHEN input_value = 'Productivity Tools for 5G Technologies and Practices' THEN 1025 WHEN input_value = 'Business & Leadership for Enriched Web Development with Angular 11' THEN 1026 WHEN input_value = 'Business & Leadership for Pythonista' THEN 1027 WHEN input_value = 'Business & Leadership for Javanista to Java Master' THEN 1028 WHEN input_value = 'Business & Leadership for Developer Fundamentals' THEN 1029 WHEN input_value = 'Business & Leadership for Programming Python in Action' THEN 1030 WHEN input_value = 'Business & Leadership for Software Product Management' THEN 1031 WHEN input_value = 'Productivity Tools for senior Software Project Managers' THEN 1032 WHEN input_value = 'Productivity Tools for Security Architects' THEN 1033 WHEN input_value = 'Business & Leadership for Enterprise Development to Full Stack Developers' THEN 1034 WHEN input_value = 'Productivity Tools for Full Stack Developer' THEN 1035 WHEN input_value = 'Productivity Tools for DevOps Engineer' THEN 1036 WHEN input_value = 'Skype 2016' THEN 1037 WHEN input_value = 'Standard Work' THEN 1038 WHEN input_value = 'Standard Work - Leader' THEN 1039 WHEN input_value = 'T1' THEN 1040 WHEN input_value = 'TACTIS' THEN 1041 WHEN input_value = 'Total Productive Maintenance' THEN 1042 WHEN input_value = 'TQM (Total Quality Management)' THEN 1043 WHEN input_value = 'TWI for Facilitators' THEN 1044 WHEN input_value = 'TWI for Learners' THEN 1045 WHEN input_value = 'US Federal Government Compliance (US Edition)' THEN 1046 WHEN input_value = 'Value Stream' THEN 1047 WHEN input_value = 'Visual Management' THEN 1048 WHEN input_value = 'Web Development' THEN 1049 WHEN input_value = 'Workplace Compliance Essentials (Brazilian Portuguese Edition)' THEN 1050 WHEN input_value = 'Workplace Compliance Essentials (UK English Edition)' THEN 1051 WHEN input_value = 'Workplace Compliance Essentials (Canadian Edition)' THEN 1052 WHEN input_value = 'Workplace Compliance Essentials (Castilian Spanish Edition)' THEN 1053 WHEN input_value = 'Workplace Compliance Essentials (Turkish Edition)' THEN 1054 WHEN input_value = 'Workplace Compliance Essentials (Australian Edition)' THEN 1055 WHEN input_value = 'Workplace Compliance Essentials (Thai Edition)' THEN 1056 WHEN input_value = 'Workplace Compliance Essentials (Swedish Edition)' THEN 1057 WHEN input_value = 'Workplace Compliance Essentials (Bahasa Malay Edition)' THEN 1058 WHEN input_value = 'Workplace Compliance Essentials (Vietnamese Edition)' THEN 1059 WHEN input_value = 'Workplace Compliance Essentials (Dutch Edition)' THEN 1060 WHEN input_value = 'Workplace Compliance Essentials (Norwegian Edition)' THEN 1061 WHEN input_value = 'Workplace Compliance Essentials (New Zealand Edition)' THEN 1062 WHEN input_value = 'Workplace Compliance Essentials (French Edition)' THEN 1063 WHEN input_value = 'Workplace Compliance Essentials (German Edition)' THEN 1064 WHEN input_value = 'Workplace Compliance Essentials (Italian Edition)' THEN 1065 WHEN input_value = 'Workplace Compliance Essentials (Japanese Edition)' THEN 1066 WHEN input_value = 'XML' THEN 1067 WHEN input_value = 'Communicating Tactfully and Diplomatically' THEN 1068 WHEN input_value = 'Leading Virtual Teams' THEN 1069 WHEN input_value = 'Thinking Strategically and Managing Risk' THEN 1070 WHEN input_value = 'Virtual Teams' THEN 1071 WHEN input_value = 'Communication' THEN 1072 WHEN input_value = 'Microsoft 365: Teams' THEN 1073 WHEN input_value = 'EHS Impacts (US Edition)' THEN 1074 WHEN input_value = 'Environmental (Latin American Spanish Edition)' THEN 1075 WHEN input_value = 'Environmental (US Edition)' THEN 1076 WHEN input_value = 'Environmental (Canadian Edition)' THEN 1077 WHEN input_value = 'Environmental (Canadian French Edition)' THEN 1078 WHEN input_value = 'Harassment (Australian Edition)' THEN 1079 WHEN input_value = 'Harassment (Bahasa Indonesian Edition)' THEN 1080 WHEN input_value = 'Harassment (Bahasa Malay Edition)' THEN 1081 WHEN input_value = 'Harassment (Brazilian Portuguese Edition)' THEN 1082 WHEN input_value = 'Harassment (Canadian Edition)' THEN 1083 WHEN input_value = 'Harassment (Czech Edition)' THEN 1084 WHEN input_value = 'Harassment (French Edition)' THEN 1085 WHEN input_value = 'Harassment (German Edition)' THEN 1086 WHEN input_value = 'Harassment (Hindi Edition)' THEN 1087 WHEN input_value = 'Harassment (Indian Edition)' THEN 1088 WHEN input_value = 'Harassment (Italian Edition)' THEN 1089 WHEN input_value = 'Harassment (Japanese Edition)' THEN 1090 WHEN input_value = 'Harassment (Korean Edition)' THEN 1091 WHEN input_value = 'Harassment (Latin American Spanish Edition)' THEN 1092 WHEN input_value = 'Harassment (New Zealand Edition)' THEN 1093 WHEN input_value = 'Harassment (Polish Edition)' THEN 1094 WHEN input_value = 'Harassment (Thai Edition)' THEN 1095 WHEN input_value = 'Harassment (Vietnamese Edition)' THEN 1096 WHEN input_value = 'Health, Safety and Security (Canadian Edition)' THEN 1097 WHEN input_value = 'Health, Safety and Security (Canadian French Edition)' THEN 1098 WHEN input_value = 'Health, Safety and Security (Castilian Spanish Edition)' THEN 1099 WHEN input_value = 'Health, Safety and Security (Dutch Edition)' THEN 1100 WHEN input_value = 'Health, Safety and Security (Korean Edition)' THEN 1101 WHEN input_value = 'Health, Safety and Security (Australian Edition)' THEN 1102 WHEN input_value = 'Health, Safety and Security (New Zealand Edition)' THEN 1103 WHEN input_value = 'Health, Safety and Security (Chinese Edition)' THEN 1104 WHEN input_value = 'Health, Safety and Security (German Edition)' THEN 1105 WHEN input_value = 'Health, Safety and Security (Latin American Spanish Edition)' THEN 1106 WHEN input_value = 'Health, Safety and Security (US Edition)' THEN 1107 WHEN input_value = 'Health, Safety and Security (UK Edition)' THEN 1108 WHEN input_value = 'Health, Safety and Security (Portuguese Brazilian Edition)' THEN 1109 WHEN input_value = 'Health, Safety and Security (French Edition)' THEN 1110 WHEN input_value = 'Health, Safety and Security (ltalian Edition)' THEN 1111 WHEN input_value = 'Legal Impacts (French Edition)' THEN 1112 WHEN input_value = 'Legal Impacts (Latin American Spanish Edition)' THEN 1113 WHEN input_value = 'Legal Impacts (UK English Edition)' THEN 1114 WHEN input_value = 'Meetings' THEN 1115 WHEN input_value = 'Navigating through Organizational Change' THEN 1116 WHEN input_value = 'Productivity Tools for Advanced Scrum Masters' THEN 1117 WHEN input_value = 'Productivity Tools for CloudOps Security Architect' THEN 1118 WHEN input_value = 'Business & Leadership for Journeyman Developers' THEN 1119 WHEN input_value = 'Productivity Tools for Journeyman Developers' THEN 1120 WHEN input_value = 'Business & Leadership for AI Architects' THEN 1121 WHEN input_value = 'Productivity Tools for AI Architects' THEN 1122 WHEN input_value = 'Business & Leadership for API Developers' THEN 1123 WHEN input_value = 'Productivity Tools for API Developers' THEN 1124 WHEN input_value = 'Business & Leadership for Software Architects' THEN 1125 WHEN input_value = 'Productivity Tools for Software Architects' THEN 1126 WHEN input_value = 'Business & Leadership for Site Reliability Engineers' THEN 1127 WHEN input_value = 'Productivity Tools for Site Reliability Engineers' THEN 1128 WHEN input_value = 'Business & Leadership for Python Master' THEN 1129 WHEN input_value = 'Productivity Tools for Python Master' THEN 1130 WHEN input_value = 'Productivity Tools for Decision-makers and Leaders' THEN 1131 WHEN input_value = 'Business & Leadership with Serverless Deployments for Developers' THEN 1132 WHEN input_value = 'Productivity Tools with Serverless Deployments for Developers' THEN 1133 WHEN input_value = 'Business & Leadership for Javanista' THEN 1134 WHEN input_value = 'Productivity Tools for Javanista' THEN 1135 WHEN input_value = 'Business & Leadership for Go Programming Essentials' THEN 1136 WHEN input_value = 'Business & Leadership for Engineering Lead' THEN 1137 WHEN input_value = 'Business & Leadership for AI and ML for Decision-makers' THEN 1138 WHEN input_value = 'Productivity Tools for Secure Agile Programmers' THEN 1139 WHEN input_value = 'Transportation (Latin American Spanish Edition)' THEN 1140 WHEN input_value = 'Transportation (US Edition)' THEN 1141 WHEN input_value = 'Transportation (Italian Edition)' THEN 1142 WHEN input_value = 'Transportation (Canadian Edition)' THEN 1143 WHEN input_value = 'Transportation (Canadian French Edition)' THEN 1144 WHEN input_value = 'Transportation (UK Edition)' THEN 1145 WHEN input_value = 'Transportation (Chinese Edition)' THEN 1146 WHEN input_value = 'Transportation (Portuguese Brazilian Edition)' THEN 1147 WHEN input_value = 'Transportation (German Edition)' THEN 1148 WHEN input_value = 'Transportation (Castilian Spanish Edition)' THEN 1149 WHEN input_value = 'Transportation (Korean Edition)' THEN 1150 WHEN input_value = 'Transportation (Dutch Edition)' THEN 1151 WHEN input_value = 'Transportation (French Edition)' THEN 1152 WHEN input_value = 'Workplace Compliance Essentials (Canadian French Edition)' THEN 1153 WHEN input_value = 'Workplace Compliance Essentials (Russian Edition)' THEN 1154 WHEN input_value = 'Workplace Compliance Essentials (US Edition)' THEN 1155 WHEN input_value = 'Workplace Compliance Essentials (Korean Edition)' THEN 1156 WHEN input_value = 'Workplace Compliance Essentials (Czech Edition)' THEN 1157 WHEN input_value = 'Workplace Compliance Essentials (Chinese Edition)' THEN 1158 WHEN input_value = 'Workplace Compliance Essentials (Hindi Edition)' THEN 1159 WHEN input_value = 'Workplace Compliance Essentials (Bahasa Indonesian Edition)' THEN 1160 WHEN input_value = 'Workplace Compliance Essentials (Hungarian Edition)' THEN 1161 WHEN input_value = 'Workplace Compliance Essentials (Romanian Edition)' THEN 1162 WHEN input_value = 'Workplace Compliance Essentials (Finnish Edition)' THEN 1163 WHEN input_value = 'Workplace Compliance Essentials (Danish Edition)' THEN 1164 WHEN input_value = 'Workplace Compliance Essentials (Chinese Traditional Edition)' THEN 1165 WHEN input_value = 'Workplace Compliance Essentials (Latin American Spanish Edition)' THEN 1166 WHEN input_value = 'Workplace Compliance Essentials (Polish Edition)' THEN 1167 WHEN input_value = 'Food Allergies And Intolerance' THEN 1168 WHEN input_value = 'Industry Specific' THEN 1169 WHEN input_value = 'Cal/OSHA Latin American Spanish' THEN 1170 WHEN input_value = 'Technology' THEN 1171 WHEN input_value = 'Disability Discrimination Awareness' THEN 1172 WHEN input_value = 'Cisco WebEx Teams' THEN 1173 WHEN input_value = 'Equality and Diversity Awareness' THEN 1174 WHEN input_value = 'Cisco WebEx for Web' THEN 1175 WHEN input_value = 'Portuguese' THEN 1176 WHEN input_value = 'French Canadian' THEN 1177 WHEN input_value = 'Japanese' THEN 1178 WHEN input_value = 'Cal/OSHA' THEN 1179 WHEN input_value = 'Coordinators' THEN 1180 WHEN input_value = 'Managers' THEN 1181 WHEN input_value = 'Skype for Business 2016 (No Assessments)' THEN 1182 WHEN input_value = 'First Aid Awareness' THEN 1183 WHEN input_value = 'Fire Safety Awareness' THEN 1184 WHEN input_value = 'Join.me for Windows (No Assessments)' THEN 1185 WHEN input_value = 'LogMeIn GoToMeeting (No Assessments)' THEN 1186 WHEN input_value = 'Presentation Skills' THEN 1187 WHEN input_value = 'Project Sheets' THEN 1188 WHEN input_value = '5S' THEN 1189 WHEN input_value = 'Label Templates' THEN 1190 WHEN input_value = 'Final Presentation' THEN 1191 WHEN input_value = 'Kaizen' THEN 1192 WHEN input_value = 'Engineering' THEN 1193 WHEN input_value = 'Lifelong Learn' THEN 1194 WHEN input_value = 'Cloud Services' THEN 1195 WHEN input_value = 'Business Operations' THEN 1196 WHEN input_value = 'Welcome to Percipio' THEN 1197 WHEN input_value = 'Aspire Journeys for Leadership' THEN 1198 WHEN input_value = 'Cybersecurity Career Journey' THEN 1199 WHEN input_value = 'Skillsoft Live Events' THEN 1200 WHEN input_value = 'Sample Content' THEN 1201 WHEN input_value = 'Customer Service' THEN 1202 WHEN input_value = 'Browse Partner Content' THEN 1203 WHEN input_value = 'Aspire Journeys' THEN 1204 WHEN input_value = 'Infrastructure & Operations' THEN 1205 WHEN input_value = 'Sales & Marketing' THEN 1206 WHEN input_value = 'Skillsoft Bootcamps' THEN 1207 WHEN input_value = 'Digital Transformation' THEN 1208 WHEN input_value = 'Professional Improvement' THEN 1209 WHEN input_value = 'Diversity, Equity, & Inclusion' THEN 1210 WHEN input_value = 'NICE Framework' THEN 1211 WHEN input_value = 'Certifications' THEN 1212 WHEN input_value = 'Skillsoft Leadercamps' THEN 1213 WHEN input_value = 'Software Craft' THEN 1214 WHEN input_value = 'Cloud Career Journey' THEN 1215 WHEN input_value = 'Codecademy' THEN 1216 WHEN input_value = 'Project Management' THEN 1217 WHEN input_value = 'Mainframe' THEN 1218 WHEN input_value = 'Perspectives' THEN 1219 WHEN input_value = 'Agile Career Journey' THEN 1220 WHEN input_value = 'Product Management' THEN 1221 WHEN input_value = 'Data' THEN 1222 WHEN input_value = 'Corporate Marketing' THEN 1223 WHEN input_value = 'Customer Success' THEN 1224 WHEN input_value = 'Product Marketing' THEN 1225 WHEN input_value = 'Corporate Communications' THEN 1226 WHEN input_value = 'Selling Skills' THEN 1227 WHEN input_value = 'Internet of Things' THEN 1228 WHEN input_value = 'Cloud Basics' THEN 1229 WHEN input_value = 'Cloud Development' THEN 1230 WHEN input_value = 'Cloud Platforms' THEN 1231 WHEN input_value = 'NEW - Azure' THEN 1232 WHEN input_value = 'Pursue an Agile Certification' THEN 1233 WHEN input_value = 'Pursue an Agile Job Role' THEN 1234 WHEN input_value = 'Pursue an Azure Cloud Job Role' THEN 1235 WHEN input_value = 'Pursue an AWS Cloud Job Role' THEN 1236 WHEN input_value = 'Pursue a GCP Cloud Job Role' THEN 1237 WHEN input_value = 'Pursue a Foundation in Cloud' THEN 1238 WHEN input_value = 'Pursue a Cloud Skill' THEN 1239 WHEN input_value = 'Pursue a Cybersecurity Skill' THEN 1240 WHEN input_value = 'Database Development' THEN 1241 WHEN input_value = 'Data Visualization & Reporting' THEN 1242 WHEN input_value = 'Big Data' THEN 1243 WHEN input_value = 'Data Architectures' THEN 1244 WHEN input_value = 'Data Core Concepts' THEN 1245 WHEN input_value = 'Data Analytics' THEN 1246 WHEN input_value = 'Data Science' THEN 1247 WHEN input_value = 'Data Platforms' THEN 1248 WHEN input_value = 'Business Intelligence' THEN 1249 WHEN input_value = 'Data Security' THEN 1250 WHEN input_value = 'Diversity, Equity & Inclusion' THEN 1251 WHEN input_value = 'DevOps IT' THEN 1252 WHEN input_value = 'Client & Server Administration' THEN 1253 WHEN input_value = 'IT Services' THEN 1254 WHEN input_value = 'Network Operations' THEN 1255 WHEN input_value = 'IT Trends' THEN 1256 WHEN input_value = '2020 Mainstage Keynotes' THEN 1257 WHEN input_value = '2020 Product Sessions' THEN 1258 WHEN input_value = '2020 Case Studies' THEN 1259 WHEN input_value = 'Leadership & Business' THEN 1260 WHEN input_value = 'NICE Work Roles' THEN 1261 WHEN input_value = 'Product Management Skills' THEN 1262 WHEN input_value = 'Software Developer Bootcamps' THEN 1263 WHEN input_value = 'Virtual Training' THEN 1264 WHEN input_value = 'Security Bootcamps' THEN 1265 WHEN input_value = 'Project Management Bootcamps' THEN 1266 WHEN input_value = 'Cloud Services Bootcamps' THEN 1267 WHEN input_value = 'Data Bootcamps' THEN 1268 WHEN input_value = 'In Pursuit of Re-engagement' THEN 1269 WHEN input_value = 'Leading HR' THEN 1270 WHEN input_value = 'Productivity & Wellness' THEN 1271 WHEN input_value = 'Art of Great Consulting' THEN 1272 WHEN input_value = 'Leading in the New Normal' THEN 1273 WHEN input_value = 'Artificial Intelligence' THEN 1274 WHEN input_value = 'Software' THEN 1275 WHEN input_value = 'Machine Learning' THEN 1276 WHEN input_value = 'Data Management' THEN 1277 WHEN input_value = 'Leadership Mindsets' THEN 1278 WHEN input_value = 'Leadership Transitions' THEN 1279 WHEN input_value = 'Espanol' THEN 1280 WHEN input_value = 'English' THEN 1281 WHEN input_value = 'Codecademy Languages' THEN 1282 WHEN input_value = 'Codecademy Subjects' THEN 1283 WHEN input_value = 'Finance' THEN 1284 WHEN input_value = 'Process Improvement' THEN 1285 WHEN input_value = 'Business Planning & Analysis' THEN 1286 WHEN input_value = 'Human Resources' THEN 1287 WHEN input_value = 'Banking' THEN 1288 WHEN input_value = 'Microsoft Office' THEN 1289 WHEN input_value = 'CompTIA' THEN 1290 WHEN input_value = 'Oracle' THEN 1291 WHEN input_value = 'VMware' THEN 1292 WHEN input_value = 'Isograd' THEN 1293 WHEN input_value = 'Cisco' THEN 1294 WHEN input_value = 'SAS' THEN 1295 WHEN input_value = 'Digital Marketing Institute' THEN 1296 WHEN input_value = 'Red Hat' THEN 1297 WHEN input_value = 'Kubernetes' THEN 1298 WHEN input_value = 'Microsoft' THEN 1299 WHEN input_value = 'Google' THEN 1300 WHEN input_value = '(ISC)2' THEN 1301 WHEN input_value = 'EC-Council' THEN 1302 WHEN input_value = 'AWS' THEN 1303 WHEN input_value = 'Virtual Work' THEN 1304 WHEN input_value = 'Digital Experiences' THEN 1305 WHEN input_value = 'Civil' THEN 1306 WHEN input_value = 'Energy' THEN 1307 WHEN input_value = 'Chemical' THEN 1308 WHEN input_value = 'Industrial' THEN 1309 WHEN input_value = 'Aerospace & Mechanical' THEN 1310 WHEN input_value = 'Electrical' THEN 1311 WHEN input_value = 'Test Channels' THEN 1312 WHEN input_value = 'Engineering Resources' THEN 1313 WHEN input_value = 'Personal Productivity' THEN 1314 WHEN input_value = 'Personal Accountability' THEN 1315 WHEN input_value = 'Well-Being' THEN 1316 WHEN input_value = 'Business Communication' THEN 1317 WHEN input_value = 'Self-Discovery' THEN 1318 WHEN input_value = 'Mainframe Security' THEN 1319 WHEN input_value = 'Mainframe Services' THEN 1320 WHEN input_value = 'Project Management Methods' THEN 1321 WHEN input_value = 'Live Events' THEN 1322 WHEN input_value = 'Emerging Tech' THEN 1323 WHEN input_value = 'Software Architectures' THEN 1324 WHEN input_value = 'Software Dev Practices' THEN 1325 WHEN input_value = 'Getting Started with Percipio' THEN 1326 WHEN input_value = 'Expert' THEN 1327 WHEN input_value = 'Associate (MTA)' THEN 1328 WHEN input_value = 'Microsoft 365 Certified Expert' THEN 1329 WHEN input_value = 'Microsoft Certified Associate' THEN 1330 WHEN input_value = 'Professional' THEN 1331 WHEN input_value = 'Entry' THEN 1332 WHEN input_value = 'Associate' THEN 1333 WHEN input_value = 'TOSA Desktop' THEN 1334 WHEN input_value = 'TOSA Digital' THEN 1335 WHEN input_value = 'Cloud Security' THEN 1336 WHEN input_value = 'Software Development' THEN 1337 WHEN input_value = 'Information Security' THEN 1338 WHEN input_value = 'Systems Security' THEN 1339 WHEN input_value = 'Cybersecurity' THEN 1340 WHEN input_value = 'Bloodborne Pathogens' THEN 1341 WHEN input_value = 'Excel' THEN 1342 WHEN input_value = 'Access' THEN 1343 WHEN input_value = 'TWI - Job Instruction' THEN 1344 WHEN input_value = 'Filehold' THEN 1345 WHEN input_value = 'Engineer Resources' THEN 1346 WHEN input_value = 'Security Skills' THEN 1347 WHEN input_value = 'Outlook' THEN 1348 WHEN input_value = 'Concur' THEN 1349 WHEN input_value = 'Teams' THEN 1350 WHEN input_value = 'TWI - Job Methods' THEN 1351 WHEN input_value = 'ADP' THEN 1352 WHEN input_value = 'Docusign' THEN 1353 WHEN input_value = 'TWI - Job Relations' THEN 1354 WHEN input_value = 'Word' THEN 1355 WHEN input_value = 'PowerPoint' THEN 1356 WHEN input_value = 'Infrastructure' THEN 1357 WHEN input_value = 'Data and Analytics' THEN 1358 WHEN input_value = 'Additional Professional' THEN 1359 WHEN input_value = 'Core' THEN 1360 WHEN input_value = 'VMware Certified Professional' THEN 1361 WHEN input_value = 'Data Analysis' THEN 1362 WHEN input_value = 'Digital Marketing Associate' THEN 1363 WHEN input_value = 'Google Workspace' THEN 1364 WHEN input_value = 'Specialty' THEN 1365 WHEN input_value = 'Architecting' THEN 1366 WHEN input_value = 'Operations' THEN 1367 WHEN input_value = 'Cloud Practitioner' THEN 1368 WHEN input_value = 'Developing' THEN 1369 WHEN input_value = 'Base Programmer' THEN 1370 WHEN input_value = 'Administrator' THEN 1371 WHEN input_value = 'Kubernetes Administrator' THEN 1372 WHEN input_value = 'Spreadsheet Software' THEN 1373 WHEN input_value = 'Microsoft Office/Office 365' THEN 1374 WHEN input_value = 'Email' THEN 1375 WHEN input_value = 'Presentation Software' THEN 1376 WHEN input_value = 'Microsoft Outlook' THEN 1377 WHEN input_value = 'Microsoft Excel' THEN 1378 WHEN input_value = 'Microsoft Powerpoint' THEN 1379 WHEN input_value = 'Google Hangouts Meet' THEN 1380 WHEN input_value = 'Google Hangouts Meet (No Assessments)' THEN 1381 WHEN input_value = 'Software Applications' THEN 532 WHEN input_value = 'Policy and Compliance' THEN 533 WHEN input_value = 'Cornerstone Product Training' THEN 534 WHEN input_value = 'Management Skills' THEN 535 WHEN input_value = 'Communication & Teamwork' THEN 536 WHEN input_value = 'Technical Skills' THEN 537 WHEN input_value = 'Business Skills' THEN 538 WHEN input_value = 'Compliance' THEN 539 WHEN input_value = 'IT Skills' THEN 540 WHEN input_value = 'Certification' THEN 541 WHEN input_value = 'Collections' THEN 542 WHEN input_value = 'Skillsoft Aspire' THEN 543 WHEN input_value = 'Productivity & Collaboration Tools' THEN 544 WHEN input_value = 'Business Continuity' THEN 545 WHEN input_value = 'Skillsoft Aspire L&B' THEN 546 WHEN input_value = 'Change' THEN 547 WHEN input_value = 'Communications Skills' THEN 548 WHEN input_value = 'Finance and Accounting' THEN 549 WHEN input_value = 'Human Resources' THEN 550 WHEN input_value = 'Industry Overviews' THEN 551 WHEN input_value = 'Leadership' THEN 552 WHEN input_value = 'Management' THEN 553 WHEN input_value = 'Operations Management' THEN 554 WHEN input_value = 'Professional Effectiveness' THEN 555 WHEN input_value = 'Project Management' THEN 556 WHEN input_value = 'Strategy and Innovation' THEN 557 WHEN input_value = 'Business Skills' THEN 558 WHEN input_value = 'Business Skills' THEN 559 WHEN input_value = 'Business Skills' THEN 560 WHEN input_value = 'Business Skills' THEN 561 WHEN input_value = 'Business Skills' THEN 562 WHEN input_value = 'Sumtotal344' THEN 563 WHEN input_value = 'ILT Events' THEN 565 WHEN input_value = 'SumTotal2' THEN 566 WHEN input_value = 'SumTotal' THEN 567 WHEN input_value = 'Materials' THEN 568 WHEN input_value = 'Videos' THEN 569 WHEN input_value = 'Curriculum' THEN 570 WHEN input_value = 'Curriculums' THEN 571 WHEN input_value = 'ILT Events' THEN 572 WHEN input_value = 'Scorm' THEN 573 WHEN input_value = 'Finance' THEN 574 WHEN input_value = 'SIAM TEAM' THEN 575 WHEN input_value = 'New Employee Training' THEN 576 WHEN input_value = 'Exercise' THEN 577 WHEN input_value = 'Leadership Development' THEN 578 WHEN input_value = 'Medicine' THEN 579 WHEN input_value = 'Teaching' THEN 580 WHEN input_value = 'Course Details' THEN 581 WHEN input_value = 'Pravir test' THEN 582 WHEN input_value = 'Tests' THEN 583 WHEN input_value = 'Online Courses' THEN 584 WHEN input_value = 'Topics' THEN 585 WHEN input_value = 'PESV2_topic' THEN 586 WHEN input_value = '1234' THEN 587 WHEN input_value = '208_Cloud Services' THEN 588 WHEN input_value = '210_Customer Service' THEN 589 WHEN input_value = '211_Developer' THEN 590 WHEN input_value = '212_Digital Transformation' THEN 591 WHEN input_value = '213_IT Operations' THEN 592 WHEN input_value = '215_Leadership Development Program' THEN 593 WHEN input_value = '216_Management' THEN 594 WHEN input_value = '58_Certifications' THEN 595 WHEN input_value = 'Aspire Journeys' THEN 596 WHEN input_value = 'Business Operations' THEN 597 WHEN input_value = '66_Cloud Services' THEN 598 WHEN input_value = '68_Customer Service' THEN 599 WHEN input_value = 'Data' THEN 600 WHEN input_value = '70_Developer' THEN 601 WHEN input_value = '71_Digital Transformation' THEN 602 WHEN input_value = '74_IT Operations' THEN 603 WHEN input_value = '82_Management' THEN 604 WHEN input_value = 'Productivity & Collaboration Tools' THEN 605 WHEN input_value = 'Professional Improvement' THEN 606 WHEN input_value = '89_Project Management' THEN 607 WHEN input_value = 'Sales & Marketing' THEN 608 WHEN input_value = '121_Customer Service: Core Concepts & Methods' THEN 609 WHEN input_value = 'Data Visualization & Reporting' THEN 610 WHEN input_value = 'Big Data' THEN 611 WHEN input_value = 'Data Security' THEN 612 WHEN input_value = 'Data Analytics' THEN 613 WHEN input_value = 'Data Core Concepts' THEN 614 WHEN input_value = 'Database Development' THEN 615 WHEN input_value = 'Data Platforms' THEN 616 WHEN input_value = 'Business Intelligence' THEN 617 WHEN input_value = '130_Data Science' THEN 618 WHEN input_value = '141_Data Science' THEN 619 WHEN input_value = '146_Digital Marketing & Communications' THEN 620 WHEN input_value = '151_Information Security' THEN 621 WHEN input_value = '152_IT Services' THEN 622 WHEN input_value = '153_DevOps' THEN 623 WHEN input_value = 'IT Trends' THEN 624 WHEN input_value = '155_Network Operations' THEN 625 WHEN input_value = '156_Client & Server Administration' THEN 626 WHEN input_value = 'Design' THEN 627 WHEN input_value = 'Productivity Tools' THEN 628 WHEN input_value = 'Collaboration' THEN 629 WHEN input_value = 'Browsers & Operating Systems' THEN 630 WHEN input_value = '186_Microsoft Office' THEN 631 WHEN input_value = 'Personal Productivity' THEN 632 WHEN input_value = 'Well-Being' THEN 633 WHEN input_value = 'Business Communication' THEN 634 WHEN input_value = 'Self-Discovery' THEN 635 WHEN input_value = 'Personal Accountability' THEN 636 WHEN input_value = 'Individual Professional Performance' THEN 637 WHEN input_value = 'Project Management Methods' THEN 638 WHEN input_value = 'Project Management Core Concepts' THEN 639 WHEN input_value = 'Product Marketing' THEN 640 WHEN input_value = 'Selling Skills' THEN 641 WHEN input_value = 'Salesforce & Channel Management' THEN 642 WHEN input_value = 'Corporate Communications' THEN 643 WHEN input_value = 'Corporate Marketing' THEN 644 WHEN input_value = '205_(ISC)2' THEN 645 WHEN input_value = '206_Amazon' THEN 646 WHEN input_value = '207_Cisco' THEN 647 WHEN input_value = '209_CompTIA' THEN 648 WHEN input_value = '214_Information Systems Audit and Control Association' THEN 649 WHEN input_value = '217_Microsoft' THEN 650 WHEN input_value = '228_Cloud Platforms' THEN 651 WHEN input_value = '229_Cloud Development' THEN 652 WHEN input_value = '245_Information Security' THEN 653 WHEN input_value = '246_IT Services' THEN 654 WHEN input_value = '247_Network Operations' THEN 655 WHEN input_value = '248_Client & Server Administration' THEN 656 WHEN input_value = '250_Leading the Business' THEN 657 WHEN input_value = '251_Leading Your Team' THEN 658 WHEN input_value = '252_Leading Yourself' THEN 659 WHEN input_value = '253_Management Essentials' THEN 660 WHEN input_value = '59_(ISC)2' THEN 661 WHEN input_value = '60_Amazon' THEN 662 WHEN input_value = 'American Society for Quality (ASQ)' THEN 663 WHEN input_value = 'BCS Professional Institute' THEN 664 WHEN input_value = '65_Cisco' THEN 665 WHEN input_value = '67_CompTIA' THEN 666 WHEN input_value = 'EC-Council' THEN 667 WHEN input_value = 'Google' THEN 668 WHEN input_value = 'ITIL®' THEN 669 WHEN input_value = '76_Information Systems Audit and Control Association' THEN 670 WHEN input_value = 'International Institute of Business Analysis (IIBA)' THEN 671 WHEN input_value = 'International Software Testing Qualification Board' THEN 672 WHEN input_value = 'Isograd' THEN 673 WHEN input_value = 'Juniper' THEN 674 WHEN input_value = 'Linux Professional Institute' THEN 675 WHEN input_value = '83_Microsoft' THEN 676 WHEN input_value = '84_Microsoft Office' THEN 677 WHEN input_value = 'Oracle' THEN 678 WHEN input_value = 'PRINCE2®' THEN 679 WHEN input_value = 'Project Management Institute (PMI)®' THEN 680 WHEN input_value = 'Red Hat' THEN 681 WHEN input_value = 'SAS' THEN 682 WHEN input_value = 'TOGAF®' THEN 683 WHEN input_value = '10_Developer' THEN 684 WHEN input_value = 'Data Analyst to Data Scientist' THEN 685 WHEN input_value = 'Business Planning & Analysis' THEN 686 WHEN input_value = 'Finance' THEN 687 WHEN input_value = 'Human Resources' THEN 688 WHEN input_value = 'Process Improvement' THEN 689 WHEN input_value = '11_Digital Transformation' THEN 690 WHEN input_value = '112_Cloud Platforms' THEN 691 WHEN input_value = 'Cloud Basics' THEN 692 WHEN input_value = 'Internet of Things' THEN 693 WHEN input_value = '115_Cloud Development' THEN 694 WHEN input_value = '116_Cloud Security' THEN 695 WHEN input_value = '12_IT Operations' THEN 696 WHEN input_value = 'Developer Trends' THEN 697 WHEN input_value = 'Web Development' THEN 698 WHEN input_value = 'Mobile Development' THEN 699 WHEN input_value = '134_DevOps' THEN 700 WHEN input_value = '135_Secure Programming' THEN 701 WHEN input_value = 'Data Modelling' THEN 702 WHEN input_value = '137_Developer Concepts & Methodologies' THEN 703 WHEN input_value = '138_Developer Tools' THEN 704 WHEN input_value = '139_Programming Languages' THEN 705 WHEN input_value = '14_Leadership Development Program' THEN 706 WHEN input_value = 'Microservices' THEN 707 WHEN input_value = '142_Essentials of Digital Transformation' THEN 708 WHEN input_value = '143_Virtual Work' THEN 709 WHEN input_value = '144_Digital Soft Skills Competencies' THEN 710 WHEN input_value = '145_Agility for Digital Transformation' THEN 711 WHEN input_value = '147_Digital Experiences' THEN 712 WHEN input_value = '15_Management' THEN 713 WHEN input_value = 'Leadership Essentials' THEN 714 WHEN input_value = '166_Management Essentials' THEN 715 WHEN input_value = 'Team Management' THEN 716 WHEN input_value = 'Business Execution' THEN 717 WHEN input_value = 'Business Strategy' THEN 718 WHEN input_value = '233_Customer Service: Core Concepts & Methods' THEN 719 WHEN input_value = '234_Secure Programming' THEN 720 WHEN input_value = '235_Developer Concepts & Methodologies' THEN 721 WHEN input_value = '236_Developer Tools' THEN 722 WHEN input_value = '237_Programming Languages' THEN 723 WHEN input_value = '238_Data Science' THEN 724 WHEN input_value = '239_Essentials of Digital Transformation' THEN 725 WHEN input_value = '240_Virtual Work' THEN 726 WHEN input_value = '241_Digital Soft Skills Competencies' THEN 727 WHEN input_value = '242_Agility for Digital Transformation' THEN 728 WHEN input_value = '243_Digital Marketing & Communications' THEN 729 WHEN input_value = '244_Digital Experiences' THEN 730 WHEN input_value = '3_Certifications' THEN 731 WHEN input_value = '7_Cloud Services' THEN 732 WHEN input_value = '9_Customer Service' THEN 733 WHEN input_value = 'ASQ (American Society for Quality)' THEN 734 WHEN input_value = '104_Foundation' THEN 735 WHEN input_value = '109_Professional' THEN 736 WHEN input_value = '110_Entry' THEN 737 WHEN input_value = '111_Associate' THEN 738 WHEN input_value = '13_Information Systems Audit and Control Association' THEN 739 WHEN input_value = '148_Core' THEN 740 WHEN input_value = '16_Microsoft' THEN 741 WHEN input_value = '161_Foundation' THEN 742 WHEN input_value = '164_Administrator' THEN 743 WHEN input_value = 'Microsoft Certified Associate' THEN 744 WHEN input_value = '171_Specialist' THEN 745 WHEN input_value = '172_Microsoft Certified Solutions Developer (MCSD)' THEN 746 WHEN input_value = '173_Microsoft Certified Solutions Associate (MCSA)' THEN 747 WHEN input_value = '174_Microsoft Certified Solutions Expert (MCSE)' THEN 748 WHEN input_value = '175_Associate (MTA)' THEN 749 WHEN input_value = 'Microsoft Certified Fundamentals' THEN 750 WHEN input_value = 'Microsoft Office Specialist (MOS)' THEN 751 WHEN input_value = '178_Professional' THEN 752 WHEN input_value = 'Expert' THEN 753 WHEN input_value = '180_Associate' THEN 754 WHEN input_value = '181_Foundation' THEN 755 WHEN input_value = '196_Administrator' THEN 756 WHEN input_value = 'Base Programmer' THEN 757 WHEN input_value = '218_Cloud Security' THEN 758 WHEN input_value = '219_Systems Security' THEN 759 WHEN input_value = '220_Software Development' THEN 760 WHEN input_value = '221_Information Security' THEN 761 WHEN input_value = '249_Auditor' THEN 762 WHEN input_value = '27_Cloud Platforms' THEN 763 WHEN input_value = '28_Cloud Development' THEN 764 WHEN input_value = '4_(ISC)2' THEN 765 WHEN input_value = '44_Information Security' THEN 766 WHEN input_value = '45_IT Services' THEN 767 WHEN input_value = '46_Network Operations' THEN 768 WHEN input_value = '47_Client & Server Administration' THEN 769 WHEN input_value = '49_Leading the Business' THEN 770 WHEN input_value = '5_Amazon' THEN 771 WHEN input_value = '50_Leading Your Team' THEN 772 WHEN input_value = '51_Leading Yourself' THEN 773 WHEN input_value = '52_Management Essentials' THEN 774 WHEN input_value = '6_Cisco' THEN 775 WHEN input_value = '8_CompTIA' THEN 776 WHEN input_value = '100_Architecting' THEN 777 WHEN input_value = '101_Operations' THEN 778 WHEN input_value = 'Additional Professional' THEN 779 WHEN input_value = '118_Cybersecurity' THEN 780 WHEN input_value = '119_Infrastructure' THEN 781 WHEN input_value = '120_Core' THEN 782 WHEN input_value = '149_Associate' THEN 783 WHEN input_value = '150_Professional' THEN 784 WHEN input_value = '157_Foundation' THEN 785 WHEN input_value = '158_Auditor' THEN 786 WHEN input_value = 'Security Manager' THEN 787 WHEN input_value = 'Level 3 - CBAP' THEN 788 WHEN input_value = 'TOSA Desktop' THEN 789 WHEN input_value = '163_Associate' THEN 790 WHEN input_value = '195_Project Management' THEN 791 WHEN input_value = 'TOGAF® 9' THEN 792 WHEN input_value = '222_Developing' THEN 793 WHEN input_value = '223_Architecting' THEN 794 WHEN input_value = '224_Operations' THEN 795 WHEN input_value = '225_Professional' THEN 796 WHEN input_value = '226_Entry' THEN 797 WHEN input_value = '227_Associate' THEN 798 WHEN input_value = '230_Cybersecurity' THEN 799 WHEN input_value = '231_Infrastructure' THEN 800 WHEN input_value = '232_Core' THEN 801 WHEN input_value = '254_Specialist' THEN 802 WHEN input_value = '255_Microsoft Certified Solutions Developer (MCSD)' THEN 803 WHEN input_value = '256_Microsoft Certified Solutions Associate (MCSA)' THEN 804 WHEN input_value = '257_Microsoft Certified Solutions Expert (MCSE)' THEN 805 WHEN input_value = '258_Associate (MTA)' THEN 806 WHEN input_value = '32_Customer Service: Core Concepts & Methods' THEN 807 WHEN input_value = '33_Secure Programming' THEN 808 WHEN input_value = '34_Developer Concepts & Methodologies' THEN 809 WHEN input_value = '35_Developer Tools' THEN 810 WHEN input_value = '36_Programming Languages' THEN 811 WHEN input_value = '37_Data Science' THEN 812 WHEN input_value = '38_Essentials of Digital Transformation' THEN 813 WHEN input_value = '39_Virtual Work' THEN 814 WHEN input_value = '40_Digital Soft Skills Competencies' THEN 815 WHEN input_value = '41_Agility for Digital Transformation' THEN 816 WHEN input_value = '42_Digital Marketing & Communications' THEN 817 WHEN input_value = '43_Digital Experiences' THEN 818 WHEN input_value = '95_Cloud Security' THEN 819 WHEN input_value = '96_Systems Security' THEN 820 WHEN input_value = '97_Software Development' THEN 821 WHEN input_value = '98_Information Security' THEN 822 WHEN input_value = '99_Developing' THEN 823 WHEN input_value = '17_Cloud Security' THEN 824 WHEN input_value = '18_Systems Security' THEN 825 WHEN input_value = '19_Software Development' THEN 826 WHEN input_value = '20_Information Security' THEN 827 WHEN input_value = '29_Cybersecurity' THEN 828 WHEN input_value = '30_Infrastructure' THEN 829 WHEN input_value = '31_Core' THEN 830 WHEN input_value = '48_Auditor' THEN 831 WHEN input_value = '21_Developing' THEN 832 WHEN input_value = '22_Architecting' THEN 833 WHEN input_value = '23_Operations' THEN 834 WHEN input_value = '24_Professional' THEN 835 WHEN input_value = '25_Entry' THEN 836 WHEN input_value = '26_Associate' THEN 837 WHEN input_value = '53_Specialist' THEN 838 WHEN input_value = '54_Microsoft Certified Solutions Developer (MCSD)' THEN 839 WHEN input_value = '55_Microsoft Certified Solutions Associate (MCSA)' THEN 840 WHEN input_value = '56_Microsoft Certified Solutions Expert (MCSE)' THEN 841 WHEN input_value = '57_Associate (MTA)' THEN 842 WHEN input_value = 'Java' THEN 843 WHEN input_value = 'oops' THEN 844 WHEN input_value = 'python' THEN 845 WHEN input_value = 'Auditor' THEN 846 WHEN input_value = 'Browsers & Operating Systems' THEN 847 WHEN input_value = 'Business Skills' THEN 848 WHEN input_value = 'Cloud' THEN 849 WHEN input_value = 'Cloud Computing' THEN 850 WHEN input_value = 'Collaboration' THEN 851 WHEN input_value = 'Data / ML / AI' THEN 852 WHEN input_value = 'Decision-makers and Leaders' THEN 853 WHEN input_value = 'Design' THEN 854 WHEN input_value = 'DevOps' THEN 855 WHEN input_value = 'Foundation' THEN 856 WHEN input_value = 'Get Started' THEN 857 WHEN input_value = 'IT Ops' THEN 858 WHEN input_value = 'Leading the Business' THEN 859 WHEN input_value = 'Leading Your Team' THEN 860 WHEN input_value = 'Leading Yourself' THEN 861 WHEN input_value = 'Level 3 - CBAP' THEN 862 WHEN input_value = 'PM' THEN 863 WHEN input_value = 'Productivity Tools' THEN 864 WHEN input_value = 'Programming' THEN 865 WHEN input_value = 'Adapting to Change' THEN 866 WHEN input_value = 'Business Execution' THEN 867 WHEN input_value = 'Business Strategy' THEN 868 WHEN input_value = 'Business Continuity Planning' THEN 869 WHEN input_value = 'Collaboration Tools' THEN 870 WHEN input_value = 'Communication Essentials' THEN 871 WHEN input_value = 'Crisis Management' THEN 872 WHEN input_value = 'Environmental, Health and Safety (EHS) Compliance' THEN 873 WHEN input_value = 'Food and Alcohol Safety' THEN 874 WHEN input_value = 'Leadership Essentials' THEN 875 WHEN input_value = 'Leading Teams' THEN 876 WHEN input_value = 'Legal Compliance' THEN 877 WHEN input_value = 'Professional Essentials' THEN 878 WHEN input_value = 'Software Tester to DevOps Automated Tester' THEN 879 WHEN input_value = 'Penetration Tester to SecOps Engineer' THEN 880 WHEN input_value = 'Web Programmer to Apprentice Programmer' THEN 881 WHEN input_value = 'Software Project Lead to Advanced Scrum Master' THEN 882 WHEN input_value = 'Network Security Specialist to CloudOps Security Architect' THEN 883 WHEN input_value = 'DevOps Engineer to Cloud Architect' THEN 884 WHEN input_value = 'Apprentice Developer to Journeyman Developer' THEN 885 WHEN input_value = 'AI Apprentice to AI Architect' THEN 886 WHEN input_value = 'Programmer to API Developer' THEN 887 WHEN input_value = 'Developer to Software Architect' THEN 888 WHEN input_value = 'Network Admin to Site Reliability Engineer' THEN 889 WHEN input_value = 'Infrastructure Support Engineer to CloudOps Engineer' THEN 890 WHEN input_value = 'Business Analyst to Data Analyst' THEN 891 WHEN input_value = 'Data Visualization' THEN 892 WHEN input_value = 'Pythonista to Python Master' THEN 893 WHEN input_value = 'Management Essentials' THEN 894 WHEN input_value = 'Microsoft Office 2016' THEN 895 WHEN input_value = 'Microsoft Office 365' THEN 896 WHEN input_value = 'Data Analysis with R' THEN 897 WHEN input_value = 'Security Essentials for Decision-makers and Leaders' THEN 898 WHEN input_value = 'Agile for Software Development' THEN 899 WHEN input_value = 'Serverless Deployments for Developers' THEN 900 WHEN input_value = 'Java Novice to Javanista' THEN 901 WHEN input_value = 'Web App Vulnerability Analyst' THEN 902 WHEN input_value = '5G Technologies and Practices' THEN 903 WHEN input_value = 'Go Programming Essentials' THEN 904 WHEN input_value = 'Enriched Web Development with Angular 11' THEN 905 WHEN input_value = 'Novice Developer to Pythonista' THEN 906 WHEN input_value = 'Javanista to Java Master' THEN 907 WHEN input_value = 'Developer Fundamentals' THEN 908 WHEN input_value = 'Programming Python in Action' THEN 909 WHEN input_value = 'Enterprise Development to DevOps Engineer' THEN 910 WHEN input_value = 'Web App Vulnerability Analyst - 2022 Update' THEN 911 WHEN input_value = 'Enterprise Development to Full Stack Developer' THEN 912 WHEN input_value = 'Software Product Management Proficiency' THEN 913 WHEN input_value = 'Engineering Lead' THEN 914 WHEN input_value = 'AI and ML for Decision-makers' THEN 915 WHEN input_value = 'Software Project Analyst to Senior Software Project Manager' THEN 916 WHEN input_value = 'Security Analyst to Security Architect' THEN 917 WHEN input_value = 'Programmer to Secure Agile Programmer' THEN 918 WHEN input_value = 'Virtual Work in the New Normal' THEN 919 WHEN input_value = 'Manage Myself' THEN 920 WHEN input_value = 'Manage Others' THEN 921 WHEN input_value = 'Security' THEN 922 WHEN input_value = 'Security Manager' THEN 923 WHEN input_value = 'Server Technology' THEN 924 WHEN input_value = 'Six Sigma Certification' THEN 925 WHEN input_value = 'Software Craftsmanship' THEN 926 WHEN input_value = 'Topics' THEN 927 WHEN input_value = 'Strategic Thinking' THEN 928 WHEN input_value = 'Team Management' THEN 929 WHEN input_value = 'Time Management and Productivity' THEN 930 WHEN input_value = 'Working on a Team' THEN 931 WHEN input_value = 'Working Remotely' THEN 932 WHEN input_value = 'Work-Life Balance' THEN 933 WHEN input_value = 'Accounting' THEN 934 WHEN input_value = 'AGG Leadership' THEN 935 WHEN input_value = 'Diversity on the Job' THEN 936 WHEN input_value = 'Time Management' THEN 937 WHEN input_value = 'Unconscious Bias' THEN 938 WHEN input_value = 'Diversity, Equity, and Inclusion' THEN 939 WHEN input_value = 'Building DEI Leadership Skills' THEN 940 WHEN input_value = 'Psychological Safety' THEN 941 WHEN input_value = 'Skills for Effective Collaboration' THEN 942 WHEN input_value = 'Managing a Crisis' THEN 943 WHEN input_value = 'Business' THEN 944 WHEN input_value = 'C#' THEN 945 WHEN input_value = 'Cisco Teams' THEN 946 WHEN input_value = 'Cisco WebEx' THEN 947 WHEN input_value = 'Computer Skills' THEN 948 WHEN input_value = 'Core Knowledge' THEN 949 WHEN input_value = 'Developer Tools' THEN 950 WHEN input_value = 'dot NET' THEN 951 WHEN input_value = 'Food and Alcohol Safety (Latin American Spanish Edition)' THEN 952 WHEN input_value = 'Food and Alcohol Safety (UK Edition)' THEN 953 WHEN input_value = 'Food and Alcohol Safety (US Edition)' THEN 954 WHEN input_value = 'Forms & Lists' THEN 955 WHEN input_value = 'Gemba' THEN 956 WHEN input_value = 'Hansei' THEN 957 WHEN input_value = 'Harassment (Canadian French Edition)' THEN 958 WHEN input_value = 'Harassment (Chinese Edition)' THEN 959 WHEN input_value = 'Harassment (Danish Edition)' THEN 960 WHEN input_value = 'Harassment (Dutch Edition)' THEN 961 WHEN input_value = 'Harassment (Finnish Edition)' THEN 962 WHEN input_value = 'Harassment (Hungarian Edition)' THEN 963 WHEN input_value = 'Harassment (Norwegian Edition)' THEN 964 WHEN input_value = 'Harassment (Romanian Edition)' THEN 965 WHEN input_value = 'Harassment (Russian Edition)' THEN 966 WHEN input_value = 'Harassment (Castilian Spanish Edition)' THEN 967 WHEN input_value = 'Harassment (Swedish Edition)' THEN 968 WHEN input_value = 'Harassment (Turkish Edition)' THEN 969 WHEN input_value = 'Harassment (UK English Edition)' THEN 970 WHEN input_value = 'Harassment (US Edition)' THEN 971 WHEN input_value = 'Health Insurance Portability and Accountability Act (HIPAA) (Latin American Spanish Edition)' THEN 972 WHEN input_value = 'Health Insurance Portability and Accountability Act (HIPAA) (US Edition)' THEN 973 WHEN input_value = 'Health and Wellness' THEN 974 WHEN input_value = 'Hoshin' THEN 975 WHEN input_value = 'Introductory Topics' THEN 976 WHEN input_value = 'JDE' THEN 977 WHEN input_value = 'Joinme' THEN 978 WHEN input_value = 'Just In Time' THEN 979 WHEN input_value = 'Kaizen Leadership' THEN 980 WHEN input_value = 'Kanban' THEN 981 WHEN input_value = 'Leadership & Teamwork' THEN 982 WHEN input_value = 'Additional Content' THEN 983 WHEN input_value = 'Legal Impacts (US Edition)' THEN 984 WHEN input_value = 'Legal Impacts (Brazilian Portuguese Edition)' THEN 985 WHEN input_value = 'Legal Impacts (Chinese Edition)' THEN 986 WHEN input_value = 'Legal Impacts (German Edition)' THEN 987 WHEN input_value = 'LMS Instructions' THEN 988 WHEN input_value = 'LogMeIn' THEN 989 WHEN input_value = 'Microservices' THEN 990 WHEN input_value = 'Mobile Development' THEN 991 WHEN input_value = 'Muda' THEN 992 WHEN input_value = 'Open Sesame' THEN 993 WHEN input_value = 'Improving Your Work/Life Balance' THEN 994 WHEN input_value = 'Improving Your Personal Productivity' THEN 995 WHEN input_value = 'Perseverance at Work' THEN 996 WHEN input_value = 'Percipio' THEN 997 WHEN input_value = 'Policies & Procedures' THEN 998 WHEN input_value = 'Problem Solving' THEN 999 ELSE  END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Availability to All Users", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Availability to Specific Users", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Availability to OU‡", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Availability OU Type", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Register Upon Approval", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Pre-Approved", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Include Subordinates", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Attempts Allowed", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "9999", csod.default_value = "0", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "View Test Score - Manager", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "View Test Score - User", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Allow Test Review - Manager", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "AllowUserToReview", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Allow Test Review - User", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "AllowUserToReview", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Allow Review After Every Attempt", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Review Level", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "Questions Only", csod.accepted_values = "Test Only, Questions and Answers, Questions Only, Question Category and Answer", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Lockout", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Lockout Type", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Days, Weeks", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Lockout Duration", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.min_value = "0", csod.max_value = "30",  csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Test Instructions", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "EstimatedDuration", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Time Limit", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.min_value = "0", csod.max_value = "300", csod.default_value = "0", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "MaxScore", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Passing Score Percentage", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.min_value = "0", csod.max_value = "100", csod.default_value = "0", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Early Exit", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "Save any progress and return", csod.accepted_values = "Save any progress and return, Must proceed all the way through", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Randomize Sections", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "RandomiseQuestions", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Randomize Questions", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (st:SumTotalField {name: "QuestionID", file: "Activity_Test"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Question Reference Number", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Recurrence", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "0", csod.accepted_values = "0, 1, 2, 3, 5, 6, 7", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Thumbnail", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "Portal Default Thumbnail", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Exclude from Course Recommendations", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Training Purpose", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "テスト", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Points", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.min_value = "0", csod.max_value = "1000", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Badge", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Onboarded, Onboarded (1), Presentation Expert, Curriculum Leader, Safety First, Video Master, NEW HIRE ONBOARDING SUCCESSFULLY DONE, voohoo, Above and Beyond, Great Work, DELETE", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_Test"})
MERGE (csod:CSODField {name: "Emails", file: "Activity_Test" })
SET csod.mandatory = "Optional", csod.field_type = "Enum", csod.char_length = "", csod.default_value = "No Email", csod.accepted_values = "System Default, No Email", csod.output_document = "Activity_Test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_TestMapping"})
MERGE (st:SumTotalField {name: "ActivityCode", file: "Activity_TestMapping"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Test ID*", file: "Activity_TestMapping" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_TestMapping"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_TestMapping"})
MERGE (st:SumTotalField {name: "QuestionID", file: "Activity_TestMapping"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Question Reference Number*", file: "Activity_TestMapping" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_TestMapping"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_TestMapping"})
MERGE (csod:CSODField {name: "Section Number*", file: "Activity_TestMapping" })
SET csod.mandatory = "Mandatory", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_TestMapping"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_TestMapping"})
MERGE (st:SumTotalField {name: "SectionName", file: "Activity_TestMapping"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Section Name", file: "Activity_TestMapping" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_TestMapping"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_TestMapping"})
MERGE (csod:CSODField {name: "Section Description", file: "Activity_TestMapping" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "3500", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_TestMapping"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_TestMapping"})
MERGE (csod:CSODField {name: "Order Number", file: "Activity_TestMapping" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.min_value = "1", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_TestMapping"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_TestMapping"})
MERGE (csod:CSODField {name: "Questions per Section Display", file: "Activity_TestMapping" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.min_value = "1", csod.default_value = "", csod.accepted_values = "", csod.output_document = "Activity_TestMapping"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE ( f:File {name: "Activity_TestMapping"})
MERGE (csod:CSODField {name: "Always Include Question‡", file: "Activity_TestMapping" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive", csod.output_document = "Activity_TestMapping"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);


MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "LastModifiedDate", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Effective Date", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "DateTime", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Reason for Change (accepted on modification)", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Data Correction, Demotion, Personal Data Change, Position Management, Promotion, Reorganization, Self-service, Termination, Transfer, User status/type change"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "PersonGuid", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "GUID", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Uuid", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "PersonNumber", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "User ID*", file: "Core_Employee-CHR"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Local System ID", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "PrefixText", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Prefix", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "10", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "FirstName", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "First Name*", file: "Core_Employee-CHR"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "MiddleName", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Middle Name", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "LastName", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Last Name*", file: "Core_Employee-CHR"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "SuffixText", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Suffix", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "10", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "UserName", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Username", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Approver", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "ManagerId", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Manager", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Absent", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Active, InActive, 1, 0, y, n, yes, no, t, f, true, false, on, off"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Allow Reconciliation", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Active, InActive, 1, 0, y, n, yes, no, t, f, true, false, on, off"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Email", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Email", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Required Training Approvals", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.min_value = "0", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "GENDER_TEXT", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Gender", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "female, male, not known, not specified"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;

MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Exempt", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "ETHNICITY_TEXT", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Ethnicity", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;

MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Months of Service", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.min_value = "0", csod.max_value = "9999", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;

MERGE ( f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Compensation Currency", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type= "Char", csod.char_length = "3", csod.default_value = "", csod.accepted_values = "USD, ", csod.transformation = "CASE WHEN input_value = 'USD' THEN 1 WHEN input_value = 'United States Dollar' THEN 1 WHEN input_value = 'GBP' THEN 2 WHEN input_value = 'United Kingdoms Pound' THEN 2 WHEN input_value = 'Euro' THEN 3 WHEN input_value = 'EUR' THEN 3 WHEN input_value = 'Mexico Peso' THEN 17 WHEN input_value = 'MXN' THEN 17 WHEN input_value = 'TND' THEN 78 WHEN input_value = 'Tunisian Dinar' THEN 78 ELSE  END"
MERGE (f) -[:OUTPUTS_FIELD] ->(csod);

MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Address1", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Address Line 1", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "110", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Address2", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Address Line 2", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "55", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "City", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "City", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "35", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "StateName", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "State", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "30", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Zip", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Zip", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "20", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Mailstop", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "20", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Country", file: "Core_Employee-CHR"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Country", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", 
    csod.field_type = "Char",
    csod.char_length = "3",
    csod.default_value = "",
    csod.accepted_values = "",
    csod.transformation = "CASE WHEN input_value = 'Afghanistan' THEN 'AFG' WHEN input_value = 'AF' THEN 'AFG' WHEN input_value = 'Albania' THEN 'ALB' WHEN input_value = 'AL' THEN 'ALB' WHEN input_value = 'Algeria' THEN 'DZA' WHEN input_value = 'DZ' THEN 'DZA' WHEN input_value = 'American Samoa' THEN 'ASM' WHEN input_value = 'AS' THEN 'ASM' WHEN input_value = 'Andorra' THEN 'AND' WHEN input_value = 'AD' THEN 'AND' WHEN input_value = 'Angola' THEN 'AGO' WHEN input_value = 'AO' THEN 'AGO' WHEN input_value = 'Anguilla' THEN 'AIA' WHEN input_value = 'AI' THEN 'AIA' WHEN input_value = 'Antarctica' THEN 'ATA' WHEN input_value = 'AQ' THEN 'ATA' WHEN input_value = 'Antigua and Barbuda' THEN 'ATG' WHEN input_value = 'AG' THEN 'ATG' WHEN input_value = 'Argentina' THEN 'ARG' WHEN input_value = 'AR' THEN 'ARG' WHEN input_value = 'Armenia' THEN 'ARM' WHEN input_value = 'AM' THEN 'ARM' WHEN input_value = 'Aruba' THEN 'ABW' WHEN input_value = 'AW' THEN 'ABW' WHEN input_value = 'Australia' THEN 'AUS' WHEN input_value = 'AU' THEN 'AUS' WHEN input_value = 'Austria' THEN 'AUT' WHEN input_value = 'AT' THEN 'AUT' WHEN input_value = 'Azerbaijan' THEN 'AZE' WHEN input_value = 'AZ' THEN 'AZE' WHEN input_value = 'Bahamas' THEN 'BHS' WHEN input_value = 'BS' THEN 'BHS' WHEN input_value = 'Bahrain' THEN 'BHR' WHEN input_value = 'BH' THEN 'BHR' WHEN input_value = 'Bangladesh' THEN 'BGD' WHEN input_value = 'BD' THEN 'BGD' WHEN input_value = 'Barbados' THEN 'BRB' WHEN input_value = 'BB' THEN 'BRB' WHEN input_value = 'Belarus' THEN 'BLR' WHEN input_value = 'BY' THEN 'BLR' WHEN input_value = 'Belgium' THEN 'BEL' WHEN input_value = 'BE' THEN 'BEL' WHEN input_value = 'Belize' THEN 'BLZ' WHEN input_value = 'BZ' THEN 'BLZ' WHEN input_value = 'Benin' THEN 'BEN' WHEN input_value = 'BJ' THEN 'BEN' WHEN input_value = 'Bermuda' THEN 'BMU' WHEN input_value = 'BM' THEN 'BMU' WHEN input_value = 'Bhutan' THEN 'BTN' WHEN input_value = 'BT' THEN 'BTN' WHEN input_value = 'Bolivia' THEN 'BOL' WHEN input_value = 'BO' THEN 'BOL' WHEN input_value = 'Bosnia and Herzegovina' THEN 'BIH' WHEN input_value = 'BA' THEN 'BIH' WHEN input_value = 'Botswana' THEN 'BWA' WHEN input_value = 'BW' THEN 'BWA' WHEN input_value = 'Bouvet Island' THEN 'BVT' WHEN input_value = 'BV' THEN 'BVT' WHEN input_value = 'Brazil' THEN 'BRA' WHEN input_value = 'BR' THEN 'BRA' WHEN input_value = 'British Indian Ocean Territory' THEN 'IOT' WHEN input_value = 'IO' THEN 'IOT' WHEN input_value = 'Brunei' THEN 'BRN' WHEN input_value = 'Brunei Darussalam' THEN 'BRN' WHEN input_value = 'BN' THEN 'BRN' WHEN input_value = 'Bulgaria' THEN 'BGR' WHEN input_value = 'BG' THEN 'BGR' WHEN input_value = 'Burkina Faso' THEN 'BFA' WHEN input_value = 'BF' THEN 'BFA' WHEN input_value = 'Burundi' THEN 'BDI' WHEN input_value = 'BI' THEN 'BDI' WHEN input_value = 'Cambodia' THEN 'KHM' WHEN input_value = 'KH' THEN 'KHM' WHEN input_value = 'Cameroon' THEN 'CMR' WHEN input_value = 'CM' THEN 'CMR' WHEN input_value = 'Canada' THEN 'CAN' WHEN input_value = 'CA' THEN 'CAN' WHEN input_value = 'Cape Verde' THEN 'CPV' WHEN input_value = 'CV' THEN 'CPV' WHEN input_value = 'Cayman Islands' THEN 'CYM' WHEN input_value = 'KY' THEN 'CYM' WHEN input_value = 'Central African Republic' THEN 'CAF' WHEN input_value = 'CF' THEN 'CAF' WHEN input_value = 'Chad' THEN 'TCD' WHEN input_value = 'TD' THEN 'TCD' WHEN input_value = 'Chile' THEN 'CHL' WHEN input_value = 'CL' THEN 'CHL' WHEN input_value = 'China' THEN 'CHN' WHEN input_value = 'CN' THEN 'CHN' WHEN input_value = 'Christmas Island' THEN 'CXR' WHEN input_value = 'CX' THEN 'CXR' WHEN input_value = 'Cocos Islands' THEN 'CCK' WHEN input_value = 'Cocos (Keeling) Islands' THEN 'CCK' WHEN input_value = 'CC' THEN 'CCK' WHEN input_value = 'Colombia' THEN 'COL' WHEN input_value = 'CO' THEN 'COL' WHEN input_value = 'Comoros' THEN 'COM' WHEN input_value = 'KM' THEN 'COM' WHEN input_value = 'Congo' THEN 'COG' WHEN input_value = 'CG' THEN 'COG' WHEN input_value = 'Congo, Democratic Republic' THEN 'COD' WHEN input_value = 'Democratic Republic of the Congo' THEN 'COD' WHEN input_value = 'CD' THEN 'COD' WHEN input_value = 'Cook Islands' THEN 'COK' WHEN input_value = 'CK' THEN 'COK' WHEN input_value = 'Costa Rica' THEN 'CRI' WHEN input_value = 'CR' THEN 'CRI' WHEN input_value = 'Cote d'Ivoire' THEN 'CIV' WHEN input_value = 'Ivory Coast' THEN 'CIV' WHEN input_value = 'CI' THEN 'CIV' WHEN input_value = 'Croatia' THEN 'HRV' WHEN input_value = 'HR' THEN 'HRV' WHEN input_value = 'Cuba' THEN 'CUB' WHEN input_value = 'CU' THEN 'CUB' WHEN input_value = 'Cyprus' THEN 'CYP' WHEN input_value = 'CY' THEN 'CYP' WHEN input_value = 'Czech Republic' THEN 'CZE' WHEN input_value = 'CZ' THEN 'CZE' WHEN input_value = 'Denmark' THEN 'DNK' WHEN input_value = 'DK' THEN 'DNK' WHEN input_value = 'Djibouti' THEN 'DJI' WHEN input_value = 'DJ' THEN 'DJI' WHEN input_value = 'Dominica' THEN 'DMA' WHEN input_value = 'DM' THEN 'DMA' WHEN input_value = 'Dominican Republic' THEN 'DOM' WHEN input_value = 'DO' THEN 'DOM' WHEN input_value = 'Ecuador' THEN 'ECU' WHEN input_value = 'EC' THEN 'ECU' WHEN input_value = 'Egypt' THEN 'EGY' WHEN input_value = 'EG' THEN 'EGY' WHEN input_value = 'El Salvador' THEN 'SLV' WHEN input_value = 'SV' THEN 'SLV' WHEN input_value = 'Equatorial Guinea' THEN 'GNQ' WHEN input_value = 'GQ' THEN 'GNQ' WHEN input_value = 'Eritrea' THEN 'ERI' WHEN input_value = 'ER' THEN 'ERI' WHEN input_value = 'Estonia' THEN 'EST' WHEN input_value = 'EE' THEN 'EST' WHEN input_value = 'Ethiopia' THEN 'ETH' WHEN input_value = 'ET' THEN 'ETH' WHEN input_value = 'Falkland Islands' THEN 'FLK' WHEN input_value = 'FK' THEN 'FLK' WHEN input_value = 'Faroe Islands' THEN 'FRO' WHEN input_value = 'FO' THEN 'FRO' WHEN input_value = 'Fiji' THEN 'FJI' WHEN input_value = 'FJ' THEN 'FJI' WHEN input_value = 'Finland' THEN 'FIN' WHEN input_value = 'FI' THEN 'FIN' WHEN input_value = 'France' THEN 'FRA' WHEN input_value = 'FR' THEN 'FRA' WHEN input_value = 'French Guiana' THEN 'GUF' WHEN input_value = 'GF' THEN 'GUF' WHEN input_value = 'French Polynesia' THEN 'PYF' WHEN input_value = 'PF' THEN 'PYF' WHEN input_value = 'French Southern Territories' THEN 'ATF' WHEN input_value = 'TF' THEN 'ATF' WHEN input_value = 'Gabon' THEN 'GAB' WHEN input_value = 'GA' THEN 'GAB' WHEN input_value = 'Gambia' THEN 'GMB' WHEN input_value = 'GM' THEN 'GMB' WHEN input_value = 'Georgia' THEN 'GEO' WHEN input_value = 'GE' THEN 'GEO' WHEN input_value = 'Germany' THEN 'DEU' WHEN input_value = 'DE' THEN 'DEU' WHEN input_value = 'Ghana' THEN 'GHA' WHEN input_value = 'GH' THEN 'GHA' WHEN input_value = 'Gibraltar' THEN 'GIB' WHEN input_value = 'GI' THEN 'GIB' WHEN input_value = 'Greece' THEN 'GRC' WHEN input_value = 'GR' THEN 'GRC' WHEN input_value = 'Greenland' THEN 'GRL' WHEN input_value = 'GL' THEN 'GRL' WHEN input_value = 'Grenada' THEN 'GRD' WHEN input_value = 'GD' THEN 'GRD' WHEN input_value = 'Guadeloupe' THEN 'GLP' WHEN input_value = 'GP' THEN 'GLP' WHEN input_value = 'Guam' THEN 'GUM' WHEN input_value = 'GU' THEN 'GUM' WHEN input_value = 'Guatemala' THEN 'GTM' WHEN input_value = 'GT' THEN 'GTM' WHEN input_value = 'Guinea' THEN 'GIN' WHEN input_value = 'GN' THEN 'GIN' WHEN input_value = 'Guinea-Bissau' THEN 'GNB' WHEN input_value = 'GW' THEN 'GNB' WHEN input_value = 'Guyana' THEN 'GUY' WHEN input_value = 'GY' THEN 'GUY' WHEN input_value = 'Haiti' THEN 'HTI' WHEN input_value = 'HT' THEN 'HTI' WHEN input_value = 'Heard Island and McDonald Islands' THEN 'HMD' WHEN input_value = 'HM' THEN 'HMD' WHEN input_value = 'Vatican City' THEN 'VAT' WHEN input_value = 'Holy See' THEN 'VAT' WHEN input_value = 'VA' THEN 'VAT' WHEN input_value = 'Honduras' THEN 'HND' WHEN input_value = 'HN' THEN 'HND' WHEN input_value = 'Hong Kong' THEN 'HKG' WHEN input_value = 'HK' THEN 'HKG' WHEN input_value = 'Hungary' THEN 'HUN' WHEN input_value = 'HU' THEN 'HUN' WHEN input_value = 'Iceland' THEN 'ISL' WHEN input_value = 'IS' THEN 'ISL' WHEN input_value = 'India' THEN 'IND' WHEN input_value = 'IN' THEN 'IND' WHEN input_value = 'Indonesia' THEN 'IDN' WHEN input_value = 'ID' THEN 'IDN' WHEN input_value = 'Iran' THEN 'IRN' WHEN input_value = 'IR' THEN 'IRN' WHEN input_value = 'Iraq' THEN 'IRQ' WHEN input_value = 'IQ' THEN 'IRQ' WHEN input_value = 'Ireland' THEN 'IRL' WHEN input_value = 'IE' THEN 'IRL' WHEN input_value = 'Israel' THEN 'ISR' WHEN input_value = 'IL' THEN 'ISR' WHEN input_value = 'Italy' THEN 'ITA' WHEN input_value = 'IT' THEN 'ITA' WHEN input_value = 'Jamaica' THEN 'JAM' WHEN input_value = 'JM' THEN 'JAM' WHEN input_value = 'Japan' THEN 'JPN' WHEN input_value = 'JP' THEN 'JPN' WHEN input_value = 'Jordan' THEN 'JOR' WHEN input_value = 'JO' THEN 'JOR' WHEN input_value = 'Kazakhstan' THEN 'KAZ' WHEN input_value = 'KZ' THEN 'KAZ' WHEN input_value = 'Kenya' THEN 'KEN' WHEN input_value = 'KE' THEN 'KEN' WHEN input_value = 'Kiribati' THEN 'KIR' WHEN input_value = 'KI' THEN 'KIR' WHEN input_value = 'North Korea' THEN 'PRK' WHEN input_value = 'KP' THEN 'PRK' WHEN input_value = 'South Korea' THEN 'KOR' WHEN input_value = 'Korea' THEN 'KOR' WHEN input_value = 'KR' THEN 'KOR' WHEN input_value = 'Kuwait' THEN 'KWT' WHEN input_value = 'KW' THEN 'KWT' WHEN input_value = 'Kyrgyzstan' THEN 'KGZ' WHEN input_value = 'KG' THEN 'KGZ' WHEN input_value = 'Laos' THEN 'LAO' WHEN input_value = 'LA' THEN 'LAO' WHEN input_value = 'Latvia' THEN 'LVA' WHEN input_value = 'LV' THEN 'LVA' WHEN input_value = 'Lebanon' THEN 'LBN' WHEN input_value = 'LB' THEN 'LBN' WHEN input_value = 'Lesotho' THEN 'LSO' WHEN input_value = 'LS' THEN 'LSO' WHEN input_value = 'Liberia' THEN 'LBR' WHEN input_value = 'LR' THEN 'LBR' WHEN input_value = 'Libya' THEN 'LBY' WHEN input_value = 'LY' THEN 'LBY' WHEN input_value = 'Liechtenstein' THEN 'LIE' WHEN input_value = 'LI' THEN 'LIE' WHEN input_value = 'Lithuania' THEN 'LTU' WHEN input_value = 'LT' THEN 'LTU' WHEN input_value = 'Luxembourg' THEN 'LUX' WHEN input_value = 'LU' THEN 'LUX' WHEN input_value = 'Macao' THEN 'MAC' WHEN input_value = 'Macau' THEN 'MAC' WHEN input_value = 'MO' THEN 'MAC' WHEN input_value = 'Macedonia' THEN 'MKD' WHEN input_value = 'North Macedonia' THEN 'MKD' WHEN input_value = 'MK' THEN 'MKD' WHEN input_value = 'Madagascar' THEN 'MDG' WHEN input_value = 'MG' THEN 'MDG' WHEN input_value = 'Malawi' THEN 'MWI' WHEN input_value = 'MW' THEN 'MWI' WHEN input_value = 'Malaysia' THEN 'MYS' WHEN input_value = 'MY' THEN 'MYS' WHEN input_value = 'Maldives' THEN 'MDV' WHEN input_value = 'MV' THEN 'MDV' WHEN input_value = 'Mali' THEN 'MLI' WHEN input_value = 'ML' THEN 'MLI' WHEN input_value = 'Malta' THEN 'MLT' WHEN input_value = 'MT' THEN 'MLT' WHEN input_value = 'Marshall Islands' THEN 'MHL' WHEN input_value = 'MH' THEN 'MHL' WHEN input_value = 'Martinique' THEN 'MTQ' WHEN input_value = 'MQ' THEN 'MTQ' WHEN input_value = 'Mauritania' THEN 'MRT' WHEN input_value = 'MR' THEN 'MRT' WHEN input_value = 'Mauritius' THEN 'MUS' WHEN input_value = 'MU' THEN 'MUS' WHEN input_value = 'Mayotte' THEN 'MYT' WHEN input_value = 'YT' THEN 'MYT' WHEN input_value = 'Mexico' THEN 'MEX' WHEN input_value = 'MX' THEN 'MEX' WHEN input_value = 'Micronesia' THEN 'FSM' WHEN input_value = 'FM' THEN 'FSM' WHEN input_value = 'Moldova' THEN 'MDA' WHEN input_value = 'MD' THEN 'MDA' WHEN input_value = 'Monaco' THEN 'MCO' WHEN input_value = 'MC' THEN 'MCO' WHEN input_value = 'Mongolia' THEN 'MNG' WHEN input_value = 'MN' THEN 'MNG' WHEN input_value = 'Montenegro' THEN 'MNE' WHEN input_value = 'ME' THEN 'MNE' WHEN input_value = 'Montserrat' THEN 'MSR' WHEN input_value = 'MS' THEN 'MSR' WHEN input_value = 'Morocco' THEN 'MAR' WHEN input_value = 'MA' THEN 'MAR' WHEN input_value = 'Mozambique' THEN 'MOZ' WHEN input_value = 'MZ' THEN 'MOZ' WHEN input_value = 'Myanmar' THEN 'MMR' WHEN input_value = 'Burma' THEN 'MMR' WHEN input_value = 'MM' THEN 'MMR' WHEN input_value = 'Namibia' THEN 'NAM' WHEN input_value = 'NA' THEN 'NAM' WHEN input_value = 'Nauru' THEN 'NRU' WHEN input_value = 'NR' THEN 'NRU' WHEN input_value = 'Nepal' THEN 'NPL' WHEN input_value = 'NP' THEN 'NPL' WHEN input_value = 'Netherlands' THEN 'NLD' WHEN input_value = 'NL' THEN 'NLD' WHEN input_value = 'Netherlands Antilles' THEN 'ANT' WHEN input_value = 'AN' THEN 'ANT' WHEN input_value = 'New Caledonia' THEN 'NCL' WHEN input_value = 'NC' THEN 'NCL' WHEN input_value = 'New Zealand' THEN 'NZL' WHEN input_value = 'NZ' THEN 'NZL' WHEN input_value = 'Nicaragua' THEN 'NIC' WHEN input_value = 'NI' THEN 'NIC' WHEN input_value = 'Niger' THEN 'NER' WHEN input_value = 'NE' THEN 'NER' WHEN input_value = 'Nigeria' THEN 'NGA' WHEN input_value = 'NG' THEN 'NGA' WHEN input_value = 'Niue' THEN 'NIU' WHEN input_value = 'NU' THEN 'NIU' WHEN input_value = 'Norfolk Island' THEN 'NFK' WHEN input_value = 'NF' THEN 'NFK' WHEN input_value = 'Northern Mariana Islands' THEN 'MNP' WHEN input_value = 'MP' THEN 'MNP' WHEN input_value = 'Norway' THEN 'NOR' WHEN input_value = 'NO' THEN 'NOR' WHEN input_value = 'Oman' THEN 'OMN' WHEN input_value = 'OM' THEN 'OMN' WHEN input_value = 'Pakistan' THEN 'PAK' WHEN input_value = 'PK' THEN 'PAK' WHEN input_value = 'Palau' THEN 'PLW' WHEN input_value = 'PW' THEN 'PLW' WHEN input_value = 'Palestine' THEN 'PSE' WHEN input_value = 'PS' THEN 'PSE' WHEN input_value = 'Panama' THEN 'PAN' WHEN input_value = 'PA' THEN 'PAN' WHEN input_value = 'Papua New Guinea' THEN 'PNG' WHEN input_value = 'PG' THEN 'PNG' WHEN input_value = 'Paraguay' THEN 'PRY' WHEN input_value = 'PY' THEN 'PRY' WHEN input_value = 'Peru' THEN 'PER' WHEN input_value = 'PE' THEN 'PER' WHEN input_value = 'Philippines' THEN 'PHL' WHEN input_value = 'PH' THEN 'PHL' WHEN input_value = 'Pitcairn' THEN 'PCN' WHEN input_value = 'PN' THEN 'PCN' WHEN input_value = 'Poland' THEN 'POL' WHEN input_value = 'PL' THEN 'POL' WHEN input_value = 'Portugal' THEN 'PRT' WHEN input_value = 'PT' THEN 'PRT' WHEN input_value = 'Puerto Rico' THEN 'PRI' WHEN input_value = 'PR' THEN 'PRI' WHEN input_value = 'Qatar' THEN 'QAT' WHEN input_value = 'QA' THEN 'QAT' WHEN input_value = 'Reunion' THEN 'REU' WHEN input_value = 'RE' THEN 'REU' WHEN input_value = 'Romania' THEN 'ROU' WHEN input_value = 'RO' THEN 'ROU' WHEN input_value = 'Russia' THEN 'RUS' WHEN input_value = 'Russian Federation' THEN 'RUS' WHEN input_value = 'RU' THEN 'RUS' WHEN input_value = 'Rwanda' THEN 'RWA' WHEN input_value = 'RW' THEN 'RWA' WHEN input_value = 'Saint Helena' THEN 'SHN' WHEN input_value = 'SH' THEN 'SHN' WHEN input_value = 'Saint Kitts and Nevis' THEN 'KNA' WHEN input_value = 'KN' THEN 'KNA' WHEN input_value = 'Saint Lucia' THEN 'LCA' WHEN input_value = 'LC' THEN 'LCA' WHEN input_value = 'Saint Pierre and Miquelon' THEN 'SPM' WHEN input_value = 'PM' THEN 'SPM' WHEN input_value = 'Saint Vincent and the Grenadines' THEN 'VCT' WHEN input_value = 'VC' THEN 'VCT' WHEN input_value = 'Samoa' THEN 'WSM' WHEN input_value = 'WS' THEN 'WSM' WHEN input_value = 'San Marino' THEN 'SMR' WHEN input_value = 'SM' THEN 'SMR' WHEN input_value = 'Sao Tome and Principe' THEN 'STP' WHEN input_value = 'ST' THEN 'STP' WHEN input_value = 'Saudi Arabia' THEN 'SAU' WHEN input_value = 'SA' THEN 'SAU' WHEN input_value = 'Senegal' THEN 'SEN' WHEN input_value = 'SN' THEN 'SEN' WHEN input_value = 'Serbia' THEN 'SRB' WHEN input_value = 'RS' THEN 'SRB' WHEN input_value = 'Seychelles' THEN 'SYC' WHEN input_value = 'SC' THEN 'SYC' WHEN input_value = 'Sierra Leone' THEN 'SLE' WHEN input_value = 'SL' THEN 'SLE' WHEN input_value = 'Singapore' THEN 'SGP' WHEN input_value = 'SG' THEN 'SGP' WHEN input_value = 'Slovakia' THEN 'SVK' WHEN input_value = 'SK' THEN 'SVK' WHEN input_value = 'Slovenia' THEN 'SVN' WHEN input_value = 'SI' THEN 'SVN' WHEN input_value = 'Solomon Islands' THEN 'SLB' WHEN input_value = 'SB' THEN 'SLB' WHEN input_value = 'Somalia' THEN 'SOM' WHEN input_value = 'SO' THEN 'SOM' WHEN input_value = 'South Africa' THEN 'ZAF' WHEN input_value = 'ZA' THEN 'ZAF' WHEN input_value = 'South Georgia and South Sandwich Islands' THEN 'SGS' WHEN input_value = 'GS' THEN 'SGS' WHEN input_value = 'South Sudan' THEN 'SSD' WHEN input_value = 'SS' THEN 'SSD' WHEN input_value = 'Spain' THEN 'ESP' WHEN input_value = 'ES' THEN 'ESP' WHEN input_value = 'Sri Lanka' THEN 'LKA' WHEN input_value = 'LK' THEN 'LKA' WHEN input_value = 'Sudan' THEN 'SDN' WHEN input_value = 'SD' THEN 'SDN' WHEN input_value = 'Suriname' THEN 'SUR' WHEN input_value = 'SR' THEN 'SUR' WHEN input_value = 'Svalbard and Jan Mayen' THEN 'SJM' WHEN input_value = 'SJ' THEN 'SJM' WHEN input_value = 'Swaziland' THEN 'SWZ' WHEN input_value = 'Eswatini' THEN 'SWZ' WHEN input_value = 'SZ' THEN 'SWZ' WHEN input_value = 'Sweden' THEN 'SWE' WHEN input_value = 'SE' THEN 'SWE' WHEN input_value = 'Switzerland' THEN 'CHE' WHEN input_value = 'CH' THEN 'CHE' WHEN input_value = 'Syria' THEN 'SYR' WHEN input_value = 'SY' THEN 'SYR' WHEN input_value = 'Taiwan' THEN 'TWN' WHEN input_value = 'TW' THEN 'TWN' WHEN input_value = 'Tajikistan' THEN 'TJK' WHEN input_value = 'TJ' THEN 'TJK' WHEN input_value = 'Tanzania' THEN 'TZA' WHEN input_value = 'TZ' THEN 'TZA' WHEN input_value = 'Thailand' THEN 'THA' WHEN input_value = 'TH' THEN 'THA' WHEN input_value = 'Timor-Leste' THEN 'TLS' WHEN input_value = 'East Timor' THEN 'TLS' WHEN input_value = 'TL' THEN 'TLS' WHEN input_value = 'Togo' THEN 'TGO' WHEN input_value = 'TG' THEN 'TGO' WHEN input_value = 'Tokelau' THEN 'TKL' WHEN input_value = 'TK' THEN 'TKL' WHEN input_value = 'Tonga' THEN 'TON' WHEN input_value = 'TO' THEN 'TON' WHEN input_value = 'Trinidad and Tobago' THEN 'TTO' WHEN input_value = 'TT' THEN 'TTO' WHEN input_value = 'Tunisia' THEN 'TUN' WHEN input_value = 'TN' THEN 'TUN' WHEN input_value = 'Turkey' THEN 'TUR' WHEN input_value = 'TR' THEN 'TUR' WHEN input_value = 'Turkmenistan' THEN 'TKM' WHEN input_value = 'TM' THEN 'TKM' WHEN input_value = 'Turks and Caicos Islands' THEN 'TCA' WHEN input_value = 'TC' THEN 'TCA' WHEN input_value = 'Tuvalu' THEN 'TUV' WHEN input_value = 'TV' THEN 'TUV' WHEN input_value = 'Uganda' THEN 'UGA' WHEN input_value = 'UG' THEN 'UGA' WHEN input_value = 'Ukraine' THEN 'UKR' WHEN input_value = 'UA' THEN 'UKR' WHEN input_value = 'United Arab Emirates' THEN 'ARE' WHEN input_value = 'UAE' THEN 'ARE' WHEN input_value = 'AE' THEN 'ARE' WHEN input_value = 'United Kingdom' THEN 'GBR' WHEN input_value = 'UK' THEN 'GBR' WHEN input_value = 'Great Britain' THEN 'GBR' WHEN input_value = 'Britain' THEN 'GBR' WHEN input_value = 'England' THEN 'GBR' WHEN input_value = 'Scotland' THEN 'GBR' WHEN input_value = 'Wales' THEN 'GBR' WHEN input_value = 'Northern Ireland' THEN 'GBR' WHEN input_value = 'GB' THEN 'GBR' WHEN input_value = 'United States' THEN 'USA' WHEN input_value = 'United States of America' THEN 'USA' WHEN input_value = 'US' THEN 'USA' WHEN input_value = 'USA' THEN 'USA' WHEN input_value = 'America' THEN 'USA' WHEN input_value = 'United States Minor Outlying Islands' THEN 'UMI' WHEN input_value = 'UM' THEN 'UMI' WHEN input_value = 'Uruguay' THEN 'URY' WHEN input_value = 'UY' THEN 'URY' WHEN input_value = 'Uzbekistan' THEN 'UZB' WHEN input_value = 'UZ' THEN 'UZB' WHEN input_value = 'Vanuatu' THEN 'VUT' WHEN input_value = 'VU' THEN 'VUT' WHEN input_value = 'Venezuela' THEN 'VEN' WHEN input_value = 'VE' THEN 'VEN' WHEN input_value = 'Vietnam' THEN 'VNM' WHEN input_value = 'VN' THEN 'VNM' WHEN input_value = 'British Virgin Islands' THEN 'VGB' WHEN input_value = 'VG' THEN 'VGB' WHEN input_value = 'US Virgin Islands' THEN 'VIR' WHEN input_value = 'Virgin Islands' THEN 'VIR' WHEN input_value = 'VI' THEN 'VIR' WHEN input_value = 'Wallis and Futuna' THEN 'WLF' WHEN input_value = 'WF' THEN 'WLF' WHEN input_value = 'Western Sahara' THEN 'ESH' WHEN input_value = 'EH' THEN 'ESH' WHEN input_value = 'Yemen' THEN 'YEM' WHEN input_value = 'YE' THEN 'YEM' WHEN input_value = 'Zambia' THEN 'ZMB' WHEN input_value = 'ZM' THEN 'ZMB' WHEN input_value = 'Zimbabwe' THEN 'ZWE' WHEN input_value = 'ZW' THEN 'ZWE' ELSE '' END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "StartDate", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Original Hire Date", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "DateTime", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Last Hire Date", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "DateTime", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Phone", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Phone", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "30", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Mobile", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Mobile", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "30", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Home Phone", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "30", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Fax1", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Fax", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "30", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Active", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Status", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Active, InActive, 1, 0, y, n, yes, no, t, f, true, false, on, off"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Email1", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Personal Email", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;

MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Language", file: "Core_Employee-CHR"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Language", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", 
    csod.field_type = "Integer",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "",
    csod.transformation = "CASE WHEN input_value = 'en-US' THEN 1 WHEN input_value = 'English (US)' THEN 1 WHEN input_value = 'en-GB' THEN 2 WHEN input_value = 'English (UK)' THEN 2 WHEN input_value = 'fr-FR' THEN 13 WHEN input_value = 'French (France)' THEN 13 WHEN input_value = 'es-MX' THEN 14 WHEN input_value = 'Spanish (Latin America)' THEN 14 ELSE  END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);


MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Time Zone", file: "Core_Employee-CHR"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Time Zone", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional",
    csod.field_type = "Integer",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "",
    csod.transformation = "CASE WHEN input_value = 'America/New_York' THEN 14 WHEN input_value = 'America/Chicago' THEN 9 WHEN input_value = 'America/Los_Angeles' THEN 5 WHEN input_value = 'America/Denver' THEN 8 WHEN input_value = 'America/Phoenix' THEN 8 WHEN input_value = 'America/Anchorage' THEN 4 WHEN input_value = 'America/Juneau' THEN 4 WHEN input_value = 'Pacific/Honolulu' THEN 3 WHEN input_value = 'America/Honolulu' THEN 3 WHEN input_value = 'America/Toronto' THEN 14 WHEN input_value = 'America/Montreal' THEN 14 WHEN input_value = 'America/Vancouver' THEN 5 WHEN input_value = 'America/Seattle' THEN 5 WHEN input_value = 'America/Calgary' THEN 8 WHEN input_value = 'America/Edmonton' THEN 8 WHEN input_value = 'America/Winnipeg' THEN 9 WHEN input_value = 'America/Regina' THEN 9 WHEN input_value = 'America/Saskatoon' THEN 9 WHEN input_value = 'America/Halifax' THEN 16 WHEN input_value = 'America/Moncton' THEN 16 WHEN input_value = 'America/St_Johns' THEN 74 WHEN input_value = 'Europe/London' THEN 26 WHEN input_value = 'Europe/Dublin' THEN 26 WHEN input_value = 'Europe/Lisbon' THEN 26 WHEN input_value = 'Europe/Amsterdam' THEN 28 WHEN input_value = 'Europe/Berlin' THEN 28 WHEN input_value = 'Europe/Rome' THEN 28 WHEN input_value = 'Europe/Vienna' THEN 28 WHEN input_value = 'Europe/Stockholm' THEN 28 WHEN input_value = 'Europe/Belgrade' THEN 29 WHEN input_value = 'Europe/Bratislava' THEN 29 WHEN input_value = 'Europe/Budapest' THEN 29 WHEN input_value = 'Europe/Ljubljana' THEN 29 WHEN input_value = 'Europe/Prague' THEN 29 WHEN input_value = 'Europe/Brussels' THEN 30 WHEN input_value = 'Europe/Copenhagen' THEN 30 WHEN input_value = 'Europe/Madrid' THEN 30 WHEN input_value = 'Europe/Paris' THEN 30 WHEN input_value = 'Europe/Sarajevo' THEN 31 WHEN input_value = 'Europe/Skopje' THEN 31 WHEN input_value = 'Europe/Warsaw' THEN 31 WHEN input_value = 'Europe/Zagreb' THEN 31 WHEN input_value = 'Europe/Athens' THEN 33 WHEN input_value = 'Europe/Bucharest' THEN 33 WHEN input_value = 'Europe/Helsinki' THEN 34 WHEN input_value = 'Europe/Kiev' THEN 34 WHEN input_value = 'Europe/Riga' THEN 34 WHEN input_value = 'Asia/Jerusalem' THEN 35 WHEN input_value = 'Asia/Baghdad' THEN 36 WHEN input_value = 'Asia/Kuwait' THEN 37 WHEN input_value = 'Asia/Riyadh' THEN 37 WHEN input_value = 'Asia/Tehran' THEN 38 WHEN input_value = 'Asia/Muscat' THEN 39 WHEN input_value = 'Asia/Baku' THEN 40 WHEN input_value = 'Asia/Tbilisi' THEN 41 WHEN input_value = 'Asia/Yerevan' THEN 42 WHEN input_value = 'Asia/Kabul' THEN 43 WHEN input_value = 'Asia/Yekaterinburg' THEN 47 WHEN input_value = 'Asia/Tashkent' THEN 48 WHEN input_value = 'Asia/Kolkata' THEN 49 WHEN input_value = 'Asia/Kathmandu' THEN 50 WHEN input_value = 'Asia/Novosibirsk' THEN 51 WHEN input_value = 'Asia/Almaty' THEN 52 WHEN input_value = 'Asia/Dhaka' THEN 53 WHEN input_value = 'Asia/Rangoon' THEN 54 WHEN input_value = 'Asia/Bangkok' THEN 55 WHEN input_value = 'Asia/Krasnoyarsk' THEN 56 WHEN input_value = 'Asia/Shanghai' THEN 57 WHEN input_value = 'Asia/Irkutsk' THEN 58 WHEN input_value = 'Asia/Kuala_Lumpur' THEN 59 WHEN input_value = 'Asia/Perth' THEN 60 WHEN input_value = 'Asia/Tokyo' THEN 62 WHEN input_value = 'Asia/Seoul' THEN 63 WHEN input_value = 'Asia/Yakutsk' THEN 64 WHEN input_value = 'Asia/Adelaide' THEN 65 WHEN input_value = 'Australia/Darwin' THEN 66 WHEN input_value = 'Australia/Brisbane' THEN 67 WHEN input_value = 'Australia/Sydney' THEN 68 WHEN input_value = 'Australia/Melbourne' THEN 68 WHEN input_value = 'Australia/Hobart' THEN 68 WHEN input_value = 'Pacific/Guam' THEN 69 WHEN input_value = 'Australia/Adelaide' THEN 70 WHEN input_value = 'Australia/Perth' THEN 71 WHEN input_value = 'Pacific/Auckland' THEN 73 WHEN input_value = 'Pacific/Fiji' THEN 74 WHEN input_value = 'Pacific/Midway' THEN 76 WHEN input_value = 'Pacific/Samoa' THEN 77 WHEN input_value = 'Pacific/Guadalcanal' THEN 78 WHEN input_value = 'Pacific/Port_Moresby' THEN 79 WHEN input_value = 'Pacific/Noumea' THEN 80 WHEN input_value = 'Pacific/Kiritimati' THEN 81 WHEN input_value = 'Pacific/Kwajalein' THEN 82 WHEN input_value = 'Pacific/Apia' THEN 83 WHEN input_value = 'Pacific/Chatham' THEN 84 WHEN input_value = 'Pacific/Easter' THEN 85 WHEN input_value = 'Pacific/Galapagos' THEN 86 WHEN input_value = 'Pacific/Marquesas' THEN 87 WHEN input_value = 'Pacific/Gambier' THEN 88 WHEN input_value = 'Pacific/Pitcairn' THEN 89 WHEN input_value = 'Pacific/Niue' THEN 90 WHEN input_value = 'Pacific/Pago_Pago' THEN 91 WHEN input_value = 'Pacific/Rarotonga' THEN 92 WHEN input_value = 'Pacific/Tahiti' THEN 93 WHEN input_value = 'Pacific/Tarawa' THEN 94 WHEN input_value = 'Pacific/Wake' THEN 95 WHEN input_value = 'Pacific/Wallis' THEN 96 WHEN input_value = 'Pacific/Tongatapu' THEN 97 WHEN input_value = 'Pacific/Fakaofo' THEN 98 WHEN input_value = 'Pacific/Chuuk' THEN 99 WHEN input_value = 'Pacific/Pohnpei' THEN 100 WHEN input_value = 'Pacific/Kosrae' THEN 101 WHEN input_value = 'Pacific/Majuro' THEN 102 WHEN input_value = 'Pacific/Kwajalein' THEN 103 WHEN input_value = 'Pacific/Nauru' THEN 104 WHEN input_value = 'Pacific/Funafuti' THEN 105 WHEN input_value = 'Pacific/Wallis' THEN 106 WHEN input_value = 'Pacific/Tokelau' THEN 107 WHEN input_value = 'Pacific/Kanton' THEN 108 WHEN input_value = 'Pacific/Fakaofo' THEN 109 WHEN input_value = 'Pacific/Chatham' THEN 110 WHEN input_value = 'Pacific/Easter' THEN 111 WHEN input_value = 'Pacific/Galapagos' THEN 112 WHEN input_value = 'Pacific/Marquesas' THEN 113 WHEN input_value = 'EST' THEN 14 WHEN input_value = 'CST' THEN 9 WHEN input_value = 'MST' THEN 8 WHEN input_value = 'PST' THEN 5 WHEN input_value = 'HST' THEN 3 WHEN input_value = 'AKST' THEN 4 WHEN input_value = 'GMT' THEN 26 WHEN input_value = 'UTC' THEN 28 ELSE  END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "usercode", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "User Type", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Consumer, Contractor, Employee, External User, Intern, Temporary, Unspecified"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Employment Status‡", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "On Leave, Onboarding, Terminated, Working"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Leave Reason‡", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Administrative, Compassionate, Disability, Education, Force Majeure, Jury Service, Medical,Military, Parental, Sabbatical, Suspension,Temporary commission"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Termination Type‡", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Termination Reason‡", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Better Opportunity, Career Change, Company leadership, Conviction of a Crime, Deceased, Declined offer, Dishonesty/Falsification/Theft, Education, Employee-job fit, End of casual employment, End of Contract, Fail to return from leave, Forced retirement, Inadequate Benefits, Inadequate Compensation, Job abandonment, Lack of Career Growth, Lack of Training/Development, Legally ineligible, Manager dissatisfaction, Medical, Move/relocation, Negligence, Offshoring, Policy violation, Poor attendance, Reduction in force/Layoff, Redundancy, Retired, Transfer, Unsatisfactory performance, Work Location, Work Schedule"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Termination Date‡", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "DateTime", csod.char_length = "", csod.default_value = "", csod.accepted_values = " "
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Eligible for Rehire‡", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "eligible, ineligible, 1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Rehired Employee‡", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Primary Domain Name", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Division*", file: "Core_Employee-CHR"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Primary Job Name", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Position*", file: "Core_Employee-CHR"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Grade", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Primary Organization Name", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Cost Center*", file: "Core_Employee-CHR"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Location", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Legal Entity", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Social Team", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Cohort Roster", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Client Account", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "TranslationTEst", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "01344780", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Company", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "HR Partner", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Emergency Contact Name", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "next of kin contact", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Dropdown", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Spouse/Partner, Parent, Child, Sibling, Other Relative, Friend"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;

MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Emergency Contact Primary Telephone", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Emergency Contact Secondary Telephone", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (st:SumTotalField {name: "Primary Job JoiningDate", file: "Core_Employee-CHR"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Job Date", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "DateTime", csod.char_length = "", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Practice Learner", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Checkbox", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive, False, True"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "diana", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "RadioButton", csod.char_length = " ", csod.default_value = "english", csod.accepted_values = "english"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Base Salary", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = " ", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_Employee-CHR"})
MERGE (csod:CSODField {name: "Availability Status", file: "Core_Employee-CHR"})
SET csod.mandatory = "Optional", csod.field_type = "Dropdown", csod.char_length = " ", csod.default_value = "", csod.accepted_values = "Yes, No"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;

MERGE (f:File {name: "Core_DivisionOU"})
MERGE (st:SumTotalField {name: "Organization Code", file: "Core_DivisionOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "OU ID*", file: "Core_DivisionOU"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_DivisionOU"})
MERGE (st:SumTotalField {name: "Organization Name", file: "Core_DivisionOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "OU Name*", file: "Core_DivisionOU"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_DivisionOU"})
MERGE (csod:CSODField {name: "Active", file: "Core_DivisionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "1", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_DivisionOU"})
MERGE (csod:CSODField {name: "Allow Reconciliation", file: "Core_DivisionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "0", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_DivisionOU"})
MERGE (st:SumTotalField {name: "Parent OrganizationCode", file: "Core_DivisionOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Parent ID", file: "Core_DivisionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_DivisionOU"})
MERGE (st:SumTotalField {name: "Owner EmployeeId", file: "Core_DivisionOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Owner ID", file: "Core_DivisionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_DivisionOU"})
MERGE (st:SumTotalField {name: "Organization Description(Note)", file: "Core_DivisionOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Description", file: "Core_DivisionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "4000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_DivisionOU"})
MERGE (csod:CSODField {name: "Avenegers squad", file: "Core_DivisionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_DivisionOU"})
MERGE (csod:CSODField {name: "Practice", file: "Core_DivisionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Dropdown", csod.char_length = "", csod.default_value = "-1", csod.accepted_values = "Active, Temporary, Contract"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_PositionOU"})
MERGE (st:SumTotalField {name: "JOB_CODE", file: "Core_PositionOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "OU ID*", file: "Core_PositionOU"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_PositionOU"})
MERGE (st:SumTotalField {name: "JOB_NAME", file: "Core_PositionOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "OU Name*", file: "Core_PositionOU"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_PositionOU"})
MERGE (csod:CSODField {name: "Active", file: "Core_PositionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "1", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_PositionOU"})
MERGE (csod:CSODField {name: "Allow Reconciliation", file: "Core_PositionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "0", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_PositionOU"})
MERGE (csod:CSODField {name: "Parent ID", file: "Core_PositionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_PositionOU"})
MERGE (st:SumTotalField {name: "created By EmployeeID", file: "Core_PositionOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Owner ID", file: "Core_PositionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_PositionOU"})
MERGE (st:SumTotalField {name: "JOB_DESC", file: "Core_PositionOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Description", file: "Core_PositionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "4000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_PositionOU"})
MERGE (csod:CSODField {name: "Req- Person ID Number", file: "Core_PositionOU"})
SET csod.mandatory = "Optional", csod.field_type = "LocalizedShortTextBox", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_PositionOU"})
MERGE (csod:CSODField {name: "Critical Position", file: "Core_PositionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_PositionOU"})
MERGE (csod:CSODField {name: "Plan Owner OU ID", file: "Core_PositionOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;

MERGE (f:File {name: "Core_CostCenterOU"})
MERGE (st:SumTotalField {name: "Organization Code", file: "Core_CostCenterOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "OU ID*", file: "Core_CostCenterOU"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_CostCenterOU"})
MERGE (st:SumTotalField {name: "Organization Name", file: "Core_CostCenterOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "OU Name*", file: "Core_CostCenterOU"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_CostCenterOU"})
MERGE (csod:CSODField {name: "Active", file: "Core_CostCenterOU"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "1", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_CostCenterOU"})
MERGE (csod:CSODField {name: "Allow Reconciliation", file: "Core_CostCenterOU"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "0", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_CostCenterOU"})
MERGE (st:SumTotalField {name: "Parent OrganizationCode", file: "Core_CostCenterOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Parent ID", file: "Core_CostCenterOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_CostCenterOU"})
MERGE (st:SumTotalField {name: "Owner EmployeeId", file: "Core_CostCenterOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Owner ID", file: "Core_CostCenterOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_CostCenterOU"})
MERGE (st:SumTotalField {name: "Organization Description(Note)", file: "Core_CostCenterOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Description", file: "Core_CostCenterOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "4000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_CostCenterOU"})
MERGE (csod:CSODField {name: "Approver ID", file: "Core_CostCenterOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;

MERGE (f:File {name: "Core_GroupsOU"})
MERGE (st:SumTotalField {name: "Audience Code", file: "Core_GroupsOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "OU ID*", file: "Core_GroupsOU"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_GroupsOU"})
MERGE (st:SumTotalField {name: "Audience Name", file: "Core_GroupsOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "OU Name*", file: "Core_GroupsOU"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_GroupsOU"})
MERGE (st:SumTotalField {name: "Audience Active", file: "Core_GroupsOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Active", file: "Core_GroupsOU"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "1", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_GroupsOU"})
MERGE (csod:CSODField {name: "Allow Reconciliation", file: "Core_GroupsOU"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "0", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_GroupsOU"})
MERGE (csod:CSODField {name: "Parent ID", file: "Core_GroupsOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_GroupsOU"})
MERGE (csod:CSODField {name: "Owner ID", file: "Core_GroupsOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_GroupsOU"})
MERGE (st:SumTotalField {name: "Audience Description", file: "Core_GroupsOU"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Description", file: "Core_GroupsOU"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "4000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Core_GroupsOU"})
MERGE (csod:CSODField {name: "Freeze Group Processing", file: "Core_GroupsOU"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "0", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;


MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (st:SumTotalField {name: "VendorName", file: "Prerequisites_Provider"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Provider Name*", file: "Prerequisites_Provider"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (st:SumTotalField {name: "Provider Type", file: "Prerequisites_Provider"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Provider Type*", file: "Prerequisites_Provider"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "ONLINE, ILT"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "Active", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "True", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "Address 1", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "Address 2", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "City", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "ZIP", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "State/Province", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "Country", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", 
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "",
    csod.transformation = "CASE WHEN input_value = 'Afghanistan' THEN 'AFG' WHEN input_value = 'AF' THEN 'AFG' WHEN input_value = 'Albania' THEN 'ALB' WHEN input_value = 'AL' THEN 'ALB' WHEN input_value = 'Algeria' THEN 'DZA' WHEN input_value = 'DZ' THEN 'DZA' WHEN input_value = 'American Samoa' THEN 'ASM' WHEN input_value = 'AS' THEN 'ASM' WHEN input_value = 'Andorra' THEN 'AND' WHEN input_value = 'AD' THEN 'AND' WHEN input_value = 'Angola' THEN 'AGO' WHEN input_value = 'AO' THEN 'AGO' WHEN input_value = 'Anguilla' THEN 'AIA' WHEN input_value = 'AI' THEN 'AIA' WHEN input_value = 'Antarctica' THEN 'ATA' WHEN input_value = 'AQ' THEN 'ATA' WHEN input_value = 'Antigua and Barbuda' THEN 'ATG' WHEN input_value = 'AG' THEN 'ATG' WHEN input_value = 'Argentina' THEN 'ARG' WHEN input_value = 'AR' THEN 'ARG' WHEN input_value = 'Armenia' THEN 'ARM' WHEN input_value = 'AM' THEN 'ARM' WHEN input_value = 'Aruba' THEN 'ABW' WHEN input_value = 'AW' THEN 'ABW' WHEN input_value = 'Australia' THEN 'AUS' WHEN input_value = 'AU' THEN 'AUS' WHEN input_value = 'Austria' THEN 'AUT' WHEN input_value = 'AT' THEN 'AUT' WHEN input_value = 'Azerbaijan' THEN 'AZE' WHEN input_value = 'AZ' THEN 'AZE' WHEN input_value = 'Bahamas' THEN 'BHS' WHEN input_value = 'BS' THEN 'BHS' WHEN input_value = 'Bahrain' THEN 'BHR' WHEN input_value = 'BH' THEN 'BHR' WHEN input_value = 'Bangladesh' THEN 'BGD' WHEN input_value = 'BD' THEN 'BGD' WHEN input_value = 'Barbados' THEN 'BRB' WHEN input_value = 'BB' THEN 'BRB' WHEN input_value = 'Belarus' THEN 'BLR' WHEN input_value = 'BY' THEN 'BLR' WHEN input_value = 'Belgium' THEN 'BEL' WHEN input_value = 'BE' THEN 'BEL' WHEN input_value = 'Belize' THEN 'BLZ' WHEN input_value = 'BZ' THEN 'BLZ' WHEN input_value = 'Benin' THEN 'BEN' WHEN input_value = 'BJ' THEN 'BEN' WHEN input_value = 'Bermuda' THEN 'BMU' WHEN input_value = 'BM' THEN 'BMU' WHEN input_value = 'Bhutan' THEN 'BTN' WHEN input_value = 'BT' THEN 'BTN' WHEN input_value = 'Bolivia' THEN 'BOL' WHEN input_value = 'BO' THEN 'BOL' WHEN input_value = 'Bosnia and Herzegovina' THEN 'BIH' WHEN input_value = 'BA' THEN 'BIH' WHEN input_value = 'Botswana' THEN 'BWA' WHEN input_value = 'BW' THEN 'BWA' WHEN input_value = 'Bouvet Island' THEN 'BVT' WHEN input_value = 'BV' THEN 'BVT' WHEN input_value = 'Brazil' THEN 'BRA' WHEN input_value = 'BR' THEN 'BRA' WHEN input_value = 'British Indian Ocean Territory' THEN 'IOT' WHEN input_value = 'IO' THEN 'IOT' WHEN input_value = 'Brunei' THEN 'BRN' WHEN input_value = 'Brunei Darussalam' THEN 'BRN' WHEN input_value = 'BN' THEN 'BRN' WHEN input_value = 'Bulgaria' THEN 'BGR' WHEN input_value = 'BG' THEN 'BGR' WHEN input_value = 'Burkina Faso' THEN 'BFA' WHEN input_value = 'BF' THEN 'BFA' WHEN input_value = 'Burundi' THEN 'BDI' WHEN input_value = 'BI' THEN 'BDI' WHEN input_value = 'Cambodia' THEN 'KHM' WHEN input_value = 'KH' THEN 'KHM' WHEN input_value = 'Cameroon' THEN 'CMR' WHEN input_value = 'CM' THEN 'CMR' WHEN input_value = 'Canada' THEN 'CAN' WHEN input_value = 'CA' THEN 'CAN' WHEN input_value = 'Cape Verde' THEN 'CPV' WHEN input_value = 'CV' THEN 'CPV' WHEN input_value = 'Cayman Islands' THEN 'CYM' WHEN input_value = 'KY' THEN 'CYM' WHEN input_value = 'Central African Republic' THEN 'CAF' WHEN input_value = 'CF' THEN 'CAF' WHEN input_value = 'Chad' THEN 'TCD' WHEN input_value = 'TD' THEN 'TCD' WHEN input_value = 'Chile' THEN 'CHL' WHEN input_value = 'CL' THEN 'CHL' WHEN input_value = 'China' THEN 'CHN' WHEN input_value = 'CN' THEN 'CHN' WHEN input_value = 'Christmas Island' THEN 'CXR' WHEN input_value = 'CX' THEN 'CXR' WHEN input_value = 'Cocos Islands' THEN 'CCK' WHEN input_value = 'Cocos (Keeling) Islands' THEN 'CCK' WHEN input_value = 'CC' THEN 'CCK' WHEN input_value = 'Colombia' THEN 'COL' WHEN input_value = 'CO' THEN 'COL' WHEN input_value = 'Comoros' THEN 'COM' WHEN input_value = 'KM' THEN 'COM' WHEN input_value = 'Congo' THEN 'COG' WHEN input_value = 'CG' THEN 'COG' WHEN input_value = 'Congo, Democratic Republic' THEN 'COD' WHEN input_value = 'Democratic Republic of the Congo' THEN 'COD' WHEN input_value = 'CD' THEN 'COD' WHEN input_value = 'Cook Islands' THEN 'COK' WHEN input_value = 'CK' THEN 'COK' WHEN input_value = 'Costa Rica' THEN 'CRI' WHEN input_value = 'CR' THEN 'CRI' WHEN input_value = 'Cote d'Ivoire' THEN 'CIV' WHEN input_value = 'Ivory Coast' THEN 'CIV' WHEN input_value = 'CI' THEN 'CIV' WHEN input_value = 'Croatia' THEN 'HRV' WHEN input_value = 'HR' THEN 'HRV' WHEN input_value = 'Cuba' THEN 'CUB' WHEN input_value = 'CU' THEN 'CUB' WHEN input_value = 'Cyprus' THEN 'CYP' WHEN input_value = 'CY' THEN 'CYP' WHEN input_value = 'Czech Republic' THEN 'CZE' WHEN input_value = 'CZ' THEN 'CZE' WHEN input_value = 'Denmark' THEN 'DNK' WHEN input_value = 'DK' THEN 'DNK' WHEN input_value = 'Djibouti' THEN 'DJI' WHEN input_value = 'DJ' THEN 'DJI' WHEN input_value = 'Dominica' THEN 'DMA' WHEN input_value = 'DM' THEN 'DMA' WHEN input_value = 'Dominican Republic' THEN 'DOM' WHEN input_value = 'DO' THEN 'DOM' WHEN input_value = 'Ecuador' THEN 'ECU' WHEN input_value = 'EC' THEN 'ECU' WHEN input_value = 'Egypt' THEN 'EGY' WHEN input_value = 'EG' THEN 'EGY' WHEN input_value = 'El Salvador' THEN 'SLV' WHEN input_value = 'SV' THEN 'SLV' WHEN input_value = 'Equatorial Guinea' THEN 'GNQ' WHEN input_value = 'GQ' THEN 'GNQ' WHEN input_value = 'Eritrea' THEN 'ERI' WHEN input_value = 'ER' THEN 'ERI' WHEN input_value = 'Estonia' THEN 'EST' WHEN input_value = 'EE' THEN 'EST' WHEN input_value = 'Ethiopia' THEN 'ETH' WHEN input_value = 'ET' THEN 'ETH' WHEN input_value = 'Falkland Islands' THEN 'FLK' WHEN input_value = 'FK' THEN 'FLK' WHEN input_value = 'Faroe Islands' THEN 'FRO' WHEN input_value = 'FO' THEN 'FRO' WHEN input_value = 'Fiji' THEN 'FJI' WHEN input_value = 'FJ' THEN 'FJI' WHEN input_value = 'Finland' THEN 'FIN' WHEN input_value = 'FI' THEN 'FIN' WHEN input_value = 'France' THEN 'FRA' WHEN input_value = 'FR' THEN 'FRA' WHEN input_value = 'French Guiana' THEN 'GUF' WHEN input_value = 'GF' THEN 'GUF' WHEN input_value = 'French Polynesia' THEN 'PYF' WHEN input_value = 'PF' THEN 'PYF' WHEN input_value = 'French Southern Territories' THEN 'ATF' WHEN input_value = 'TF' THEN 'ATF' WHEN input_value = 'Gabon' THEN 'GAB' WHEN input_value = 'GA' THEN 'GAB' WHEN input_value = 'Gambia' THEN 'GMB' WHEN input_value = 'GM' THEN 'GMB' WHEN input_value = 'Georgia' THEN 'GEO' WHEN input_value = 'GE' THEN 'GEO' WHEN input_value = 'Germany' THEN 'DEU' WHEN input_value = 'DE' THEN 'DEU' WHEN input_value = 'Ghana' THEN 'GHA' WHEN input_value = 'GH' THEN 'GHA' WHEN input_value = 'Gibraltar' THEN 'GIB' WHEN input_value = 'GI' THEN 'GIB' WHEN input_value = 'Greece' THEN 'GRC' WHEN input_value = 'GR' THEN 'GRC' WHEN input_value = 'Greenland' THEN 'GRL' WHEN input_value = 'GL' THEN 'GRL' WHEN input_value = 'Grenada' THEN 'GRD' WHEN input_value = 'GD' THEN 'GRD' WHEN input_value = 'Guadeloupe' THEN 'GLP' WHEN input_value = 'GP' THEN 'GLP' WHEN input_value = 'Guam' THEN 'GUM' WHEN input_value = 'GU' THEN 'GUM' WHEN input_value = 'Guatemala' THEN 'GTM' WHEN input_value = 'GT' THEN 'GTM' WHEN input_value = 'Guinea' THEN 'GIN' WHEN input_value = 'GN' THEN 'GIN' WHEN input_value = 'Guinea-Bissau' THEN 'GNB' WHEN input_value = 'GW' THEN 'GNB' WHEN input_value = 'Guyana' THEN 'GUY' WHEN input_value = 'GY' THEN 'GUY' WHEN input_value = 'Haiti' THEN 'HTI' WHEN input_value = 'HT' THEN 'HTI' WHEN input_value = 'Heard Island and McDonald Islands' THEN 'HMD' WHEN input_value = 'HM' THEN 'HMD' WHEN input_value = 'Vatican City' THEN 'VAT' WHEN input_value = 'Holy See' THEN 'VAT' WHEN input_value = 'VA' THEN 'VAT' WHEN input_value = 'Honduras' THEN 'HND' WHEN input_value = 'HN' THEN 'HND' WHEN input_value = 'Hong Kong' THEN 'HKG' WHEN input_value = 'HK' THEN 'HKG' WHEN input_value = 'Hungary' THEN 'HUN' WHEN input_value = 'HU' THEN 'HUN' WHEN input_value = 'Iceland' THEN 'ISL' WHEN input_value = 'IS' THEN 'ISL' WHEN input_value = 'India' THEN 'IND' WHEN input_value = 'IN' THEN 'IND' WHEN input_value = 'Indonesia' THEN 'IDN' WHEN input_value = 'ID' THEN 'IDN' WHEN input_value = 'Iran' THEN 'IRN' WHEN input_value = 'IR' THEN 'IRN' WHEN input_value = 'Iraq' THEN 'IRQ' WHEN input_value = 'IQ' THEN 'IRQ' WHEN input_value = 'Ireland' THEN 'IRL' WHEN input_value = 'IE' THEN 'IRL' WHEN input_value = 'Israel' THEN 'ISR' WHEN input_value = 'IL' THEN 'ISR' WHEN input_value = 'Italy' THEN 'ITA' WHEN input_value = 'IT' THEN 'ITA' WHEN input_value = 'Jamaica' THEN 'JAM' WHEN input_value = 'JM' THEN 'JAM' WHEN input_value = 'Japan' THEN 'JPN' WHEN input_value = 'JP' THEN 'JPN' WHEN input_value = 'Jordan' THEN 'JOR' WHEN input_value = 'JO' THEN 'JOR' WHEN input_value = 'Kazakhstan' THEN 'KAZ' WHEN input_value = 'KZ' THEN 'KAZ' WHEN input_value = 'Kenya' THEN 'KEN' WHEN input_value = 'KE' THEN 'KEN' WHEN input_value = 'Kiribati' THEN 'KIR' WHEN input_value = 'KI' THEN 'KIR' WHEN input_value = 'North Korea' THEN 'PRK' WHEN input_value = 'KP' THEN 'PRK' WHEN input_value = 'South Korea' THEN 'KOR' WHEN input_value = 'Korea' THEN 'KOR' WHEN input_value = 'KR' THEN 'KOR' WHEN input_value = 'Kuwait' THEN 'KWT' WHEN input_value = 'KW' THEN 'KWT' WHEN input_value = 'Kyrgyzstan' THEN 'KGZ' WHEN input_value = 'KG' THEN 'KGZ' WHEN input_value = 'Laos' THEN 'LAO' WHEN input_value = 'LA' THEN 'LAO' WHEN input_value = 'Latvia' THEN 'LVA' WHEN input_value = 'LV' THEN 'LVA' WHEN input_value = 'Lebanon' THEN 'LBN' WHEN input_value = 'LB' THEN 'LBN' WHEN input_value = 'Lesotho' THEN 'LSO' WHEN input_value = 'LS' THEN 'LSO' WHEN input_value = 'Liberia' THEN 'LBR' WHEN input_value = 'LR' THEN 'LBR' WHEN input_value = 'Libya' THEN 'LBY' WHEN input_value = 'LY' THEN 'LBY' WHEN input_value = 'Liechtenstein' THEN 'LIE' WHEN input_value = 'LI' THEN 'LIE' WHEN input_value = 'Lithuania' THEN 'LTU' WHEN input_value = 'LT' THEN 'LTU' WHEN input_value = 'Luxembourg' THEN 'LUX' WHEN input_value = 'LU' THEN 'LUX' WHEN input_value = 'Macao' THEN 'MAC' WHEN input_value = 'Macau' THEN 'MAC' WHEN input_value = 'MO' THEN 'MAC' WHEN input_value = 'Macedonia' THEN 'MKD' WHEN input_value = 'North Macedonia' THEN 'MKD' WHEN input_value = 'MK' THEN 'MKD' WHEN input_value = 'Madagascar' THEN 'MDG' WHEN input_value = 'MG' THEN 'MDG' WHEN input_value = 'Malawi' THEN 'MWI' WHEN input_value = 'MW' THEN 'MWI' WHEN input_value = 'Malaysia' THEN 'MYS' WHEN input_value = 'MY' THEN 'MYS' WHEN input_value = 'Maldives' THEN 'MDV' WHEN input_value = 'MV' THEN 'MDV' WHEN input_value = 'Mali' THEN 'MLI' WHEN input_value = 'ML' THEN 'MLI' WHEN input_value = 'Malta' THEN 'MLT' WHEN input_value = 'MT' THEN 'MLT' WHEN input_value = 'Marshall Islands' THEN 'MHL' WHEN input_value = 'MH' THEN 'MHL' WHEN input_value = 'Martinique' THEN 'MTQ' WHEN input_value = 'MQ' THEN 'MTQ' WHEN input_value = 'Mauritania' THEN 'MRT' WHEN input_value = 'MR' THEN 'MRT' WHEN input_value = 'Mauritius' THEN 'MUS' WHEN input_value = 'MU' THEN 'MUS' WHEN input_value = 'Mayotte' THEN 'MYT' WHEN input_value = 'YT' THEN 'MYT' WHEN input_value = 'Mexico' THEN 'MEX' WHEN input_value = 'MX' THEN 'MEX' WHEN input_value = 'Micronesia' THEN 'FSM' WHEN input_value = 'FM' THEN 'FSM' WHEN input_value = 'Moldova' THEN 'MDA' WHEN input_value = 'MD' THEN 'MDA' WHEN input_value = 'Monaco' THEN 'MCO' WHEN input_value = 'MC' THEN 'MCO' WHEN input_value = 'Mongolia' THEN 'MNG' WHEN input_value = 'MN' THEN 'MNG' WHEN input_value = 'Montenegro' THEN 'MNE' WHEN input_value = 'ME' THEN 'MNE' WHEN input_value = 'Montserrat' THEN 'MSR' WHEN input_value = 'MS' THEN 'MSR' WHEN input_value = 'Morocco' THEN 'MAR' WHEN input_value = 'MA' THEN 'MAR' WHEN input_value = 'Mozambique' THEN 'MOZ' WHEN input_value = 'MZ' THEN 'MOZ' WHEN input_value = 'Myanmar' THEN 'MMR' WHEN input_value = 'Burma' THEN 'MMR' WHEN input_value = 'MM' THEN 'MMR' WHEN input_value = 'Namibia' THEN 'NAM' WHEN input_value = 'NA' THEN 'NAM' WHEN input_value = 'Nauru' THEN 'NRU' WHEN input_value = 'NR' THEN 'NRU' WHEN input_value = 'Nepal' THEN 'NPL' WHEN input_value = 'NP' THEN 'NPL' WHEN input_value = 'Netherlands' THEN 'NLD' WHEN input_value = 'NL' THEN 'NLD' WHEN input_value = 'Netherlands Antilles' THEN 'ANT' WHEN input_value = 'AN' THEN 'ANT' WHEN input_value = 'New Caledonia' THEN 'NCL' WHEN input_value = 'NC' THEN 'NCL' WHEN input_value = 'New Zealand' THEN 'NZL' WHEN input_value = 'NZ' THEN 'NZL' WHEN input_value = 'Nicaragua' THEN 'NIC' WHEN input_value = 'NI' THEN 'NIC' WHEN input_value = 'Niger' THEN 'NER' WHEN input_value = 'NE' THEN 'NER' WHEN input_value = 'Nigeria' THEN 'NGA' WHEN input_value = 'NG' THEN 'NGA' WHEN input_value = 'Niue' THEN 'NIU' WHEN input_value = 'NU' THEN 'NIU' WHEN input_value = 'Norfolk Island' THEN 'NFK' WHEN input_value = 'NF' THEN 'NFK' WHEN input_value = 'Northern Mariana Islands' THEN 'MNP' WHEN input_value = 'MP' THEN 'MNP' WHEN input_value = 'Norway' THEN 'NOR' WHEN input_value = 'NO' THEN 'NOR' WHEN input_value = 'Oman' THEN 'OMN' WHEN input_value = 'OM' THEN 'OMN' WHEN input_value = 'Pakistan' THEN 'PAK' WHEN input_value = 'PK' THEN 'PAK' WHEN input_value = 'Palau' THEN 'PLW' WHEN input_value = 'PW' THEN 'PLW' WHEN input_value = 'Palestine' THEN 'PSE' WHEN input_value = 'PS' THEN 'PSE' WHEN input_value = 'Panama' THEN 'PAN' WHEN input_value = 'PA' THEN 'PAN' WHEN input_value = 'Papua New Guinea' THEN 'PNG' WHEN input_value = 'PG' THEN 'PNG' WHEN input_value = 'Paraguay' THEN 'PRY' WHEN input_value = 'PY' THEN 'PRY' WHEN input_value = 'Peru' THEN 'PER' WHEN input_value = 'PE' THEN 'PER' WHEN input_value = 'Philippines' THEN 'PHL' WHEN input_value = 'PH' THEN 'PHL' WHEN input_value = 'Pitcairn' THEN 'PCN' WHEN input_value = 'PN' THEN 'PCN' WHEN input_value = 'Poland' THEN 'POL' WHEN input_value = 'PL' THEN 'POL' WHEN input_value = 'Portugal' THEN 'PRT' WHEN input_value = 'PT' THEN 'PRT' WHEN input_value = 'Puerto Rico' THEN 'PRI' WHEN input_value = 'PR' THEN 'PRI' WHEN input_value = 'Qatar' THEN 'QAT' WHEN input_value = 'QA' THEN 'QAT' WHEN input_value = 'Reunion' THEN 'REU' WHEN input_value = 'RE' THEN 'REU' WHEN input_value = 'Romania' THEN 'ROU' WHEN input_value = 'RO' THEN 'ROU' WHEN input_value = 'Russia' THEN 'RUS' WHEN input_value = 'Russian Federation' THEN 'RUS' WHEN input_value = 'RU' THEN 'RUS' WHEN input_value = 'Rwanda' THEN 'RWA' WHEN input_value = 'RW' THEN 'RWA' WHEN input_value = 'Saint Helena' THEN 'SHN' WHEN input_value = 'SH' THEN 'SHN' WHEN input_value = 'Saint Kitts and Nevis' THEN 'KNA' WHEN input_value = 'KN' THEN 'KNA' WHEN input_value = 'Saint Lucia' THEN 'LCA' WHEN input_value = 'LC' THEN 'LCA' WHEN input_value = 'Saint Pierre and Miquelon' THEN 'SPM' WHEN input_value = 'PM' THEN 'SPM' WHEN input_value = 'Saint Vincent and the Grenadines' THEN 'VCT' WHEN input_value = 'VC' THEN 'VCT' WHEN input_value = 'Samoa' THEN 'WSM' WHEN input_value = 'WS' THEN 'WSM' WHEN input_value = 'San Marino' THEN 'SMR' WHEN input_value = 'SM' THEN 'SMR' WHEN input_value = 'Sao Tome and Principe' THEN 'STP' WHEN input_value = 'ST' THEN 'STP' WHEN input_value = 'Saudi Arabia' THEN 'SAU' WHEN input_value = 'SA' THEN 'SAU' WHEN input_value = 'Senegal' THEN 'SEN' WHEN input_value = 'SN' THEN 'SEN' WHEN input_value = 'Serbia' THEN 'SRB' WHEN input_value = 'RS' THEN 'SRB' WHEN input_value = 'Seychelles' THEN 'SYC' WHEN input_value = 'SC' THEN 'SYC' WHEN input_value = 'Sierra Leone' THEN 'SLE' WHEN input_value = 'SL' THEN 'SLE' WHEN input_value = 'Singapore' THEN 'SGP' WHEN input_value = 'SG' THEN 'SGP' WHEN input_value = 'Slovakia' THEN 'SVK' WHEN input_value = 'SK' THEN 'SVK' WHEN input_value = 'Slovenia' THEN 'SVN' WHEN input_value = 'SI' THEN 'SVN' WHEN input_value = 'Solomon Islands' THEN 'SLB' WHEN input_value = 'SB' THEN 'SLB' WHEN input_value = 'Somalia' THEN 'SOM' WHEN input_value = 'SO' THEN 'SOM' WHEN input_value = 'South Africa' THEN 'ZAF' WHEN input_value = 'ZA' THEN 'ZAF' WHEN input_value = 'South Georgia and South Sandwich Islands' THEN 'SGS' WHEN input_value = 'GS' THEN 'SGS' WHEN input_value = 'South Sudan' THEN 'SSD' WHEN input_value = 'SS' THEN 'SSD' WHEN input_value = 'Spain' THEN 'ESP' WHEN input_value = 'ES' THEN 'ESP' WHEN input_value = 'Sri Lanka' THEN 'LKA' WHEN input_value = 'LK' THEN 'LKA' WHEN input_value = 'Sudan' THEN 'SDN' WHEN input_value = 'SD' THEN 'SDN' WHEN input_value = 'Suriname' THEN 'SUR' WHEN input_value = 'SR' THEN 'SUR' WHEN input_value = 'Svalbard and Jan Mayen' THEN 'SJM' WHEN input_value = 'SJ' THEN 'SJM' WHEN input_value = 'Swaziland' THEN 'SWZ' WHEN input_value = 'Eswatini' THEN 'SWZ' WHEN input_value = 'SZ' THEN 'SWZ' WHEN input_value = 'Sweden' THEN 'SWE' WHEN input_value = 'SE' THEN 'SWE' WHEN input_value = 'Switzerland' THEN 'CHE' WHEN input_value = 'CH' THEN 'CHE' WHEN input_value = 'Syria' THEN 'SYR' WHEN input_value = 'SY' THEN 'SYR' WHEN input_value = 'Taiwan' THEN 'TWN' WHEN input_value = 'TW' THEN 'TWN' WHEN input_value = 'Tajikistan' THEN 'TJK' WHEN input_value = 'TJ' THEN 'TJK' WHEN input_value = 'Tanzania' THEN 'TZA' WHEN input_value = 'TZ' THEN 'TZA' WHEN input_value = 'Thailand' THEN 'THA' WHEN input_value = 'TH' THEN 'THA' WHEN input_value = 'Timor-Leste' THEN 'TLS' WHEN input_value = 'East Timor' THEN 'TLS' WHEN input_value = 'TL' THEN 'TLS' WHEN input_value = 'Togo' THEN 'TGO' WHEN input_value = 'TG' THEN 'TGO' WHEN input_value = 'Tokelau' THEN 'TKL' WHEN input_value = 'TK' THEN 'TKL' WHEN input_value = 'Tonga' THEN 'TON' WHEN input_value = 'TO' THEN 'TON' WHEN input_value = 'Trinidad and Tobago' THEN 'TTO' WHEN input_value = 'TT' THEN 'TTO' WHEN input_value = 'Tunisia' THEN 'TUN' WHEN input_value = 'TN' THEN 'TUN' WHEN input_value = 'Turkey' THEN 'TUR' WHEN input_value = 'TR' THEN 'TUR' WHEN input_value = 'Turkmenistan' THEN 'TKM' WHEN input_value = 'TM' THEN 'TKM' WHEN input_value = 'Turks and Caicos Islands' THEN 'TCA' WHEN input_value = 'TC' THEN 'TCA' WHEN input_value = 'Tuvalu' THEN 'TUV' WHEN input_value = 'TV' THEN 'TUV' WHEN input_value = 'Uganda' THEN 'UGA' WHEN input_value = 'UG' THEN 'UGA' WHEN input_value = 'Ukraine' THEN 'UKR' WHEN input_value = 'UA' THEN 'UKR' WHEN input_value = 'United Arab Emirates' THEN 'ARE' WHEN input_value = 'UAE' THEN 'ARE' WHEN input_value = 'AE' THEN 'ARE' WHEN input_value = 'United Kingdom' THEN 'GBR' WHEN input_value = 'UK' THEN 'GBR' WHEN input_value = 'Great Britain' THEN 'GBR' WHEN input_value = 'Britain' THEN 'GBR' WHEN input_value = 'England' THEN 'GBR' WHEN input_value = 'Scotland' THEN 'GBR' WHEN input_value = 'Wales' THEN 'GBR' WHEN input_value = 'Northern Ireland' THEN 'GBR' WHEN input_value = 'GB' THEN 'GBR' WHEN input_value = 'United States' THEN 'USA' WHEN input_value = 'United States of America' THEN 'USA' WHEN input_value = 'US' THEN 'USA' WHEN input_value = 'USA' THEN 'USA' WHEN input_value = 'America' THEN 'USA' WHEN input_value = 'United States Minor Outlying Islands' THEN 'UMI' WHEN input_value = 'UM' THEN 'UMI' WHEN input_value = 'Uruguay' THEN 'URY' WHEN input_value = 'UY' THEN 'URY' WHEN input_value = 'Uzbekistan' THEN 'UZB' WHEN input_value = 'UZ' THEN 'UZB' WHEN input_value = 'Vanuatu' THEN 'VUT' WHEN input_value = 'VU' THEN 'VUT' WHEN input_value = 'Venezuela' THEN 'VEN' WHEN input_value = 'VE' THEN 'VEN' WHEN input_value = 'Vietnam' THEN 'VNM' WHEN input_value = 'VN' THEN 'VNM' WHEN input_value = 'British Virgin Islands' THEN 'VGB' WHEN input_value = 'VG' THEN 'VGB' WHEN input_value = 'US Virgin Islands' THEN 'VIR' WHEN input_value = 'Virgin Islands' THEN 'VIR' WHEN input_value = 'VI' THEN 'VIR' WHEN input_value = 'Wallis and Futuna' THEN 'WLF' WHEN input_value = 'WF' THEN 'WLF' WHEN input_value = 'Western Sahara' THEN 'ESH' WHEN input_value = 'EH' THEN 'ESH' WHEN input_value = 'Yemen' THEN 'YEM' WHEN input_value = 'YE' THEN 'YEM' WHEN input_value = 'Zambia' THEN 'ZMB' WHEN input_value = 'ZM' THEN 'ZMB' WHEN input_value = 'Zimbabwe' THEN 'ZWE' WHEN input_value = 'ZW' THEN 'ZWE' ELSE '' END"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "Contact Name", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "Phone number", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "Fax number", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "URL", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", csod.field_type = "Url", csod.char_length = "225", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "Email", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Provider"})
MERGE (csod:CSODField {name: "Description", file: "Prerequisites_Provider"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "FacilityId", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Facility Id*", file: "Prerequisites_Facility" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "Facility Name", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Facility Name*", file: "Prerequisites_Facility" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (csod:CSODField {name: "Active", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "Facility Type", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Facility Type*", file: "Prerequisites_Facility" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Region, City, Building, Floor, Room, Seat/Desk, Not Specified"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "TimeZone", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Time Zone ID*", file: "Prerequisites_Facility" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "", csod.transformation = "CASE WHEN input_value = 'America/New_York' THEN 14 WHEN input_value = 'America/Chicago' THEN 9 WHEN input_value = 'America/Los_Angeles' THEN 5 WHEN input_value = 'America/Denver' THEN 8 WHEN input_value = 'America/Phoenix' THEN 8 WHEN input_value = 'America/Anchorage' THEN 4 WHEN input_value = 'America/Juneau' THEN 4 WHEN input_value = 'Pacific/Honolulu' THEN 3 WHEN input_value = 'America/Honolulu' THEN 3 WHEN input_value = 'America/Toronto' THEN 14 WHEN input_value = 'America/Montreal' THEN 14 WHEN input_value = 'America/Vancouver' THEN 5 WHEN input_value = 'America/Seattle' THEN 5 WHEN input_value = 'America/Calgary' THEN 8 WHEN input_value = 'America/Edmonton' THEN 8 WHEN input_value = 'America/Winnipeg' THEN 9 WHEN input_value = 'America/Regina' THEN 9 WHEN input_value = 'America/Saskatoon' THEN 9 WHEN input_value = 'America/Halifax' THEN 16 WHEN input_value = 'America/Moncton' THEN 16 WHEN input_value = 'America/St_Johns' THEN 74 WHEN input_value = 'Europe/London' THEN 26 WHEN input_value = 'Europe/Dublin' THEN 26 WHEN input_value = 'Europe/Lisbon' THEN 26 WHEN input_value = 'Europe/Amsterdam' THEN 28 WHEN input_value = 'Europe/Berlin' THEN 28 WHEN input_value = 'Europe/Rome' THEN 28 WHEN input_value = 'Europe/Vienna' THEN 28 WHEN input_value = 'Europe/Stockholm' THEN 28 WHEN input_value = 'Europe/Belgrade' THEN 29 WHEN input_value = 'Europe/Bratislava' THEN 29 WHEN input_value = 'Europe/Budapest' THEN 29 WHEN input_value = 'Europe/Ljubljana' THEN 29 WHEN input_value = 'Europe/Prague' THEN 29 WHEN input_value = 'Europe/Brussels' THEN 30 WHEN input_value = 'Europe/Copenhagen' THEN 30 WHEN input_value = 'Europe/Madrid' THEN 30 WHEN input_value = 'Europe/Paris' THEN 30 WHEN input_value = 'Europe/Sarajevo' THEN 31 WHEN input_value = 'Europe/Skopje' THEN 31 WHEN input_value = 'Europe/Warsaw' THEN 31 WHEN input_value = 'Europe/Zagreb' THEN 31 WHEN input_value = 'Europe/Athens' THEN 33 WHEN input_value = 'Europe/Bucharest' THEN 33 WHEN input_value = 'Europe/Helsinki' THEN 34 WHEN input_value = 'Europe/Kiev' THEN 34 WHEN input_value = 'Europe/Riga' THEN 34 WHEN input_value = 'Asia/Jerusalem' THEN 35 WHEN input_value = 'Asia/Baghdad' THEN 36 WHEN input_value = 'Asia/Kuwait' THEN 37 WHEN input_value = 'Asia/Riyadh' THEN 37 WHEN input_value = 'Asia/Tehran' THEN 38 WHEN input_value = 'Asia/Muscat' THEN 39 WHEN input_value = 'Asia/Baku' THEN 40 WHEN input_value = 'Asia/Tbilisi' THEN 41 WHEN input_value = 'Asia/Yerevan' THEN 42 WHEN input_value = 'Asia/Kabul' THEN 43 WHEN input_value = 'Asia/Yekaterinburg' THEN 47 WHEN input_value = 'Asia/Tashkent' THEN 48 WHEN input_value = 'Asia/Kolkata' THEN 49 WHEN input_value = 'Asia/Kathmandu' THEN 50 WHEN input_value = 'Asia/Novosibirsk' THEN 51 WHEN input_value = 'Asia/Almaty' THEN 52 WHEN input_value = 'Asia/Dhaka' THEN 53 WHEN input_value = 'Asia/Rangoon' THEN 54 WHEN input_value = 'Asia/Bangkok' THEN 55 WHEN input_value = 'Asia/Krasnoyarsk' THEN 56 WHEN input_value = 'Asia/Shanghai' THEN 57 WHEN input_value = 'Asia/Irkutsk' THEN 58 WHEN input_value = 'Asia/Kuala_Lumpur' THEN 59 WHEN input_value = 'Asia/Perth' THEN 60 WHEN input_value = 'Asia/Tokyo' THEN 62 WHEN input_value = 'Asia/Seoul' THEN 63 WHEN input_value = 'Asia/Yakutsk' THEN 64 WHEN input_value = 'Asia/Adelaide' THEN 65 WHEN input_value = 'Australia/Darwin' THEN 66 WHEN input_value = 'Australia/Brisbane' THEN 67 WHEN input_value = 'Australia/Sydney' THEN 68 WHEN input_value = 'Australia/Melbourne' THEN 68 WHEN input_value = 'Australia/Hobart' THEN 68 WHEN input_value = 'Pacific/Guam' THEN 69 WHEN input_value = 'Australia/Adelaide' THEN 70 WHEN input_value = 'Australia/Perth' THEN 71 WHEN input_value = 'Pacific/Auckland' THEN 73 WHEN input_value = 'Pacific/Fiji' THEN 74 WHEN input_value = 'Pacific/Midway' THEN 76 WHEN input_value = 'Pacific/Samoa' THEN 77 WHEN input_value = 'Pacific/Guadalcanal' THEN 78 WHEN input_value = 'Pacific/Port_Moresby' THEN 79 WHEN input_value = 'Pacific/Noumea' THEN 80 WHEN input_value = 'Pacific/Kiritimati' THEN 81 WHEN input_value = 'Pacific/Kwajalein' THEN 82 WHEN input_value = 'Pacific/Apia' THEN 83 WHEN input_value = 'Pacific/Chatham' THEN 84 WHEN input_value = 'Pacific/Easter' THEN 85 WHEN input_value = 'Pacific/Galapagos' THEN 86 WHEN input_value = 'Pacific/Marquesas' THEN 87 WHEN input_value = 'Pacific/Gambier' THEN 88 WHEN input_value = 'Pacific/Pitcairn' THEN 89 WHEN input_value = 'Pacific/Niue' THEN 90 WHEN input_value = 'Pacific/Pago_Pago' THEN 91 WHEN input_value = 'Pacific/Rarotonga' THEN 92 WHEN input_value = 'Pacific/Tahiti' THEN 93 WHEN input_value = 'Pacific/Tarawa' THEN 94 WHEN input_value = 'Pacific/Wake' THEN 95 WHEN input_value = 'Pacific/Wallis' THEN 96 WHEN input_value = 'Pacific/Tongatapu' THEN 97 WHEN input_value = 'Pacific/Fakaofo' THEN 98 WHEN input_value = 'Pacific/Chuuk' THEN 99 WHEN input_value = 'Pacific/Pohnpei' THEN 100 WHEN input_value = 'Pacific/Kosrae' THEN 101 WHEN input_value = 'Pacific/Majuro' THEN 102 WHEN input_value = 'Pacific/Kwajalein' THEN 103 WHEN input_value = 'Pacific/Nauru' THEN 104 WHEN input_value = 'Pacific/Funafuti' THEN 105 WHEN input_value = 'Pacific/Wallis' THEN 106 WHEN input_value = 'Pacific/Tokelau' THEN 107 WHEN input_value = 'Pacific/Kanton' THEN 108 WHEN input_value = 'Pacific/Fakaofo' THEN 109 WHEN input_value = 'Pacific/Chatham' THEN 110 WHEN input_value = 'Pacific/Easter' THEN 111 WHEN input_value = 'Pacific/Galapagos' THEN 112 WHEN input_value = 'Pacific/Marquesas' THEN 113 WHEN input_value = 'EST' THEN 14 WHEN input_value = 'CST' THEN 9 WHEN input_value = 'MST' THEN 8 WHEN input_value = 'PST' THEN 5 WHEN input_value = 'HST' THEN 3 WHEN input_value = 'AKST' THEN 4 WHEN input_value = 'GMT' THEN 26 WHEN input_value = 'UTC' THEN 28 ELSE  END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "Approval Required", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Approval Required", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (csod:CSODField {name: "On site", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "TRUE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (csod:CSODField {name: "Allow Reconcile", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "FALSE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (csod:CSODField {name: "Parent ID", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "Address 1", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Address 1", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "55", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "Address 2", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Address 2", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "55", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "City", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "City", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "35", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "State", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "State", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "30", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "Zip", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Zip", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "20", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "Country", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Country", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", 
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "",
    csod.transformation = "CASE WHEN input_value = 'Afghanistan' THEN 'AFG' WHEN input_value = 'AF' THEN 'AFG' WHEN input_value = 'Albania' THEN 'ALB' WHEN input_value = 'AL' THEN 'ALB' WHEN input_value = 'Algeria' THEN 'DZA' WHEN input_value = 'DZ' THEN 'DZA' WHEN input_value = 'American Samoa' THEN 'ASM' WHEN input_value = 'AS' THEN 'ASM' WHEN input_value = 'Andorra' THEN 'AND' WHEN input_value = 'AD' THEN 'AND' WHEN input_value = 'Angola' THEN 'AGO' WHEN input_value = 'AO' THEN 'AGO' WHEN input_value = 'Anguilla' THEN 'AIA' WHEN input_value = 'AI' THEN 'AIA' WHEN input_value = 'Antarctica' THEN 'ATA' WHEN input_value = 'AQ' THEN 'ATA' WHEN input_value = 'Antigua and Barbuda' THEN 'ATG' WHEN input_value = 'AG' THEN 'ATG' WHEN input_value = 'Argentina' THEN 'ARG' WHEN input_value = 'AR' THEN 'ARG' WHEN input_value = 'Armenia' THEN 'ARM' WHEN input_value = 'AM' THEN 'ARM' WHEN input_value = 'Aruba' THEN 'ABW' WHEN input_value = 'AW' THEN 'ABW' WHEN input_value = 'Australia' THEN 'AUS' WHEN input_value = 'AU' THEN 'AUS' WHEN input_value = 'Austria' THEN 'AUT' WHEN input_value = 'AT' THEN 'AUT' WHEN input_value = 'Azerbaijan' THEN 'AZE' WHEN input_value = 'AZ' THEN 'AZE' WHEN input_value = 'Bahamas' THEN 'BHS' WHEN input_value = 'BS' THEN 'BHS' WHEN input_value = 'Bahrain' THEN 'BHR' WHEN input_value = 'BH' THEN 'BHR' WHEN input_value = 'Bangladesh' THEN 'BGD' WHEN input_value = 'BD' THEN 'BGD' WHEN input_value = 'Barbados' THEN 'BRB' WHEN input_value = 'BB' THEN 'BRB' WHEN input_value = 'Belarus' THEN 'BLR' WHEN input_value = 'BY' THEN 'BLR' WHEN input_value = 'Belgium' THEN 'BEL' WHEN input_value = 'BE' THEN 'BEL' WHEN input_value = 'Belize' THEN 'BLZ' WHEN input_value = 'BZ' THEN 'BLZ' WHEN input_value = 'Benin' THEN 'BEN' WHEN input_value = 'BJ' THEN 'BEN' WHEN input_value = 'Bermuda' THEN 'BMU' WHEN input_value = 'BM' THEN 'BMU' WHEN input_value = 'Bhutan' THEN 'BTN' WHEN input_value = 'BT' THEN 'BTN' WHEN input_value = 'Bolivia' THEN 'BOL' WHEN input_value = 'BO' THEN 'BOL' WHEN input_value = 'Bosnia and Herzegovina' THEN 'BIH' WHEN input_value = 'BA' THEN 'BIH' WHEN input_value = 'Botswana' THEN 'BWA' WHEN input_value = 'BW' THEN 'BWA' WHEN input_value = 'Bouvet Island' THEN 'BVT' WHEN input_value = 'BV' THEN 'BVT' WHEN input_value = 'Brazil' THEN 'BRA' WHEN input_value = 'BR' THEN 'BRA' WHEN input_value = 'British Indian Ocean Territory' THEN 'IOT' WHEN input_value = 'IO' THEN 'IOT' WHEN input_value = 'Brunei' THEN 'BRN' WHEN input_value = 'Brunei Darussalam' THEN 'BRN' WHEN input_value = 'BN' THEN 'BRN' WHEN input_value = 'Bulgaria' THEN 'BGR' WHEN input_value = 'BG' THEN 'BGR' WHEN input_value = 'Burkina Faso' THEN 'BFA' WHEN input_value = 'BF' THEN 'BFA' WHEN input_value = 'Burundi' THEN 'BDI' WHEN input_value = 'BI' THEN 'BDI' WHEN input_value = 'Cambodia' THEN 'KHM' WHEN input_value = 'KH' THEN 'KHM' WHEN input_value = 'Cameroon' THEN 'CMR' WHEN input_value = 'CM' THEN 'CMR' WHEN input_value = 'Canada' THEN 'CAN' WHEN input_value = 'CA' THEN 'CAN' WHEN input_value = 'Cape Verde' THEN 'CPV' WHEN input_value = 'CV' THEN 'CPV' WHEN input_value = 'Cayman Islands' THEN 'CYM' WHEN input_value = 'KY' THEN 'CYM' WHEN input_value = 'Central African Republic' THEN 'CAF' WHEN input_value = 'CF' THEN 'CAF' WHEN input_value = 'Chad' THEN 'TCD' WHEN input_value = 'TD' THEN 'TCD' WHEN input_value = 'Chile' THEN 'CHL' WHEN input_value = 'CL' THEN 'CHL' WHEN input_value = 'China' THEN 'CHN' WHEN input_value = 'CN' THEN 'CHN' WHEN input_value = 'Christmas Island' THEN 'CXR' WHEN input_value = 'CX' THEN 'CXR' WHEN input_value = 'Cocos Islands' THEN 'CCK' WHEN input_value = 'Cocos (Keeling) Islands' THEN 'CCK' WHEN input_value = 'CC' THEN 'CCK' WHEN input_value = 'Colombia' THEN 'COL' WHEN input_value = 'CO' THEN 'COL' WHEN input_value = 'Comoros' THEN 'COM' WHEN input_value = 'KM' THEN 'COM' WHEN input_value = 'Congo' THEN 'COG' WHEN input_value = 'CG' THEN 'COG' WHEN input_value = 'Congo, Democratic Republic' THEN 'COD' WHEN input_value = 'Democratic Republic of the Congo' THEN 'COD' WHEN input_value = 'CD' THEN 'COD' WHEN input_value = 'Cook Islands' THEN 'COK' WHEN input_value = 'CK' THEN 'COK' WHEN input_value = 'Costa Rica' THEN 'CRI' WHEN input_value = 'CR' THEN 'CRI' WHEN input_value = 'Cote d'Ivoire' THEN 'CIV' WHEN input_value = 'Ivory Coast' THEN 'CIV' WHEN input_value = 'CI' THEN 'CIV' WHEN input_value = 'Croatia' THEN 'HRV' WHEN input_value = 'HR' THEN 'HRV' WHEN input_value = 'Cuba' THEN 'CUB' WHEN input_value = 'CU' THEN 'CUB' WHEN input_value = 'Cyprus' THEN 'CYP' WHEN input_value = 'CY' THEN 'CYP' WHEN input_value = 'Czech Republic' THEN 'CZE' WHEN input_value = 'CZ' THEN 'CZE' WHEN input_value = 'Denmark' THEN 'DNK' WHEN input_value = 'DK' THEN 'DNK' WHEN input_value = 'Djibouti' THEN 'DJI' WHEN input_value = 'DJ' THEN 'DJI' WHEN input_value = 'Dominica' THEN 'DMA' WHEN input_value = 'DM' THEN 'DMA' WHEN input_value = 'Dominican Republic' THEN 'DOM' WHEN input_value = 'DO' THEN 'DOM' WHEN input_value = 'Ecuador' THEN 'ECU' WHEN input_value = 'EC' THEN 'ECU' WHEN input_value = 'Egypt' THEN 'EGY' WHEN input_value = 'EG' THEN 'EGY' WHEN input_value = 'El Salvador' THEN 'SLV' WHEN input_value = 'SV' THEN 'SLV' WHEN input_value = 'Equatorial Guinea' THEN 'GNQ' WHEN input_value = 'GQ' THEN 'GNQ' WHEN input_value = 'Eritrea' THEN 'ERI' WHEN input_value = 'ER' THEN 'ERI' WHEN input_value = 'Estonia' THEN 'EST' WHEN input_value = 'EE' THEN 'EST' WHEN input_value = 'Ethiopia' THEN 'ETH' WHEN input_value = 'ET' THEN 'ETH' WHEN input_value = 'Falkland Islands' THEN 'FLK' WHEN input_value = 'FK' THEN 'FLK' WHEN input_value = 'Faroe Islands' THEN 'FRO' WHEN input_value = 'FO' THEN 'FRO' WHEN input_value = 'Fiji' THEN 'FJI' WHEN input_value = 'FJ' THEN 'FJI' WHEN input_value = 'Finland' THEN 'FIN' WHEN input_value = 'FI' THEN 'FIN' WHEN input_value = 'France' THEN 'FRA' WHEN input_value = 'FR' THEN 'FRA' WHEN input_value = 'French Guiana' THEN 'GUF' WHEN input_value = 'GF' THEN 'GUF' WHEN input_value = 'French Polynesia' THEN 'PYF' WHEN input_value = 'PF' THEN 'PYF' WHEN input_value = 'French Southern Territories' THEN 'ATF' WHEN input_value = 'TF' THEN 'ATF' WHEN input_value = 'Gabon' THEN 'GAB' WHEN input_value = 'GA' THEN 'GAB' WHEN input_value = 'Gambia' THEN 'GMB' WHEN input_value = 'GM' THEN 'GMB' WHEN input_value = 'Georgia' THEN 'GEO' WHEN input_value = 'GE' THEN 'GEO' WHEN input_value = 'Germany' THEN 'DEU' WHEN input_value = 'DE' THEN 'DEU' WHEN input_value = 'Ghana' THEN 'GHA' WHEN input_value = 'GH' THEN 'GHA' WHEN input_value = 'Gibraltar' THEN 'GIB' WHEN input_value = 'GI' THEN 'GIB' WHEN input_value = 'Greece' THEN 'GRC' WHEN input_value = 'GR' THEN 'GRC' WHEN input_value = 'Greenland' THEN 'GRL' WHEN input_value = 'GL' THEN 'GRL' WHEN input_value = 'Grenada' THEN 'GRD' WHEN input_value = 'GD' THEN 'GRD' WHEN input_value = 'Guadeloupe' THEN 'GLP' WHEN input_value = 'GP' THEN 'GLP' WHEN input_value = 'Guam' THEN 'GUM' WHEN input_value = 'GU' THEN 'GUM' WHEN input_value = 'Guatemala' THEN 'GTM' WHEN input_value = 'GT' THEN 'GTM' WHEN input_value = 'Guinea' THEN 'GIN' WHEN input_value = 'GN' THEN 'GIN' WHEN input_value = 'Guinea-Bissau' THEN 'GNB' WHEN input_value = 'GW' THEN 'GNB' WHEN input_value = 'Guyana' THEN 'GUY' WHEN input_value = 'GY' THEN 'GUY' WHEN input_value = 'Haiti' THEN 'HTI' WHEN input_value = 'HT' THEN 'HTI' WHEN input_value = 'Heard Island and McDonald Islands' THEN 'HMD' WHEN input_value = 'HM' THEN 'HMD' WHEN input_value = 'Vatican City' THEN 'VAT' WHEN input_value = 'Holy See' THEN 'VAT' WHEN input_value = 'VA' THEN 'VAT' WHEN input_value = 'Honduras' THEN 'HND' WHEN input_value = 'HN' THEN 'HND' WHEN input_value = 'Hong Kong' THEN 'HKG' WHEN input_value = 'HK' THEN 'HKG' WHEN input_value = 'Hungary' THEN 'HUN' WHEN input_value = 'HU' THEN 'HUN' WHEN input_value = 'Iceland' THEN 'ISL' WHEN input_value = 'IS' THEN 'ISL' WHEN input_value = 'India' THEN 'IND' WHEN input_value = 'IN' THEN 'IND' WHEN input_value = 'Indonesia' THEN 'IDN' WHEN input_value = 'ID' THEN 'IDN' WHEN input_value = 'Iran' THEN 'IRN' WHEN input_value = 'IR' THEN 'IRN' WHEN input_value = 'Iraq' THEN 'IRQ' WHEN input_value = 'IQ' THEN 'IRQ' WHEN input_value = 'Ireland' THEN 'IRL' WHEN input_value = 'IE' THEN 'IRL' WHEN input_value = 'Israel' THEN 'ISR' WHEN input_value = 'IL' THEN 'ISR' WHEN input_value = 'Italy' THEN 'ITA' WHEN input_value = 'IT' THEN 'ITA' WHEN input_value = 'Jamaica' THEN 'JAM' WHEN input_value = 'JM' THEN 'JAM' WHEN input_value = 'Japan' THEN 'JPN' WHEN input_value = 'JP' THEN 'JPN' WHEN input_value = 'Jordan' THEN 'JOR' WHEN input_value = 'JO' THEN 'JOR' WHEN input_value = 'Kazakhstan' THEN 'KAZ' WHEN input_value = 'KZ' THEN 'KAZ' WHEN input_value = 'Kenya' THEN 'KEN' WHEN input_value = 'KE' THEN 'KEN' WHEN input_value = 'Kiribati' THEN 'KIR' WHEN input_value = 'KI' THEN 'KIR' WHEN input_value = 'North Korea' THEN 'PRK' WHEN input_value = 'KP' THEN 'PRK' WHEN input_value = 'South Korea' THEN 'KOR' WHEN input_value = 'Korea' THEN 'KOR' WHEN input_value = 'KR' THEN 'KOR' WHEN input_value = 'Kuwait' THEN 'KWT' WHEN input_value = 'KW' THEN 'KWT' WHEN input_value = 'Kyrgyzstan' THEN 'KGZ' WHEN input_value = 'KG' THEN 'KGZ' WHEN input_value = 'Laos' THEN 'LAO' WHEN input_value = 'LA' THEN 'LAO' WHEN input_value = 'Latvia' THEN 'LVA' WHEN input_value = 'LV' THEN 'LVA' WHEN input_value = 'Lebanon' THEN 'LBN' WHEN input_value = 'LB' THEN 'LBN' WHEN input_value = 'Lesotho' THEN 'LSO' WHEN input_value = 'LS' THEN 'LSO' WHEN input_value = 'Liberia' THEN 'LBR' WHEN input_value = 'LR' THEN 'LBR' WHEN input_value = 'Libya' THEN 'LBY' WHEN input_value = 'LY' THEN 'LBY' WHEN input_value = 'Liechtenstein' THEN 'LIE' WHEN input_value = 'LI' THEN 'LIE' WHEN input_value = 'Lithuania' THEN 'LTU' WHEN input_value = 'LT' THEN 'LTU' WHEN input_value = 'Luxembourg' THEN 'LUX' WHEN input_value = 'LU' THEN 'LUX' WHEN input_value = 'Macao' THEN 'MAC' WHEN input_value = 'Macau' THEN 'MAC' WHEN input_value = 'MO' THEN 'MAC' WHEN input_value = 'Macedonia' THEN 'MKD' WHEN input_value = 'North Macedonia' THEN 'MKD' WHEN input_value = 'MK' THEN 'MKD' WHEN input_value = 'Madagascar' THEN 'MDG' WHEN input_value = 'MG' THEN 'MDG' WHEN input_value = 'Malawi' THEN 'MWI' WHEN input_value = 'MW' THEN 'MWI' WHEN input_value = 'Malaysia' THEN 'MYS' WHEN input_value = 'MY' THEN 'MYS' WHEN input_value = 'Maldives' THEN 'MDV' WHEN input_value = 'MV' THEN 'MDV' WHEN input_value = 'Mali' THEN 'MLI' WHEN input_value = 'ML' THEN 'MLI' WHEN input_value = 'Malta' THEN 'MLT' WHEN input_value = 'MT' THEN 'MLT' WHEN input_value = 'Marshall Islands' THEN 'MHL' WHEN input_value = 'MH' THEN 'MHL' WHEN input_value = 'Martinique' THEN 'MTQ' WHEN input_value = 'MQ' THEN 'MTQ' WHEN input_value = 'Mauritania' THEN 'MRT' WHEN input_value = 'MR' THEN 'MRT' WHEN input_value = 'Mauritius' THEN 'MUS' WHEN input_value = 'MU' THEN 'MUS' WHEN input_value = 'Mayotte' THEN 'MYT' WHEN input_value = 'YT' THEN 'MYT' WHEN input_value = 'Mexico' THEN 'MEX' WHEN input_value = 'MX' THEN 'MEX' WHEN input_value = 'Micronesia' THEN 'FSM' WHEN input_value = 'FM' THEN 'FSM' WHEN input_value = 'Moldova' THEN 'MDA' WHEN input_value = 'MD' THEN 'MDA' WHEN input_value = 'Monaco' THEN 'MCO' WHEN input_value = 'MC' THEN 'MCO' WHEN input_value = 'Mongolia' THEN 'MNG' WHEN input_value = 'MN' THEN 'MNG' WHEN input_value = 'Montenegro' THEN 'MNE' WHEN input_value = 'ME' THEN 'MNE' WHEN input_value = 'Montserrat' THEN 'MSR' WHEN input_value = 'MS' THEN 'MSR' WHEN input_value = 'Morocco' THEN 'MAR' WHEN input_value = 'MA' THEN 'MAR' WHEN input_value = 'Mozambique' THEN 'MOZ' WHEN input_value = 'MZ' THEN 'MOZ' WHEN input_value = 'Myanmar' THEN 'MMR' WHEN input_value = 'Burma' THEN 'MMR' WHEN input_value = 'MM' THEN 'MMR' WHEN input_value = 'Namibia' THEN 'NAM' WHEN input_value = 'NA' THEN 'NAM' WHEN input_value = 'Nauru' THEN 'NRU' WHEN input_value = 'NR' THEN 'NRU' WHEN input_value = 'Nepal' THEN 'NPL' WHEN input_value = 'NP' THEN 'NPL' WHEN input_value = 'Netherlands' THEN 'NLD' WHEN input_value = 'NL' THEN 'NLD' WHEN input_value = 'Netherlands Antilles' THEN 'ANT' WHEN input_value = 'AN' THEN 'ANT' WHEN input_value = 'New Caledonia' THEN 'NCL' WHEN input_value = 'NC' THEN 'NCL' WHEN input_value = 'New Zealand' THEN 'NZL' WHEN input_value = 'NZ' THEN 'NZL' WHEN input_value = 'Nicaragua' THEN 'NIC' WHEN input_value = 'NI' THEN 'NIC' WHEN input_value = 'Niger' THEN 'NER' WHEN input_value = 'NE' THEN 'NER' WHEN input_value = 'Nigeria' THEN 'NGA' WHEN input_value = 'NG' THEN 'NGA' WHEN input_value = 'Niue' THEN 'NIU' WHEN input_value = 'NU' THEN 'NIU' WHEN input_value = 'Norfolk Island' THEN 'NFK' WHEN input_value = 'NF' THEN 'NFK' WHEN input_value = 'Northern Mariana Islands' THEN 'MNP' WHEN input_value = 'MP' THEN 'MNP' WHEN input_value = 'Norway' THEN 'NOR' WHEN input_value = 'NO' THEN 'NOR' WHEN input_value = 'Oman' THEN 'OMN' WHEN input_value = 'OM' THEN 'OMN' WHEN input_value = 'Pakistan' THEN 'PAK' WHEN input_value = 'PK' THEN 'PAK' WHEN input_value = 'Palau' THEN 'PLW' WHEN input_value = 'PW' THEN 'PLW' WHEN input_value = 'Palestine' THEN 'PSE' WHEN input_value = 'PS' THEN 'PSE' WHEN input_value = 'Panama' THEN 'PAN' WHEN input_value = 'PA' THEN 'PAN' WHEN input_value = 'Papua New Guinea' THEN 'PNG' WHEN input_value = 'PG' THEN 'PNG' WHEN input_value = 'Paraguay' THEN 'PRY' WHEN input_value = 'PY' THEN 'PRY' WHEN input_value = 'Peru' THEN 'PER' WHEN input_value = 'PE' THEN 'PER' WHEN input_value = 'Philippines' THEN 'PHL' WHEN input_value = 'PH' THEN 'PHL' WHEN input_value = 'Pitcairn' THEN 'PCN' WHEN input_value = 'PN' THEN 'PCN' WHEN input_value = 'Poland' THEN 'POL' WHEN input_value = 'PL' THEN 'POL' WHEN input_value = 'Portugal' THEN 'PRT' WHEN input_value = 'PT' THEN 'PRT' WHEN input_value = 'Puerto Rico' THEN 'PRI' WHEN input_value = 'PR' THEN 'PRI' WHEN input_value = 'Qatar' THEN 'QAT' WHEN input_value = 'QA' THEN 'QAT' WHEN input_value = 'Reunion' THEN 'REU' WHEN input_value = 'RE' THEN 'REU' WHEN input_value = 'Romania' THEN 'ROU' WHEN input_value = 'RO' THEN 'ROU' WHEN input_value = 'Russia' THEN 'RUS' WHEN input_value = 'Russian Federation' THEN 'RUS' WHEN input_value = 'RU' THEN 'RUS' WHEN input_value = 'Rwanda' THEN 'RWA' WHEN input_value = 'RW' THEN 'RWA' WHEN input_value = 'Saint Helena' THEN 'SHN' WHEN input_value = 'SH' THEN 'SHN' WHEN input_value = 'Saint Kitts and Nevis' THEN 'KNA' WHEN input_value = 'KN' THEN 'KNA' WHEN input_value = 'Saint Lucia' THEN 'LCA' WHEN input_value = 'LC' THEN 'LCA' WHEN input_value = 'Saint Pierre and Miquelon' THEN 'SPM' WHEN input_value = 'PM' THEN 'SPM' WHEN input_value = 'Saint Vincent and the Grenadines' THEN 'VCT' WHEN input_value = 'VC' THEN 'VCT' WHEN input_value = 'Samoa' THEN 'WSM' WHEN input_value = 'WS' THEN 'WSM' WHEN input_value = 'San Marino' THEN 'SMR' WHEN input_value = 'SM' THEN 'SMR' WHEN input_value = 'Sao Tome and Principe' THEN 'STP' WHEN input_value = 'ST' THEN 'STP' WHEN input_value = 'Saudi Arabia' THEN 'SAU' WHEN input_value = 'SA' THEN 'SAU' WHEN input_value = 'Senegal' THEN 'SEN' WHEN input_value = 'SN' THEN 'SEN' WHEN input_value = 'Serbia' THEN 'SRB' WHEN input_value = 'RS' THEN 'SRB' WHEN input_value = 'Seychelles' THEN 'SYC' WHEN input_value = 'SC' THEN 'SYC' WHEN input_value = 'Sierra Leone' THEN 'SLE' WHEN input_value = 'SL' THEN 'SLE' WHEN input_value = 'Singapore' THEN 'SGP' WHEN input_value = 'SG' THEN 'SGP' WHEN input_value = 'Slovakia' THEN 'SVK' WHEN input_value = 'SK' THEN 'SVK' WHEN input_value = 'Slovenia' THEN 'SVN' WHEN input_value = 'SI' THEN 'SVN' WHEN input_value = 'Solomon Islands' THEN 'SLB' WHEN input_value = 'SB' THEN 'SLB' WHEN input_value = 'Somalia' THEN 'SOM' WHEN input_value = 'SO' THEN 'SOM' WHEN input_value = 'South Africa' THEN 'ZAF' WHEN input_value = 'ZA' THEN 'ZAF' WHEN input_value = 'South Georgia and South Sandwich Islands' THEN 'SGS' WHEN input_value = 'GS' THEN 'SGS' WHEN input_value = 'South Sudan' THEN 'SSD' WHEN input_value = 'SS' THEN 'SSD' WHEN input_value = 'Spain' THEN 'ESP' WHEN input_value = 'ES' THEN 'ESP' WHEN input_value = 'Sri Lanka' THEN 'LKA' WHEN input_value = 'LK' THEN 'LKA' WHEN input_value = 'Sudan' THEN 'SDN' WHEN input_value = 'SD' THEN 'SDN' WHEN input_value = 'Suriname' THEN 'SUR' WHEN input_value = 'SR' THEN 'SUR' WHEN input_value = 'Svalbard and Jan Mayen' THEN 'SJM' WHEN input_value = 'SJ' THEN 'SJM' WHEN input_value = 'Swaziland' THEN 'SWZ' WHEN input_value = 'Eswatini' THEN 'SWZ' WHEN input_value = 'SZ' THEN 'SWZ' WHEN input_value = 'Sweden' THEN 'SWE' WHEN input_value = 'SE' THEN 'SWE' WHEN input_value = 'Switzerland' THEN 'CHE' WHEN input_value = 'CH' THEN 'CHE' WHEN input_value = 'Syria' THEN 'SYR' WHEN input_value = 'SY' THEN 'SYR' WHEN input_value = 'Taiwan' THEN 'TWN' WHEN input_value = 'TW' THEN 'TWN' WHEN input_value = 'Tajikistan' THEN 'TJK' WHEN input_value = 'TJ' THEN 'TJK' WHEN input_value = 'Tanzania' THEN 'TZA' WHEN input_value = 'TZ' THEN 'TZA' WHEN input_value = 'Thailand' THEN 'THA' WHEN input_value = 'TH' THEN 'THA' WHEN input_value = 'Timor-Leste' THEN 'TLS' WHEN input_value = 'East Timor' THEN 'TLS' WHEN input_value = 'TL' THEN 'TLS' WHEN input_value = 'Togo' THEN 'TGO' WHEN input_value = 'TG' THEN 'TGO' WHEN input_value = 'Tokelau' THEN 'TKL' WHEN input_value = 'TK' THEN 'TKL' WHEN input_value = 'Tonga' THEN 'TON' WHEN input_value = 'TO' THEN 'TON' WHEN input_value = 'Trinidad and Tobago' THEN 'TTO' WHEN input_value = 'TT' THEN 'TTO' WHEN input_value = 'Tunisia' THEN 'TUN' WHEN input_value = 'TN' THEN 'TUN' WHEN input_value = 'Turkey' THEN 'TUR' WHEN input_value = 'TR' THEN 'TUR' WHEN input_value = 'Turkmenistan' THEN 'TKM' WHEN input_value = 'TM' THEN 'TKM' WHEN input_value = 'Turks and Caicos Islands' THEN 'TCA' WHEN input_value = 'TC' THEN 'TCA' WHEN input_value = 'Tuvalu' THEN 'TUV' WHEN input_value = 'TV' THEN 'TUV' WHEN input_value = 'Uganda' THEN 'UGA' WHEN input_value = 'UG' THEN 'UGA' WHEN input_value = 'Ukraine' THEN 'UKR' WHEN input_value = 'UA' THEN 'UKR' WHEN input_value = 'United Arab Emirates' THEN 'ARE' WHEN input_value = 'UAE' THEN 'ARE' WHEN input_value = 'AE' THEN 'ARE' WHEN input_value = 'United Kingdom' THEN 'GBR' WHEN input_value = 'UK' THEN 'GBR' WHEN input_value = 'Great Britain' THEN 'GBR' WHEN input_value = 'Britain' THEN 'GBR' WHEN input_value = 'England' THEN 'GBR' WHEN input_value = 'Scotland' THEN 'GBR' WHEN input_value = 'Wales' THEN 'GBR' WHEN input_value = 'Northern Ireland' THEN 'GBR' WHEN input_value = 'GB' THEN 'GBR' WHEN input_value = 'United States' THEN 'USA' WHEN input_value = 'United States of America' THEN 'USA' WHEN input_value = 'US' THEN 'USA' WHEN input_value = 'USA' THEN 'USA' WHEN input_value = 'America' THEN 'USA' WHEN input_value = 'United States Minor Outlying Islands' THEN 'UMI' WHEN input_value = 'UM' THEN 'UMI' WHEN input_value = 'Uruguay' THEN 'URY' WHEN input_value = 'UY' THEN 'URY' WHEN input_value = 'Uzbekistan' THEN 'UZB' WHEN input_value = 'UZ' THEN 'UZB' WHEN input_value = 'Vanuatu' THEN 'VUT' WHEN input_value = 'VU' THEN 'VUT' WHEN input_value = 'Venezuela' THEN 'VEN' WHEN input_value = 'VE' THEN 'VEN' WHEN input_value = 'Vietnam' THEN 'VNM' WHEN input_value = 'VN' THEN 'VNM' WHEN input_value = 'British Virgin Islands' THEN 'VGB' WHEN input_value = 'VG' THEN 'VGB' WHEN input_value = 'US Virgin Islands' THEN 'VIR' WHEN input_value = 'Virgin Islands' THEN 'VIR' WHEN input_value = 'VI' THEN 'VIR' WHEN input_value = 'Wallis and Futuna' THEN 'WLF' WHEN input_value = 'WF' THEN 'WLF' WHEN input_value = 'Western Sahara' THEN 'ESH' WHEN input_value = 'EH' THEN 'ESH' WHEN input_value = 'Yemen' THEN 'YEM' WHEN input_value = 'YE' THEN 'YEM' WHEN input_value = 'Zambia' THEN 'ZMB' WHEN input_value = 'ZM' THEN 'ZMB' WHEN input_value = 'Zimbabwe' THEN 'ZWE' WHEN input_value = 'ZW' THEN 'ZWE' ELSE '' END"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "Contact", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Contact", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "Phone", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Phone", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "25", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "Fax", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Fax", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "25", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "Facility Email", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Facility Email", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (st:SumTotalField {name: "Occupancy", file: "Prerequisites_Facility"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Occupancy", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.max_value = "9999", csod.default_value = "0", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (csod:CSODField {name: "Created/Modified By", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Facility"})
MERGE (csod:CSODField {name: "Owner ID", file: "Prerequisites_Facility" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Subject"})
MERGE (st:SumTotalField {name: "Topic Code", file: "Prerequisites_Subject"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Subject Ref*", file: "Prerequisites_Subject" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "30", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Subject"})
MERGE (st:SumTotalField {name: "Parent topic code", file: "Prerequisites_Subject"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Parent Subject Ref", file: "Prerequisites_Subject" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "30", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Subject"})
MERGE (st:SumTotalField {name: "TopicName", file: "Prerequisites_Subject"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Title*", file: "Prerequisites_Subject" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Subject"})
MERGE (csod:CSODField {name: "Active", file: "Prerequisites_Subject" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "TRUE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (st:SumTotalField {name: "EmployeeId", file: "Prerequisites_Instructor"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Instructor ID*", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (st:SumTotalField {name: "ProviderName", file: "Prerequisites_Instructor"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Vendor/Provider*", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (st:SumTotalField {name: "EmployeeActive", file: "Prerequisites_Instructor"})
MERGE (f) -[:HAS_FIELD] -> (st)
MERGE (csod:CSODField {name: "Active", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "TRUE", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (st)-[:MAPS_TO]-> (csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (csod:CSODField {name: "Home Location", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (csod:CSODField {name: "Internal/External*", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Mandatory", csod.field_type = "", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Internal, External"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (csod:CSODField {name: "First Name", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (csod:CSODField {name: "Last Name", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (csod:CSODField {name: "Phone", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (csod:CSODField {name: "Fax", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (csod:CSODField {name: "Email", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (csod:CSODField {name: "Languages Spoken", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (csod:CSODField {name: "Education", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (csod:CSODField {name: "Biography", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE ( f:File {name: "Prerequisites_Instructor"})
MERGE (csod:CSODField {name: "Certifications", file: "Prerequisites_Instructor" })
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_QuestionsCategories"})
MERGE (st:SumTotalField {name: "QuestionBankCode", file: "Prerequisites_QuestionsCategories"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Category Ref*", file: "Prerequisites_QuestionsCategories"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_QuestionsCategories"})
MERGE (st:SumTotalField {name: "QuestionBankName", file: "Prerequisites_QuestionsCategories"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Category Name*", file: "Prerequisites_QuestionsCategories"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "100", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_QuestionsCategories"})
MERGE (csod:CSODField {name: "Active", file: "Prerequisites_QuestionsCategories"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_QuestionsCategories"})
MERGE (csod:CSODField {name: "Parent Category Ref", file: "Prerequisites_QuestionsCategories"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (st:SumTotalField {name: "QuestionID", file: "Prerequisites_Questions"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Question Reference Number*", file: "Prerequisites_Questions"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "50", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (st:SumTotalField {name: "Questiontext", file: "Prerequisites_Questions"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Question Text*", file: "Prerequisites_Questions"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (st:SumTotalField {name: "Questiontype", file: "Prerequisites_Questions"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Question Type*", file: "Prerequisites_Questions"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "", csod.default_value = "", csod.accepted_values = "Yes / No, True / False, Multiple Choice / Single Answer, Multiple Choice / Multiple Answer, Text Only, Free Form(Essay), Image"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (st:SumTotalField {name: "Correct Answer", file: "Prerequisites_Questions"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Correct Answer", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (st:SumTotalField {name: "QuestionBankCode", file: "Prerequisites_Questions"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Category Ref*", file: "Prerequisites_Questions"})
SET csod.mandatory = "Mandatory", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Default Language", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "", csod.default_value = "en-US", csod.accepted_values = "", csod.transformation = "CASE WHEN input_value = 'en-US' THEN 1 WHEN input_value = 'English (US)' THEN 1 WHEN input_value = 'en-GB' THEN 2 WHEN input_value = 'English (UK)' THEN 2 WHEN input_value = 'fr-FR' THEN 13 WHEN input_value = 'French (France)' THEN 13 WHEN input_value = 'es-MX' THEN 14 WHEN input_value = 'Spanish (Latin America)' THEN 14 ELSE ‘en-US’ END"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Active", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Randomize Answer Choices", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Answer Explanation", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "1000", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (st:SumTotalField {name: "# of Answer Choices", file: "Prerequisites_Questions"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "# of Answer Choices", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Integer", csod.char_length = "", csod.default_value = "0", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (st:SumTotalField {name: "All of the Above", file: "Prerequisites_Questions"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "All of the Above", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (st:SumTotalField {name: "None of the Above", file: "Prerequisites_Questions"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "None of the Above", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "False", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (st:SumTotalField {name: "Answer 1", file: "Prerequisites_Questions"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Answer 1", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (st:SumTotalField {name: "Answer 2", file: "Prerequisites_Questions"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Answer 2", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (st:SumTotalField {name: "Answer 3", file: "Prerequisites_Questions"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Answer 3", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (st:SumTotalField {name: "Answer 4", file: "Prerequisites_Questions"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Answer 4", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Answer 5", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Answer 6", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Answer 7", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Answer 8", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Answer 9", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Answer 10", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "500", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Image Filename", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "200", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Answer Coordinates", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "2000", csod.default_value = "", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Apply partial scoring", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Boolean", csod.char_length = "", csod.default_value = "", csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;
MERGE (f:File {name: "Prerequisites_Questions"})
MERGE (csod:CSODField {name: "Author", file: "Prerequisites_Questions"})
SET csod.mandatory = "Optional", csod.field_type = "Char", csod.char_length = "128", csod.default_value = "User performing the load", csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod)
;

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (st:SumTotalField {name: "EmployeeID", file: "Transcript_CurriculumTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "User ID*", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (st:SumTotalField {name: "ActivityCode", file: "Transcript_CurriculumTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Curriculum ID*", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (st:SumTotalField {name: "Training Status", file: "Transcript_CurriculumTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Transcript Status*", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Registered, Completed, Exempt"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (st:SumTotalField {name: "RegistrationDate", file: "Transcript_CurriculumTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Request Date/Time*", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "HHHHHH:MM:SS"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (st:SumTotalField {name: "RegistrationDate", file: "Transcript_CurriculumTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Registration Date/Time*", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "HHHHHH:MM:SS"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (csod:CSODField {name: "Transcript Action", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Create, Update"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (st:SumTotalField {name: "CompletionDate", file: "Transcript_CurriculumTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Completion Date/Time", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "HHHHHH:MM:SS"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (st:SumTotalField {name: "DueDate", file: "Transcript_CurriculumTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Due Date/Time‡", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "HHHHHH:MM:SS"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (csod:CSODField {name: "Archived", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Boolean",
    csod.char_length = "",
    csod.default_value = "false",
    csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (csod:CSODField {name: "User Exempt Reason", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "0",
    csod.accepted_values = "Other, Completed comparable training at prior organization, Acknowledged expert on subject matter, On leave, test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (csod:CSODField {name: "Approver Exempt Reason", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "0",
    csod.accepted_values = "Other, Completed comparable training at prior organization, Acknowledged expert on subject matter, On leave, test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (csod:CSODField {name: "User's Exemption Comments", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "EIL",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (csod:CSODField {name: "Approver's Exemption Comments", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "EIL",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (csod:CSODField {name: "Exempt By", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "User performing the load",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (st:SumTotalField {name: "Note", file: "Transcript_CurriculumTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Comments", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "245",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (csod:CSODField {name: "Training Purpose", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "テスト"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (csod:CSODField {name: "Training Points", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Apply, Delete"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_CurriculumTranscript"})
MERGE (csod:CSODField {name: "Training Badge", file: "Transcript_CurriculumTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Apply, Delete"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (st:SumTotalField {name: "EmployeeID", file: "Transcript_MaterialTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "User ID*", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (st:SumTotalField {name: "ActivityCode", file: "Transcript_MaterialTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Material ID*", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (st:SumTotalField {name: "TrainingStatus", file: "Transcript_MaterialTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Transcript Status*", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Registered, Completed, Exempt"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (st:SumTotalField {name: "RegistrationDate", file: "Transcript_MaterialTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Request Date/Time*", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "HHHHHH:MM:SS"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (st:SumTotalField {name: "RegistrationDate", file: "Transcript_MaterialTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Registration Date/Time*", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "HHHHHH:MM:SS"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (csod:CSODField {name: "Transcript Action", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Create, Update"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (st:SumTotalField {name: "CompletionDate", file: "Transcript_MaterialTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Completion Date/Time", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "HHHHHH:MM:SS"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (st:SumTotalField {name: "DueDate", file: "Transcript_MaterialTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Due Date/Time‡", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (csod:CSODField {name: "Due Date Action type", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "Update ONLY for this transcript",
    csod.accepted_values = "Update ONLY for this transcript, Update this and ALL LO associated transcript, Delete ONLY for this transcript, Delete for ALL LO associated transcript"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (csod:CSODField {name: "Archived", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Boolean",
    csod.char_length = "",
    csod.default_value = "false",
    csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (csod:CSODField {name: "User Exempt Reason", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "0",
    csod.accepted_values = "Other, Completed comparable training at prior organization, Acknowledged expert on subject matter, On leave, test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (csod:CSODField {name: "Approver Exempt Reason", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "0",
    csod.accepted_values = "Other, Completed comparable training at prior organization, Acknowledged expert on subject matter, On leave, test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (csod:CSODField {name: "User's Exemption Comments", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "EIL",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (csod:CSODField {name: "Approver's Exemption Comments", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "EIL",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (csod:CSODField {name: "Exempt By", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "User performing the load",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (st:SumTotalField {name: "Notes", file: "Transcript_MaterialTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Comments", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "245",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (csod:CSODField {name: "Training Purpose", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "テスト"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (csod:CSODField {name: "Training Points", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Apply, Delete"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_MaterialTranscript"})
MERGE (csod:CSODField {name: "Training Badge", file: "Transcript_MaterialTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Apply, Delete"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);


MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (st:SumTotalField {name: "EmployeeID", file: "Transcript_SessionTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "User ID*", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (st:SumTotalField {name: "ActivityCode", file: "Transcript_SessionTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Session ID*", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (st:SumTotalField {name: "TrainingStatus", file: "Transcript_SessionTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Transcript Status", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "10",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (st:SumTotalField {name: "Score", file: "Transcript_SessionTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Score", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Integer",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (st:SumTotalField {name: "Success", file: "Transcript_SessionTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Pass/Fail", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "Pass",
    csod.accepted_values = "Fail, Pass"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (st:SumTotalField {name: "RegistrationDate", file: "Transcript_SessionTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Request Date/Time", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (st:SumTotalField {name: "RegistrationDate", file: "Transcript_SessionTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Registration Date/Time", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (st:SumTotalField {name: "CompletionDate", file: "Transcript_SessionTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Completion Date/Time", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (st:SumTotalField {name: "DueDate", file: "Transcript_SessionTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Due Date/Time", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (csod:CSODField {name: "User Exempt Reason", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (csod:CSODField {name: "Approver Exempt Reason", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (csod:CSODField {name: "User's Exemption Comments", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (csod:CSODField {name: "Approver's Exemption Comments", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (csod:CSODField {name: "Exempt By", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (st:SumTotalField {name: "Notes", file: "Transcript_SessionTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Comments*", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "245",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_SessionTranscript"})
MERGE (csod:CSODField {name: "Archived", file: "Transcript_SessionTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Boolean",
    csod.char_length = "",
    csod.default_value = "0",
    csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (st:SumTotalField {name: "EmployeeID", file: "Transcript_OnlineCourse"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "User ID*", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (st:SumTotalField {name: "ActivityCode", file: "Transcript_OnlineCourse"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Online Course ID*", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (st:SumTotalField {name: "TrainingStatus", file: "Transcript_OnlineCourse"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Transcript Status*", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "50",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (st:SumTotalField {name: "RegistrationDate", file: "Transcript_OnlineCourse"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Request Date/Time*", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (st:SumTotalField {name: "RegistrationDate", file: "Transcript_OnlineCourse"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Registration Date/Time*", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (csod:CSODField {name: "Transcript Action", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Create, Update"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (st:SumTotalField {name: "CompletionDate", file: "Transcript_OnlineCourse"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Completion Date/Time", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (st:SumTotalField {name: "DueDate", file: "Transcript_OnlineCourse"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Due Date/Time", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (csod:CSODField {name: "Due Date Action type", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (st:SumTotalField {name: "Score", file: "Transcript_OnlineCourse"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Score", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "Integer",
    csod.max_value = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (csod:CSODField {name: "Archived", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "Boolean",
    csod.char_length = "",
    csod.default_value = "0",
    csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (csod:CSODField {name: "User Exempt Reason", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (csod:CSODField {name: "Approver Exempt Reason", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (csod:CSODField {name: "User's Exemption Comments", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (csod:CSODField {name: "Approver's Exemption Comments", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (csod:CSODField {name: "Exempt By", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (st:SumTotalField {name: "Notes", file: "Transcript_OnlineCourse"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Comments", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "245",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (csod:CSODField {name: "Training Points", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Apply, Delete"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_OnlineCourse"})
MERGE (csod:CSODField {name: "Training Badge", file: "Transcript_OnlineCourse"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Apply, Delete"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (st:SumTotalField {name: "EmployeeID", file: "Transcript_TestTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "User ID*", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (st:SumTotalField {name: "ActivityCode", file: "Transcript_TestTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Test ID*", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (st:SumTotalField {name: "TrainingStatus", file: "Transcript_TestTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Transcript Status*", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Registered, Completed, Exempt, Failed"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (st:SumTotalField {name: "RegistrationDate", file: "Transcript_TestTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Request Date/Time*", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "HHHHHH:MM:SS"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (st:SumTotalField {name: "RegistrationDate", file: "Transcript_TestTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Registration Date/Time*", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Mandatory",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "HHHHHH:MM:SS"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (csod:CSODField {name: "Transcript Action", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Create, Update"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (st:SumTotalField {name: "CompletionDate", file: "Transcript_TestTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Completion Date/Time", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "HHHHHH:MM:SS"
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (st:SumTotalField {name: "DueDate", file: "Transcript_TestTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Due Date/Time‡", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "DateTime",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (csod:CSODField {name: "Due Date Action type", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Update ONLY for this transcript, Update this and ALL LO associated transcript, Delete ONLY for this transcript, Delete for ALL LO associated transcript"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (st:SumTotalField {name: "Score", file: "Transcript_TestTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Score", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Integer",
    csod.min_value = "0",
    csod.max_value = "100",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (csod:CSODField {name: "Archived", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Boolean",
    csod.char_length = "",
    csod.default_value = "0",
    csod.accepted_values = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (csod:CSODField {name: "User Exempt Reason", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "0",
    csod.accepted_values = "Other, Completed comparable training at prior organization, Acknowledged expert on subject matter, On leave, test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (csod:CSODField {name: "Approver Exempt Reason", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "",
    csod.default_value = "0",
    csod.accepted_values = "Other, Completed comparable training at prior organization, Acknowledged expert on subject matter, On leave, test"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (csod:CSODField {name: "User's Exemption Comments", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "EIL",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (csod:CSODField {name: "Approver's Exemption Comments", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "100",
    csod.default_value = "EIL",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (csod:CSODField {name: "Exempt By", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "128",
    csod.default_value = "User performing the load",
    csod.accepted_values = ""
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (st:SumTotalField {name: "Notes", file: "Transcript_TestTranscript"})
MERGE (f)-[:HAS_FIELD]->(st)
MERGE (csod:CSODField {name: "Comments", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Char",
    csod.char_length = "245",
    csod.default_value = "",
    csod.accepted_values = ""
MERGE (st)-[:MAPS_TO]->(csod)
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (csod:CSODField {name: "Training Purpose", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "テスト"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (csod:CSODField {name: "Training Points", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Apply, Delete"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);

MERGE (f:File {name: "Transcript_TestTranscript"})
MERGE (csod:CSODField {name: "Training Badge", file: "Transcript_TestTranscript"})
SET csod.mandatory = "Optional",
    csod.field_type = "Enum",
    csod.char_length = "",
    csod.default_value = "",
    csod.accepted_values = "Apply, Delete"
MERGE (f)-[:OUTPUTS_FIELD]->(csod);


