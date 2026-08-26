# CUEstrap Codex Contract-Surface Impact Report

## Run identity

- Run ID: `20260722T042019Z`
- Factory revision: `a80569adc33287c56805dd5549ba6d062e747b08`
- CUEstrap revision: `781801e6500bcef92169b8748ae82166bae56c88`
- Signal: `loop_bootstrap_request`
- Profile: `cuestrap`

## CUEstrap context state

All seven required context paths were read from `fatb4f/cuestrap@781801e6500bcef92169b8748ae82166bae56c88`. The repository remains subject context only. The supervisory controller exposes closed CUE/Pydantic hook, permission, session/turn, tool-routing, and evidence contracts; the Marimo workbook remains a gopy-backed native CUE qualification harness.

## Channel state: main

Resolved independently to `21db216db05d13713f09189fc44872d22cf47fc4` (`workspace.package.version = 0.0.0`). Against its prior channel head `0b175e6439a8608ba7726ee153fd8590619e8f34`, main is 40 commits ahead and 0 behind. The 300 changed paths were scanned against every declared surface.

## Channel state: latest-alpha-cli

Resolved independently to `3b61fac9b7d7b003183ff1b73c28df6abeb062a4` (`workspace.package.version = 0.145.0-alpha.30`). Against its prior channel head `5d724b1bc65073572298c78b031e3b7e4dc2724e`, alpha is 8 commits ahead and 150 behind. Its 18 changed paths were scanned separately against every declared surface.

## Purpose impact: supervisory session controller

**`blocking-gate`** — requalification is required for managed permission/config requirements, replay-locked session configuration, request-scoped MCP tool bindings, skill/plugin instruction rendering, thread identity, and alpha unified-exec permission/process semantics.

## Purpose impact: idiomatic CUE workbook harness

**`contract-update`** — update qualification for request-scoped MCP resource/tool bindings and the alpha code-mode session/runtime changes before making current-channel compatibility claims.

## Critical

### Managed configuration and session replay changed on main

Main adds layered requirement provenance and exact requirement application across approvals, sandbox mode, permission profiles, MCP requirements, and hooks; session lock replay now persists resolved model, permission, app, collaboration, environment, and agent settings. This intersects `permission-sandbox-approval` and `session-turn-identity`.

Local impact: extend and requalify the CUE/Pydantic controller contract for requirement provenance, replay identity, and effective permission state.

### MCP dispatch is now request-scoped on main

`codex-rs/codex-mcp/src/binding.rs` defines an exact, frozen tool catalogue and execution/resource clients for one model sampling request. This intersects `tool-dispatch-classification` and `mcp-code-mode`.

Local impact: bind CUEstrap classifications and pending operations to the advertised request-scoped tool/resource identity rather than a mutable global catalogue.

### Skill and plugin instruction projection changed on main

Main changes skill rendering budgets and plugin-list/config requirement schemas. This intersects `instruction-skill-policy` and `context-turn-lifecycle`.

Local impact: requalify the repository phase contract and context-budget assumptions before supervisory enforcement.

### Alpha unified-exec permission and process semantics changed

Alpha changes `write_stdin` polling/interaction emission, permission-profile environment injection, sandbox retries, and process management. This intersects `tool-dispatch-classification`, `permission-sandbox-approval`, and `tool-result-error-semantics`.

Local impact: requalify dispatch classification, post-tool correlation, permission-state projection, and terminal outcome normalization on alpha independently.

## High

### Alpha code-mode session runtime changed

Alpha changes the in-process code-mode session service, nested tool delegation, task-failure handling, and wait/execute outcomes. This intersects `mcp-code-mode` and `tool-result-error-semantics`.

Local impact: update the Marimo/code-mode adapter qualification and structured error projection for alpha.

### Main thread-fork identity contract changed

Main expands thread-fork behavior and explicitly serializes `sessionId` on the forked thread object. This intersects `session-turn-identity` and `context-turn-lifecycle`.

Local impact: preserve parent/fork/session/turn binding in controller ledgers and workbook context boundaries.

## Notes

### Release channels diverged further

Main remains `0.0.0`; alpha advanced to `0.145.0-alpha.30` while its branch lineage diverged 8 ahead and 150 behind the prior alpha head. Separate support baselines remain mandatory.

## No local action

No additional matched observation was classified as `none`. All ten declared surfaces were scanned on both channels; unmatched surfaces have empty observation sets for this delta.

## Publication

- Canonical factory run bundle: `contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260722T042019Z/`
- Canonical factory manifest: `contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260722T042019Z/manifest.json`
- Factory latest pointer: `contracts/upstream-monitor/codex/cuestrap-contract-surface/latest.json`
- CUEstrap repository artifacts written: `false`

## Tracking issue

- Target: `fatb4f/cuestrap#9`
- Update policy: `every_run`
- Mutation: `append_comment`
- Tracking identity: `cuestrap-codex-contract-surface/20260722T042019Z`
- Comment: `pending append-only terminal comment`
- Duplicate suppressed: `false`

## Validation notes

- Factory-local shared vocabulary, the complete selected CUEstrap profile, public export, and fixed report template were structurally read.
- The publication plan contains no `mirror` or `legacyReadOnly` target and declares `forbidLegacyPathsPresent: true` and `forbidCuestrapRepositoryArtifacts: true`.
- Prior state was resolved only through `latest.json`, its referenced manifest, and bundled `evidence.json`.
- Search/index and intervening factory-delta checks found no legacy `reports/` or `evidence/` ledger path; neither path was read as fallback state.
- Both upstream refs were concretely resolved and classified independently.
- Report and summary are projections of the typed evidence observations in this bundle.
- The GitHub App cannot execute `cue fmt`, `cue vet`, or `cue export`; no executable CUE-validation claim is made.
- No CUEstrap artifact or plumbing write is admitted; issue #9 append is the sole declared cross-repository mutation.
