#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
package=./projects/cyber-incidents/shadow-rail/world
cue vet -c "$package"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
cue export "$package" -e crosswalk --out json > "$tmpdir/crosswalk.json"
cue export "$package" -e ontology --out json > "$tmpdir/ontology.json"
cue vet -c "$tmpdir/crosswalk.json" "$package"/*.cue -d '#Crosswalk'
cue vet -c "$tmpdir/ontology.json" "$package"/*.cue -d ontology
python3 - "$tmpdir" <<'PY'
import copy, json, pathlib, sys
root = pathlib.Path(sys.argv[1])
crosswalk = json.loads((root / 'crosswalk.json').read_text())
ontology = json.loads((root / 'ontology.json').read_text())
def save(name, data):
    (root / (name + '.json')).write_text(json.dumps(data))
def changed(name, mutate):
    data = copy.deepcopy(crosswalk)
    mutate(data)
    save(name, data)
changed('missing-concept', lambda d: d['mappings'].pop('evidence'))
changed('wrong-concept', lambda d: d['mappings']['claim'].__setitem__('concept', 'actor'))
changed('false-equivalence', lambda d: d['mappings']['claim'].__setitem__('relation', 'equivalent'))
changed('missing-reference', lambda d: d['mappings']['claim'].pop('reference'))
changed('unmapped-with-reference', lambda d: d['mappings']['evidence'].__setitem__('reference', {'iri':'https://www.commoncoreontologies.org/ont00000958', 'label':'Information Content Entity'}))
changed('unknown-concept', lambda d: d['mappings'].__setitem__('unknown', d['mappings']['claim']))
ontology['boundaries']['mapping_establishes_fact'] = True
save('false-boundary', ontology)
PY
for fixture in missing-concept wrong-concept false-equivalence missing-reference unmapped-with-reference unknown-concept; do
  if cue vet -c "$tmpdir/$fixture.json" "$package"/*.cue -d '#Crosswalk' >/dev/null 2>&1; then
    echo "invalid crosswalk accepted: $fixture" >&2
    exit 1
  fi
done
if cue vet -c "$tmpdir/false-boundary.json" "$package"/*.cue -d ontology >/dev/null 2>&1; then
  echo 'invalid epistemic boundary accepted' >&2
  exit 1
fi
