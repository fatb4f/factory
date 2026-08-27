# Generic upstream-monitor worker procedure

This file is execution procedure, not semantic authority. Shared semantic authority is `contracts/workers/upstream-monitor/contract.cue` plus every CUE file in exactly one explicitly selected `profiles_<profile>/` directory.

## Read order

1. repository-root instructions that apply to the run;
2. `contracts/workers/upstream-monitor/contract.cue`;
3. every CUE file in exactly one selected profile directory;
4. subject semantic authority and context declared by that profile;
5. this worker procedure;
6. the selected unit-local task procedure under `projects/<unit>/.agents/`;
7. the fixed report template declared by the selected profile.

Upstream repositories, GitHub adapter responses, ChatGPT conclusions, subject-repository observations, generated run bundles, prior reports, and prior evidence are observations unless the selected CUE contract explicitly admits them.

## Actuator model

ChatGPT using the GitHub App performs bounded acquisition, graph-aware semantic classification, report and summary rendering, bundle sealing, and admitted GitHub writes. Read shared vocabulary, the selected profile, current subject context, source graph, evidence model, publication plan, and unit-local task procedure before acquiring upstream evidence.

The GitHub App cannot execute CUE or local binaries. Preserve that coverage gap rather than replacing executable validation with claimant-supplied booleans.

## Source-qualified evidence

Preserve `source + channel + revision/ref + observed surface` for every material observation. Channel names are source-scoped; never merge observations solely because channel strings match.

A source may declare active-baseline, forecast, release-watch, or pinned-authority channels. Pinned-authority channels identify admitted external semantics only where the selected profile says so; they do not become Factory authority.

## Graph-aware classification

Impact propagation follows declared graph relationships. Do not infer propagation from path, package, component, or concept naming similarity.

Keep implementation/source evidence, upstream behavioral evidence, analyzer evidence, runtime/probe evidence, telemetry, externally acquired observations, normalized/correlated evidence, and qualification decisions distinct. Upstream tests do not directly establish local qualification.

## Publication

Each selected profile owns its project-local publication path. The canonical export unit is one immutable run directory:

```text
runs/<run_id>/
├── report.md
├── summary.md
├── evidence.json
└── manifest.json
```

Write report, summary, and evidence first. Write `manifest.json` after their exact blob identities are known. Update the selected profile's `latest.json` only after the manifest seals the bundle. Corrections require a new run with explicit lineage.
