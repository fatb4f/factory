#!/usr/bin/env python3
"""Lossless per-unit source navigation; never statutory qualification.

Shared schedules remain shared. In particular, bilateral unit 13 has a common
schedule, and the aesthetic percentage matrix follows all eight unit bodies.
No row boundary, OR scope or class-to-percentage pairing is inferred from PDF
reading order. The original candidate remains the authoritative acquisition
work queue; this is a reproducible projection of that queue.
"""
import argparse
import json
from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import ivac_regulatory_sources as sources


def build(candidate, text):
    sources.verify_candidate(candidate, text)
    sections, units, occurrences = [], [], []
    for section in candidate['sections']:
        number, span = section['number'], section['text']
        leaves = [u for u in candidate['units'] if u['section'] == number]
        names = [u['number'] for u in leaves]
        starts = []
        if len(leaves) > 1:
            for match in re.finditer(r'^ +([0-9]+\.[0-9]+)\.? +([^\n]+)', span['exactText'], re.M):
                # The contents lists use mixed case; the body headings use
                # uppercase initial words. Do not treat summary matrix rows as headings.
                if match[1] in names and match[2][:5].isupper():
                    starts.append((span['start'] + match.start(), match[1]))
            if starts and [n for _, n in starts] != names:
                raise ValueError(f'unexpected unit heading sequence in section {number}')
        pieces = []
        boundaries = [(span['start'], 'section-context', names)]
        if starts:
            boundaries += [(a, 'unit-body', [n]) for a, n in starts]
        else:
            # Section 13 uses a single bilateral schedule rather than distinct
            # right/left body headings. Unsplit sections preserve every character.
            boundaries = [(span['start'], 'shared-schedule' if len(names) > 1 else 'unit-body', names)]
        for i, (a, role, owners) in enumerate(boundaries):
            b = boundaries[i + 1][0] if i + 1 < len(boundaries) else span['end']
            if a == b:
                continue
            identity = f'section-{number}-piece-{i}'
            pieces.append({'id': identity, 'role': role, 'unitNumbers': owners,
                           'citation': sources.citation(text, candidate['acquisition']['id'], a, b,
                                                       f'Annexe I, rubrique {number}, segment {i}')})
        # The final aesthetic body also includes a shared summary matrix. Keep
        # the complete section available to every aesthetic unit: assigning the
        # matrix only to 25.8 would silently hide other units' percentage cells.
        section_refs = [p['id'] for p in pieces]
        for leaf in leaves:
            refs = section_refs if number == '25' else [p['id'] for p in pieces if leaf['number'] in p['unitNumbers']]
            units.append({**leaf, 'pieceIDs': refs})
        sections.append({'number': number, 'pieces': pieces})
        for marker in candidate['markers']:
            c = marker['citation']
            if not span['start'] <= c['start'] < span['end']:
                continue
            owner = [p for p in pieces if p['citation']['start'] <= c['start'] and c['end'] <= p['citation']['end']]
            if len(owner) != 1:
                raise ValueError('marker crosses a piece boundary')
            occurrences.append({'id': f'occurrence-{len(occurrences)}', 'pieceID': owner[0]['id'], **marker})
    return {'format': 'ivac.regulatory-schedule-index/v1', 'status': 'candidate',
            'acquisition': candidate['acquisition'], 'semantics': 'pending-review',
            'caseApplicability': 'unresolved', 'globalRules': candidate['globalRules'],
            'sections': sections, 'units': units,
            'occurrences': occurrences}


def verify(index, candidate, text):
    if index != build(candidate, text):
        raise ValueError('schedule index differs from source-derived projection')
    sources.spans.validate(index, '#RegulatoryScheduleIndex')
    for span in sources.spans.citations(index):
        sources.spans.verify_span(span, text, index['acquisition']['id'])


def rows(index):
    """Flat occurrence rows for Ibis/DuckDB source inspection, with exact spans.

    One row per occurrence and referencing unit; shared context deliberately
    fans out. occurrenceID identifies source occurrences for distinct counts.
    There is no classID, percentage value or qualification column.
    """
    from personal.ivac.regulatory.generated.rows import RegulatoryScheduleOccurrenceRow
    for unit in index['units']:
        refs = set(unit['pieceIDs'])
        for occurrence in index['occurrences']:
            if occurrence['pieceID'] in refs:
                row = {'sourceVersion': index['acquisition']['id'], 'unitNumber': unit['number'],
                       'unitKind': unit['kind'], 'occurrenceID': occurrence['id'],
                       'pieceID': occurrence['pieceID'], 'kind': occurrence['kind'],
                       'semantics': index['semantics'], **{k: v for k, v in occurrence['citation'].items() if k != 'sourceVersion'}}
                yield json.loads(RegulatoryScheduleOccurrenceRow.model_validate(row).model_dump_json())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['build', 'verify', 'rows'])
    parser.add_argument('--candidate', type=Path, default=sources.DATA / 'annex-i-2021.candidate.json')
    parser.add_argument('--index', type=Path, default=sources.DATA / 'annex-i-2021.schedule-index.json')
    args = parser.parse_args()
    candidate = sources.read_json(args.candidate)
    text = sources.verify_acquisition(candidate['acquisition'])
    if args.mode == 'build':
        value = build(candidate, text)
        verify(value, candidate, text)
        print(sources.encoded(value).decode(), end='')
    else:
        value = sources.read_json(args.index)
        verify(value, candidate, text)
        if args.mode == 'rows':
            for row in rows(value):
                print(json.dumps(row, ensure_ascii=False, sort_keys=True))


if __name__ == '__main__':
    main()
