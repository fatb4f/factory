# Codex contract-surface scheduled loop

## Instruction chain

Load in order:

```text
contracts/upstream-monitor/AGENTS.md
contracts/upstream-monitor/codex/AGENTS.md
contracts/upstream-monitor/codex/contract-surface/AGENTS.md
contracts/factory/workers/codex/upstream-monitor/AGENTS.md
contracts/factory/workers/codex/upstream-monitor/contract.cue
contracts/factory/workers/codex/upstream-monitor/surfaces.cue
contracts/factory/workers/codex/upstream-monitor/report.cue
contracts/factory/workers/codex/upstream-monitor/publication.cue
contracts/factory/workers/codex/upstream-monitor/assertions.cue
contracts/factory/workers/codex/upstream-monitor/public.cue
```

The factory-local files are semantic authority. This file is the stable scheduled-task entrypoint and actuator procedure.

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

The ChatGPT scheduled task is the actuator. Keep reasoning in ChatGPT, constrained by the CUE surface catalogue and publication contract. Do not replace it with an acquisition/classification script.

## Run procedure

1. Read all authority files and confirm `operational: true`.
2. Read `upstreamCodexImpactReportTemplate` and `upstreamCodexPublicationPlan`.
3. Resolve the current target-repository revision when available.
4. Acquire concrete evidence for `openai/codex@main`.
5. Separately acquire concrete evidence for `openai/codex@latest-alpha-cli`.
6. Compare each channel with its own prior recorded state. Do not use alpha state as the main baseline or vice versa.
7. Match evidence only against `surfaceCatalogue`.
8. Classify admitted items as `none`, `note`, `contract-update`, or `blocking-gate`.
9. Render the fixed report template, including explicit state sections for both channels.
10. Check all proposed paths and issue targets against the publication plan.
11. Write the run report, run evidence, latest report, and latest evidence in declared order.
12. Update only issues explicitly present in `issueTargets`.
13. Return a concise run summary and validation notes.

## Evidence rules

- Exact commit, branch, tag, release, file, or version evidence is concrete.
- An unresolved exact head SHA remains unresolved.
- Concrete file content may be recorded while its branch head remains unresolved.
- Do not infer an alpha SHA from `main`, a version string, a compare result, or a prior report.
- Keep every report item bound to one or both explicitly named channels.

## Publication boundaries

Allowed report paths are under:

```text
contracts/upstream-monitor/codex/contract-surface/reports/
```

Allowed evidence paths are under:

```text
contracts/upstream-monitor/codex/contract-surface/evidence/
```

No other report or evidence path is admitted. `issueTargets: {}` means no issue update.

## Validation notes

The GitHub App actuator cannot run CUE commands. State that limitation; do not claim `cue vet` or `cue export` ran. Still inspect the CUE exports structurally and check all forbidden attractors listed in `assertions.cue`.

A missing authority file, template, channel, publication path, or required concrete observation terminates as `terminal_deferred`, `coverage_gap`, or `terminal_abort` as appropriate.
