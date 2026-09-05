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

contracts/world/industrial-constraints/
    industrial observations and future industrial relational/graph authority

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

No generic `graph` or `multigraph` contract is introduced. Engineering, industrial, clean-energy, climate-readiness and financial topology remain independently modeled until their actual intersection demonstrates a reusable invariant.

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
world.industrial-constraints.monitor       enabled
world.canada-clean-energy.monitor           enabled
world.canada-climate-readiness.monitor      enabled

world.financial-signals.monitor             disabled
world.resource-allocation.correlate         disabled
world.financial-opportunities.qualify       disabled
projects.engineering-pocs.qualify           disabled
```

All declared cadences are weekly / Monday. The shared dispatcher runs only enabled tasks.

## Why downstream tasks are registered but disabled

The repository now carries semantic authority for the target multi-graph system without asserting execution capability that does not exist.

```text
observation-ready now
    engineering-signals
    industrial-constraints
    canada-clean-energy
    canada-climate-readiness

contracted but not executable yet
    financial-signals broad watch
    resource-allocation correlation
    financial-opportunity qualification
    engineering-POC qualification
```

Financial monitoring remains disabled until an issuer/hypothesis/source universe is explicitly configured. Resource-allocation remains disabled until immutable graph snapshots and qualified bridges exist. Financial opportunities and POC selection remain disabled until their upstream evidence paths are real.

Registration therefore means "Factory knows this task and its authority," not "all prerequisites have been satisfied."

## Multi-graph topology

The architectural target is:

```text
engineering graph
      |
      | qualified engineering-to-industrial translation
      v
industrial graph
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
        snapshot-qualified bridges /
         shared resources / demands /
              conjunctions
                      |
                      v
                financial graph
                      |
                      v
          qualification / decisions
              |               |
              v               v
      engineering POCs   financial opportunities
```

The arrows do not imply that one domain owns another domain's relations. Each cross-domain identity or path must be supported by an explicit qualified bridge or source-domain path.

## Current phase semantics

### Engineering signals

The enabled engineering watch tracks technical mechanisms, tests, prototypes, standards, patents, manufacturing/process developments and failure analysis. A `poc-candidate` disposition is an observation prioritization hint only; it cannot admit a POC.

### Industrial constraints

The industrial contract currently selects `event-watch`. It admits source-qualified documents/events while its Ibis/DuckDB relational graph remains a future target. Current event publication cannot establish canonical graph propagation or constraint claims.

### Clean energy and climate readiness

These watches track initiatives only where they create, redirect, finance or constrain engineering/industrial demand. Their events cannot establish an industrial shortage, cross-domain resource identity, economic capture or investment attractiveness.

### Financial signals

The financial domain owns issuers, reporting segments, instruments, capital structure, financial relations and time-qualified measurements. It must not duplicate engineering/industrial/policy topology.

### Resource allocation

This is a coordination/control authority, not a source graph. It consumes immutable external graph references, separately qualifies bridge hypotheses, represents shared resources and explicit source-domain demand paths, and admits conjunction/intervention/decision state only when prerequisites are satisfied.

### Engineering POCs

World domains observe reality. `projects.engineering-pocs` decides what Factory should build or test. Policy convergence and financial value may raise priority, but an admitted engineering mechanism plus an explicit industrial problem remain mandatory.

## Scheduler evolution

Do not add generic task dependencies yet. The currently enabled observation watches are independent.

When the first real correlation task becomes executable, scheduler ordering must be declared explicitly rather than inferred from names:

```text
acquisition tasks
      ↓ explicit task references
correlation
      ↓
qualification / decision
```

Only then should `contracts/unit.cue` gain dependency semantics.

## UQAM and upstream-monitor preservation

The multi-graph refactor does not alter existing UQAM or software upstream-monitor authority.

UQAM event comparison state remains task-local and contractually separate from dispatcher state. Upstream-monitor still consists of shared worker CUE plus exactly one selected independent profile; `profiles_ctrl` is not a template for the new world domains.

## Reference

The sequencing, gates, initiative routing and implementation state are defined in `docs/architecture/multi-graph-world-refactor.md`.
