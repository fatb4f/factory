# UQAM academic substrate

`academic.uqam` is split into two independent task contracts with a one-way contextual projection:

```text
official UQAM / organizer sources
            │
            ├───────────────┐
            ▼               ▼
 academic.uqam.catalog   academic.uqam.events
 stable entities         time-sensitive events
 + explicit relations    + comparison/delta state
            │               ▲
            └── admitted ────┘
                identity context only
```

## Catalog

Semantic authority: `contracts/academic/uqam/catalog/`

The catalog models slower-changing UQAM substrate such as:

- university, faculties, departments and administrative/service units;
- faculty/program associations;
- recognized student groups and student media;
- student cafés and common/community resources;
- digital platforms, libraries, sports/recreation, funding and accessibility services;
- explicit source-supported relations such as `part-of`, `operated-by`, `supported-by`, `represents`, `offers` and `located-at`.

A catalog baseline is admitted only after every required discovery source and every declared student-group category has been traversed. Partial discovery remains observation/fixture state.

## Events

Semantic authority: `contracts/academic/uqam/events/`

The daily event watch covers student/community activity in addition to the existing technical/scientific scope. It keeps its own stable event identity and comparison state. When explicit evidence permits, an event may project an organizer or venue to an admitted catalog entity ID.

Catalog state is context for event normalization; it never decides whether an event is added, changed, reportable or admitted.

## Scheduling

`registry.cue` schedules:

- `academic.uqam.events` daily;
- `academic.uqam.catalog` weekly.

The dispatcher only invokes each task and records its task-native outcome. Each task owns its own acquisition, comparison and publication state.
