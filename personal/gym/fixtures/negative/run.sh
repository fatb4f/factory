#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base="$root/base.cue"

fixtures=(
  rejected_admission_capacity.cue
  grant_demand_outside_basis.cue
  incompatible_comparison_relation.cue
  mismatched_normalization_comparison.cue
  compensation_phase_mismatch.cue
  multi_demand_scalar_capacity.cue
  unknown_phase_reference.cue
  unresolved_evidence_reference.cue
  dangling_contributor_reference.cue
  contribution_demand_context_mismatch.cue
  distribution_dangling_contributor.cue
  equilibrium_dangling_distribution.cue
)

for fixture in "${fixtures[@]}"; do
  path="$root/$fixture"
  echo "expecting CUE contradiction: $fixture"
  if cue vet -c=false "$base" "$path"; then
    echo "ERROR: negative fixture unexpectedly validated: $fixture" >&2
    exit 1
  fi
done

echo "all Gym semantic-integrity negative fixtures contradicted as expected"
