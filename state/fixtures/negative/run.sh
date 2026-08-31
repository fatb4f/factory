#!/usr/bin/env bash
set -euo pipefail

if cue vet -c=false ./state/fixtures/negative; then
  echo "expected negative comparison-state fixtures to fail" >&2
  exit 1
fi
