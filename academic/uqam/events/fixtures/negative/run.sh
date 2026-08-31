#!/usr/bin/env bash
set -euo pipefail

if cue vet -c=false ./academic/uqam/events/fixtures/negative; then
  echo "expected contradictory UQAM run-bundle fixtures to fail" >&2
  exit 1
fi
