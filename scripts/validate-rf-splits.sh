#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
manifest=docs/signal-processing/model-training/datasets/example-split.json
vet=(cue vet -c -d '#SplitManifest' contracts/rf/model-training/splits.cue)
"${vet[@]}" "$manifest"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

expect_rejection() {
  local mutation="$1" diagnostic="$2"
  jq -e "$mutation" "$manifest" >"$tmpdir/manifest.json"
  if "${vet[@]}" "$tmpdir/manifest.json" >"$tmpdir/diagnostic" 2>&1; then
    echo "Unexpectedly accepted manifest after $mutation" >&2
    exit 1
  fi
  if ! grep -Fq "$diagnostic" "$tmpdir/diagnostic"; then
    cat "$tmpdir/diagnostic" >&2
    exit 1
  fi
}

expect_rejection 'del(.splits.validation)' 'splits.validation'
expect_rejection '.splits.test = []' 'splits.test'
expect_rejection '.splits.test[0].session = .splits.train[0].session' '_groupForSession'
expect_rejection '.splits.test[0].group = .splits.train[0].group' '_splitForGroup'
expect_rejection '.splits.test[0].id = .splits.train[0].id' '_recordingIDs'
