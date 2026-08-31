#!/usr/bin/env bash
set -euo pipefail

root="world/industrial-constraints/fixtures/negative"
fixtures=(
  binding_single_observation.cue
  dangling_projection_input.cue
)

for fixture in "${fixtures[@]}"; do
  echo "expecting CUE contradiction: $fixture"
  if cue vet -c=false "$root/$fixture"; then
    echo "negative industrial fixture unexpectedly validated: $fixture" >&2
    exit 1
  fi
done

echo "all industrial negative fixtures contradicted as expected"
