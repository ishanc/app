import os

"""This is  a file that will eventually have to get deleted due to keeping things business agnostic. """
class FilenameMapper:
    """Utility to map uploaded filenames to Neo4j database keys consistently across modules."""
    
    @staticmethod
    def to_db_key(filename: str) -> str:
        """
        Map filename to the correct database key for mapping rules.
        
        Args:
            filename: Original uploaded filename (e.g., "Activity_Curriculum.xlsx")
            
        Returns:
            Mapped database key (e.g., "Activity_Curriculum")
        """
        # Remove file extension
        file_key = os.path.splitext(filename)[0]
        
        # Define the mapping from incoming filenames to database file names
        filename_mappings = {
            # Activity mappings
            "Activity_Curriculum": "Activity_Curriculum",
            "Activity_QuickAssessment": "Activity_Test",
            "Activity_ILTSessions": "Activity_SessionParts",
            "Activity_ILTClass": "Activity_Sessions", 
            "Activity_ILTCourse": "Activity_Events",
            "Activity_OnlineCourse": "Activity_OnlineCourse",
            "Activity_Online Course": "Activity_OnlineCourse",  # Original with space
            "Activity_Online_Course": "Activity_OnlineCourse",  # Flask converts space to underscore
            "Activity_Document": "Activity_Material",
            
            # Transcript mappings
            "Transcript_Curriculum": "Transcript_CurriculumTranscript",
            "Transcript_Document": "Transcript_MaterialTranscript", 
            "Transcript_ILT Class": "Transcript_SessionTranscript",
            "Transcript_ILT_Class": "Transcript_SessionTranscript",
            "Transcript_Online Course": "Transcript_OnlineCourse",
            "Transcript_Online_Course": "Transcript_OnlineCourse",
            "Transcript_QuickAssessment": "Transcript_TestTranscript",
            
            # Core mappings
            "Core_Audience": "Core_GroupsOU",
            "Core_Domain": "Core_DivisionOU",
            "Core_Employee": "Core_Employee-CHR", 
            "Core_Jobs": "Core_PositionOU",
            "Core_Organization": "Core_CostCenterOU",
            
            # Prerequisites mappings
            "Prerequisites_Facility": "Prerequisites_Facility",
            "Prerequisites_Instructor": "Prerequisites_Instructor",
            "Prerequisites_Provider": "Prerequisites_Provider",
            "Prerequisites_Question": "Prerequisites_Questions",
            "Prerequisites_QuestionBanks": "Prerequisites_QuestionsCategories",
            "Prerequisites_Subject": "Prerequisites_Subject"
        }
        
        # Return mapped key if exists, otherwise return original
        return filename_mappings.get(file_key, file_key)
