# CUEstrap Codex contract-surface scheduled loop

## Instruction chain

Load in order:

```text
contracts/upstream-monitor/AGENTS.md
contracts/upstream-monitor/codex/AGENTS.md
contracts/factory/workers/codex/upstream-monitor/AGENTS.md
contracts/factory/workers/codex/upstream-monitor/contract.cue
contracts/factory/workers/codex/upstream-monitor/profiles_cuestrap/contract.cue
contracts/factory/workers/codex/upstream-monitor/profiles_cuestrap/surfaces.cue
contracts/factory/workers/codex/upstream-monitor/profiles_cuestrap/report.cue
contracts/factory/workers/codex/upstream-monitor/profiles_cuestrap/publication.cue
contracts/factory/workers/codex/upstream-monitor/profiles_cuestrap/assertions.cue
contracts/factory/workers/codex/upstream-monitor/profiles_cuestrap/public.cue
```

The shared root contract and `profiles_cuestrap` package are semantic authority. Do not load any other profile package for this run. This file is the stable scheduled-task entrypoint and actuator procedure for profile `cuestrap`.

## Accepted input

Accept exactly:

```text
signal_id: loop_bootstrap_request
profile_id: cuestrap
target_repo: fatb4f/factory
context_repo: fatb4f/cuestrap
entrypoint: contracts/upstream-monitor/codex/cuestrap-contract-surface/AGENTS.md
adapter: github_app
```

Any mismatch terminates as `terminal_abort` before context acquisition, upstream acquisition, or writes.

## Mission

Maintain a versioned impact view of upstream `openai/codex` changes against the current `fatb4f/cuestrap@main` context.

CUEstrap has two independently assessed purposes:

1. a gopy, CUE, Pydantic, and Hypothesis supervisory session-controller implementation;
2. a gopy-backed Marimo workbook harness for idiomatic CUE exploration and qualification.

The ChatGPT scheduled task remains the semantic actuator. Do not replace it with a classification script.

## Run procedure

1. Read the shared root contract and every file in `profiles_cuestrap`; confirm `cuestrapOperational: true`.
2. Validate the exact signal and profile ID.
3. Resolve the current `fatb4f/factory@main` revision.
4. Resolve `fatb4f/cuestrap@main` and read every path in `cuestrapContext.requiredContextReads`.
5. Record the exact cuestrap revision used for classification.
6. Acquire concrete evidence for `openai/codex@main`.
7. Separately acquire concrete evidence for `openai/codex@latest-alpha-cli`.
8. Compare each upstream channel only with its own prior cuestrap-profile state.
9. Match evidence only against `cuestrapSurfaceCatalogue`.
10. Assign every reportable item to one or both declared cuestrap purposes.
11. Classify admitted items as `none`, `note`, `contract-update`, or `blocking-gate`.
12. Render `cuestrapCodexImpactReportTemplate` with separate channel and purpose sections.
13. Check all proposed paths against `cuestrapPublicationPlan`.
14. Publish the factory run report, factory run evidence, factory latest report, and factory latest evidence in declared order.
15. Copy the exact run and latest report contents to the declared paths in `fatb4f/cuestrap@main`.
16. Verify that each cuestrap report copy is byte-equivalent to its factory source report.
17. Update only issues explicitly present in `cuestrapPublicationPlan.issueTargets`.
18. Return a concise run summary and validation notes.

## Context rules

- CUEstrap repository state is required subject context, not monitor authority.
- Do not classify against stale cuestrap paths when the current revision is resolvable.
- Do not mutate cuestrap implementation, tests, configuration, CUE contracts, AGENTS files, or actuator plumbing.
- A missing required context path terminates as `coverage_gap` or `terminal_deferred`; do not silently omit it.

## Evidence rules

- Exact commit, branch, tag, release, file, or version evidence is concrete.
- Keep `main` and `latest-alpha-cli` independent through acquisition, classification, report, and evidence.
- An unresolved exact head remains unresolved.
- Do not infer alpha state from main, main state from alpha, or either from a version string.
- Bind every report item to concrete upstream evidence, declared cuestrap surfaces, and one or both cuestrap purposes.

## Publication boundaries

Factory reports are limited to:

```text
contracts/upstream-monitor/codex/cuestrap-contract-surface/reports/
```

Factory evidence is limited to:

```text
contracts/upstream-monitor/codex/cuestrap-contract-surface/evidence/
```

CUEstrap report copies are limited to:

```text
reports/upstream-monitor/codex/
```

No evidence artifact, CUE authority, AGENTS file, prompt, actuator configuration, or other plumbing may be written to `fatb4f/cuestrap`. `issueTargets: {}` means no issue update.

## Validation notes

The GitHub App actuator cannot run CUE commands. State that limitation and do not claim `cue vet` or `cue export` ran. Inspect the selected package structurally and check every forbidden attractor in `profiles_cuestrap/assertions.cue`.

A missing authority file, context read, template, channel, publication path, mirror permission, or content-equivalence check terminates fail-closed.
