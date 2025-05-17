import unittest
import pandas as pd
from sumtotal_transformer_with_neo4j import transform_sumtotal_file, transform_provider_type

class TestProviderMapping(unittest.TestCase):
    def setUp(self):
        self.mapping_rules = [
            {
                "CSOD Field Name": "Vendor/Provider*",
                "SumTotal Field Name": "Provider",
                "mandatory": "Mandatory",
                "Default value": ""
            },
            {
                "CSOD Field Name": "Provider type*", 
                "SumTotal Field Name": "",
                "mandatory": "Mandatory",
                "Default value": "ONLINE"
            }
        ]

    def test_provider_type_mapping(self):
        test_cases = {
            'ILT Content': 'ILT',
            'Online Content': 'ONLINE',
            'Assessment': 'ONLINE',
            '': 'ONLINE',
            None: 'ONLINE',
            'Unknown Provider': 'ONLINE'
        }
        
        for provider, expected_type in test_cases.items():
            with self.subTest(provider=provider):
                actual_type = transform_provider_type(provider)
                self.assertEqual(actual_type, expected_type)

    def test_transform_with_sumtotal_mapping(self):
        input_data = pd.DataFrame({
            'Provider': ['ILT Content', 'Online Content', 'Assessment']
        })
        
        expected_types = ['ILT', 'ONLINE', 'ONLINE']
        
        result = transform_sumtotal_file(input_data, self.mapping_rules, 'test')
        
        self.assertTrue('Vendor/Provider*' in result.columns)
        self.assertTrue('Provider type*' in result.columns)
        self.assertEqual(result['Provider type*'].tolist(), expected_types)

    def test_transform_without_sumtotal_mapping(self):
        input_data = pd.DataFrame({'OtherField': ['value']})
        
        result = transform_sumtotal_file(input_data, self.mapping_rules, 'test')
        
        self.assertTrue('Vendor/Provider*' in result.columns)
        self.assertTrue('Provider type*' in result.columns)
        self.assertEqual(result['Vendor/Provider*'].iloc[0], 'Online Content')
        self.assertEqual(result['Provider type*'].iloc[0], 'ONLINE')

    def test_transform_with_empty_values(self):
        input_data = pd.DataFrame({
            'Provider': ['', None, 'ILT Content']
        })
        
        result = transform_sumtotal_file(input_data, self.mapping_rules, 'test')
        
        self.assertTrue('Vendor/Provider*' in result.columns)
        self.assertTrue('Provider type*' in result.columns)
        
        self.assertEqual(result['Vendor/Provider*'].iloc[0], 'Online Content')
        self.assertEqual(result['Provider type*'].iloc[0], 'ONLINE')
        self.assertEqual(result['Vendor/Provider*'].iloc[1], 'Online Content') 
        self.assertEqual(result['Provider type*'].iloc[1], 'ONLINE')
        
        self.assertEqual(result['Vendor/Provider*'].iloc[2], 'ILT Content')
        self.assertEqual(result['Provider type*'].iloc[2], 'ILT')

if __name__ == '__main__':
    unittest.main(verbosity=2)