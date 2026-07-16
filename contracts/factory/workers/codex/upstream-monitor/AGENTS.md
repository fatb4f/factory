# Codex upstream-monitor worker authority

This directory is the authoritative contract for the ChatGPT-actuated Codex upstream monitor and its admitted impact profiles.

## Authority order

1. repository-root authority and applicable issue requirements;
2. shared CUE vocabulary in `contract.cue`;
3. every CUE file in exactly one selected `profiles_$profile/` directory;
4. this instruction file;
5. the selected compatibility entrypoint under `contracts/upstream-monitor/`;
6. the selected fixed report template.

`openai/codex`, GitHub adapter responses, ChatGPT conclusions, subject-repository observations, reports, and evidence are observations only. They never amend this contract.

## Actuator model

The actuator is a scheduled ChatGPT task using the GitHub App. Keep this model. ChatGPT performs bounded acquisition, semantic classification, report rendering, and admitted GitHub writes. It must read the shared vocabulary, selected profile authority, and selected publication plan before inspecting upstream evidence.

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
publication: cuestrapPublicationPlan
assertions: cuestrapValidationAssertions / cuestrapForbiddenAttractors
public export: publicContract
```

This profile evaluates upstream Codex impact against the current `fatb4f/cuestrap@main` context. It keeps authority, evidence, and primary reports in factory and admits only byte-equivalent report copies into cuestrap.

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
→ publication_admission
→ selected publication steps
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

## Publication

Use only the selected profile's report template and publication plan.

Allowed writes are limited to the exact declared report, evidence, mirror, and issue targets. An empty `issueTargets` map means no issue updates. Write run-specific artifacts before replacing `latest` artifacts. Preserve the signal, profile, and run IDs across report and evidence artifacts.

For cross-repository report mirrors:

- the destination repository and branch must be explicit in the selected plan;
- source and mirror report contents must be byte-equivalent;
- evidence and actuator plumbing remain forbidden unless separately and explicitly admitted;
- a partial mirror terminates fail-closed and must be reported.

## Validation notes

Every run records:

- shared vocabulary and selected profile files read;
- current factory revision when available;
- profile-required context repository revision and reads;
- separate `main` and `latest-alpha-cli` resolution state;
- whether CUE execution was available;
- selected forbidden-attractor checks;
- publication and mirror paths used;
- mirror equivalence when required;
- issue update targets, or an explicit statement that none were declared.
