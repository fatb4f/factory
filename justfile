set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

check:
  cd contracts/factory && cue vet -c=false . ./object ./transition ./extraction ./workers ./workers/codex ./workers/cue ./workers/cue/cue-lsp ./workers/cue/cue-rg ./workers/gitbutler ./adapters ./assertions
  cd contracts/upstream-monitor && cue vet -c=false . ./codex/contract-surface ./codex/contract-surface/output
  cd contracts/factory && cue eval ./assertions -c >/dev/null
  cd contracts/factory && cue vet ./fixtures/negative/valid
  cd contracts/factory && ! cue vet ./fixtures/negative/invalid-candidate-without-negative-fixture
  cd contracts/factory && ! cue vet ./fixtures/negative/invalid-candidate-raw-output
  cd contracts/factory && ! cue vet ./fixtures/negative/invalid-evaluation-without-fixture-verdict
  cd contracts/factory && ! cue vet ./fixtures/negative/invalid-feedback-admits-failed-evaluation
  cd contracts/factory && ! cue vet ./fixtures/negative/invalid-transition-without-admitted-feedback
  cd contracts/factory && ! cue vet ./fixtures/negative/invalid-materialization-before-admitted-transition
  checks/agent-context-hook
  test ! -e fixtures
  test ! -e generated
  test ! -e providers
  test ! -e projections
  test ! -e adapters
  test ! -e test

hook-smoke:
  checks/agent-context-hook
