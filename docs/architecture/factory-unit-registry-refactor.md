# Factory Unit Registry Layout

Status: current

Factory is a small registry of independently owned work units. `contracts/` contains semantic CUE authority. `.agents/` contains execution procedures. Unit directories own task-local procedure, templates, and generated state where applicable.

## Repository topology

```text
factory/
|-- cue.mod/
|-- registry.cue
|-- contracts/
|   |-- unit.cue
|   `-- workers/
|       `-- upstream-monitor/
|           |-- contract.cue
|           |-- profiles_ctrl/
|           `-- profiles_epistemic_plant_bootstrap/
|-- .agents/
|   |-- dispatcher/
|   `-- workers/
|       `-- upstream-monitor/AGENTS.md
|-- projects/
|   |-- ctrl/
|   `-- epistemic-plant-bootstrap/
|-- academic/
|   `-- uqam/
|       `-- .agents/events/
`-- world/
```

The old root `contract.cue` facade is removed: consumers import `contracts:unit` directly. There is no repository-name layer or compatibility/publication namespace inside `contracts/`.

## Boundaries

```text
contracts/
    semantic CUE authority only

.agents/workers/
    shared worker execution procedures

<unit>/.agents/
    unit/task execution procedure and fixed templates

<unit>/<task-state>/
    generated state/publication only when that task defines one
```

Moving a procedure into `.agents/` does not promote it to semantic authority. For upstream-monitor, shared worker CUE plus the selected profile CUE remain authoritative; the shared and unit-local `AGENTS.md` files are execution surfaces.

## Registry

`registry.cue` records only demonstrated scheduling/discovery invariants:

- unit identity and kind;
- unit `.agents` root;
- task identity;
- optional semantic-authority path;
- task-local agent path;
- enabled state;
- cadence in days.

A task does not need a CUE semantic contract merely to be scheduled. `authority` is optional so simple procedural watches do not inherit an invented qualification model.

Current registrations:

```text
projects.ctrl.upstream-monitor
    authority -> contracts/workers/upstream-monitor/profiles_ctrl/contract.cue
    agent     -> projects/ctrl/.agents/AGENTS.md

projects.epistemic-plant-bootstrap.upstream-monitor
    authority -> contracts/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/contract.cue
    agent     -> projects/epistemic-plant-bootstrap/.agents/AGENTS.md

academic.uqam.events
    authority -> none
    agent     -> academic/uqam/.agents/events/AGENTS.md
```

All three remain disabled in the dispatcher registry while their existing recurring automations remain the running implementations.

## Upstream-monitor topology

```text
contracts/workers/upstream-monitor/contract.cue
        + selected profiles_<profile>/*.cue
                |
                v
.agents/workers/upstream-monitor/AGENTS.md
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

The first line is semantic authority. The remaining `.agents` layers are procedures. Project-local run bundles remain generated evidence/publication, not authority.

## Cross-domain test

`academic.uqam.events` is intentionally smaller than an upstream-monitor profile. Its current requirements are source selection, delta filtering, deduplication, relevance ranking, and concise notification. Those do not justify a new CUE semantic family yet.

`world/industrial-constraints` should be modeled independently when added. Its graph, evidence, constraint, problem-set, and scenario semantics must arise from that domain rather than being copied from `ctrl`.

Shared Factory vocabulary should grow only from the demonstrated intersection of real units.
