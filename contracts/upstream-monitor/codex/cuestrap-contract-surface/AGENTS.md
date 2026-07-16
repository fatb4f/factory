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
4. Allocate one `run_id` and derive tracking identity `cuestrap-codex-contract-surface/<run_id>`.
5. Resolve the declared tracking target `fatb4f/cuestrap#9`; read its comments and determine whether the tracking identity already exists.
6. Resolve the current `fatb4f/factory@main` revision.
7. Resolve `fatb4f/cuestrap@main` and read every path in `cuestrapContext.requiredContextReads`.
8. Record the exact cuestrap revision used for classification.
9. Resolve prior profile state only through the factory `latest.json`, its manifest, and bundled `evidence.json`.
10. Acquire concrete evidence for `openai/codex@main`.
11. Separately acquire concrete evidence for `openai/codex@latest-alpha-cli`.
12. Compare each upstream channel only with its own prior cuestrap-profile state.
13. Match evidence only against `cuestrapSurfaceCatalogue`.
14. Assign every reportable item to one or both declared cuestrap purposes.
15. Classify admitted items as `none`, `note`, `contract-update`, or `blocking-gate`.
16. Render the fixed report and concise summary with separate channel and purpose sections.
17. Check the canonical factory bundle, latest pointer, and issue target against `cuestrapPublicationPlan`.
18. Write factory `report.md`, `summary.md`, and `evidence.json` into one `runs/<run_id>/` directory.
19. Fetch their exact Git blob identities and write the factory `manifest.json` last.
20. Replace the factory `latest.json` only after the factory bundle is sealed.
21. Append exactly one run comment to `fatb4f/cuestrap#9` after the terminal state is known. Include the run ID, terminal state, channel heads, purpose decisions, canonical factory bundle link, validation failures, and tracking identity.
22. Return the concise run summary and validation notes.

## Tracking issue rules

- The only admitted tracking target is `fatb4f/cuestrap#9`.
- The issue body is stable. Mutate it only through append-only comments; never edit the title or body during a run.
- Every run that reaches `terminal_success`, `terminal_abort`, `terminal_deferred`, or `coverage_gap` requires one comment.
- Before posting, search existing comments for the exact tracking identity `cuestrap-codex-contract-surface/<run_id>`.
- If that identity already exists, do not post again. Record the existing comment URL as the satisfied issue update.
- A successful run comment is posted after factory bundle and pointer publication.
- A failed, deferred, or coverage-gap run comment is posted immediately after the terminal state is determined and includes whatever factory artifact links are available plus the failure reason.
- Do not use impact severity as an issue-update gate. The declared policy is `every_run`.

## Context rules

- CUEstrap repository state is required subject context, not monitor authority.
- Do not classify against stale cuestrap paths when the current revision is resolvable.
- Do not mutate cuestrap implementation, tests, configuration, CUE contracts, AGENTS files, actuator plumbing, or monitor artifact paths.
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

The former `reports/` and `evidence/` ledgers are forbidden. They must not exist and may not be used as fallback state.

No monitor artifact file may be written to `fatb4f/cuestrap`. This includes reports, summaries, evidence, manifests, and latest pointers. The only admitted mutation in CUEstrap is one deduplicated append-only comment per run on issue `#9`.

## Validation notes

The GitHub App actuator cannot run CUE commands. State that limitation and do not claim `cue vet` or `cue export` ran. Inspect the selected package structurally and check every forbidden attractor in `profiles_cuestrap/assertions.cue`.

A missing authority file, context read, report template, summary contract, channel, factory bundle artifact, manifest seal, latest pointer, or tracking issue target terminates fail-closed.
