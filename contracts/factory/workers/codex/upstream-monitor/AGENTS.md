# Codex upstream-monitor worker authority

This directory is the authoritative contract for the ChatGPT-actuated Codex upstream monitor and its admitted impact profiles.

## Authority order

1. repository-root authority and applicable issue requirements;
2. shared CUE vocabulary in `contract.cue`;
3. every CUE file in exactly one selected `profiles_$profile/` directory;
4. this instruction file;
5. the selected compatibility entrypoint under `contracts/upstream-monitor/`;
6. the selected fixed report template.

`openai/codex`, GitHub adapter responses, ChatGPT conclusions, subject-repository observations, run bundles, legacy reports, and legacy evidence are observations only. They never amend this contract.

## Actuator model

The actuator is a scheduled ChatGPT task using the GitHub App. Keep this model. ChatGPT performs bounded acquisition, semantic classification, report and summary rendering, bundle sealing, and admitted GitHub writes. It must read the shared vocabulary, selected profile authority, and selected publication plan before inspecting upstream evidence.

The GitHub App cannot execute CUE. Record this limitation in validation notes. Do not replace CUE validation with claimant-supplied booleans or prior generated evidence.

## Profile containment and dispatch

Every admitted profile is contained in one directory named `profiles_$profile`. Resolve exactly one profile from the accepted input and entrypoint. Load `contract.cue` plus only that profile directory. Never merge profile packages, catalogues, prior evidence, report templates, or publication plans.

### Factory profile

```text
package: contracts/factory/workers/codex/upstream-monitor/profiles_factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
signal: acceptedSignal
surfaces: surfaceCatalogue
classification: classificationPolicy
report: upstreamCodexImpactReportTemplate
summary: upstreamCodexRunSummaryTemplate
publication: upstreamCodexPublicationPlan
assertions: validationAssertions / forbiddenAttractors
public export: publicContract
```

This profile evaluates upstream Codex impact on the factory's own Codex contract surface.

### CUEstrap profile

```text
package: contracts/factory/workers/codex/upstream-monitor/profiles_cuestrap
entrypoint: contracts/upstream-monitor/codex/cuestrap-contract-surface/AGENTS.md
profile_id: cuestrap
signal: cuestrapAcceptedSignal
context: cuestrapContext
surfaces: cuestrapSurfaceCatalogue
classification: cuestrapClassificationPolicy
report: cuestrapCodexImpactReportTemplate
summary: cuestrapRunSummaryTemplate
publication: cuestrapPublicationPlan
assertions: cuestrapValidationAssertions / cuestrapForbiddenAttractors
public export: publicContract
```

This profile evaluates upstream Codex impact against the current `fatb4f/cuestrap@main` context. It keeps every report, summary, evidence artifact, manifest, and latest pointer in factory. Its only admitted mutation in `fatb4f/cuestrap` is one deduplicated append-only comment per run on the declared tracking issue.

An unknown, missing, ambiguous, or cross-profile selection terminates as `terminal_abort` before acquisition or writes.

## Required run sequence

Every profile follows the selected closed workflow. The shared core is:

```text
authority_read
→ input_admission
→ profile-required context acquisition, when declared
→ main_acquisition
→ alpha_acquisition
→ semantic_classification
→ report_render
→ summary_render
→ publication_admission
→ immutable run-bundle artifact writes
→ manifest seal
→ latest-pointer update
→ declared issue steps
→ terminal_success
```

Failure terminates as `terminal_abort`, `terminal_deferred`, or `coverage_gap`.

## Channel isolation

Treat these as separate evidence channels:

```text
openai/codex@main
openai/codex@latest-alpha-cli
```

Never substitute one channel's commit, version, changed paths, prior state, or conclusions for the other. An unresolved head SHA remains unresolved unless concrete branch, ref, tag, or commit evidence is available. Concrete content evidence may be recorded while the exact ref SHA remains unresolved.

## Classification

Classify only against the selected profile's surface catalogue. A reportable item requires:

- a declared surface match;
- concrete upstream evidence;
- an admitted impact decision;
- a stated local contract impact for `note`, `contract-update`, or `blocking-gate`;
- any profile-required context or purpose assignment.

Do not create semantic classification scripts. ChatGPT is the semantic actuator constrained by the selected CUE vocabulary.

## Run bundles and publication

Use only the selected profile's report template, summary contract, and publication plan.

The canonical export unit for one run is exactly one immutable directory:

```text
runs/<run_id>/
├── report.md
├── summary.md
├── evidence.json
└── manifest.json
```

Rules:

- report, summary, and evidence must be written into the same run directory;
- `manifest.json` is written only after every required artifact exists and records their exact Git blob identities;
- the manifest seals the directory as a complete exportable run bundle;
- `latest.json` is a pointer to the sealed run directory and manifest, never a mutable copy of report or evidence content;
- prior state is resolved through `latest.json` and then the referenced bundle manifest and evidence;
- a publication plan may declare exact legacy latest paths as read-only migration inputs when no `latest.json` exists;
- legacy `reports/` and `evidence/` paths must never receive new writes;
- an empty `issueTargets` map means no issue updates;
- cross-repository artifact writes are forbidden unless the selected profile explicitly declares them.

## Validation notes

Every run records:

- shared vocabulary and selected profile files read;
- current factory revision when available;
- profile-required context repository revision and reads;
- separate `main` and `latest-alpha-cli` resolution state;
- whether CUE execution was available;
- selected forbidden-attractor checks;
- the canonical run-bundle path and artifact inventory;
- manifest seal and latest-pointer state;
- cross-repository mutation state;
- issue update targets, or an explicit statement that none were declared.
