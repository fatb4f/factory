#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
package=./projects/cyber-incidents/shadow-rail/galaxy
cue vet -c=false "$package"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
python3 - "$tmpdir" <<'PY'
import copy, json, pathlib, sys
root = pathlib.Path(sys.argv[1])
catalog = {
    'apiVersion': 'shadow-galaxy/0.1.0', 'id': 'example', 'version': '1',
    'terms': [{'id': 'example-actor', 'label': 'Example actor', 'description': 'Synthetic vocabulary term',
               'srw_concept': 'actor', 'source': {'uri': 'https://example.org/source', 'version': '1'},
               'alignment': {'status': 'unmapped', 'reason': 'No alignment established'}}],
    'boundaries': {'vocabulary_establishes_fact': False, 'mapping_establishes_fact': False, 'actor_affiliation_inferred': False},
}
def save(name, data):
    (root / (name + '.json')).write_text(json.dumps(data))
save('valid', catalog)
mapped = copy.deepcopy(catalog)
mapped['terms'][0]['alignment'] = {'status': 'mapped', 'target': 'example', 'relation': 'related', 'source': {'uri': 'https://example.org/reference', 'version': '1'}, 'limitations': 'Not equivalent'}
save('mapped', mapped)
for name, change in {
    'missing-source': lambda d: d['terms'][0].pop('source'),
    'unknown-concept': lambda d: d['terms'][0].update(srw_concept='unknown'),
    'missing-reason': lambda d: d['terms'][0]['alignment'].pop('reason'),
    'false-boundary': lambda d: d['boundaries'].update(actor_affiliation_inferred=True),
    'affiliation': lambda d: d['terms'][0].update(affiliation='example'),
    'empty-terms': lambda d: d.update(terms=[]),
    'unknown-field': lambda d: d.update(extra=True),
}.items():
    invalid = copy.deepcopy(catalog)
    change(invalid)
    save(name, invalid)
duplicate = copy.deepcopy(catalog)
duplicate['terms'].append(copy.deepcopy(duplicate['terms'][0]))
save('duplicate', duplicate)
PY
check() {
  cue vet -c "$1" "$package"/*.cue -d '#Galaxy' && python3 - "$1" <<'PY'
import json, sys
terms = json.load(open(sys.argv[1]))['terms']
ids = [term['id'] for term in terms]
if len(ids) != len(set(ids)):
    raise SystemExit('duplicate term ID')
PY
}
check "$tmpdir/valid.json"
check "$tmpdir/mapped.json"
for fixture in missing-source unknown-concept missing-reason false-boundary affiliation empty-terms unknown-field duplicate; do
  if check "$tmpdir/$fixture.json" >/dev/null 2>&1; then
    echo "invalid catalog accepted: $fixture" >&2
    exit 1
  fi
done
