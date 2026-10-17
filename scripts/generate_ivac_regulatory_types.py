#!/usr/bin/env python3
"""CUE → JSON Schema → disposable Pydantic v2 transport types (not legal authority)."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import tempfile
from ivac_regulatory import ROOT
from ivac_regulatory_sources import encoded

TARGET = ROOT / 'personal/ivac/regulatory/generated'


def generate():
    schema = json.loads(subprocess.check_output([
        'cue', 'export', './contracts/personal/ivac:ivac', '-e', 'regulatoryRowSchemas',
        '--out', 'jsonschema'], cwd=ROOT))
    # Normalize equivalent scalar intersections emitted by CUE for this generator.
    # Keep the raw CUE authority and fail closed on any unsupported intersection.
    def adapt(value):
        if isinstance(value, dict):
            if 'allOf' in value and all(set(x) <= {'type', 'minimum', 'maximum'} for x in value['allOf']):
                parts = value.pop('allOf')
                for part in parts:
                    for key, item in part.items():
                        if key != 'type': value[key] = item
                value['type'] = 'integer' if any(x.get('type') == 'integer' for x in parts) else 'number'
            if value.get('not') == {'const': ''} and value.get('type') == 'string':
                value.pop('not')
                value['minLength'] = 1
            for v in value.values(): adapt(v)
        elif isinstance(value, list):
            for v in value: adapt(v)
    adapt(schema)
    with tempfile.TemporaryDirectory() as d:
        source, output = Path(d)/'rows.json', Path(d)/'rows.py'
        source.write_bytes(encoded(schema))
        subprocess.run([sys.executable, '-m', 'datamodel_code_generator', '--input', str(source),
                        '--input-file-type', 'jsonschema', '--output-model-type', 'pydantic_v2.BaseModel',
                        '--output', str(output), '--disable-timestamp', '--use-standard-collections',
                        '--use-union-operator', '--use-annotated', '--field-constraints',
                        '--use-schema-description', '--extra-fields', 'forbid', '--use-subclass-enum'], check=True)
        code = output.read_text().replace('#   filename:  rows.json', '#   filename:  rows.json (CUE regulatoryRowSchemas)')
        # The codegen extension is not honored by every generator version. Reject
        # float output rather than silently degrading percentage fidelity.
        code = code.replace('from typing import', 'from decimal import Decimal\nfrom typing import') if 'Decimal' not in code else code
        code = code.replace('float', 'Decimal')
        return encoded(schema), code.encode()


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--check', action='store_true')
    a = p.parse_args()
    schema, code = generate()
    for name, data in [('rows.schema.json', schema), ('rows.py', code)]:
        path = TARGET/name
        if a.check:
            if path.read_bytes() != data: raise SystemExit(f'generated drift: {path}')
        else:
            TARGET.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
