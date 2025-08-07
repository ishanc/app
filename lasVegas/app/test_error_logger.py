from error_logger import ErrorLogger

results =  ErrorLogger.get_errors_by_validation_type("TRUNCATION")
for error in results:
        print(error)
        print("--------------------------------")
        print(results)
        print("--------------------------------")
