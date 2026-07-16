# Codex contract-surface scheduled loop

## Instruction chain

Load in order:

```text
contracts/upstream-monitor/AGENTS.md
contracts/upstream-monitor/codex/AGENTS.md
contracts/upstream-monitor/codex/contract-surface/AGENTS.md
contracts/factory/workers/codex/upstream-monitor/AGENTS.md
contracts/factory/workers/codex/upstream-monitor/contract.cue
contracts/factory/workers/codex/upstream-monitor/profiles_factory/contract.cue
contracts/factory/workers/codex/upstream-monitor/profiles_factory/surfaces.cue
contracts/factory/workers/codex/upstream-monitor/profiles_factory/report.cue
contracts/factory/workers/codex/upstream-monitor/profiles_factory/publication.cue
contracts/factory/workers/codex/upstream-monitor/profiles_factory/assertions.cue
contracts/factory/workers/codex/upstream-monitor/profiles_factory/public.cue
```

The shared root contract and `profiles_factory` package are semantic authority. Do not load any other profile package for this run. This file is the stable scheduled-task entrypoint and actuator procedure.

## Accepted input

Accept exactly:

```text
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
```

Any mismatch terminates as `input_invalid` / `terminal_abort` without upstream acquisition or writes.

## Mission

Maintain a versioned local impact view of upstream `openai/codex` changes intersecting the CUE-declared local Codex contract surface.

The ChatGPT scheduled task is the actuator. Keep reasoning in ChatGPT, constrained by the CUE surface catalogue and publication contract. Do not replace it with an acquisition or classification script.

## Run procedure

1. Read the shared root contract and every file in `profiles_factory`; confirm `operational: true`.
2. Read `upstreamCodexImpactReportTemplate`, `upstreamCodexRunSummaryTemplate`, and `upstreamCodexPublicationPlan`.
3. Validate the exact accepted signal.
4. Resolve the current target-repository revision when available.
5. Resolve prior profile state through the declared `latest.json`, its manifest, and bundled `evidence.json`.
6. If `latest.json` is absent, read only the exact legacy evidence path declared by `legacyReadOnly`; never write it.
7. Acquire concrete evidence for `openai/codex@main`.
8. Separately acquire concrete evidence for `openai/codex@latest-alpha-cli`.
9. Compare each channel with its own prior recorded state. Do not use alpha state as the main baseline or vice versa.
10. Match evidence only against `surfaceCatalogue`.
11. Classify admitted items as `none`, `note`, `contract-update`, or `blocking-gate`.
12. Render the fixed report and concise summary.
13. Check the proposed run directory, filenames, latest pointer, and issue targets against the publication plan.
14. Write `report.md`, `summary.md`, and `evidence.json` into the same `runs/<run_id>/` directory.
15. Fetch the exact Git blob identity of each artifact and write `manifest.json` last to seal the bundle.
16. Replace `latest.json` only after the sealed manifest exists.
17. Update only issues explicitly present in `issueTargets`.
18. Return the concise run summary and validation notes.

## Evidence rules

- Exact commit, branch, tag, release, file, or version evidence is concrete.
- An unresolved exact head SHA remains unresolved.
- Concrete file content may be recorded while its branch head remains unresolved.
- Do not infer an alpha SHA from `main`, a version string, a compare result, or a prior report.
- Keep every report item bound to one or both explicitly named channels.

## Publication boundary

The only admitted canonical run path is:

```text
contracts/upstream-monitor/codex/contract-surface/runs/<run_id>/
```

It must contain exactly the publication-plan artifacts for that run. The only mutable discovery artifact is:

```text
contracts/upstream-monitor/codex/contract-surface/latest.json
```

Legacy paths under `reports/` and `evidence/` are read-only migration inputs. No new report, summary, evidence, manifest, or latest content may be written there. `issueTargets: {}` means no issue update.

## Validation notes

The GitHub App actuator cannot run CUE commands. State that limitation; do not claim `cue vet` or `cue export` ran. Still inspect the selected package structurally and check all forbidden attractors listed in `profiles_factory/assertions.cue`.

A missing authority file, template, summary contract, channel, publication path, required artifact, manifest seal, or concrete observation terminates as `terminal_deferred`, `coverage_gap`, or `terminal_abort` as appropriate.
