#!/usr/bin/env python3
"""Reuse Factory's CUE -> JSON Schema -> Pydantic v2 transport generator."""
import argparse
from generate_ivac_regulatory_types import generate
from ivac_regulatory import ROOT

TARGET = ROOT / 'personal/ivac/workbench/generated'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    schema, code = generate('workbenchProjectionSchemas', './contracts/personal/ivac/workbench:ivacworkbench')
    code = code.replace(b'(CUE regulatoryRowSchemas)', b'(CUE workbenchProjectionSchemas)')
    for name, data in [('rows.schema.json', schema), ('rows.py', code)]:
        path = TARGET/name
        if args.check:
            if path.read_bytes() != data:
                raise SystemExit(f'generated drift: {path}')
        else:
            TARGET.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)


if __name__ == '__main__':
    main()
