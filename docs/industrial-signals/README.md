# Industrial signals documentation

This documentation TLD is the human-facing project index for Factory's engineering-to-industry intelligence model.

It groups documentation for several independent graph/domain authorities without collapsing them into one semantic graph.

## Topology

```text
engineering-signals
        |
        | explicit translation / adoption evidence
        v
industrial-signals
        |
        | admitted industrial state
        v
industrial-constraints
        |
        +-----------------------------+
                                      |
canada-clean-energy ------------------+
canada-climate-readiness -------------+--> resource-allocation
                                      |
financial-signals --------------------+
```

Graph-specific documentation lives under:

```text
docs/industrial-signals/
  engineering-signals/
  industrial-signals/
  financial-signals/
```

Canadian initiative documentation lives separately under:

```text
docs/industrial-signals/
  canadian-initiatives/
    initiative-routing.md
    canada-clean-energy/
    canada-climate-readiness/
```

The initiative branch is intentionally distinct from graph directories. `canada-clean-energy` and `canada-climate-readiness` are independent policy/project-demand authorities with current event-watch execution and future graph targets; they do not become engineering, industrial, or financial graph semantics by documentation placement.

Downstream qualification domains such as `industrial-constraints`, `resource-allocation`, `financial-opportunities`, and `projects.engineering-pocs` are not graph directories merely because they consume graph/domain snapshots.

## Authority

The documentation tree is descriptive. Semantic authority remains in:

- `contracts/world/engineering-signals/`
- `contracts/world/industrial-signals/`
- `contracts/world/financial-signals/`
- `contracts/world/canada-clean-energy/`
- `contracts/world/canada-climate-readiness/`

Execution procedures remain colocated with the corresponding world domains under `.agents/AGENTS.md`.

## Acquisition model

See [acquisition-model.md](acquisition-model.md) for the shared acquisition vocabulary.

All monitored graph and initiative documentation distinguishes two execution surfaces:

```text
CURRENT
manual / agent-assisted acquisition
        ↓
source-qualified captured occurrence
        ↓
typed observation / explicit coverage gap
        ↓
domain admission

PROJECTED
source registry + schedule
        ↓
replaceable source adapters
        ↓
immutable raw capture
        ↓
canonicalization / normalization
        ↓
typed validation + identity/relationship qualification
        ↓
domain admission
        ↓
immutable domain snapshot
```

The projected pipeline is an architectural target. It must not be treated as implemented merely because it is documented.

## Canadian initiative routing

See [canadian-initiatives/initiative-routing.md](canadian-initiatives/initiative-routing.md) for routing of Major Projects Office/coordinating surfaces, industrial subsidies, workforce programs, critical-mineral finance, sovereign-AI/compute initiatives, and comparable cross-cutting Canadian programs into their actual semantic authorities.

## Project architecture

See [architecture.md](architecture.md) for the project-relative topology and authority boundaries.

The existing implementation/sequencing record remains `docs/architecture/multi-graph-world-refactor.md` during migration.
