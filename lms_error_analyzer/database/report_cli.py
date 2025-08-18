import argparse
import os
import sys


def main():
    # Ensure we can import siblings when executed as a script
    here = os.path.dirname(os.path.abspath(__file__))
    if here not in sys.path:
        sys.path.append(here)

    from report_generator import generate_anomaly_report_csv

    parser = argparse.ArgumentParser(description="Generate anomaly report CSV from error_logs and completeness")
    parser.add_argument("--file", required=True, help="Original uploaded filename as stored in error_logs.file_name (e.g., Activity_Curriculum.xlsx)")
    parser.add_argument("--out", required=True, help="Output directory for the anomaly CSV")
    args = parser.parse_args()

    os.makedirs(args.out, exist_ok=True)
    report_filename = generate_anomaly_report_csv(args.file, args.out)
    print(os.path.join(args.out, report_filename))


if __name__ == "__main__":
    main()

