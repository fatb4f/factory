# Codex contract-surface impact report

```text
apiVersion: factory.upstream-monitor.codex/v0
kind: CodexImpactReport
loop: codex-contract-surface
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
run_result: terminal_success_new_admitted_main_upstream_impact_with_validation_caveats
channels: main, latest-alpha-cli
run_id: 20260708T165446Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: a219b6fdb4e9f9655968adf20984916abc8b2290
workspace_version: 0.0.0
previous_recorded_head: f1affbac5e5164b2bae825e9b39e9868bc4e0be2
change_since_previous_evidence: advanced
compare_status: ahead
ahead_by: 8
behind_by: 0
changed_files_count: 51 observed from connector compare file list
```

### latest-alpha-cli

```text
status: resolved-content; exact head sha unresolved through connector response
repo: openai/codex
ref: latest-alpha-cli
head_commit: unresolved
relation_to_main: diverged; ahead-by-1; behind-by-43 from current main
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0
previous_recorded_workspace_version: 0.143.0
change_since_previous_evidence: unchanged by concrete branch-content version evidence; exact ref sha unresolved
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### main: extension-owned web-search item surface

```text
id: openai-codex-main-a219b6f-web-search-extension-item
channel: main
commit: a219b6fdb4e9f9655968adf20984916abc8b2290
impact: high
surface: extension item schema, app-server v2 ThreadItem, web-search action projection
```

Upstream now exposes a standalone extension-owned `WebSearchItem` with `id`, `query`, and optional `action`. The action is a tagged app-server-facing enum with `search`, `openPage`, `findInPage`, and `other` variants. App-server v2 re-exports `WebSearchItem` and `WebSearchAction`, and `ThreadItem` now has a `WebSearch(WebSearchItem)` variant whose id is read from the extension item.

Evidence anchors:

```text
- codex-rs/ext/items/src/web_search.rs defines WebSearchItem and WebSearchAction with TS/JSON-schema derivations.
- codex-rs/app-server-protocol/src/protocol/v2/item.rs re-exports web-search extension item types.
- codex-rs/app-server-protocol/src/protocol/v2/item.rs includes ThreadItem::WebSearch(WebSearchItem) and id dispatch for WebSearch.
```

Local contract targets to review:

```text
- extension-owned WebSearchItem schema/type generation
- app-server v2 ThreadItem discriminant/projection fixtures
- web-search action optionality for query/queries/url/pattern
```

### main: extension tool TurnItem emission bridge

```text
id: openai-codex-main-a219b6f-extension-turnitem-emission-bridge
channel: main
commit: a219b6fdb4e9f9655968adf20984916abc8b2290
impact: high
surface: extension tool lifecycle, canonical TurnItem emission, legacy EventMsg compatibility
```

Extension tools now emit canonical extension `TurnItem` lifecycle events through a `TurnItemEmitter`, then forward supplied legacy `EventMsg` values for compatibility. The adapter passes conversation history, environment/sandbox context, model/truncation metadata, and a turn item emitter into extension tool calls.

Evidence anchors:

```text
- codex-rs/core/src/tools/handlers/extension_tools.rs defines CoreTurnItemEmitter and emits TurnItem::Extension on start/completion.
- extension tool calls receive ConversationHistory, ToolEnvironment values, model/truncation metadata, payload, and turn_item_emitter.
```

Local contract targets to review:

```text
- canonical extension item lifecycle events
- legacy EventMsg compatibility sequencing
- extension tool environment/sandbox-context projection invariants
```

### main: remote plugin bundle install constraints

```text
id: openai-codex-main-a219b6f-remote-plugin-bundle-install-constraints
channel: main
commit: a219b6fdb4e9f9655968adf20984916abc8b2290
impact: high
surface: remote plugin bundle validation, plugin cache/data roots, install metadata, download/extract limits
```

Remote plugin bundles now have explicit validation and install constraints: backend release version and download URL validation, HTTPS-only download admission except debug loopback HTTP, bounded download/error-body/extracted-size limits, redirect final-URL scheme checks, staging install behavior, and remote install metadata. PluginStore also separates cache and data roots and tracks active remote/local versions.

Evidence anchors:

```text
- codex-rs/core-plugins/src/remote_bundle.rs defines bundle download timeout, max download bytes, max extracted bytes, scheme validation, final URL validation, and install/extract paths.
- codex-rs/core-plugins/src/store.rs defines plugin cache/data roots, remote install metadata, plugin version roots, data roots, and active version discovery.
```

Local contract targets to review:

```text
- plugin-bundle source constraints for URL scheme, redirects, size limits, and staging
- remote plugin install metadata schema/version
- plugin cache/data root separation and active-version selection
```

### main: install context package-layout resources

```text
id: openai-codex-main-a219b6f-install-context-package-layout
channel: main
commit: a219b6fdb4e9f9655968adf20984916abc8b2290
impact: high
surface: managed package layout, resource/path resolution, standalone install context
```

Install context now models a package layout with package root, `bin`, optional `codex-resources`, and optional `codex-path` directories. Runtime resolution prefers bundled tools/resources from package-layout paths before legacy standalone resources, affecting managed helper binaries such as `rg` and bundled shell resources.

Evidence anchors:

```text
- codex-rs/install-context/src/lib.rs defines CodexPackageLayout with package_dir, bin_dir, resources_dir, and path_dir.
- InstallContext::rg_command and bundled_resource prefer package-layout paths before legacy standalone resource directories.
```

Local contract targets to review:

```text
- managed package layout schema and resource-directory invariants
- PATH helper resolution order for codex-path versus legacy resources
- standalone/npm/bun/pnpm install-method projections
```

## Alpha channel impact

No new `latest-alpha-cli` impact admitted in this run. Concrete branch-content evidence still reports `workspace.package.version = "0.143.0"`; exact branch head SHA remains unresolved through connector responses and is not inferred.

## No local action

No issue updates were performed because `upstreamCodexPublicationPlan.issueTargets` is currently `{}`.

No contract authority was changed from upstream evidence.

No local contract mutation was performed; only admitted report/evidence projections were written.

## Suggested local targets

```text
- Add extension-owned WebSearchItem and WebSearchAction schema/type fixtures.
- Model extension-tool canonical TurnItem emission plus legacy EventMsg compatibility sequencing.
- Add remote plugin bundle validation constraints for URL scheme, redirects, size limits, extracted-size limits, and staging.
- Add plugin install metadata/version/data-root fixtures.
- Model CodexPackageLayout resource/path resolution before legacy standalone resources.
- Keep latest-alpha-cli version evidence distinct even when only Cargo.toml differs from main.
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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260708T165446Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260708T165446Z.codex-impact.report.json
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
reason: new admitted upstream impact on main; latest-alpha-cli concrete version evidence unchanged
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
