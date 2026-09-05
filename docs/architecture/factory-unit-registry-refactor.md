# Factory Unit Registry Layout

Status: current

Factory is a registry of independently owned work units. CUE under `contracts/` defines semantic authority; unit-local `.agents/` files define procedure; immutable runs and mutable task-local state remain below their owning unit. Registration does not promote a unit into shared semantic authority.

## Authority families

```text
contracts/workers/upstream-monitor/
    shared software upstream-monitor vocabulary/invariants

contracts/workers/upstream-monitor/profiles_<profile>/
    concrete upstream-monitor profile authority

contracts/academic/uqam/
    independent academic event/catalog authorities

contracts/world/engineering-signals/
    engineering frontier and future engineering-graph authority

contracts/world/industrial-signals/
    industrial actors, roles, signals, actions, innovation adoption, subsidy/public-support
    flows, project milestones, outcomes and future industrial graph authority

contracts/world/industrial-constraints/
    downstream industrial bottleneck/choke-point qualification authority

contracts/world/canada-clean-energy/
    Canadian/Quebec clean-energy policy/project authority

contracts/world/canada-climate-readiness/
    Canadian/Quebec adaptation/resilience authority

contracts/world/financial-signals/
    financial topology and time-qualified financial observations

contracts/world/resource-allocation/
    qualified cross-domain snapshot/bridge/resource/conjunction authority

contracts/world/financial-opportunities/
    downstream investment qualification authority

contracts/projects/engineering-pocs/
    Factory-owned POC selection authority
```

`contracts/workers/upstream-monitor/AGENTS.md` remains the canonical shared procedure for that worker family. None of the world domains inherit upstream-monitor semantics merely because they reuse epistemic patterns such as source-qualified observations, claims or fail-closed publication.

No generic `graph` or `multigraph` contract is introduced. Engineering, industrial-signal, industrial-constraint, clean-energy, climate-readiness and financial semantics remain independently modeled until their actual intersection demonstrates reusable invariants.

## Registry contract

`registry.cue` records only scheduling/discovery information:

- unit identity and kind;
- unit `.agents` root;
- task identity;
- optional semantic-authority path;
- task-local agent path;
- enabled state;
- weekly weekday cadence.

It does not define graph semantics, task dependencies, correlation, publication or qualification.

Current upstream/academic registrations include:

```text
projects.ctrl.upstream-monitor
    authority -> contracts/workers/upstream-monitor/profiles_ctrl/contract.cue
    enabled   -> true

projects.epistemic-plant-bootstrap.upstream-monitor
    authority -> contracts/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/contract.cue
    enabled   -> true

academic.uqam.events
    authority -> contracts/academic/uqam/events/contract.cue
    enabled   -> true

academic.uqam.catalog
    authority -> contracts/academic/uqam/catalog/contract.cue
    enabled   -> true
```

World intelligence and project-decision registrations are:

```text
world.engineering-signals.monitor          enabled
world.industrial-signals.monitor           enabled
world.industrial-constraints.monitor       enabled
world.canada-clean-energy.monitor           enabled
world.canada-climate-readiness.monitor      enabled

world.financial-signals.monitor             disabled
world.resource-allocation.correlate         disabled
world.financial-opportunities.qualify       disabled
projects.engineering-pocs.qualify           disabled
```

All declared cadences are weekly / Monday. The shared dispatcher runs only enabled tasks.

## Why industrial signals is a separate unit

`industrial-signals` answers what industrial actors are doing and what happens afterward. `industrial-constraints` answers what is actually constrained and why.

```text
engineering signal
      |
      v
industrial actor signal / action / adoption / funding / milestone / outcome
      |
      v
snapshot-qualified industrial state
      |
      v
industrial constraint qualification
```

The split prevents announcements, subsidies or actor actions from being promoted directly into shortage/choke-point claims.

Public-support follow-through is explicitly longitudinal:

```text
award != disbursement != expenditure != milestone != outcome
```

The industrial-signals watch therefore seeks evidence about how subsidized actors use funds and how projects progress, while preserving source-specific evidence and coverage gaps.

## Why downstream tasks are registered but disabled

The repository carries semantic authority for the target multi-graph system without asserting execution capability that does not exist.

```text
observation-ready now
    engineering-signals
    industrial-signals
    industrial-constraints event-watch
    canada-clean-energy
    canada-climate-readiness

contracted but not executable yet
    industrial-signals canonical graph/snapshot
    industrial-constraints relational qualification from snapshot
    financial-signals broad watch
    resource-allocation correlation
    financial-opportunity qualification
    engineering-POC qualification
```

The industrial-constraints monitor remains enabled only because its current selected phase is still an independent event watch. Its relational target now requires a snapshot-qualified `world.industrial-signals` input.

Financial monitoring remains disabled until an issuer/hypothesis/source universe is explicitly configured. Resource-allocation remains disabled until immutable graph snapshots and qualified bridges exist. Financial opportunities and POC selection remain disabled until their upstream evidence paths are real.

Registration therefore means "Factory knows this task and its authority," not "all prerequisites have been satisfied."

## Multi-graph topology

```text
engineering graph
      |
      v
industrial-signal graph
      |
      v
industrial-constraint qualification
      |
      +-------------------------------+
      |                               |
      v                               v
clean-energy graph             climate-readiness graph
      |                               |
      +---------------+---------------+
                      |
                      v
              resource-allocation
                      |
                      v
                financial graph
                      |
              +-------+-------+
              |               |
              v               v
      engineering POCs   financial opportunities
```

The arrows do not transfer semantic authority. Cross-domain identity and propagation require explicit admitted references/bridges.

## Scheduler evolution

Do not add generic task dependencies yet. The enabled watches are still independent observation tasks.

When the first real correlation or downstream qualification task becomes executable, scheduler ordering must be declared explicitly rather than inferred from names:

```text
acquisition tasks
      ↓ explicit task references
correlation / qualification
      ↓
decision
```

Only then should `contracts/unit.cue` gain dependency semantics.

## UQAM and upstream-monitor preservation

The world refactor does not alter existing UQAM or software upstream-monitor authority.

UQAM event comparison state remains task-local and contractually separate from dispatcher state. Upstream-monitor still consists of shared worker CUE plus exactly one selected independent profile; `profiles_ctrl` is not a template for the world domains.

## Reference

The sequencing, gates, industrial actor/subsidy model and implementation state are defined in `docs/architecture/multi-graph-world-refactor.md`.
