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
run_id: 20260707T165254Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: a3f8b0b33284054133474e7b1cc5fa7600221d97
workspace_version: 0.0.0
previous_recorded_head: cca16a10878202cb2f6e9666b6b4330329ea7e65
change_since_previous_evidence: advanced
compare_status: ahead
ahead_by: 4
behind_by: 0
changed_files_count: 15
```

### latest-alpha-cli

```text
status: resolved-content; exact head sha unresolved through connector response
repo: openai/codex
ref: latest-alpha-cli
head_commit: unresolved
relation_to_main: diverged; ahead-by-1; behind-by-7 from current main
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.38
previous_recorded_workspace_version: 0.143.0-alpha.38
change_since_previous_evidence: unchanged by concrete branch-content version evidence; exact ref sha unresolved
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### main: canonical dynamic tool call item producer

```text
id: openai-codex-main-f659eb1-canonical-dynamic-tool-call-items
channel: main
commit: f659eb12bc8cecb976d92db192d9b2983c8053ff
upstream_pr: openai/codex#31298
impact: high
surface: dynamic tool lifecycle, app-server v2 item stream, client dynamic-tool request dispatch, legacy event compatibility
```

Dynamic tools now emit canonical `TurnItem::DynamicToolCall` lifecycle instead of direct `DynamicToolCallRequest` / `DynamicToolCallResponse` events. App-server v2 dispatches the client dynamic-tool request from the canonical item start and ignores mapped legacy request/response events, preserving exactly-one request behavior while moving the authority surface to canonical item lifecycle.

Evidence anchors:

```text
- commit f659eb12bc8cecb976d92db192d9b2983c8053ff message: feat(core): emit canonical dynamic tool call items (#31298)
- app-server bespoke event handling ignores deprecated DynamicToolCallRequest/Response for v2 and dispatches requests from canonical DynamicToolCall ItemStarted events.
- core dynamic tool handler emits DynamicToolCallItem started/completed lifecycle with status, content_items, success, error, and duration.
```

Local contract targets to review:

```text
- dynamic tool item schema/type generation
- app-server v2 DynamicToolCall request dispatch invariants
- duplicate dynamic-tool request negative fixtures
- legacy DynamicToolCallRequest/Response compatibility projections
```

### main: Intel macOS V8 signing entitlement split

```text
id: openai-codex-main-f363ed7-intel-v8-signing-entitlements
channel: main
commit: f363ed70cc1c6e2cae15fc1b8711f7e0d7b96cf1
upstream_pr: openai/codex#30953
impact: high
surface: release workflow, macOS signing entitlements, V8 Code Mode startup, binary verification
```

The release workflow now selects per-binary macOS entitlement profiles. Intel V8-linked binaries (`codex`, `codex-app-server`, and `codex-code-mode-host`) receive both `allow-jit` and `allow-unsigned-executable-memory`, while `codex-responses-api-proxy` stays on the narrower `allow-jit` profile. Verification now checks Mach-O architecture and exact entitlement dictionaries across signed binary copies and packages.

Evidence anchors:

```text
- commit f363ed70cc1c6e2cae15fc1b8711f7e0d7b96cf1 message: fix(release): add missing Intel V8 signing entitlement (#30953)
- .github/scripts/macos-signing adds per-binary entitlement files.
- .github/workflows/rust-release.yml signs and verifies binaries against the per-binary entitlement file.
```

Local contract targets to review:

```text
- release artifact signing policy projections
- platform/architecture-specific entitlement fixtures
- fail-closed binary selector constraints for generated release adapters
```

### main: ExternalAuth returns CodexAuth directly

```text
id: openai-codex-main-a3f8b0b-external-auth-codexauth
channel: main
commit: a3f8b0b33284054133474e7b1cc5fa7600221d97
upstream_pr: openai/codex#31355
impact: high
surface: auth manager contracts, external bearer flow, ChatGPT token refresh, app-server auth refresh bridge
```

`ExternalAuth` now resolves and refreshes `CodexAuth` directly instead of returning the removed `ExternalAuthTokens` wrapper. Bearer-only external auth is represented as API-key `CodexAuth`; ChatGPT external refresh returns `CodexAuth::from_external_chatgpt_tokens`, and refresh validation now asserts concrete auth mode/account state rather than wrapper metadata.

Evidence anchors:

```text
- commit a3f8b0b33284054133474e7b1cc5fa7600221d97 message: refactor: make ExternalAuth return CodexAuth (#31355)
- codex-login auth trait signatures change from ExternalAuthTokens to CodexAuth.
- AuthManager ignores non-API-key auth from external API-key providers and validates external ChatGPT auth token state/account id during refresh.
```

Local contract targets to review:

```text
- auth adapter type projections that still model ExternalAuthTokens
- external bearer and ChatGPT refresh fixtures
- account/workspace validation constraints for externally supplied ChatGPT auth
```

## Notes

### main: plugin namespace loading test coverage

```text
id: openai-codex-main-42156ba-plugin-namespace-loading-coverage
channel: main
commit: 42156ba007278d9068f1518ac1f627b56c136ef6
impact: note
surface: skill/plugin namespace loading tests, nested plugin manifests, symlink behavior
```

Upstream added coverage for nested plugin skill namespace inheritance/override behavior and symlink scan-root edge cases. No implementation behavior changed in this commit, but the tests clarify expected namespace precedence and are useful fixture evidence for local plugin-skill contracts.

## No local action

No issue updates were performed because `upstreamCodexPublicationPlan.issueTargets` is currently `{}`.

No contract authority was changed from upstream evidence.

No local contract mutation was performed; only admitted report/evidence projections were written.

## Suggested local targets

```text
- Add canonical DynamicToolCall item lifecycle and request-dispatch fixtures.
- Add a no-duplicate dynamic-tool request negative fixture for mapped legacy events.
- Model macOS release signing as per-binary entitlement selection with architecture-specific verification.
- Replace any ExternalAuthTokens local projection with direct CodexAuth-mode projections.
- Add plugin namespace precedence/symlink cases as fixture references, if the local surface models plugin skills.
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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260707T165254Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260707T165254Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for configured/known terms returned no matches in `fatb4f/factory` during this run.

Caveat: direct GitHub content reads for `contracts/upstream-monitor/codex/contract-surface/publication.cue`, `public.cue`, and `report.cue` were previously recorded as 404 through the GitHub content API. This report therefore relies on the prior latest evidence/publication projection for admitted paths and issue target shape.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface recorded by prior latest evidence.

Caveat: `latest-alpha-cli` exact branch head SHA was not exposed by connector responses. It is kept unresolved; only concrete branch-content evidence and the `0.143.0-alpha.38` version are recorded.

## Control action

```text
action: publish-contract-local-impact-run-and-latest-report
reason: new admitted upstream impact on main; recurring observation run still admitted report/evidence publication
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
