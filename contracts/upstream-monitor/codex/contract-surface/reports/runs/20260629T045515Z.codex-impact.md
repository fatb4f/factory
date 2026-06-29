# Codex contract-surface impact report

```text
apiVersion: factory.upstream-monitor.codex/v0
kind: CodexImpactReport
loop: codex-contract-surface
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
run_result: terminal_success_new_main_upstream_impact_with_validation_caveats
channels: main, latest-alpha-cli
run_id: 20260629T045515Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: ccdfb4f342a2e659be7ab878309cc5d81683d737
workspace_version: 0.0.0
previous_recorded_head: bdd282f3bbd55df3a869a5438519cd948c134d4d
change_since_previous_evidence: ahead-by-5
changed_files_since_previous_evidence: 48
```

### latest-alpha-cli

```text
status: resolved
repo: openai/codex
ref: latest-alpha-cli
head_commit: e4198a095c36a9f8f703b61be900f66df85e0984
relation_to_main: diverged-from-current-main; ahead-by-1; behind-by-5
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.29
channel_relation: distinct-from-main
change_since_previous_evidence: none
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

### main: auto-review on-request escalation prompt rollback

```text
id: openai/codex#30508
upstream_repo: openai/codex
kind: commit/merged-pr-evidence
status: admitted
severity: critical
classes: policy, protocol
evidence_channel: main
refs:
- ccdfb4f342a2e659be7ab878309cc5d81683d737
- openai/codex#30508
```

Impact: upstream reverted the dedicated `on_request_auto_review.md` prompt path and now routes `ApprovalsReviewer::AutoReview` through the generic `on_request.md` instruction body plus the auto-review suffix. This intersects local contract-surface policy because it changes the effective permissions/escalation instruction fragment emitted to the model for `on-request` approval mode.

Local reason: this is a prompt/policy contract surface, not just implementation detail. Any local assumptions that auto-review has a distinct on-request guidance body should be treated as stale until the local contract surface explicitly models generic-body-plus-suffix behavior.

Suggested local targets:

```text
contracts/upstream-monitor/codex/contract-surface/report.cue
contracts/upstream-monitor/codex/contract-surface/publication.cue
contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
```

## High

### main: skills instructions fragment rendering changes

```text
id: main-skills-instructions-fragment-rendering
upstream_repo: openai/codex
kind: commit-range-evidence
status: admitted
severity: high
classes: adapter, protocol
evidence_channel: main
refs:
- bdd282f3bbd55df3a869a5438519cd948c134d4d..ccdfb4f342a2e659be7ab878309cc5d81683d737
```

Impact: upstream changed available-skills context fragment construction and rendering paths across core and skills extension code. The current core path preserves skill-root lines and chooses alias-aware vs absolute-path usage instructions; the extension path continues rendering skill instructions as developer/user contextual fragments.

Local reason: this intersects the contract-surface monitor because skills are model-context fragments with explicit role/marker/body projection. Local report consumers should keep skills-context evidence separate from plugin marketplace and MCP evidence.

## Notes

### main: plugin/skills test surface churn

```text
id: main-plugin-skills-test-surface-churn
upstream_repo: openai/codex
kind: commit-range-evidence
status: admitted
severity: note
classes: adapter
evidence_channel: main
refs:
- bdd282f3bbd55df3a869a5438519cd948c134d4d..ccdfb4f342a2e659be7ab878309cc5d81683d737
```

Impact: upstream changed multiple app-server plugin and skills tests. The changes were not admitted as direct local contract changes in this run because the observed files are primarily test fixtures/smoke coverage, but they remain supporting evidence for plugin and skills behavior drift.

## No local action

No issue updates were performed because `upstreamCodexPublicationPlan.issueTargets` is currently `{}`.

No contract authority was changed from upstream evidence.

No local contract mutation was performed; only admitted report/evidence projections were written.

## Suggested local targets

```text
contracts/upstream-monitor/codex/contract-surface/report.cue
contracts/upstream-monitor/codex/contract-surface/publication.cue
contracts/upstream-monitor/codex/contract-surface/public.cue
contracts/upstream-monitor/codex/contract-surface/AGENTS.md
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
contracts/upstream-monitor/codex/contract-surface/publication.cue
contracts/upstream-monitor/codex/contract-surface/public.cue
contracts/upstream-monitor/codex/contract-surface/report.cue
```

Publication admission observed:

```text
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260629T045515Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260629T045515Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for the configured terms returned no matches in `fatb4f/factory` during this run.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface that explicitly admit report/evidence publication.

## Control action

```text
action: publish-contract-local-new-main-impact-run-and-latest-report
reason: upstream main advanced by 5 commits and changed policy/prompt plus skills context-fragment surfaces; latest-alpha-cli did not move
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
