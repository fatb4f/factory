# Factory Unit Registry Layout

Status: current

Factory is a small registry of independently owned work units. Shared and profile CUE under `contracts/` define semantic authority. Worker `AGENTS.md` files colocated with a worker contract define shared execution procedure. Unit directories own task-local procedure, templates, adapters, and generated state where applicable.

## Repository topology

```text
factory/
|-- cue.mod/
|-- registry.cue
|-- contracts/
|   |-- unit.cue
|   |-- workers/
|   |   `-- upstream-monitor/
|   |       |-- contract.cue
|   |       |-- AGENTS.md
|   |       |-- profiles_ctrl/
|   |       `-- profiles_epistemic_plant_bootstrap/
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
|   `-- dispatcher/
|-- projects/
|   |-- ctrl/
|   `-- epistemic-plant-bootstrap/
|-- academic/
|   `-- uqam/
|       `-- .agents/events/
`-- world/
    `-- industrial-constraints/
```

The old root `contract.cue` facade is removed: consumers import `contracts:unit` directly. There is no repository-name layer or compatibility/publication namespace inside `contracts/`.

## Boundaries

```text
contracts/workers/<worker>/contract.cue
    shared worker semantic CUE authority

contracts/workers/<worker>/profiles_<profile>/*.cue
    selected profile semantic CUE authority

contracts/world/industrial-constraints/*.cue
    domain-owned industrial intelligence semantic authority

contracts/workers/<worker>/AGENTS.md
    shared worker execution procedure

<unit>/.agents/
    unit/task execution procedure and fixed templates

<unit>/<task-state>/
    generated state/publication only when that task defines one
```

Colocation does not promote procedural Markdown to semantic authority. For upstream-monitor, shared worker CUE plus exactly one selected profile CUE package define semantics; worker and unit-local `AGENTS.md` files define execution procedure. `world.industrial-constraints` is independent domain authority and does not inherit upstream-monitor semantics.

## Registry

`registry.cue` records only demonstrated scheduling/discovery invariants:

- unit identity and kind;
- unit `.agents` root;
- task identity;
- optional semantic-authority path;
- task-local agent path;
- enabled state;
- cadence in days.

A task does not need a CUE semantic contract merely to be scheduled. `authority` is optional so simple procedural watches do not inherit an invented qualification model. The registry selects an authority/entrypoint pair; it does not redefine domain or profile semantics.

Current registrations:

```text
projects.ctrl.upstream-monitor
    authority -> contracts/workers/upstream-monitor/profiles_ctrl/contract.cue
    agent     -> projects/ctrl/.agents/AGENTS.md
    enabled   -> true

projects.epistemic-plant-bootstrap.upstream-monitor
    authority -> contracts/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/contract.cue
    agent     -> projects/epistemic-plant-bootstrap/.agents/AGENTS.md
    enabled   -> true

academic.uqam.events
    authority -> none
    agent     -> academic/uqam/.agents/events/AGENTS.md
    enabled   -> true

world.industrial-constraints.monitor
    authority -> contracts/world/industrial-constraints/contract.cue
    agent     -> world/industrial-constraints/.agents/AGENTS.md
    enabled   -> false
```

The daily dispatcher is the scheduler for the first three tasks. `world.industrial-constraints.monitor` remains registered but disabled while its domain contract is unqualified; its standalone weekly automation remains the temporary execution surface until explicit qualification and dispatcher admission.

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

The CUE layer is semantic authority. The `AGENTS.md` layers are procedures. Project-local run bundles remain generated evidence/publication, not authority.

`profiles_ctrl` and `profiles_epistemic_plant_bootstrap` are independent concrete reference profiles. Neither is the universal shape for future profiles. Shared worker vocabulary should grow only from the demonstrated intersection of independent profiles.

## Industrial-constraints topology

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
bounded source acquisition + Ibis projections
        |
        v
admitted DuckDB/Parquet relational state
        |
        +--> graph projection
        +--> constraint evidence / assessment
        |
        v
admitted immutable run bundle
```

BigQuery and source APIs are observational spaces. The relational CUE model constrains meaning; Ibis expresses deterministic transformations; DuckDB/Parquet hold bounded admitted analytical state; graphs are projections; constraints are evidence-backed claims. The synthetic qualification fixture lives outside `runs/` and carries no real-world industrial claim.

## Execution environment

The generic upstream-monitor does not require a tailored container, distributed archive, OCI image, or local executable environment. The current actuator is ChatGPT through the GitHub App; when a selected profile requires executable evidence unavailable through that actuator, the run records a coverage gap rather than asserting validation.

The same principle applies to `world.industrial-constraints`: a BigQuery, Ibis, DuckDB, or other runtime becomes an execution adapter only when available. Missing executable coverage is represented as a gap rather than replaced by asserted success.

If executable validation later becomes a demonstrated profile requirement, model its execution semantics at the narrowest authority boundary and project them to a runner adapter. A container runtime is an implementation choice unless and until its semantics are proven to be a shared invariant.

## Cross-domain test

`academic.uqam.events` is intentionally smaller than a contracted intelligence profile. Its current requirements are source selection, delta filtering, deduplication, relevance ranking, and concise notification. Those do not justify a new CUE semantic family yet.

`world.industrial-constraints` demonstrates a distinct domain-owned relational/constraint model rather than a third upstream-monitor profile. Shared Factory vocabulary should grow only from the demonstrated intersection of real units.
