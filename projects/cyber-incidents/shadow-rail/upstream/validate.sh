#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
package=./projects/cyber-incidents/shadow-rail/upstream
cue vet -c "$package"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
printf '%s\n' '{"availability":"native-public","dataset":"x.y","verification_source":"https://example.org","read_only":true}' > "$tmpdir/valid.json"
cue vet -c "$tmpdir/valid.json" "$package"/*.cue -d '#BigQueryAccess'
printf '%s\n' '{"availability":"native-public","read_only":true}' > "$tmpdir/missing.json"
printf '%s\n' '{"availability":"third-party-public","dataset":"x.y","verification_source":"https://example.org","read_only":false}' > "$tmpdir/writable.json"
for fixture in "$tmpdir/missing.json" "$tmpdir/writable.json"; do
  if cue vet -c "$fixture" "$package"/*.cue -d '#BigQueryAccess' >/dev/null 2>&1; then
    echo "invalid BigQuery access accepted: $fixture" >&2
    exit 1
  fi
done
