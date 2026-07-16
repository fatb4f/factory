Use the GitHub App to operate from `fatb4f/factory@main`.

Load and follow:

1. `contracts/upstream-monitor/AGENTS.md`
2. `contracts/upstream-monitor/codex/AGENTS.md`
3. `contracts/upstream-monitor/codex/cuestrap-contract-surface/AGENTS.md`

Input signal:

```text
signal_id: loop_bootstrap_request
profile_id: cuestrap
target_repo: fatb4f/factory
context_repo: fatb4f/cuestrap
entrypoint: contracts/upstream-monitor/codex/cuestrap-contract-surface/AGENTS.md
adapter: github_app
```

Run the CUEstrap-adapted Codex contract-surface monitor. Keep all authority, actuator instructions, evidence, and primary publication plumbing in `fatb4f/factory`. Read the current `fatb4f/cuestrap@main` context before classifying upstream evidence. Treat `openai/codex@main` and `openai/codex@latest-alpha-cli` as separate evidence channels.

Assess impact independently for:

- the gopy/CUE/Pydantic/Hypothesis supervisory session controller;
- the gopy-backed Marimo workbook harness for idiomatic CUE.

Publish primary report and evidence artifacts only through `cuestrapPublicationPlan`. Publish byte-equivalent run and latest report copies to the admitted `fatb4f/cuestrap` report paths. Do not publish evidence or plumbing to cuestrap. Do not update issues unless explicitly declared.
