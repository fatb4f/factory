#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

section() {
  printf '\n== %s ==\n' "$1"
}

validate_registry() {
  section "registry"
  cue vet -c=false ./registry.cue
  local registry_json
  registry_json="$(mktemp)"
  trap 'rm -f "$registry_json"' RETURN
  cue export ./registry.cue --out json >"$registry_json"

  while IFS= read -r path; do
    [[ -e "$path" ]] || { echo "registry authority path missing: $path" >&2; exit 1; }
  done < <(jq -r '.tasks[] | .authority // empty' "$registry_json")

  while IFS= read -r path; do
    [[ -e "$path" ]] || { echo "registry agent path missing: $path" >&2; exit 1; }
  done < <(jq -r '.tasks[] | .agent' "$registry_json")

  grep -Fq 'authority -> contracts/academic/uqam/events/contract.cue' docs/architecture/factory-unit-registry-refactor.md
  grep -Fq 'contracts/workers/upstream-monitor/AGENTS.md' docs/architecture/factory-unit-registry-refactor.md
}

validate_upstream_latest() {
  local profile="$1"
  local evidence_schema="$2"
  local profile_package="$3"
  local latest="projects/${profile}/upstream-monitor/latest.json"

  section "upstream-monitor latest: ${profile}"
  cue vet -c=false "$latest" ./contracts/workers/upstream-monitor:upstreammonitor -d '#LatestRunPointer'

  local bundle manifest evidence
  bundle="$(jq -r '.bundle_path' "$latest")"
  manifest="$(jq -r '.manifest_path' "$latest")"
  evidence="${bundle%/}/evidence.json"

  [[ -d "$bundle" ]] || { echo "missing bundle: $bundle" >&2; exit 1; }
  [[ -f "$manifest" ]] || { echo "missing manifest: $manifest" >&2; exit 1; }
  [[ -f "$evidence" ]] || { echo "missing evidence: $evidence" >&2; exit 1; }

  cue vet -c=false "$manifest" ./contracts/workers/upstream-monitor:upstreammonitor -d '#RunBundleManifest'
  cue vet -c=false "$evidence" "$profile_package" -d "$evidence_schema"

  [[ "$(jq -r '.run_id' "$latest")" == "$(jq -r '.run_id' "$manifest")" ]]
  [[ "$(jq -r '.profile_id' "$latest")" == "$(jq -r '.profile_id' "$manifest")" ]]

  while IFS=$'\t' read -r filename expected; do
    local artifact="${bundle%/}/$filename"
    [[ -f "$artifact" ]] || { echo "missing sealed artifact: $artifact" >&2; exit 1; }
    local actual
    actual="$(git hash-object "$artifact")"
    [[ "$actual" == "$expected" ]] || {
      echo "blob mismatch: $artifact expected=$expected actual=$actual" >&2
      exit 1
    }
  done < <(jq -r '.artifacts[] | [.filename, .gitBlobSHA] | @tsv' "$manifest")
}

validate_epistemic_template() {
  section "epistemic report template"
  local expected actual
  expected="$(mktemp)"
  actual="$(mktemp)"
  trap 'rm -f "$expected" "$actual"' RETURN
  cat >"$expected" <<'EOF'
## Run identity
## Subject authority
## Source state
## Authority separation
## Dependency and admission graph
## Correlation lineage
## Critical
## High
## Notes
## No local action
## Executable validation
## Publication
EOF
  grep '^## ' projects/epistemic-plant-bootstrap/.agents/report-template.md >"$actual"
  diff -u "$expected" "$actual"
  grep '^## ' projects/epistemic-plant-bootstrap/upstream-monitor/fixtures/report-template-rendered.md | diff -u "$expected" -
}

section "shared state"
cue vet -c=false ./contracts/state:state
cue vet -c=false ./state/fixtures:statefixtures
bash state/fixtures/negative/run.sh

section "UQAM event watch"
cue vet -c=false ./contracts/academic/uqam/events:uqamevents
cue vet -c=false ./academic/uqam/events/fixtures:uqameventsfixtures
bash academic/uqam/events/fixtures/negative/run.sh

section "upstream-monitor contracts"
cue vet -c=false ./contracts/workers/upstream-monitor:upstreammonitor
cue export ./contracts/workers/upstream-monitor/profiles_ctrl:ctrlprofile -e publicContract --out json >/dev/null
cue export ./contracts/workers/upstream-monitor/profiles_epistemic_plant_bootstrap:epistemicplantprofile -e publicContract --out json >/dev/null
validate_upstream_latest "ctrl" '#CtrlRunEvidence' './contracts/workers/upstream-monitor/profiles_ctrl:ctrlprofile'
validate_upstream_latest "epistemic-plant-bootstrap" '#EpistemicPlantRunEvidence' './contracts/workers/upstream-monitor/profiles_epistemic_plant_bootstrap:epistemicplantprofile'
validate_epistemic_template

section "industrial constraints"
cue vet -c=false ./contracts/world/industrial-constraints:industrialconstraints
cue vet -c=false ./world/industrial-constraints/fixtures:qualification
if [[ -x world/industrial-constraints/fixtures/negative/run.sh ]]; then
  bash world/industrial-constraints/fixtures/negative/run.sh
fi

section "Gym"
cue vet -c=false ./contracts/personal/gym:gym
cue vet -c=false ./personal/gym/fixtures:fixtures
bash personal/gym/fixtures/negative/run.sh
cue export ./contracts/personal/gym:gym -e public --out json >/dev/null

validate_registry

section "worker-procedure uniqueness"
grep -Fq 'This path is non-normative compatibility only.' .agents/workers/upstream-monitor/AGENTS.md
! grep -q '^## \(Read order\|Actuator model\|Publication\)' .agents/workers/upstream-monitor/AGENTS.md

echo "all contract validation surfaces passed"
