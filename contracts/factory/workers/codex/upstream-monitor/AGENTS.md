# Codex upstream-monitor worker authority

This directory is the authoritative contract for the ChatGPT-actuated Codex upstream monitor and its admitted impact profiles.

## Authority order

1. repository-root authority and applicable issue requirements;
2. shared CUE vocabulary in `contract.cue`;
3. every CUE file in exactly one selected `profiles_$profile/` directory;
4. this instruction file;
5. the selected project-local task procedure under `projects/<unit>/.agents/`;
6. the selected fixed report template declared by the profile.

`openai/codex`, GitHub adapter responses, ChatGPT conclusions, subject-repository observations, run bundles, legacy reports, and legacy evidence are observations only. They never amend this contract.

## Profile containment

Resolve exactly one profile from the accepted input and entrypoint. Never merge profile packages, catalogues, prior evidence, report templates, or publication plans.

### Factory profile

```text
package: contracts/factory/workers/codex/upstream-monitor/profiles_factory
entrypoint: projects/factory/.agents/AGENTS.md
publication: projects/factory/upstream-monitor/
```

### CUEstrap profile

```text
package: contracts/factory/workers/codex/upstream-monitor/profiles_cuestrap
entrypoint: projects/cuestrap/.agents/AGENTS.md
publication: projects/cuestrap/upstream-monitor/
```

An unknown, missing, ambiguous, or cross-profile selection terminates as `terminal_abort` before acquisition or writes.

## Required behavior

Preserve separate `openai/codex@main` and `openai/codex@latest-alpha-cli` evidence channels. Classify only against the selected profile's declared surfaces and evidence model. Report and summary rendering must follow the selected profile contracts and fixed template. Generated evidence cannot self-authorize semantic claims.

The canonical export unit for one run is one immutable directory containing `report.md`, `summary.md`, `evidence.json`, and `manifest.json`. Write the manifest last and update the profile's `latest.json` only after the bundle is sealed. Corrections create a new run; sealed runs are never mutated.

CUEstrap may append only the exact tracking-issue comment admitted by its profile. Cross-repository artifact writes remain forbidden unless explicitly declared by the selected profile.
