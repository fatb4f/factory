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
run_id: 20260709T165422Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: b58952b0fa889f7958af37d057b521f3fdab4d3c
workspace_version: 0.0.0
previous_recorded_head: 3380969a29134630d56feb6218e8e8dcc5e8196d
change_since_previous_evidence: advanced
compare_status: ahead
ahead_by: 17
behind_by: 0
changed_files_count: 86 observed from connector compare file list
```

### latest-alpha-cli

```text
status: resolved-content; exact head sha unresolved through connector response
repo: openai/codex
ref: latest-alpha-cli
head_commit: unresolved
relation_to_main: diverged from current main; ahead_by: 1; behind_by: 17
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.144.0
previous_recorded_workspace_version: 0.144.0-alpha.4
change_since_previous_evidence: advanced by concrete branch-content version evidence; exact ref sha unresolved
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### main: exec-server environment registry + selected capability-root readiness

```text
id: openai-codex-main-b58952b-exec-environment-capability-roots
channel: main
commit: b58952b0fa889f7958af37d057b521f3fdab4d3c
impact: high
```

EnvironmentManager now models default/disabled/local/remote/Noise environments; selected capability roots resolve only against ready stable environment identities.

Local contract targets: schema/type fixtures, generated projections, ordering/admission constraints, and compatibility adapters for this surface.

### main: external-agent config import outcome + pending plugin split

```text
id: openai-codex-main-b58952b-external-agent-config-import-outcome
channel: main
commit: b58952b0fa889f7958af37d057b521f3fdab4d3c
impact: high
```

Import outcome now has typed item results, successes, raw errors, and pending_plugin_imports for remote plugin details.

Local contract targets: schema/type fixtures, generated projections, ordering/admission constraints, and compatibility adapters for this surface.

### main: skill discovery bounded inventory + metadata probe

```text
id: openai-codex-main-b58952b-skill-discovery-inventory-contract
channel: main
commit: b58952b0fa889f7958af37d057b521f3fdab4d3c
impact: high
```

Discovery now has walk limits, symlink/hidden policies, plugin/namespace roots, warnings, and metadata present/absent/probe classification.

Local contract targets: schema/type fixtures, generated projections, ordering/admission constraints, and compatibility adapters for this surface.

### main: code-mode exec pragma + nested-tool description

```text
id: openai-codex-main-b58952b-code-mode-exec-pragma
channel: main
commit: b58952b0fa889f7958af37d057b521f3fdab4d3c
impact: high
```

Code-mode exec accepts first-line // @exec JSON pragma for yield_time_ms and max_output_tokens with parser/admission errors.

Local contract targets: schema/type fixtures, generated projections, ordering/admission constraints, and compatibility adapters for this surface.

### main: network proxy domain/unix-socket permissions

```text
id: openai-codex-main-b58952b-network-proxy-permissions
channel: main
commit: b58952b0fa889f7958af37d057b521f3fdab4d3c
impact: high
```

Network proxy config now has explicit domain permission precedence none<allow<deny, Unix socket permissions, MITM/credential broker knobs.

Local contract targets: schema/type fixtures, generated projections, ordering/admission constraints, and compatibility adapters for this surface.

### latest-alpha-cli: release-channel version evidence

```text
id: openai-codex-alpha-0.144.0-version-advance
channel: latest-alpha-cli
commit: unresolved
impact: high
```

`latest-alpha-cli` advanced by concrete `codex-rs/Cargo.toml` branch-content evidence from `0.144.0-alpha.4` to `0.144.0`. Exact alpha branch head SHA remains unresolved through connector response and is not inferred.

## Evidence anchors

```text
main compare: 3380969a29134630d56feb6218e8e8dcc5e8196d..main => ahead_by=17, behind_by=0, current main head=b58952b0fa889f7958af37d057b521f3fdab4d3c
main changed-file samples: codex-rs/exec-server/src/environment.rs; codex-rs/exec-server/src/resolved_capability.rs; codex-rs/app-server/src/config/external_agent_config.rs; codex-rs/core-skills/src/loader/discovery.rs; codex-rs/code-mode-protocol/src/description.rs; codex-rs/network-proxy/src/config.rs
alpha compare: main..latest-alpha-cli => diverged; ahead_by=1; behind_by=17; changed_files=codex-rs/Cargo.toml
alpha version evidence: workspace.package.version = 0.144.0
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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260709T165422Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260709T165422Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo because the GitHub App adapter exposes repository content read/write operations, not a repo shell. Expected local validation remains: vet/export the upstream-monitor CUE package, `upstreamCodexImpactReportTemplate`, `upstreamCodexPublicationPlan`, and `upstreamCodexScheduledTaskPrompt`.

Forbidden-attractor GitHub code search for configured/known migrated-location terms returned no matches in `fatb4f/factory` during this run.

Caveats: direct GitHub content reads for `publication.cue`, `public.cue`, and `report.cue` were previously recorded as 404 through the GitHub content API; publication admission therefore relies on the prior latest evidence/publication projection. The loop entrypoint still contains older initial-gate text that conflicts with the newer admitted publication task prompt. `latest-alpha-cli` exact branch head SHA remains unresolved and is not inferred.

## Control action

```text
action: publish-contract-local-impact-run-and-latest-report
reason: new admitted upstream impact on main and latest-alpha-cli concrete version evidence advanced
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
