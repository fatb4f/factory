# Factory Unit Registry Refactor

Status: active migration design

Factory is organized as a small registry of independently owned work units rather than as one universal workflow schema.

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
|-- projects/
|   |-- ctrl/
|   |   `-- .agents/
|   `-- epistemic-plant-bootstrap/
|       `-- .agents/
|-- academic/
|   `-- <future units>/
|-- world/
|   `-- <future units>/
`-- .agents/
    `-- dispatcher/
```

Directory taxonomy classifies scope. It does not define semantic authority.

## Shared vocabulary

`contracts/factory/unit.cue` defines only the shared repository concepts currently demonstrated across units:

- unit identity and kind;
- repository-relative paths;
- task identity;
- task semantic-authority path;
- task-local agent path;
- enabled state; and
- simple day cadence for recurring tasks.

Do not promote domain schemas, evidence models, graph semantics, publication rules, or task-result semantics into this shared vocabulary merely because current units happen to resemble each other.

## Root registry

Root `registry.cue` is the discovery and scheduling index.

```text
unit
  -> id
  -> kind
  -> .agents root

task
  -> id
  -> owning unit
  -> semantic authority
  -> agent procedure
  -> enabled
  -> cadence
```

The registry does not replace the referenced task authority.

For the two current project monitors:

```text
projects.ctrl.upstream-monitor
    authority -> profiles_ctrl/contract.cue
    agent     -> projects/ctrl/.agents/AGENTS.md

projects.epistemic-plant-bootstrap.upstream-monitor
    authority -> profiles_epistemic_plant_bootstrap/contract.cue
    agent     -> projects/epistemic-plant-bootstrap/.agents/AGENTS.md
```

Their established upstream-monitor contracts remain unchanged.

## Unit-local `.agents`

`.agents/` contains execution instructions and task parameters only.

```text
semantic authority
        |
        v
unit-local AGENTS.md
        |
        v
agent / automation
        |
        v
existing task evidence and publication
```

Agent instructions may point to compatibility entrypoints and subject context, but they do not become semantic authority.

## Semantic families

`projects/` contains software and research-project work.

`academic/` will contain institution- and education-specific state such as UQAM events, courses, funding, and services.

`world/` will contain external-system intelligence such as industrial constraints.

Each new unit should model its own sources, evidence, graph, decisions, and publication needs. Shared Factory vocabulary should grow only from demonstrated invariants across multiple units.

## Dispatcher relationship

The dispatcher is orthogonal to unit semantics:

```text
registry schedule
      |
      v
unit task agent
      |
      v
existing task contract
```

Factory does not wrap tasks in another admission or qualification protocol. The dispatcher only determines whether a task is due and records when it ran.

See `factory-daily-dispatcher.md` for the scheduling procedure.

## Migration sequence

```text
1. keep existing semantic authorities in place
2. expose project/academic/world unit roots as needed
3. colocate execution instructions under each unit's .agents/
4. register only concrete tasks that already have a usable workflow
5. migrate recurring clocks to the shared dispatcher when useful
6. add UQAM and world units independently when their own contracts are ready
```

Compatibility surfaces remain until a concrete migration demonstrates that they can be removed safely.

## Current stage

The current repository stage establishes the root unit/task registry and the two existing project task instruction surfaces. It intentionally removes the experimental dispatcher workflow engine, dispatcher-specific CUE admission package, and GitHub Actions qualification job.

The two dispatcher task entries remain disabled until operational cutover. Existing `ctrl` and `epistemic-plant-bootstrap` scheduled workflows remain the running reference implementation in the meantime.
