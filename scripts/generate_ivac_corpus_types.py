#!/usr/bin/env python3
"""Reuse the CUE -> JSON Schema -> Pydantic transport generator."""
import argparse
from generate_ivac_regulatory_types import generate
from ivac_regulatory import ROOT

PACKAGE = './contracts/personal/ivac/corpus:ivaccorpus'
TARGET = ROOT / 'personal/ivac/corpus/generated'

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--check', action='store_true')
    args = p.parse_args()
    schema, code = generate('corpusProjectionSchemas', PACKAGE)
    code = code.replace(b'(CUE regulatoryRowSchemas)', b'(CUE corpusProjectionSchemas)')
    for name, data in [('rows.schema.json', schema), ('rows.py', code)]:
        path = TARGET / name
        if args.check:
            if path.read_bytes() != data:
                raise ValueError(f'generated drift: {path}')
        else:
            TARGET.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)

if __name__ == '__main__':
    main()
