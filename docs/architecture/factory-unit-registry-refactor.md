# Factory Unit Registry Refactor

Status: active migration design

Factory is organized as a small registry of independently owned work units. Contracts define semantic authority; project directories own execution procedures and generated task state.

## Repository topology

```text
factory/
|-- cue.mod/
|-- contract.cue
|-- registry.cue
|-- contracts/
|   `-- factory/
|       |-- unit.cue
|       `-- workers/
|           |-- upstream-monitor/
|           `-- codex/upstream-monitor/
|-- projects/
|   |-- ctrl/
|   |   |-- .agents/
|   |   `-- upstream-monitor/
|   |-- epistemic-plant-bootstrap/
|   |   |-- .agents/
|   |   `-- upstream-monitor/
|   |-- factory/
|   |   |-- .agents/
|   |   `-- upstream-monitor/
|   `-- cuestrap/
|       |-- .agents/
|       `-- upstream-monitor/
|-- academic/
|-- world/
`-- .agents/
    `-- dispatcher/
```

There is no parallel `contracts/upstream-monitor/` compatibility/publication tree.

## Authority boundary

`contracts/factory/` contains semantic contracts only:

- shared unit vocabulary in `unit.cue`;
- shared worker contracts;
- profile-specific CUE authority.

Project-local surfaces have different roles:

```text
projects/<unit>/.agents/
    execution instructions and fixed templates

projects/<unit>/upstream-monitor/
    latest pointer, immutable run bundles, and retained historical outputs
```

Neither `.agents/` nor generated run state becomes semantic authority.

## Root registry

Root `registry.cue` is the discovery and scheduling index. It records only unit identity, task identity, semantic-authority path, task-local agent path, enabled state, and simple day cadence.

For the two current project monitors:

```text
projects.ctrl.upstream-monitor
    authority -> contracts/factory/workers/upstream-monitor/profiles_ctrl/contract.cue
    agent     -> projects/ctrl/.agents/AGENTS.md

projects.epistemic-plant-bootstrap.upstream-monitor
    authority -> contracts/factory/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/contract.cue
    agent     -> projects/epistemic-plant-bootstrap/.agents/AGENTS.md
```

The registry does not replace the referenced task authority.

## Monitor topology

The active monitor path is now direct:

```text
profile CUE authority
        |
        v
project-local .agents procedure
        |
        v
ChatGPT / GitHub actuator
        |
        v
project-local upstream-monitor runs + latest pointer
```

The prior `contracts/upstream-monitor/` layer was compatibility ingress plus templates and generated state. Those responsibilities now live with their owning projects.

Historical Factory Codex and CUEstrap run state is retained under `projects/factory/upstream-monitor/` and `projects/cuestrap/upstream-monitor/`; their semantic profiles remain under `contracts/factory/workers/codex/upstream-monitor/`.

## Semantic families

`projects/` contains software and research-project work.

`academic/` will contain institution- and education-specific state such as UQAM events, courses, funding, and services.

`world/` will contain external-system intelligence such as industrial constraints.

Each new unit should model its own sources, evidence, graph, decisions, and publication needs. Shared Factory vocabulary should grow only from demonstrated invariants across multiple units.

## Dispatcher relationship

The dispatcher remains orthogonal to unit semantics:

```text
registry schedule
      |
      v
project-local task agent
      |
      v
existing task contract
```

Factory does not wrap tasks in another admission or qualification protocol. The dispatcher only determines whether a task is due and records when it ran.

## Current stage

The repository now separates three planes cleanly:

```text
contracts/factory/       semantic authority
projects/*/.agents/      execution procedure and templates
projects/*/upstream-monitor/ generated run state
```

The two dispatcher task entries remain disabled until operational cutover. Existing ctrl and epistemic-plant-bootstrap scheduled workflows remain the running reference implementation in the meantime.
