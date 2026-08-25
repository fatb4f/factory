# Factory Typed Unit Registry Refactor

Status: proposed, non-authoritative design plan

This document defines the intended repository refactor and its implementation
ordering. It does not itself create semantic authority, admit a unit, move an
existing authority, or replace a vetted CUE contract.

## Summary

Refactor Factory from a mixture of worker contracts, task ingress, prompts,
generated evidence, and recurring-monitor parameters into a typed registry and
ledger of independently contracted work units.

The repository root is the discovery surface. CUE contracts define authority;
directory names classify scope; `.agents/` contains execution procedures; and
generated observations and publications remain evidence.

```text
directory taxonomy != semantic authority
```

The control order is:

```text
CUE authority
    |
    v
root registry reference
    |
    v
task or procedure
    |
    v
agent / automation
    |
    v
observation and task-local admission
```

There is no root `.kb` or parallel knowledge-index layer. Tooling consumes the
root CUE registry directly.

## Target topology

```text
factory/
|-- cue.mod/
|   `-- module.cue
|-- contract.cue
|-- registry.cue
|-- contracts/
|   |-- factory/
|   |   |-- unit.cue
|   |   `-- dispatcher/
|   `-- compatibility/
|-- projects/
|   |-- ctrl/
|   |   |-- contract.cue
|   |   `-- .agents/
|   `-- epistemic-plant-bootstrap/
|       |-- contract.cue
|       `-- .agents/
|-- academic/
|   `-- uqam/
|       |-- contract.cue
|       |-- .agents/
|       |-- identity/
|       |-- courses/
|       |-- calendar/
|       |-- events/
|       |-- funding/
|       |-- services/
|       `-- monitoring/
|-- world/
|   `-- industrial-constraints/
|       |-- contract.cue
|       |-- .agents/
|       |-- ontology/
|       |-- sources/
|       |-- projections/
|       |-- claims/
|       `-- reports/
`-- .agents/
    `-- dispatcher/
```

Empty target directories are not created merely to imply authority. A unit is
present only when its canonical contract is implemented and admitted into the
root registry.

## Root unit contract

The first implementation unit establishes the repository-root CUE module, the
shared unit vocabulary, and an empty admitted registry. It does not relocate or
register existing monitors.

The root module is `github.com/fatb4f/factory` with CUE language version
`v0.16.0`, matching the compatibility floor of the existing nested monitor
module. The nested module remains independent.

### Stable identities

V1 uses fixed-depth, lowercase kebab-case identities:

```text
unit:   <projects|academic|world>.<unit-name>
task:   <unit-id>.<task-name>
output: <unit-id>.<output-name>
```

Examples:

```text
projects.ctrl
projects.ctrl.upstream-monitor
academic.uqam.events-monitor
world.industrial-constraints.monitor
```

The unit namespace determines its kind:

```text
projects -> project
academic -> academic
world    -> world
```

Task and output IDs must be owned by the containing unit. Registry map keys
supply the stable ID and must unify with the referenced value.

### Shared vocabulary

`contracts/factory/unit.cue` defines closed types for:

- unit, task, and output IDs;
- normalized repository-relative paths with no absolute, empty, `.` or `..`
  segments;
- authority references ending in `contract.cue`;
- optional agent roots ending in `.agents`;
- minimal task and output references containing identity and domain-local
  authority; and
- units containing identity, kind, authority, optional agents, tasks, and
  outputs.

Root `contract.cue` re-exports the registry-facing vocabulary and defines a
closed registry map. Root `registry.cue` initially exports:

```cue
units: #Registry & {}
```

The production registry remains empty until canonical unit-local contracts
exist. Positive fixtures demonstrate all three unit kinds and optional
references without admitting those examples.

Relationships, inputs, schedules, invocation adapters, and domain-specific
schemas are intentionally absent from V1. They are added only when a concrete
contracted use case establishes a shared invariant.

Authority paths are explicit rather than derived from an ID. This preserves
the distinction between directory classification and semantic authority.
CUE validates reference shape; a future non-empty registration must also prove
that every referenced repository path exists.

## Unit-local agent surface

Each substantial unit may expose:

```text
<unit>/.agents/
|-- AGENTS.md
|-- tasks/
|-- prompts/
|-- templates/
|-- adapters/
`-- procedures/
```

This surface is execution material, not semantic authority:

```text
CUE contract
    |
    v
task / procedure
    |
    v
agent / automation
```

Generated observations, reports, manifests, attempts, and execution ledgers
remain outside authority unless a unit-local CUE contract explicitly admits a
projection from them.

## Semantic families

### Projects

`projects/` contains units whose primary identity is a software or research
project. Initial candidates are `ctrl` and `epistemic-plant-bootstrap`.
Project contracts may reference external repositories, monitors,
qualification contracts, experiments, and publications without promoting
those observations to Factory authority.

### Academic

`academic/` contains institutional and educational state. The initial UQAM
unit separates identity, courses, calendar, events, funding, services, and
monitoring. Its recurring task moves only after the unit contracts the full
path from source evidence through typed observation, projection, claim, and
admitted publication.

### World

`world/` contains contracted models of external system state. The initial
industrial-constraints unit represents an evidence-backed constraint graph,
not a news collection:

```text
materials
  -> components
  -> fabs
  -> HBM / packaging
  -> compute
  -> electrical equipment
  -> generation / transmission
  -> data centres
```

Its ontology, sources, projections, claims, and reports remain domain-local.

## Dispatcher boundary

The dispatcher is orthogonal to the directory hierarchy and domain semantics.
It consumes admitted task references projected from the root registry:

```text
root registry
    |
    v
admitted task reference
    |-- projects.ctrl.upstream-monitor
    |-- projects.epistemic-plant-bootstrap.upstream-monitor
    |-- academic.uqam.events-monitor
    `-- world.industrial-constraints.monitor
```

The dispatcher owns task ID, schedule, occurrence, attempt, invocation, and
common result state. It does not own UQAM event semantics, the industrial
constraint graph, project qualification, or upstream-monitor classification.

No UQAM or industrial placeholder is registered. Each task becomes
dispatcher-ready only after its unit-local authority, evidence flow,
publication contract, adapter, and scenarios are independently admitted.

The detailed scheduling design remains in
[`factory-daily-dispatcher.md`](factory-daily-dispatcher.md).

## Migration sequence

```text
0. inventory existing authorities
            |
1. root unit schema
            |
2. root registry
            |
3. establish projects/academic/world topology
            |
4. project existing authorities into canonical units
            |
5. introduce unit-local .agents surfaces
            |
6. contract and migrate recurring tasks independently
            |
7. integrate admitted task references with the dispatcher
            |
8. retain compatibility invocation and publication surfaces
            |
9. remove legacy layout after equivalence proof
```

### Phase 0: inventory

Classify every existing surface as semantic authority, task configuration,
execution procedure, generated observation/evidence, publication,
compatibility adapter, or historical state. Do not move files during the
inventory.

### Phases 1-2: root contract and registry

Implement the minimal shared vocabulary and empty registry described above.
Use closed-schema positive and negative fixtures to prove identity, ownership,
path, and unknown-field behavior.

### Phases 3-5: topology and unit projection

Create topology only as canonical unit contracts are introduced. Migrate one
unit at a time. Keep legacy ingress and publication surfaces as thin adapters
to the new authority, and colocate non-authoritative procedures under the
unit's `.agents/` directory.

### Phase 6: independent task contracts

Contract UQAM, industrial monitoring, and each project task independently. A
recurring task must establish:

```text
signal
  -> acquisition
  -> typed observation
  -> projection / correlation
  -> claim
  -> decision / report
  -> admitted publication
```

### Phases 7-9: dispatcher, compatibility, and removal

Register only admitted task references with the dispatcher. Preserve legacy
callers during cutover. Remove a legacy authority, ingress, or publication path
only after equivalence, retry safety, and rollback have been demonstrated.

## First implementation unit

The next change is limited to:

- `cue.mod/module.cue` for the root module;
- `contracts/factory/unit.cue` for shared types;
- root `contract.cue` and `registry.cue`;
- positive and build-tagged negative CUE fixtures; and
- the dispatcher documentation correction.

It does not create `projects/`, `academic/`, `world/`, `.agents/`, dispatcher
contracts, compatibility adapters, or non-empty registry entries.

Acceptance requires:

- scoped CUE formatting for added or edited files;
- root package and existing worker-package vetting;
- an exported empty root `units` object;
- successful positive fixtures for all three kinds;
- expected rejection of malformed IDs, kind mismatches, foreign task/output
  ownership, escaping or incorrectly suffixed paths, mismatched IDs, unknown
  fields, and relationships; and
- unchanged evaluation of the existing ctrl, epistemic-plant-bootstrap, and
  nested Codex monitor contracts.
