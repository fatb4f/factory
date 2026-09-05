#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

section() {
  printf '\n== %s ==\n' "$1"
}

sha256_uri() {
  printf 'sha256:%s\n' "$(sha256sum "$1" | awk '{print $1}')"
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
  grep -Fq 'contracts/academic/uqam/catalog/contract.cue' registry.cue
  grep -Fq 'contracts/workers/upstream-monitor/AGENTS.md' docs/architecture/factory-unit-registry-refactor.md
}

validate_uqam_admitted_state() {
  section "UQAM admitted comparison state"

  local contract_dir="./contracts/academic/uqam/events"
  local pointer="academic/uqam/events/state/admitted-baseline.json"
  [[ -f "$pointer" ]] || { echo "missing UQAM admitted baseline pointer: $pointer" >&2; exit 1; }

  cue vet -c=false "$pointer" "$contract_dir"/*.cue -d '#EventBaselinePointer'

  local bundle manifest normalized decision
  bundle="$(jq -r '.baseline.run.bundle_path' "$pointer")"
  manifest="${bundle%/}/manifest.json"
  [[ -f "$manifest" ]] || { echo "missing UQAM manifest: $manifest" >&2; exit 1; }

  cue vet -c=false "$manifest" "$contract_dir"/*.cue -d '#RunManifest'

  normalized="${bundle%/}/$(jq -r '.normalized_path' "$manifest")"
  decision="${bundle%/}/$(jq -r '.decision_path' "$manifest")"
  [[ -f "$normalized" ]] || { echo "missing UQAM normalized artifact: $normalized" >&2; exit 1; }
  [[ -f "$decision" ]] || { echo "missing UQAM decision artifact: $decision" >&2; exit 1; }

  cue vet -c=false "$normalized" "$contract_dir"/*.cue -d '#NormalizedSnapshot'
  cue vet -c=false "$decision" "$contract_dir"/*.cue -d '#DecisionArtifact'

  [[ "$(jq -r '.baseline.run.run_id' "$pointer")" == "$(jq -r '.run_id' "$manifest")" ]]
  [[ "$(jq -r '.baseline.run.normalized_digest' "$pointer")" == "$(jq -r '.normalized_digest' "$manifest")" ]]
  [[ "$(jq -r '.baseline.run.observed_at' "$pointer")" == "$(jq -r '.observed_at' "$manifest")" ]]

  [[ "$(jq -r '.task_id' "$normalized")" == "$(jq -r '.task_id' "$manifest")" ]]
  [[ "$(jq -r '.schema' "$normalized")" == "$(jq -r '.schema' "$manifest")" ]]
  [[ "$(jq -r '.observed_at' "$normalized")" == "$(jq -r '.observed_at' "$manifest")" ]]

  [[ "$(jq -r '.currentRun.run_id' "$decision")" == "$(jq -r '.run_id' "$manifest")" ]]
  [[ "$(jq -r '.currentRun.normalized_digest' "$decision")" == "$(jq -r '.normalized_digest' "$manifest")" ]]
  [[ "$(sha256_uri "$normalized")" == "$(jq -r '.normalized_digest' "$manifest")" ]]
  [[ "$(sha256_uri "$decision")" == "$(jq -r '.decision_digest' "$manifest")" ]]

  jq -e --slurpfile admitted "$pointer" '(.pointer.action != "advance") or (.pointer.transition.next == $admitted[0])' "$decision" >/dev/null
}

validate_upstream_latest() {
  local profile="$1"
  local evidence_schema="$2"
  local profile_dir="$3"
  local latest="projects/${profile}/upstream-monitor/latest.json"

  section "upstream-monitor latest: ${profile}"
  cue vet -c=false "$latest" ./contracts/workers/upstream-monitor/*.cue -d '#LatestRunPointer'

  local bundle manifest evidence
  bundle="$(jq -r '.bundle_path' "$latest")"
  manifest="$(jq -r '.manifest_path' "$latest")"
  evidence="${bundle%/}/evidence.json"

  [[ -d "$bundle" ]] || { echo "missing bundle: $bundle" >&2; exit 1; }
  [[ -f "$manifest" ]] || { echo "missing manifest: $manifest" >&2; exit 1; }
  [[ -f "$evidence" ]] || { echo "missing evidence: $evidence" >&2; exit 1; }

  cue vet -c=false "$manifest" ./contracts/workers/upstream-monitor/*.cue -d '#RunBundleManifest'
  cue vet -c=false "$evidence" "$profile_dir"/*.cue -d "$evidence_schema"

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

validate_gym_public() {
  section "Gym public compatibility"

  local tmpdir public_json
  tmpdir="$(mktemp -d)"
  public_json="$tmpdir/public.json"
  cue export ./contracts/personal/gym:gym -e public --out json >"$public_json"

  local pairs=(
    "body:bodyRegions"
    "chains:chains"
    "relations:chainRelations"
    "metrics:metrics"
    "equilibriumMetrics:equilibriumMetrics"
    "protocols:protocols"
    "exercises:exerciseProfiles"
    "mappings:exerciseMappings"
    "programs:programs"
    "projections:projectionRelations"
  )

  local pair public_key expression canonical_json public_count canonical_count
  for pair in "${pairs[@]}"; do
    public_key="${pair%%:*}"
    expression="${pair#*:}"
    canonical_json="$tmpdir/${public_key}.json"
    cue export ./contracts/personal/gym:gym -e "$expression" --out json >"$canonical_json"
    public_count="$(jq --arg key "$public_key" '.[$key] | length' "$public_json")"
    canonical_count="$(jq 'length' "$canonical_json")"
    [[ "$public_count" == "$canonical_count" ]] || {
      echo "Gym public registry count mismatch: $public_key public=$public_count canonical=$canonical_count" >&2
      rm -rf "$tmpdir"
      exit 1
    }
  done

  rm -rf "$tmpdir"
}

section "shared state"
cue vet -c=false ./contracts/state:state
cue vet -c=false ./state/fixtures:statefixtures
bash state/fixtures/negative/run.sh

section "UQAM event watch"
cue vet -c=false ./contracts/academic/uqam/events:uqamevents
cue vet -c=false ./academic/uqam/events/fixtures:uqameventsfixtures
bash academic/uqam/events/fixtures/negative/run.sh
validate_uqam_admitted_state

section "UQAM institutional catalog"
cue vet -c=false ./contracts/academic/uqam/catalog:uqamcatalog
cue vet -c=false ./academic/uqam/catalog/fixtures:uqamcatalogfixtures

section "upstream-monitor contracts"
cue vet -c=false ./contracts/workers/upstream-monitor:upstreammonitor
cue export ./contracts/workers/upstream-monitor/profiles_ctrl:ctrlprofile -e publicContract --out json >/dev/null
cue export ./contracts/workers/upstream-monitor/profiles_epistemic_plant_bootstrap:epistemicplantprofile -e publicContract --out json >/dev/null
validate_upstream_latest "ctrl" '#CtrlRunEvidence' './contracts/workers/upstream-monitor/profiles_ctrl'
validate_upstream_latest "epistemic-plant-bootstrap" '#EpistemicPlantRunEvidence' './contracts/workers/upstream-monitor/profiles_epistemic_plant_bootstrap'
validate_epistemic_template

section "industrial constraints"
cue vet -c=false ./contracts/world/industrial-constraints:industrialconstraints
cue vet -c=false ./world/industrial-constraints/fixtures:qualification
if [[ -x world/industrial-constraints/fixtures/negative/run.sh ]]; then
  bash world/industrial-constraints/fixtures/negative/run.sh
fi

section "engineering signals"
cue vet -c=false ./contracts/world/engineering-signals:engineeringsignals

section "Canada clean energy"
cue vet -c=false ./contracts/world/canada-clean-energy:cleanenergy

section "Canada climate readiness"
cue vet -c=false ./contracts/world/canada-climate-readiness:climatereadiness

section "financial signals"
cue vet -c=false ./contracts/world/financial-signals:financialsignals

section "resource allocation"
cue vet -c=false ./contracts/world/resource-allocation:resourceallocation

section "financial opportunities"
cue vet -c=false ./contracts/world/financial-opportunities:financialopportunities

section "engineering POCs"
cue vet -c=false ./contracts/projects/engineering-pocs:engineeringpocs

section "Gym"
cue vet -c=false ./contracts/personal/gym:gym
cue vet -c=false ./personal/gym/fixtures:fixtures
bash personal/gym/fixtures/negative/run.sh
validate_gym_public

validate_registry

section "worker-procedure uniqueness"
grep -Fq 'This path is non-normative compatibility only.' .agents/workers/upstream-monitor/AGENTS.md
! grep -q '^## \(Read order\|Actuator model\|Publication\)' .agents/workers/upstream-monitor/AGENTS.md

echo "all contract validation surfaces passed"
