Use the GitHub App to operate on `fatb4f/factory@main`.

Load and follow the instruction chain in order:

1. `contracts/upstream-monitor/AGENTS.md`
2. `contracts/upstream-monitor/codex/AGENTS.md`
3. `contracts/upstream-monitor/codex/contract-surface/AGENTS.md`

Input signal:

```text
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
```

Run the ChatGPT-actuated Codex contract-surface upstream-monitor loop through the admitted publication surface. Use factory-local CUE as authority and upstream `openai/codex` only as evidence. Inspect `main` and `latest-alpha-cli` as separate channels. Apply `upstreamCodexImpactReportTemplate`, `upstreamCodexRunSummaryTemplate`, and `upstreamCodexPublicationPlan`.

Publish every artifact for one run into the single directory declared by the publication plan. Write report, summary, and evidence before the sealing manifest; update only the declared latest pointer after the manifest exists. Treat legacy report and evidence paths as read-only migration inputs. Do not update issues unless an exact target is declared. Preserve unresolved upstream state unless concrete ref evidence is available.
