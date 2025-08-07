class ColumnMetaData:
    """
    Metadata class to track data type distribution within a column.
    """
    
    def __init__(self, column_name: str):
        """
        Initialize ColumnMetaData with column name and default data type counts.
        
        Args:
            column_name: Name of the column being analyzed
        """
        self.column_name: str = column_name
        self.data_type_to_count: dict[str, int] = {
            'str': 0,
            'int': 0,
            'boolean': 0
        }
    
    def increment_data_type_count(self, data_type: str) -> None:
        """
        Increment the count for a specific data type.
        
        Args:
            data_type: The data type to increment count for
        """
        if data_type in self.data_type_to_count:
            self.data_type_to_count[data_type] += 1
        else:
            # If data type doesn't exist, add it with count 1
            self.data_type_to_count[data_type] = 1
    
    def get_data_type_count(self, data_type: str) -> int:
        """
        Get the count for a specific data type.
        
        Args:
            data_type: The data type to get count for
            
        Returns:
            Count for the specified data type, 0 if not found
        """
        return self.data_type_to_count.get(data_type, 0)