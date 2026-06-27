# Codex contract-surface impact report

```text
apiVersion: factory.upstream-monitor.codex/v0
kind: CodexImpactReport
loop: codex-contract-surface
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
run_result: terminal_deferred
```

## Critical

No upstream critical impacts were admitted in this run.

Reason: the active loop entrypoint still declares the initial gate as pre-acquisition and explicitly forbids upstream `openai/codex` inspection, report creation, issue updates, and ledger writes until signal continuity and next-state closure are proven.

## High

No upstream high impacts were admitted in this run.

## Notes

- `upstreamCodexPublicationPlan` admits a contract-local report artifact at `contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md`.
- `upstreamCodexPublicationPlan.issueTargets` is currently empty, so no issue updates were admitted.
- The scheduled task prompt asks for upstream-monitor execution through the report/publication surface, but the nearest loop `AGENTS.md` still gates the implementation before acquisition.

## No local action

No upstream `openai/codex` evidence was inspected, classified, or reduced in this run.

This is intentional under the active AGENTS gate. Upstream state remains evidence-only and unobserved by this run.

## Suggested local targets

```text
contracts/upstream-monitor/codex/contract-surface/AGENTS.md
contracts/upstream-monitor/codex/contract-surface/public.cue
contracts/upstream-monitor/codex/contract-surface/publication.cue
```

## Issue updates

No issue updates were performed.

Reason: the publication plan contains no concrete issue targets.

## Validation notes

Static contract read performed through the GitHub App:

```text
contracts/upstream-monitor/AGENTS.md
contracts/upstream-monitor/codex/AGENTS.md
contracts/upstream-monitor/codex/contract-surface/AGENTS.md
contracts/upstream-monitor/codex/contract-surface/report.cue
contracts/upstream-monitor/codex/contract-surface/publication.cue
contracts/upstream-monitor/codex/contract-surface/public.cue
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content mutation, not a repo shell.

Expected validation commands remain:

```bash
cue vet ./contracts/upstream-monitor
cue export ./contracts/upstream-monitor/codex/contract-surface -e upstreamCodexImpactReportTemplate
cue export ./contracts/upstream-monitor/codex/contract-surface -e upstreamCodexPublicationPlan
cue export ./contracts/upstream-monitor/codex/contract-surface -e upstreamCodexScheduledTaskPrompt
! rg 'generated/reports|reportAsAuthority|adapterAuthority|operator.*truth|expectedBottom|bottomCheckSurface|expression:' ./contracts/upstream-monitor
```

## Control action

```text
action: defer-upstream-acquisition
reason: active loop AGENTS gate still forbids upstream inspection and report/update behavior before transition closure proof
next_state: align AGENTS gate with admitted publication slice or complete initial next-state closure proof before monitor acquisition
```
