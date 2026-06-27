# Codex contract-surface impact report

```text
apiVersion: factory.upstream-monitor.codex/v0
kind: CodexImpactReport
loop: codex-contract-surface
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
run_result: terminal_success_with_validation_caveats
channels: main, latest-alpha-cli
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
workspace_version: 0.0.0
```

### latest-alpha-cli

```text
status: resolved
repo: openai/codex
ref: latest-alpha-cli
workspace_version: 0.143.0-alpha.26
channel_relation: distinct-from-main
```

`latest-alpha-cli` is resolved evidence for this run and must remain separate from `main` in report and evidence artifacts.

## Critical

### openai/codex#30292-#30296 — MCP lifecycle coordination stack

```text
channel: main
classes: mcp, storage, adapter
impact: blocking-gate
```

Suggested local targets:

```text
contracts/factory/adapters/mcp/oauth_credentials.cue
contracts/factory/adapters/mcp/config_layers.cue
contracts/factory/adapters/mcp/tool_namespace.cue
```

### openai/codex#30282 / #30283 / #30188 — canonical TurnItem rollout lifecycle stack

```text
channel: main
classes: protocol, storage, rollout-trace, ui, multi-agent
impact: blocking-gate
```

Suggested local targets:

```text
contracts/factory/rollout/turn_items.cue
contracts/factory/rollout/thread_projection.cue
contracts/factory/rollout/response_item_ids.cue
contracts/agent-context-resolver/projection.cue
```

## High

### openai/codex#30223 — plugin guidance reacts to environment readiness

```text
channel: main
classes: mcp, adapter, context-window, policy
impact: contract-update
```

### openai/codex#30369 — durable external Matrix thread goals

```text
channel: main
classes: protocol, storage, multi-agent, rollout-trace
impact: contract-update
```

### openai/codex#30341 — preserve late steer after turn finalization

```text
channel: main
classes: protocol, rollout-trace, ui
impact: contract-update
```

### openai/codex#30302 — custom tool-call namespaces

```text
channel: main
classes: protocol, adapter, mcp, ui
impact: contract-update
```

### openai/codex#30311 — normalized prompt output IDs

```text
channel: main
classes: protocol, storage, context-window, rollout-trace
impact: contract-update
```

### latest-alpha-cli — CLI alpha version channel

```text
channel: latest-alpha-cli
classes: release-channel, config
impact: note
```

## Notes

### openai/codex#27999 — image generation error history

```text
channel: main
classes: protocol, storage, ui
impact: note
```

### openai/codex#27249 / #27968 — session segmentation and rollout reference histories

```text
channel: main
classes: storage, rollout-trace, protocol
impact: note
```

### openai/codex#27815 / #27824 / #27836 — pending environment lifecycle

```text
channel: main
classes: adapter, context-window, protocol
impact: note
```

## No local action

No local action for `latest-alpha-cli` beyond channel/version evidence.

No issue updates were performed because `upstreamCodexPublicationPlan.issueTargets` is currently `{}`.

## Suggested local targets

```text
contracts/factory/adapters/mcp/oauth_credentials.cue
contracts/factory/adapters/mcp/config_layers.cue
contracts/factory/adapters/mcp/tool_namespace.cue
contracts/factory/rollout/turn_items.cue
contracts/factory/rollout/thread_projection.cue
contracts/factory/rollout/response_item_ids.cue
contracts/factory/security/exec_server_process_events.cue
contracts/agent-context-resolver/projection.cue
contracts/upstream-monitor/codex/contract-surface/report.cue
contracts/upstream-monitor/codex/contract-surface/publication.cue
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
```

Publication admission observed:

```text
report path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
issueTargets: {}
```

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the newer scheduled task prompt and publication surface that explicitly requested this admitted report execution.

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

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
action: publish-contract-local-report
reason: upstream evidence from main and latest-alpha-cli was reduced through the fixed report template and admitted repo-local publication path
next_state: align contract-surface AGENTS initial-gate text with the admitted Z4 report publication slice
```
