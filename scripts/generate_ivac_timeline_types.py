#!/usr/bin/env python3
"""Generate IVAC acquisition transports using the existing CUE projection chain."""
import argparse
from generate_ivac_regulatory_types import generate
from ivac_regulatory import ROOT

TARGET = ROOT/'personal/ivac/workbench/generated'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    for expression, stem in [('timelineProjectionSchemas','timeline_rows'),('timelineExchangeSchemas','timeline_exchange')]:
        schema, code = generate(expression, './contracts/personal/ivac/workbench:ivacworkbench')
        code = code.replace(b'(CUE regulatoryRowSchemas)', ('(CUE '+expression+')').encode())
        for extension, data in [('schema.json',schema),('py',code)]:
            path=TARGET/(stem+'.'+extension)
            if args.check:
                if path.read_bytes()!=data: raise SystemExit(f'generated drift: {path}')
            else: path.write_bytes(data)


if __name__=='__main__': main()
