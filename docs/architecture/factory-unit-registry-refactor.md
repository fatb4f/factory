# Factory Unit Registry Layout

Status: current

Factory is a small registry of independently owned work units. Shared and profile CUE under `contracts/` define semantic authority. Worker `AGENTS.md` files colocated with a worker contract define shared execution procedure. Unit directories own task-local procedure, templates, adapters, immutable run bundles, and mutable pointers where a selected contract admits them.

## Repository topology

```text
factory/
|-- cue.mod/
|-- registry.cue
|-- contracts/
|   |-- unit.cue
|   |-- state/
|   |   `-- comparison.cue
|   |-- workers/
|   |   `-- upstream-monitor/
|   |       |-- contract.cue
|   |       |-- AGENTS.md
|   |       |-- profiles_ctrl/
|   |       `-- profiles_epistemic_plant_bootstrap/
|   |-- academic/
|   |   `-- uqam/
|   |       |-- events/
|   |       `-- catalog/
|   `-- world/
|       `-- industrial-constraints/
|           |-- contract.cue
|           |-- vocabulary.cue
|           |-- sources.cue
|           |-- documents.cue
|           |-- identity.cue
|           |-- observations.cue
|           |-- relations.cue
|           |-- projections.cue
|           |-- constraints.cue
|           |-- evidence.cue
|           `-- public.cue
|-- .agents/
|   |-- dispatcher/
|   `-- workers/upstream-monitor/AGENTS.md   # compatibility pointer only
|-- projects/
|   |-- ctrl/
|   `-- epistemic-plant-bootstrap/
|-- academic/
|   `-- uqam/
|       |-- .agents/
|       |   |-- events/
|       |   `-- catalog/
|       |-- events/
|       `-- catalog/
`-- world/
    `-- industrial-constraints/
```

The old root `contract.cue` facade is removed: consumers import `contracts:unit` directly. There is no repository-name layer or compatibility/publication namespace inside `contracts/`.

## Boundaries

```text
contracts/state/comparison.cue
    shared comparison-state and CAS vocabulary

contracts/workers/<worker>/contract.cue
    shared worker semantic CUE authority

contracts/workers/<worker>/profiles_<profile>/*.cue
    selected profile semantic CUE authority

contracts/academic/uqam/events/*.cue
    UQAM event-watch semantic authority

contracts/academic/uqam/catalog/*.cue
    UQAM catalog semantic authority

contracts/world/industrial-constraints/*.cue
    domain-owned industrial intelligence semantic authority

contracts/workers/<worker>/AGENTS.md
    canonical shared worker execution procedure

<unit>/.agents/
    unit/task execution procedure and fixed templates

<unit>/<task-state>/
    generated immutable runs and admitted mutable pointers when contracted
```

Colocation does not promote procedural Markdown to semantic authority. For upstream-monitor, shared worker CUE plus exactly one selected profile CUE package define semantics; the contract-colocated worker `AGENTS.md` and unit-local `AGENTS.md` files define procedure. The legacy `.agents/workers/upstream-monitor/AGENTS.md` path is a non-normative compatibility pointer only.

`academic.uqam.*` and `world.industrial-constraints` are independent domain authorities and do not inherit upstream-monitor semantics.

## Registry

`registry.cue` records demonstrated scheduling/discovery invariants:

- unit identity and kind;
- unit `.agents` root;
- task identity;
- optional semantic-authority path;
- task-local agent path;
- enabled state;
- explicit weekly cadence and weekday.

A task does not need a CUE semantic contract merely to be scheduled. `authority` remains optional in the generic task type; where the registry declares one, however, the dispatcher must preserve that authority/entrypoint pair and may not replace it with procedural inference.

Current registrations:

```text
projects.ctrl.upstream-monitor
    authority -> contracts/workers/upstream-monitor/profiles_ctrl/contract.cue
    agent     -> projects/ctrl/.agents/AGENTS.md
    enabled   -> true
    cadence   -> weekly / Monday

projects.epistemic-plant-bootstrap.upstream-monitor
    authority -> contracts/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/contract.cue
    agent     -> projects/epistemic-plant-bootstrap/.agents/AGENTS.md
    enabled   -> true
    cadence   -> weekly / Monday

academic.uqam.events
    authority -> contracts/academic/uqam/events/contract.cue
    agent     -> academic/uqam/.agents/events/AGENTS.md
    enabled   -> true
    cadence   -> weekly / Monday

academic.uqam.catalog
    authority -> contracts/academic/uqam/catalog/contract.cue
    agent     -> academic/uqam/.agents/catalog/AGENTS.md
    enabled   -> true
    cadence   -> weekly / Monday

world.industrial-constraints.monitor
    authority -> contracts/world/industrial-constraints/contract.cue
    agent     -> world/industrial-constraints/.agents/AGENTS.md
    enabled   -> true
    cadence   -> weekly / Monday
```

The shared Monday-morning dispatcher schedules all enabled registered tasks. Scheduler state only deduplicates execution on the same local calendar date; task-local semantic state remains outside the dispatcher ledger.

## Upstream-monitor topology

```text
contracts/workers/upstream-monitor/contract.cue
        + exactly one selected profiles_<profile>/*.cue
                |
                v
contracts/workers/upstream-monitor/AGENTS.md
                |
                v
projects/<unit>/.agents/AGENTS.md
                |
                v
ChatGPT / GitHub actuator
                |
                v
projects/<unit>/upstream-monitor/
```

The CUE layer is semantic authority. The `AGENTS.md` layers are procedure. Project-local run bundles remain generated evidence/publication, not authority.

`profiles_ctrl` and `profiles_epistemic_plant_bootstrap` are independent concrete reference profiles. Neither is the universal shape for future profiles. Shared worker vocabulary should grow only from the demonstrated intersection of independent profiles.

## UQAM event-watch topology

UQAM events is a contracted event-watch domain, but not an upstream-monitor profile:

```text
registry.cue
    |
    v
contracts/academic/uqam/events/*.cue
    |              |
    |              +--> contracts/state/comparison.cue
    |
    v
academic/uqam/.agents/events/AGENTS.md
    |
    v
required-source acquisition
    |
    v
normalized event observations
    |
    v
comparison against admitted baseline
    |
    v
admitted decision
    |
    +--> immutable academic/uqam/events/runs/<run_id>/
    |
    `--> CAS update of academic/uqam/events/state/admitted-baseline.json
```

The UQAM event contract owns exact required-source coverage, normalized event identity, material delta semantics, outcome/baseline-action coupling, and publication admission. The shared state package owns only generic run/baseline references and compare-and-swap vocabulary.

The first complete run is a contracted `bootstrap` state and may establish the baseline. Incomplete required acquisition permits only `source_gap` with pointer hold. Comparable state may advance only through the admitted `no_change` or `new_matches` branches; invalidated comparison and CAS conflict hold the pointer. The run manifest seals both normalized and decision artifacts.

The baseline pointer is task-local persistent comparison state. It is not scheduler authority and it is not a substitute for an immutable run bundle.

## Industrial-constraints topology

Industrial intelligence has an explicit selected execution phase. The current phase tracks public events without claiming that the future data platform already exists.

Current phase:

```text
Factory registry
        |
        v
contracts/world/industrial-constraints/*.cue
        |
        v
world/industrial-constraints/.agents/AGENTS.md
        |
        v
bounded official-source acquisition
        |
        v
source-qualified documents
        |
        v
event-observation records
        |
        v
scope/relevance classification
        |
        v
admitted immutable event-watch bundle
```

An `event-observation` preserves source/channel/publisher/record/revision/surface provenance while its actors and subjects remain observed labels. It does not require canonical identity resolution and cannot establish graph propagation or a constraint claim.

The contract separately preserves the target relational phase:

```text
heterogeneous source adapters
        |
        v
typed relational normalization
        |
        v
canonical identity
        |
        v
Ibis projections
        |
        v
admitted DuckDB/Parquet relational state
        |
        +--> graph projection/correlation
        +--> constraint evidence/assessment
        |
        v
evidence-backed constraint claims
        |
        v
admitted immutable relational run bundle
```

BigQuery, Ibis, DuckDB and Parquet therefore belong to the selected `relational-pipeline` execution phase. Their absence does not invalidate an `event-watch` run. During `event-watch`, publication may contain source-qualified events and coverage gaps, but no canonical graph propagation, assessment or constraint claim.

The synthetic relational qualification fixture, when used, remains outside `runs/` and carries no real-world industrial claim.

## Execution environment

The generic upstream-monitor does not require a tailored container, distributed archive, OCI image, or local executable environment. The current actuator is ChatGPT through the GitHub App; when a selected profile requires executable evidence unavailable through that actuator, the run records a coverage gap rather than asserting validation.

The same phase-sensitive principle applies to UQAM and `world.industrial-constraints`: an adapter is required only when the currently selected task contract requires it. Future relational-pipeline tooling must not be turned into a false prerequisite for the current industrial event watch.

If executable validation later becomes a demonstrated profile requirement, model its execution semantics at the narrowest authority boundary and project them to a runner adapter. A container runtime is an implementation choice unless and until its semantics are proven to be a shared invariant.

## Cross-domain test

The repository demonstrates distinct contract families:

```text
upstream-monitor
    changing software/upstream state -> graph-bound evidence -> impact/qualification

academic.uqam.events
    bounded event acquisition -> normalized comparison state -> admitted delta publication

world.industrial-constraints / event-watch
    bounded official-source acquisition -> source-qualified event observations -> admitted observation bundle

world.industrial-constraints / relational-pipeline target
    heterogeneous records -> relational admission -> graph/correlation -> constraint intelligence
```

Their shared vocabulary should remain limited to semantics that are actually invariant. UQAM comparison-state reuse does not promote event-watch semantics into upstream-monitor. The industrial future relational/correlation machinery does not become generic worker-core machinery and does not constrain the currently selected event-watch phase. Early duplication is preferable to false cross-domain abstraction.
