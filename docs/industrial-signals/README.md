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

financial-signals remains an independent time-qualified graph
and may connect only through explicit admitted bridges.
```

Graph-specific documentation lives under:

```text
docs/industrial-signals/
  engineering-signals/
  industrial-signals/
  financial-signals/
```

Downstream qualification domains such as `industrial-constraints`, `resource-allocation`, `financial-opportunities`, and `projects.engineering-pocs` are not graph directories merely because they consume graph snapshots.

## Authority

The documentation tree is descriptive. Semantic authority remains in:

- `contracts/world/engineering-signals/`
- `contracts/world/industrial-signals/`
- `contracts/world/financial-signals/`

Execution procedures remain colocated with the corresponding world domains under `.agents/AGENTS.md`.

## Acquisition model

All monitored graph documentation distinguishes two execution surfaces:

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
immutable graph snapshot
```

The projected pipeline is an architectural target. It must not be treated as implemented merely because it is documented.

## Related architecture

The existing implementation/sequencing reference remains `docs/architecture/multi-graph-world-refactor.md` while project-specific documentation is migrated into this TLD.
