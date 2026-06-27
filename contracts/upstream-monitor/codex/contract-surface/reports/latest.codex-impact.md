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
```

## Critical

### openai/codex#30292-#30296 — MCP lifecycle coordination stack

```text
classes: mcp, security, storage, adapter
impact: blocking-gate
```

Local reason: the upstream stack changes MCP lifecycle coordination and recovery ownership. Local adapter contracts should gate MCP store coordination, recovery, and diagnostic surfaces before treating the new behavior as admitted.

Suggested local targets:

```text
contracts/factory/adapters/mcp/oauth_credentials.cue
contracts/factory/adapters/mcp/config_layers.cue
contracts/factory/adapters/mcp/tool_namespace.cue
```

### openai/codex#30282 / #30283 / #30188 — canonical TurnItem rollout lifecycle stack

```text
classes: protocol, storage, rollout-trace, ui, multi-agent
impact: blocking-gate
```

Local reason: canonical TurnItem lifecycle is now the live projection surface for command execution, dynamic tool calls, collab agent tool calls, and sub-agent activity. Local rollout/thread contracts should treat legacy event fanout as compatibility where canonical items are present.

Suggested local targets:

```text
contracts/factory/rollout/turn_items.cue
contracts/factory/rollout/thread_projection.cue
contracts/factory/rollout/response_item_ids.cue
contracts/agent-context-resolver/projection.cue
```

## High

### openai/codex#30311 — normalized prompt output IDs

```text
classes: protocol, storage, context-window, rollout-trace
impact: contract-update
```

Local reason: local response-item and context-window contracts should require IDs for normalized rendered response items.

### openai/codex#30302 — custom tool-call namespaces

```text
classes: protocol, adapter, mcp, ui
impact: contract-update
```

Local reason: local tool-call contracts should represent namespace as a preserved dispatch identity component.

### openai/codex#30273 — pushed exec-server process events

```text
classes: adapter, security, protocol, ui
impact: contract-update
```

Local reason: local exec-server contracts should model pushed terminal events and compatibility fallback behavior.

### openai/codex#29905 — partial MCP server definitions across config layers

```text
classes: mcp, config, adapter, policy
impact: contract-update
```

Local reason: config-layer validation contracts should distinguish layer-local partial validity from composed effective-config completeness.

## Notes

### openai/codex#30257 — nested MCP startup error classification

```text
classes: mcp, security, ui, adapter
impact: note
```

Useful for notification fixtures, but not a new authority shape.

### openai/codex#30000 / #30148 — Codex Apps and MCP runtime reuse

```text
classes: mcp, adapter, context-window, config
impact: note
```

Relevant architectural evidence, not admitted as a local contract change in this run.

## No local action

### alpha-latest

```text
status: unresolved
impact: no-local-action
```

No visible alpha branch/ref delta was established through GitHub branch search. Treat alpha-latest as unresolved evidence only.

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
contracts/upstream-monitor/codex/contract-surface/report.cue
contracts/upstream-monitor/codex/contract-surface/publication.cue
contracts/upstream-monitor/codex/contract-surface/public.cue
```

Publication admission observed:

```text
report path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
issueTargets: {}
```

Caveat: the loop entrypoint still contains an older initial-gate warning forbidding upstream inspection/report creation before transition closure proof. The scheduled task prompt and publication surface explicitly requested this report run, so this run proceeded under the newer admitted publication control input and records the AGENTS mismatch as a contract-alignment caveat.

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
reason: upstream evidence was reduced through the fixed report template and admitted repo-local publication path
next_state: align contract-surface AGENTS initial-gate text with the admitted Z4 report publication slice
```
