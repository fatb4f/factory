# ctrl upstream monitor summary

## Run identity

- Run: `20260812T140347Z`
- Profile: `ctrl`
- Terminal state: `terminal_success`
- Factory authority acquisition: `cbb224d491e0a792b96bffb10ba70e3173fe6106`
- ctrl context: `fatb4f/ctrl@b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`

## Baseline

This first run established exact baselines for Codex main/alpha, CPython 3.14/main, ctrl's pinned CUE revision plus CUE master forecast, and optional uv/Jujutsu release-watch channels.

Key active heads:

- Codex main: `eb752e43d9b7bd7dc5965ea20642bcf7f1a492d8`
- Codex latest-alpha-cli: `9392c3fa5bcda342b5b96a1a04d67b2f781617c2`
- CPython 3.14: `b842ab829fa265df7c00a9034d007f4bbfd95577`
- CPython main: `b11e749f7590e9a0907db908fa3e7e76c772c28f`
- CUE pinned: `806821e40fae070318600a264d311517e596353b`
- CUE master: `f356f8f46cedb8e853ed200fb46ab49a68bfe357`

## Decisions

- Critical / blocking-gate: **0**
- High / contract-update: **5**
- Notes: **2**

High-priority work:

1. qualify Codex Rust protocol -> exported schemas -> generated Python SDK;
2. correlate live Codex runtime with rollout raw evidence and deterministic reduced graphs;
3. operationalize the CPython subsystem DAG for impact propagation;
4. invoke selected CPython regrtests through a typed process adapter;
5. implement normalized CPython monitoring/frame/code/instruction probes.

## Operationalization gap

The contract now defines CPython as an operational plant with a CUE-owned operation graph, Pydantic transport projection, replaceable graph executor candidate, and Marimo projection/diagnosis surface. The GitHub App could not execute CUE, build CPython, run regrtest, or run local probes during this bootstrap, so those are explicitly unexecuted rather than inferred.

## Bundle

`contracts/upstream-monitor/ctrl/contract-surface/runs/20260812T140347Z/`

Artifacts:

- `report.md`
- `summary.md`
- `evidence.json`
- `manifest.json` (seal written after artifact blob identities are resolved)

## Validation

Authority/context/source/graph/publication reads completed. No cross-repository writes or issue mutations were admitted. Markdown is a projection of `evidence.json`.
