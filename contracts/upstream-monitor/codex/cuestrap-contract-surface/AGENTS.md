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
3. Read `cuestrapCodexImpactReportTemplate`, `cuestrapRunSummaryTemplate`, and `cuestrapPublicationPlan`.
4. Resolve the current `fatb4f/factory@main` revision.
5. Resolve `fatb4f/cuestrap@main` and read every path in `cuestrapContext.requiredContextReads`.
6. Record the exact cuestrap revision used for classification.
7. Resolve prior profile state through the factory `latest.json`, its manifest, and bundled `evidence.json`.
8. If `latest.json` is absent, read only the exact factory legacy evidence path declared by `legacyReadOnly`; never write it.
9. Acquire concrete evidence for `openai/codex@main`.
10. Separately acquire concrete evidence for `openai/codex@latest-alpha-cli`.
11. Compare each upstream channel only with its own prior cuestrap-profile state.
12. Match evidence only against `cuestrapSurfaceCatalogue`.
13. Assign every reportable item to one or both declared cuestrap purposes.
14. Classify admitted items as `none`, `note`, `contract-update`, or `blocking-gate`.
15. Render the fixed report and concise summary with separate channel and purpose sections.
16. Check the canonical factory bundle, mirror projection bundle, latest pointers, and issue targets against `cuestrapPublicationPlan`.
17. Write factory `report.md`, `summary.md`, and `evidence.json` into one `runs/<run_id>/` directory.
18. Fetch their exact Git blob identities and write the factory `manifest.json` last.
19. Replace the factory `latest.json` only after the factory bundle is sealed.
20. Copy the exact report and summary bytes into one CUEstrap report-projection directory for the same run ID.
21. Write the CUEstrap projection `manifest.json`, binding it to the canonical factory bundle and recording the mirrored blob identities.
22. Replace the CUEstrap `latest.json` only after the projection manifest exists.
23. Verify that the CUEstrap report and summary copies are byte-equivalent to their factory sources.
24. Update only issues explicitly present in `cuestrapPublicationPlan.issueTargets`.
25. Return the concise run summary and validation notes.

## Context rules

- CUEstrap repository state is required subject context, not monitor authority.
- Do not classify against stale cuestrap paths when the current revision is resolvable.
- Do not mutate cuestrap implementation, tests, configuration, CUE contracts, AGENTS files, or actuator plumbing.
- A missing required context path terminates as `coverage_gap` or `terminal_deferred`; do not silently omit it.

## Evidence rules

- Exact commit, branch, tag, release, file, or version evidence is concrete.
- Keep `main` and `latest-alpha-cli` independent through acquisition, classification, report, summary, and evidence.
- An unresolved exact head remains unresolved.
- Do not infer alpha state from main, main state from alpha, or either from a version string.
- Bind every report item to concrete upstream evidence, declared cuestrap surfaces, and one or both cuestrap purposes.

## Publication boundaries

The canonical factory run bundle is limited to:

```text
contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/<run_id>/
```

It contains `report.md`, `summary.md`, `evidence.json`, and the sealing `manifest.json`. Its only mutable discovery artifact is:

```text
contracts/upstream-monitor/codex/cuestrap-contract-surface/latest.json
```

The CUEstrap report projection is limited to:

```text
reports/upstream-monitor/codex/runs/<run_id>/
```

It contains byte-equivalent `report.md` and `summary.md` copies plus a projection `manifest.json` that references the canonical factory bundle. Its only mutable discovery artifact is:

```text
reports/upstream-monitor/codex/latest.json
```

Legacy report and evidence paths are read-only migration inputs. No new run artifact may be written there. No evidence artifact, CUE authority, AGENTS file, prompt, actuator configuration, or other plumbing may be written to `fatb4f/cuestrap`. `issueTargets: {}` means no issue update.

## Validation notes

The GitHub App actuator cannot run CUE commands. State that limitation and do not claim `cue vet` or `cue export` ran. Inspect the selected package structurally and check every forbidden attractor in `profiles_cuestrap/assertions.cue`.

A missing authority file, context read, report template, summary contract, channel, bundle artifact, manifest seal, mirror permission, source binding, or content-equivalence check terminates fail-closed.
