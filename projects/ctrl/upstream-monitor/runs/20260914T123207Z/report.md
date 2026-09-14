# ctrl upstream impact report

## Run identity

- Run ID: `20260914T123207Z`
- Monitor state: `terminal_success`
- Qualification state: `observation_only`
- Authority revision: `7580eb3a8a7302d9e1b63e217742fcc0bace3892`
- Publication revision: `not-yet-sealed`
- ctrl context revision: `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`
- Bootstrap baseline: `false`

## Subject context

The ctrl subject revision is unchanged. Factory-local profile CUE remains monitor authority; `ctrl/spec` remains subject qualification authority.

## Critical

- Codex main advanced to `99cda7a9a5997c36aff413d42a222bdb5f95c434`. Guardian review-session reuse now incorporates destructive parent-history reset state. This widens the already-open Codex runtime/policy compatibility gate; no profile-declared executable compatibility witness ran in this actuator.

## High

- CPython 3.14 advanced to `38b79e8bbd1456351ffeacf48b51cba69063bdca`; active-runtime compiler/monitoring/C-API movement remains locally unqualified without regrtest and differential probes.
- Astral ty advanced to `a65f3d6a54dbe2abb575680cc1241ef5d18c4494`; file-selection/path semantics changed and remain analyzer/correlation evidence only.
- Weaver advanced to `7b9ac7fb79d0f59e1df969737ae718432338f144`; its live-check v2 matcher and OTLP interface surface expanded substantially. Weaver remains projection/interface realization, never CUE qualification authority.

## Notes

- OpenTelemetry Python core changed cumulative synchronous-gauge retention. Metrics remain outside the current trace-only P0 comparator.
- OTel Arrow renamed filter-processor telemetry and aligned it to universal node metrics; this is a forecast migration surface, not a semantic authority change.
- SCIP's newest delta is dependency maintenance; no new semantic identity contract is inferred.
- CUE pinned authority is unchanged; CUE master remains forecast only.

## Validation notes

Required source channels were resolved separately. CUE execution, CPython regrtest/local probes, Astral/SCIP correlation, OTel pipeline, OTLP/OTAP round-trip, semantic-kernel execution and Weaver projection were not executable through the current GitHub actuator. Monitor completion therefore does not imply executable qualification.
