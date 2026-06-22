set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

generate-validation:
  contracts/factory/reflection/scripts/generate-validation

export-validation-loop:
  just generate-validation
  tmp_file="$(mktemp)"; trap 'rm -f "$tmp_file"' EXIT; cd contracts/factory && cue export . -e introspection.controlLoopExportCommands > "$tmp_file"; cd ../..; jq -r '.[]' "$tmp_file" | while IFS= read -r command; do just export-validation-loop-command "$command"; done
  just check-drift
  for f in generated/evidence/control-loop/*.json; do jq -e '.authority == false and .bounded == true and (.provenance.sourceDigest | test("^sha256:[0-9a-f]{64}$")) and (.provenance.inventoryDigest | test("^sha256:[0-9a-f]{64}$")) and (.provenance.materializedAt | test("^run:[0-9a-f]{16,64}$"))' "$f" >/dev/null; done
  jq -e '.payload.status == "closed"' generated/evidence/control-loop/error-signal.json >/dev/null
  jq -e '.payload.action == "admit"' generated/evidence/control-loop/control-action.json >/dev/null

export-validation-loop-stage stage:
  tmp_file="$(mktemp)"; trap 'rm -f "$tmp_file"' EXIT; source_digest="$(jq -r '.provenance.sourceDigest' generated/evidence/materialization-report.json)"; inventory_digest="$(jq -r '.provenance.inventoryDigest' generated/evidence/materialization-report.json)"; materialized_at="$(jq -r '.provenance.materializedAt' generated/evidence/materialization-report.json)"; cd contracts/factory && cue export . -e introspection -t sourceDigest="$source_digest" -t inventoryDigest="$inventory_digest" -t materializedAt="$materialized_at" > "$tmp_file"; cd ../..; command="$(jq -r --arg stage "{{stage}}" '.adapterCommands | to_entries[] | select(.value.action == "export-view" and .value.view == $stage) | .key' "$tmp_file")"; [ -n "$command" ] || { printf 'unknown validation loop stage: %s\n' "{{stage}}" >&2; exit 2; }; just export-validation-loop-command "$command"

export-validation-loop-command command:
  mkdir -p generated/evidence/control-loop
  repo_root="$PWD"; command_file="$(mktemp)"; export_file="$(mktemp)"; bound_file="$(mktemp)"; trap 'rm -f "$command_file" "$export_file" "$bound_file"' EXIT; source_digest="$(jq -r '.provenance.sourceDigest' generated/evidence/materialization-report.json)"; inventory_digest="$(jq -r '.provenance.inventoryDigest' generated/evidence/materialization-report.json)"; materialized_at="$(jq -r '.provenance.materializedAt' generated/evidence/materialization-report.json)"; cd contracts/factory && cue export . -e 'introspection.adapterCommands["{{command}}"]' -t sourceDigest="$source_digest" -t inventoryDigest="$inventory_digest" -t materializedAt="$materialized_at" > "$command_file"; expr="$(jq -r '.target.path | join(".")' "$command_file")"; out="$repo_root/$(jq -r '.materializes[0].path' "$command_file")"; cue export . -e "$expr" -t sourceDigest="$source_digest" -t inventoryDigest="$inventory_digest" -t materializedAt="$materialized_at" > "$export_file"; cd "$repo_root"; binding_kind="$(jq -r '.payloadBinding.kind // empty' "$command_file")"; case "$binding_kind" in json-pointer) source_path="$(jq -r '.payloadBinding.sourcePath' "$command_file")"; pointer="$(jq -c '.payloadBinding.pointer' "$command_file")"; target_path="$(jq -c '.payloadBinding.targetPath' "$command_file")"; jq --slurpfile source "$source_path" --argjson pointer "$pointer" --argjson targetPath "$target_path" 'setpath($targetPath; ($source[0] | getpath($pointer)))' "$export_file" > "$bound_file"; mv "$bound_file" "$out" ;; "") mv "$export_file" "$out" ;; *) printf 'unsupported introspection payload binding: %s\n' "$binding_kind" >&2; exit 2 ;; esac; schema="$(jq -r '.materializes[0].schema' "$command_file")"; case "$schema" in factory.control-loop-stage-export.v1) cd contracts/factory && cue vet -c -d '#StageExport' . "$out" ;; *) printf 'unsupported exported evidence schema: %s\n' "$schema" >&2; exit 2 ;; esac

check-drift:
  source_digest="$(jq -r '.provenance.sourceDigest' generated/evidence/materialization-report.json)"; inventory_digest="$(jq -r '.provenance.inventoryDigest' generated/evidence/materialization-report.json)"; materialized_at="$(jq -r '.provenance.materializedAt' generated/evidence/materialization-report.json)"; introspection_file="$(mktemp)"; generated_roots_file="$(mktemp)"; evidence_file="$(mktemp)"; checks_file="$(mktemp)"; trap 'rm -f "$introspection_file" "$generated_roots_file" "$evidence_file" "$checks_file"' EXIT; cd contracts/factory; cue eval . -e introspection.driftAssertions -c -t sourceDigest="$source_digest" -t inventoryDigest="$inventory_digest" -t materializedAt="$materialized_at" >/dev/null; cue export . -e introspection -t sourceDigest="$source_digest" -t inventoryDigest="$inventory_digest" -t materializedAt="$materialized_at" > "$introspection_file"; cd ../..; find generated -mindepth 1 -maxdepth 1 -type d | sort | jq -R -s 'split("\n")[:-1]' > "$generated_roots_file"; find generated/evidence -type f | sort | jq -R -s 'split("\n")[:-1]' > "$evidence_file"; find generated/checks -type f -perm -111 | sort | jq -R -s 'split("\n")[:-1]' > "$checks_file"; jq -e --slurpfile roots "$generated_roots_file" --slurpfile evidence "$evidence_file" --slurpfile checks "$checks_file" 'def diff($a; $b): [$a[] as $x | select(($b | index($x)) | not)]; .adapterCommands as $commands | ([.adapterCommands | to_entries[] | .key as $commandName | (.value.materializes // [])[] | select(.writtenBy != $commandName)] | length == 0) and ([.materializations[] | select((.writtenBy as $writer | $commands[$writer] == null) or (.admittedBy as $admitter | $commands[$admitter] == null))] | length == 0) and (diff($roots[0]; .allowedGeneratedSubroots) | length == 0) and (diff($evidence[0]; [.materializations[] | select(.kind == "evidence") | .path]) | length == 0) and (diff($checks[0]; [.materializations[] | select(.kind == "executable-check") | .path]) | length == 0)' "$introspection_file" >/dev/null

check:
  just generate-validation
  cd contracts/factory && cue vet -c=false . ./object ./transition ./extraction ./workers ./workers/codex ./workers/cue ./workers/cue/cue-lsp ./workers/cue/cue-rg ./workers/gitbutler ./adapters ./assertions
  cd contracts/factory && cue eval ./assertions/generated -e agentContextHookAssertion -c >/dev/null
  cd contracts/upstream-monitor && cue vet -c=false . ./codex/contract-surface ./codex/contract-surface/output
  cd contracts/factory && cue eval ./assertions -c >/dev/null
  cd contracts/factory && cue vet ./fixtures/negative/valid
  cd contracts/factory && ! cue vet ./fixtures/negative/invalid-candidate-without-negative-fixture
  cd contracts/factory && ! cue vet ./fixtures/negative/invalid-candidate-raw-output
  cd contracts/factory && ! cue vet ./fixtures/negative/invalid-evaluation-without-fixture-verdict
  cd contracts/factory && ! cue vet ./fixtures/negative/invalid-feedback-admits-failed-evaluation
  cd contracts/factory && ! cue vet ./fixtures/negative/invalid-transition-without-admitted-feedback
  cd contracts/factory && ! cue vet ./fixtures/negative/invalid-materialization-before-admitted-transition
  generated/checks/agent-context-hook
  just export-validation-loop
  just check-drift
  git diff --exit-code -- generated/checks generated/fixtures generated/evidence contracts/factory/assertions/generated
  test ! -e checks
  test ! -e fixtures
  test "$(find generated -mindepth 1 -maxdepth 1 ! -name checks ! -name fixtures ! -name evidence | wc -l)" -eq 0
  test ! -e providers
  test ! -e projections
  test ! -e adapters
  test ! -e test

hook-smoke:
  generated/checks/agent-context-hook
