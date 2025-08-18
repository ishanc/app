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
              }
            ]
          }
        }
      }
    """

    def __init__(self, api_key: str | None = None, use_openai: bool = False):
        self.api_key = api_key or os.getenv("OPENAI_API_KEY")
        self.use_openai = use_openai and bool(self.api_key)

        # Map validation types to human-readable anomalies and default severities
        self.validation_to_anomaly: dict[str, tuple[str, str]] = {
            'MANDATORY_EMPTY': ("Mandatory field has empty values", 'High'),
            'TRUNCATION': ("Potential truncation risk: value exceeds target length", 'High'),
            'LEADING_SPACES': ("Leading whitespace present; trim required", 'Medium'),
            'TRAILING_SPACES': ("Trailing whitespace present; trim required", 'Medium'),
            'ENCODING_ISSUE': ("Encoding/invalid character issue; validate charset", 'High'),
            'DATE_FORMAT': ("Invalid or inconsistent date format", 'Medium'),
            'LEADING_ZEROS': ("Unwanted leading zeros in numeric field", 'Low'),
            'DUPLICATE_RECORD': ("Duplicate record detected", 'High'),
            'HETEROGENEOUS_TYPE': ("Heterogeneous data types within field (numeric/text mix)", 'High'),
            'OUTLIER_VALUE': ("Outlier values detected; review thresholds", 'Medium'),
            'TYPE_COMPATIBILITY': ("Type compatibility issues vs. target type", 'High'),
            'BOOLEAN_CONVERSION': ("Boolean normalization required (true/false/yes/no)", 'Low'),
            'HEADER_INCONSISTENCY': ("Header/structure inconsistency vs. expected mapping", 'High'),
            'DELIMITER_ISSUE': ("Delimiter/record terminator inconsistencies", 'High'),
            'COMPLETENESS_SCORE': ("Low completeness vs. threshold", 'Medium'),
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
                    })
                })

                file_bucket['summary']['total_errors'] += 1

                anomaly_text, default_severity = self.validation_to_anomaly.get(
                    validation_type, (f"Unmapped validation: {validation_type}", 'Low')
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
        seen = set()
        unique = []
        for text in rec.get('anomalies', []):
            if text not in seen:
                seen.add(text)
                unique.append(text)
        rec['anomalies'] = unique
        return rec

