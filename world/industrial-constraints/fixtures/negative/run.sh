#!/usr/bin/env bash
set -euo pipefail

if cue vet -c=false ./world/industrial-constraints/fixtures/negative:negative; then
  echo "expected single-observation binding fixture to fail" >&2
  exit 1
fi
