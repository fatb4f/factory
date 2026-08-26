# Factory Unit Registry Layout

Status: current

Factory is organized as a small registry of independently owned work units. Contracts define semantic authority; unit directories own execution procedures and generated task state.

## Repository topology

```text
factory/
|-- cue.mod/
|-- contract.cue
|-- registry.cue
|-- contracts/
|   |-- unit.cue
|   `-- workers/
|       `-- upstream-monitor/
|           |-- contract.cue
|           |-- AGENTS.md
|           |-- profiles_ctrl/
|           `-- profiles_epistemic_plant_bootstrap/
|-- projects/
|   |-- ctrl/
|   |   |-- .agents/
|   |   `-- upstream-monitor/
|   `-- epistemic-plant-bootstrap/
|       |-- .agents/
|       `-- upstream-monitor/
|-- academic/
|-- world/
`-- .agents/
    `-- dispatcher/
```

There is no repository-name layer inside `contracts/`: this repository already supplies the Factory namespace. There is also no parallel compatibility/publication tree under `contracts/`.

## Authority boundary

`contracts/` contains semantic contracts only:

- shared unit vocabulary in `unit.cue`;
- shared worker contracts under `workers/`;
- profile-specific CUE authority beneath the selected worker.

Unit-local surfaces have different roles:

```text
projects/<unit>/.agents/
    execution instructions and fixed templates

projects/<unit>/upstream-monitor/
    latest pointer, immutable run bundles, and retained outputs
```

Neither `.agents/` nor generated run state becomes semantic authority.

## Root registry

Root `registry.cue` is the discovery and scheduling index. It records only unit identity, task identity, semantic-authority path, task-local agent path, enabled state, and simple day cadence.

The current tasks are:

```text
projects.ctrl.upstream-monitor
    authority -> contracts/workers/upstream-monitor/profiles_ctrl/contract.cue
    agent     -> projects/ctrl/.agents/AGENTS.md

projects.epistemic-plant-bootstrap.upstream-monitor
    authority -> contracts/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/contract.cue
    agent     -> projects/epistemic-plant-bootstrap/.agents/AGENTS.md
```

The registry does not replace the referenced task authority.

## Monitor topology

```text
contracts/workers/upstream-monitor/
        shared worker authority
                |
                v
profiles_<profile>/
        profile authority
                |
                v
projects/<unit>/.agents/
        invocation/rendering procedure
                |
                v
ChatGPT / GitHub actuator
                |
                v
projects/<unit>/upstream-monitor/
        immutable run publication
```

No compatibility layer sits between the unit procedure and worker/profile authority.

## Semantic families

`projects/` contains software and research-project work.

`academic/` is reserved for institution- and education-specific units such as UQAM events, courses, funding, and services.

`world/` is reserved for external-system intelligence such as industrial constraints.

New units should model their actual sources, evidence, graph, decisions, and publication needs. Shared Factory vocabulary should grow only from demonstrated invariants across multiple units.

## Dispatcher relationship

The dispatcher remains orthogonal to unit semantics:

```text
registry schedule
      |
      v
unit-local task agent
      |
      v
existing task contract
```

Factory does not wrap tasks in another admission or qualification protocol. The dispatcher only determines whether a task is due and records when it ran.

The two dispatcher registry entries remain disabled until operational cutover. The existing combined ctrl and epistemic-plant-bootstrap scheduled workflow remains the running implementation in the meantime.
