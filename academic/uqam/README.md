# UQAM academic substrate

`academic.uqam` separates institutional identity, time-sensitive events, and course-local syllabus normalization:

```text
official UQAM / organizer sources
            │
            ├───────────────┬──────────────────┐
            ▼               ▼                  ▼
 academic.uqam.catalog   academic.uqam.events   academic/uqam/syllabus
 stable entities         time-sensitive events  course-local corpus graph
 + explicit relations    + comparison/delta     + concepts/constraints
            │               ▲                  + assessment/material edges
            └── admitted ────┘
                identity context only
```

## Catalog

Semantic authority: `contracts/academic/uqam/catalog/`

The catalog models slower-changing UQAM substrate such as university units, programs, associations, student groups, community resources, services and explicit source-supported relationships.

## Events

Semantic authority: `contracts/academic/uqam/events/`

The event watch owns time-sensitive activity, stable event identity, comparison state and event admission. Catalog state may provide admitted identity context but does not decide event deltas.

## Syllabus

Semantic shape: `contracts/academic/uqam/syllabus/`

`academic/uqam/syllabus/` stores term-qualified course corpora. Current course authority, topic resources, historical assessment evidence, concept dependencies, assessment structure and course-specific correction constraints stay distinct. Relationship edges carry both a derivation basis and evidence source IDs so inferred topology cannot masquerade as an explicit source fact.

The syllabus substrate is not scheduled by `registry.cue`; it changes when course material is acquired or revised.

## Scheduling

`registry.cue` schedules `academic.uqam.events` daily and `academic.uqam.catalog` weekly. Each scheduled task owns its acquisition, comparison and publication state.
