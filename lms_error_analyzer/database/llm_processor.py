import typing as t
from collections import defaultdict
import os
import json
from typing import Any, Dict


class LLMProcessor:
    """
    Minimal anomaly judge that synthesizes error logs and completeness signals
    into a structured anomaly report per field. This is a heuristic baseline
    that can be swapped with a real LLM call later.

    Input shape (categorized_errors):
      {
        category_name: [
          {
            'error_id': int,
            'message': str,
            'file_name': str | None,
            'line_number': int | None,
            'error_category': str,         # e.g., VALIDATION
            'validation_type': str,        # e.g., MANDATORY_EMPTY, TRUNCATION
            'timestamp': str | None,
            'stack_trace': str | None
          }, ...
        ],
        ...
      }

    Output shape:
      {
        'files': {
          file_name: {
            'summary': {
              'mandatory_completeness': float | None,
              'total_errors': int
            },
            'fields': [
              {
                'field': str,
                'type': str | None,
                'severity': 'High' | 'Medium' | 'Low',
                'anomalies': [str],
                'remediation_recommendations': [str],
              }
            ]
          }
        }
      }
    """

    def __init__(self, api_key: str | None = None, use_openai: bool = False):
        self.api_key = api_key or os.getenv("OPENAI_API_KEY")
        self.use_openai = use_openai and bool(self.api_key)

        # Map validation types to human-readable anomalies, default severities, and remediation recommendations
        self.validation_to_anomaly: dict[str, tuple[str, str, str]] = {
            'MANDATORY_EMPTY': (
                "Mandatory field has empty values", 
                'High',
                "At Source/Data Discovery Workshop, mandatory field is empty or null. Requires source data correction or default value assignment strategy."
            ),
            'TRUNCATION': (
                "Potential truncation risk: value exceeds target length", 
                'High',
                "At Source, field value exceeds character length limit. Remediate by adjusting target field length or truncating source data with approval."
            ),
            'LEADING_SPACES': (
                "Leading whitespace present; trim required", 
                'Medium',
                "Data Transformation, field value has leading whitespace. Can be automatically fixed in code/workshop agent by implementing trim logic."
            ),
            'TRAILING_SPACES': (
                "Trailing whitespace present; trim required", 
                'Medium',
                "Data Transformation, field value has trailing whitespace. Can be automatically fixed by implementing trim logic during transformation."
            ),
            'ENCODING_ISSUE': (
                "Encoding/invalid character issue; validate charset", 
                'High',
                "At Source, field value contains invalid characters. Requires source file correction or character encoding fix at source level."
            ),
            'DATE_FORMAT': (
                "Invalid or inconsistent date format", 
                'Medium',
                "Data Discovery Workshop, invalid date/time format detected. Workshop transformation needed based on target format requirements."
            ),
            'LEADING_ZEROS': (
                "Unwanted leading zeros in numeric field", 
                'Low',
                "Data Discovery Workshop, numeric field has unwanted leading zeros. Requires workshop confirmation for zero removal or preservation."
            ),
            'DUPLICATE_RECORD': (
                "Duplicate record detected", 
                'High',
                "Data Transformation, duplicate record found. Requires implementation of deduplication logic and business rule confirmation during transformation."
            ),
            'HETEROGENEOUS_TYPE': (
                "Heterogeneous data types within field (numeric/text mix)", 
                'High',
                "Data Discovery Workshop, field contains heterogeneous data types. Requires workshop confirmation for type standardization approach."
            ),
            'OUTLIER_VALUE': (
                "Outlier values detected; review thresholds", 
                'Medium',
                "At Source/Data Discovery Workshop, field value is an outlier. Date values cannot be too extreme and percentages cannot exceed 100%. Requires validation and potential correction."
            ),
            'TYPE_COMPATIBILITY': (
                "Type compatibility issues vs. target type", 
                'High',
                "Data Discovery Workshop, field value is not type compatible. Requires compatibility resolution through workshop parameter adjustment and transformation logic."
            ),
            'BOOLEAN_CONVERSION': (
                "Boolean normalization required (true/false/yes/no)", 
                'Low',
                "Data Discovery Workshop, boolean value transformation issue detected. Requires transformation validation workshop for proper boolean mapping."
            ),
            'HEADER_INCONSISTENCY': (
                "Header/structure inconsistency vs. expected mapping", 
                'High',
                "At Source/Data Discovery Workshop, file header/structure inconsistency detected. Requires workshop confirmation for header mapping and structure validation."
            ),
            'DELIMITER_ISSUE': (
                "Delimiter/record terminator inconsistencies", 
                'High',
                "At Source, file delimiter/structure issue detected. Requires implementation of delimiter detection and parsing logic at source level."
            ),
            'COMPLETENESS_SCORE': (
                "Low completeness vs. threshold", 
                'Medium',
                "At Source/Data Discovery Workshop, data completeness issue identified. Report percentage score to user as test metric for data quality assessment."
            ),
        }

    def generate_insights(
        self,
        categorized_errors: dict[str, list[dict]],
        chunker: t.Callable[[str, list[dict]], list[list[dict]]] | None = None,
        *,
        completeness_by_file: dict[str, dict] | None = None,
        field_meta_by_file: dict[str, dict[str, dict]] | None = None,
    ) -> dict:
        """
        Synthesize errors and optional completeness into structured anomalies.

        - completeness_by_file: optional, keyed by file_name with keys:
            mandatory_completeness
        - field_meta_by_file: optional, e.g., {'file.csv': {'ActivityDescription': {'char_length': 5000}}}
        - If self.use_openai is True and an API key is present, attempt to produce
          LLM-generated structured output. Fallback to heuristic if JSON parse fails.
        """

        if self.use_openai:
            try:
                return self._generate_with_openai(
                    categorized_errors,
                    completeness_by_file=completeness_by_file or {},
                )
            except Exception:
                # Fall back to heuristic below
                pass

        files: dict[str, dict] = {}

        # Ensure files with completeness data but no errors still get a payload
        if completeness_by_file:
            for file_name in completeness_by_file.keys():
                files.setdefault(file_name, {
                    'summary': {
                        'mandatory_completeness': None,
                        'total_errors': 0,
                    },
                    'fields': defaultdict(lambda: {
                        'field': None,
                        'type': None,
                        'severity': 'Low',
                        'anomalies': [],
                        'remediation_recommendations': [],
                    })
                })

        # Flatten categorized errors to iterate per file and field
        for category, errors in (categorized_errors or {}).items():
            if not errors:
                continue

            # Optionally chunk for future LLM usage (no-op for heuristic path)
            _ = chunker(category, errors) if chunker else None

            for err in errors:
                file_name = err.get('file_name') or 'unknown'
                validation_type = err.get('validation_type') or 'unknown_type'

                # Attempt to extract field_name from message pattern if available
                field_name = self._extract_field_name(err)

                file_bucket = files.setdefault(file_name, {
                    'summary': {
                        'mandatory_completeness': None,
                        'total_errors': 0,
                    },
                    'fields': defaultdict(lambda: {
                        'field': None,
                        'type': None,
                        'severity': 'Low',
                        'anomalies': [],
                        'remediation_recommendations': [],
                    })
                })

                file_bucket['summary']['total_errors'] += 1

                anomaly_text, default_severity, remediation_recommendation = self.validation_to_anomaly.get(
                    validation_type, (f"Unmapped validation: {validation_type}", 'Low', "Manual review required - no automated remediation recommendation available")
                )

                field_key = field_name or '<unknown-field>'
                field_rec = file_bucket['fields'][field_key]
                field_rec['field'] = field_key

                # Enrich anomaly messages using optional metadata when present
                enriched_anomaly = self._enrich_anomaly(
                    anomaly_text,
                    validation_type=validation_type,
                    field_name=field_key,
                    file_name=file_name,
                    field_meta_by_file=field_meta_by_file,
                )
                field_rec['anomalies'].append(enriched_anomaly)
                field_rec['remediation_recommendations'].append(remediation_recommendation)

                # Escalate severity when high-signal validations are present
                field_rec['severity'] = self._max_severity(
                    field_rec['severity'], default_severity
                )

        # Fold defaultdicts to lists and merge completeness
        for file_name, payload in files.items():
            if completeness_by_file and file_name in completeness_by_file:
                payload['summary'].update({
                    'mandatory_completeness': completeness_by_file[file_name].get('mandatory_completeness'),
                })

            # Convert fields map to list and normalize duplicates
            fields_map: dict[str, dict] = payload['fields']  # type: ignore
            payload['fields'] = [self._dedupe_anomalies(rec) for rec in fields_map.values()]

        return { 'files': files }

    # --- OpenAI path ---
    def _generate_with_openai(
        self,
        categorized_errors: Dict[str, list[Dict[str, Any]]],
        *,
        completeness_by_file: Dict[str, Dict[str, Any]],
    ) -> Dict[str, Any]:
        try:
            from openai import OpenAI
        except Exception as e:  # pragma: no cover
            raise RuntimeError("openai package not available") from e

        client = OpenAI(api_key=self.api_key)

        # Take only the first 10 errors per category for LLM analysis, with a global cap
        file_to_errors: Dict[str, list[Dict[str, Any]]] = defaultdict(list)
        total = 0
        per_category_limit = 10
        for category_name, errs in (categorized_errors or {}).items():
            for err in errs[:per_category_limit]:
                file_name = err.get('file_name') or 'unknown'
                file_to_errors[file_name].append({
                    'validation_type': err.get('validation_type'),
                    'message': str(err.get('message', ''))[:300],
                    'category': category_name,
                })
                total += 1
                if total > 400:
                    break

        # Select one file if multiple; typical run uses a single file
        if not file_to_errors:
            return {'files': {}}
        target_file = next(iter(file_to_errors.keys()))
        compact_errors = file_to_errors[target_file]
        completeness = completeness_by_file.get(target_file, {})

        system_instructions = (
            "You are a data quality analyst. Return strict JSON only. "
            "Given validation errors and optional completeness, produce a minimal anomaly report per field with severity. "
            "Map validations to actionable anomalies (e.g., TRUNCATION→truncation risk with target length guidance; "
            "ENCODING_ISSUE→encoding validation; LEADING/TRAILING_SPACES→trim)."
        )

        user_payload = {
            'file_name': target_file,
            'completeness': {
                'mandatory_completeness': completeness.get('mandatory_completeness'),
            },
            'errors_sample': compact_errors[:800],
            'output_schema': {
                'files': {
                    '<file_name>': {
                        'summary': {
                            'mandatory_completeness': 'float|null',
                            'total_errors': 'int'
                        },
                        'fields': [
                            {
                                'field': 'string',
                                'severity': 'High|Medium|Low',
                                'anomalies': ['string']
                            }
                        ]
                    }
                }
            },
        }

        messages = [
            {"role": "system", "content": system_instructions},
            {"role": "user", "content": json.dumps(user_payload)},
            {"role": "user", "content": "Return only the JSON object with no prose."},
        ]

        completion = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=messages,
            temperature=0.2,
            response_format={"type": "json_object"},
            max_tokens=1200,
        )
        content = completion.choices[0].message.content
        parsed = json.loads(content)

        # Ensure required shape and fill summary totals if missing
        files = parsed.get('files', {})
        if target_file in files:
            files[target_file].setdefault('summary', {})
            files[target_file]['summary'].setdefault('total_errors', len(compact_errors))
        return {'files': files}

    def _extract_field_name(self, err: dict) -> str | None:
        # error_logger message pattern: "Field 'X' at row N ..." or "Mandatory field 'X' ..."
        msg = (err.get('message') or '').strip()
        if not msg:
            return None
        # Simple parse for quoted field names
        try:
            first_quote = msg.index("'")
            second_quote = msg.index("'", first_quote + 1)
            return msg[first_quote + 1:second_quote]
        except ValueError:
            return None

    def _enrich_anomaly(
        self,
        base_text: str,
        *,
        validation_type: str,
        field_name: str,
        file_name: str,
        field_meta_by_file: dict[str, dict[str, dict]] | None,
    ) -> str:
        # Inject char_length advice when available for TRUNCATION
        if validation_type == 'TRUNCATION' and field_meta_by_file:
            meta = field_meta_by_file.get(file_name, {}).get(field_name)
            if meta and 'char_length' in meta:
                return f"{base_text} (target length {meta['char_length']})"

        # Add targeted guidance for specific types
        if validation_type == 'ENCODING_ISSUE':
            return f"{base_text}; validate nvarchar→char conversion and normalize Unicode"
        if validation_type in {'LEADING_SPACES', 'TRAILING_SPACES'}:
            return f"{base_text}; trim before load"
        if validation_type == 'HETEROGENEOUS_TYPE':
            return f"{base_text}; validate against target's unique ID rules"
        if validation_type == 'DATE_FORMAT':
            return f"{base_text}; ensure ISO-8601 or target date/time format"
        return base_text

    def _max_severity(self, a: str, b: str) -> str:
        order = {'Low': 0, 'Medium': 1, 'High': 2}
        inv = {v: k for k, v in order.items()}
        return inv[max(order.get(a, 0), order.get(b, 0))]

    def _dedupe_anomalies(self, rec: dict) -> dict:
        # Deduplicate anomalies
        seen_anomalies = set()
        unique_anomalies = []
        for text in rec.get('anomalies', []):
            if text not in seen_anomalies:
                seen_anomalies.add(text)
                unique_anomalies.append(text)
        rec['anomalies'] = unique_anomalies
        
        # Deduplicate remediation recommendations
        seen_recommendations = set()
        unique_recommendations = []
        for text in rec.get('remediation_recommendations', []):
            if text not in seen_recommendations:
                seen_recommendations.add(text)
                unique_recommendations.append(text)
        rec['remediation_recommendations'] = unique_recommendations
        
        return rec

