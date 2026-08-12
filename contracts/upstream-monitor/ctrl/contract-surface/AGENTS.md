# ctrl multi-source upstream monitor

This is the compatibility entrypoint for the `ctrl` profile. It is not independent semantic authority.

## Instruction chain

Read, in order:

```text
contracts/upstream-monitor/AGENTS.md
contracts/factory/workers/upstream-monitor/AGENTS.md
contracts/upstream-monitor/ctrl/contract-surface/AGENTS.md
contracts/factory/workers/upstream-monitor/contract.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/contract.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/sources.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/surfaces.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/graph.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/evidence.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/report.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/publication.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/assertions.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/public.cue
contracts/upstream-monitor/ctrl/contract-surface/output/report-template.md
```

Accepted input is exactly:

```text
signal_id: loop_bootstrap_request
profile_id: ctrl
target_repo: fatb4f/factory
context_repo: fatb4f/ctrl
entrypoint: contracts/upstream-monitor/ctrl/contract-surface/AGENTS.md
adapter: github_app
```

## Mission

Maintain a versioned, graph-aware impact and operationalization view of upstream changes that intersect `fatb4f/ctrl@main`.

Required evidence families:

1. Codex: Rust protocol, exported schemas, Python `openai_codex` SDK, live app-server/tool/config semantics, rollout persistence/lineage/reconstruction.
2. CPython: Python 3.14 active branch plus main forecast, subsystem dependency DAG, CPython regrtest as upstream behavioral evidence, and ctrl-local executable probes.
3. CUE: ctrl's pinned evaluator revision kept distinct from upstream master forecast.
4. uv and Jujutsu: release-watch satellites limited to declared local consumers.

## CPython operationalization

Treat operational CPython as a qualification target. The durable operation graph is declared in CUE and may project to Pydantic transports. `pydantic-graph` is an initial executor candidate, not authority. Marimo is an interactive projection/diagnosis surface, not workflow, evidence, or qualification authority.

The CPython process adapter must invoke the checked-out interpreter through `./python -m test` for regrtest slices. Do not import `test.libregrtest` as a stable dependency. Local probes emit normalized observations; they do not emit claimant-authored qualification verdicts.

## Bootstrap run

If `latest.json` does not exist, establish a bootstrap baseline rather than inventing a historical delta. Resolve exact current source/channel revisions, verify required upstream surfaces exist, bind observations to declared graph nodes/edges, disclose that executable CUE/regrtest/local probes were not run when the GitHub App cannot execute them, and publish a normal sealed bundle.

## Publication

Write only:

```text
contracts/upstream-monitor/ctrl/contract-surface/runs/<run_id>/report.md
contracts/upstream-monitor/ctrl/contract-surface/runs/<run_id>/summary.md
contracts/upstream-monitor/ctrl/contract-surface/runs/<run_id>/evidence.json
contracts/upstream-monitor/ctrl/contract-surface/runs/<run_id>/manifest.json
contracts/upstream-monitor/ctrl/contract-surface/latest.json
```

Write the manifest after report, summary, and evidence; update `latest.json` after the manifest. No issue updates or cross-repository writes are admitted.
