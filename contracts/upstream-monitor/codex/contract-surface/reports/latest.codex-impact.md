# Codex contract-surface impact report

```text
apiVersion: factory.upstream-monitor.codex/v0
kind: CodexImpactReport
loop: codex-contract-surface
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
run_result: terminal_success_new_admitted_upstream_impact_with_validation_caveats
channels: main, latest-alpha-cli
run_id: 20260708T045308Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: f1affbac5e5164b2bae825e9b39e9868bc4e0be2
workspace_version: 0.0.0
previous_recorded_head: a3f8b0b33284054133474e7b1cc5fa7600221d97
change_since_previous_evidence: advanced
compare_status: ahead
ahead_by: 28
behind_by: 0
changed_files_count: unresolved-from-connector-total; broad app-server/core/schema/workflow set observed
```

### latest-alpha-cli

```text
status: resolved-content; exact head sha unresolved through connector response
repo: openai/codex
ref: latest-alpha-cli
head_commit: unresolved
relation_to_main: diverged; ahead-by-1; behind-by-35 from current main
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0
previous_recorded_workspace_version: 0.143.0-alpha.38
change_since_previous_evidence: advanced by concrete branch-content version evidence; exact ref sha unresolved
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### main: extension-owned image-generation item surface

```text
id: openai-codex-main-f1affba-image-generation-extension-item
channel: main
commit: f1affbac5e5164b2bae825e9b39e9868bc4e0be2
impact: high
surface: extension item schema, app-server thread history projection, image-generation persistence envelope
```

Upstream now exposes a standalone `ImageGenerationItem` owned by the image extension and imported into app-server thread-history projection. The item carries `id`, `status`, `revised_prompt`, `result`, and optional `saved_path`, while core/rollout persistence carry it inside an extension envelope.

Evidence anchors:

```text
- codex-rs/ext/items/src/image_generation.rs defines the serialized/TS/JSON-schema ImageGenerationItem contract.
- codex-rs/app-server-protocol/src/protocol/thread_history.rs imports codex_extension_items::image_generation::ImageGenerationItem into thread-history projection.
```

Local contract targets to review:

```text
- extension item schema/type generation
- app-server v2 ThreadItem / thread-history projection fixtures
- saved_path optionality and persistence-envelope invariants
```

### main: app-server account login brand and external auth bridge

```text
id: openai-codex-main-f1affba-app-server-login-auth-bridge
channel: main
commit: f1affbac5e5164b2bae825e9b39e9868bc4e0be2
impact: high
surface: account/login/start params, ChatGPT hosted login, external auth refresh bridge, app-server auth state
```

`LoginAccountParams.Chatgpt` now admits `app_brand` in addition to streamlined/hosted login flags, with `LoginAppBrand` values `codex` and `chatgpt`. App-server also has an `ExternalAuthBridge` that stores `CodexAuth`, issues `chatgptAuthTokensRefresh` server requests, times out refresh after 10s, and writes refreshed `CodexAuth` back into bridge state.

Evidence anchors:

```text
- codex-rs/app-server-protocol/src/protocol/v2/account.rs defines LoginAccountParams.Chatgpt.app_brand and LoginAppBrand.
- codex-rs/app-server/src/external_auth.rs implements ExternalAuthBridge around CodexAuth and chatgptAuthTokensRefresh.
```

Local contract targets to review:

```text
- account/login/start request schema and TypeScript generation
- hosted login success-page/client-brand fixtures
- external ChatGPT auth refresh timeout and account-id validation constraints
```

### main: remote compaction request and fallback telemetry split

```text
id: openai-codex-main-f1affba-remote-compaction-request-fallback
channel: main
commit: f1affbac5e5164b2bae825e9b39e9868bc4e0be2
impact: high
surface: remote compaction request assembly, responses metadata, model fallback telemetry, active-context token accounting
```

Remote compaction now has a separated request-attempt module that trims function-call history before compaction, adjusts active-context token accounting, builds model-visible tools and responses metadata, and submits compaction with auth-mode-sensitive service-tier selection. A dedicated fallback helper emits `codex.compaction.model_fallback` telemetry tagged by reason, implementation, and outcome.

Evidence anchors:

```text
- codex-rs/core/src/compact_remote_request.rs defines RemoteCompactAttempt and run_remote_compact_attempt.
- codex-rs/core/src/compact_model_fallback.rs records fallback telemetry and logs model fallback outcomes.
```

Local contract targets to review:

```text
- compaction request projection and trace-input fixtures
- service-tier omission for API-key auth mode
- compaction telemetry tag constraints
```

### main: MCP tool metadata, policy, and elicitation context

```text
id: openai-codex-main-f1affba-mcp-tool-metadata-policy
channel: main
commit: f1affbac5e5164b2bae825e9b39e9868bc4e0be2
impact: high
surface: MCP tool-call lifecycle, app-tool policy evaluation, approval metadata, elicitation flow, turn metadata
```

MCP tool-call handling now threads richer metadata and policy state through the tool-call lifecycle: approval metadata constants, connector/tool descriptors, app-tool policy evaluation for the Codex Apps MCP server, auth elicitation helpers, and turn metadata context are all in the path before lifecycle dispatch.

Evidence anchors:

```text
- codex-rs/core/src/mcp_tool_call.rs imports McpTurnMetadataContext, auth elicitation helpers, approval metadata keys, and AppToolPolicyEvaluator.
- handle_mcp_tool_call builds invocation metadata and app-tool policy before dispatching MCP tool-call item lifecycle events.
```

Local contract targets to review:

```text
- MCP approval metadata schema/type generation
- app-tool policy evaluator fixtures for selected/plugin connector tools
- auth elicitation and server-user-flow telemetry invariants
```

### main: skill namespace resolver implementation

```text
id: openai-codex-main-f1affba-skill-namespace-resolver
channel: main
commit: f1affbac5e5164b2bae825e9b39e9868bc4e0be2
impact: high
surface: plugin skill namespace resolution, nested manifests, symlink root precedence, skill loader naming
```

Upstream now implements a scan-local `SkillNamespaceResolver` with explicit precedence: provided plugin namespace, deepest canonical symlink or nested plugin root, then scan-root inherited namespace. Skill names are qualified as `namespace:skill` when a plugin namespace applies.

Evidence anchors:

```text
- codex-rs/core-skills/src/loader/namespace.rs defines SkillNamespaceResolver and its namespace precedence.
- ResolvedSkillNamespace::qualify emits namespace-qualified skill names.
```

Local contract targets to review:

```text
- plugin skill namespace resolver contract
- nested manifest and symlink-root precedence fixtures
- generated skill-name collision/qualification constraints
```

### main: delivered managed config layers model

```text
id: openai-codex-main-f1affba-delivered-managed-layers
channel: main
commit: f1affbac5e5164b2bae825e9b39e9868bc4e0be2
impact: high
surface: backend OpenAPI models, delivered managed layers, config TOML fragment layering
```

The generated backend model surface now includes `DeliveredManagedLayers` with explicit `baseline` and `system_overlay` TOML fragment vectors. Local managed-config projections should avoid collapsing these layers into a single delivered TOML fragment list.

Evidence anchors:

```text
- codex-rs/codex-backend-openapi-models/src/models/delivered_managed_layers.rs defines baseline and system_overlay fields.
```

Local contract targets to review:

```text
- managed config layer schema
- baseline vs system_overlay ordering/merge semantics
- generated backend OpenAPI type projections
```

## Alpha channel impact

### latest-alpha-cli: version channel advanced to 0.143.0

```text
id: openai-codex-alpha-0.143.0-version-channel
channel: latest-alpha-cli
commit: unresolved
impact: high
surface: alpha CLI version channel, release/package version tracking
```

`latest-alpha-cli` content now reports `workspace.package.version = "0.143.0"`, replacing the previously recorded `0.143.0-alpha.38`. The exact branch head SHA remains unresolved through this connector response and is intentionally not inferred.

Local contract targets to review:

```text
- alpha/stable release-channel distinction
- version evidence schema that allows concrete content evidence with unresolved head SHA
- downstream package/version gate fixtures
```

## No local action

No issue updates were performed because `upstreamCodexPublicationPlan.issueTargets` is currently `{}`.

No contract authority was changed from upstream evidence.

No local contract mutation was performed; only admitted report/evidence projections were written.

## Suggested local targets

```text
- Add extension-owned ImageGenerationItem schema/type fixtures.
- Add app-server account/login app_brand and external-auth refresh bridge fixtures.
- Model remote compaction request attempts and model fallback telemetry tags.
- Add MCP app-tool policy/approval metadata/auth elicitation fixtures.
- Promote skill namespace resolver precedence from note-level coverage to contract fixtures.
- Preserve delivered managed config baseline and system_overlay layers separately.
- Allow alpha-channel version evidence to advance even when exact branch head is unresolved.
```

## Issue updates

No issue updates were performed.

Reason: `upstreamCodexPublicationPlan.issueTargets` is currently `{}`, so no concrete issue mutation target is admitted for this run.

## Validation notes

Static contract reads performed through the GitHub App:

```text
contracts/upstream-monitor/AGENTS.md
contracts/upstream-monitor/codex/AGENTS.md
contracts/upstream-monitor/codex/contract-surface/AGENTS.md
contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
```

Publication admission observed from the previous latest evidence/publication projection:

```text
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260708T045308Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260708T045308Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for configured/known terms returned no matches in `fatb4f/factory` during this run.

Caveat: direct GitHub content reads for `contracts/upstream-monitor/codex/contract-surface/publication.cue`, `public.cue`, and `report.cue` were previously recorded as 404 through the GitHub content API. This report therefore relies on the prior latest evidence/publication projection for admitted paths and issue target shape.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface recorded by prior latest evidence.

Caveat: `latest-alpha-cli` exact branch head SHA was not exposed by connector responses. It is kept unresolved; only concrete branch-content version evidence is recorded.

## Control action

```text
action: publish-contract-local-impact-run-and-latest-report
reason: new admitted upstream impact on main and concrete latest-alpha-cli version evidence changed
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
