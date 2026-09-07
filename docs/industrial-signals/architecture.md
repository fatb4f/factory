# Industrial signals architecture

This document is the project-relative architecture index for Factory's engineering-to-industry intelligence system.

## Authority topology

```text
engineering-signals
        |
        | translation / adoption evidence
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
                                      v
                               financial-signals
                                      |
                         +------------+------------+
                         |                         |
                         v                         v
                  engineering-pocs       financial-opportunities
```

The graph authorities documented under this TLD are independent:

- `contracts/world/engineering-signals/`
- `contracts/world/industrial-signals/`
- `contracts/world/financial-signals/`

No graph may manufacture another graph's topology. Cross-domain linkage requires explicit identity evidence, admitted relation/bridge semantics, and snapshot-qualified references.

## Graph documentation

- `engineering-signals/sources-and-acquisition.md` — engineering source obligations, current acquisition and projected pipeline.
- `industrial-signals/sources-and-acquisition.md` — actor/project/funding/translation source obligations, follow-through acquisition and projected pipeline.
- `financial-signals/sources-and-acquisition.md` — regulatory/issuer/market source obligations, time-qualified acquisition and projected pipeline.

## Shared acquisition shape

```text
source obligations
        ↓
manual / agent-assisted acquisition today
        ↓
immutable source-qualified occurrence
        ↓
typed observation candidate
        ↓
validation / explicit coverage gap
        ↓
domain admission
        ↓
immutable graph snapshot
```

The projected automated form preserves the same authority boundary:

```text
source registry + schedule
        ↓
replaceable adapter
        ↓
immutable raw capture
        ↓
canonicalization / extraction
        ↓
typed normalization
        ↓
identity / relationship qualification
        ↓
CUE validation + domain admission
        ↓
immutable graph snapshot
```

Automation changes acquisition realization, not semantic authority.

## Cross-domain invariants

```text
domain observation != domain graph fact
hypothesis != admitted edge
graph A node != graph B node without identity evidence
cross-domain correlation != source-domain authority
financial measurement != timeless relation
industrial observation != binding constraint
industrial scarcity != investment opportunity
poc-candidate disposition != admitted POC
```

For industrial public-support tracking:

```text
announcement != award
authorized award != disbursement
disbursement != expenditure
recipient-reported expenditure != audited expenditure
expenditure != milestone
milestone != outcome
```

Missing downstream evidence remains a coverage gap.

## Current and target execution

Current/manual event-watch execution remains enabled for engineering and industrial signals. Financial-signals remains disabled until its issuer/hypothesis/source universe is explicitly configured.

Target progression:

1. bounded source acquisition;
2. typed source-qualified observations and coverage state;
3. canonical graph identity/relation admission;
4. deterministic relational/storage projection;
5. immutable graph snapshots;
6. explicit downstream constraint, allocation, financial and POC qualification.

## Legacy reference

`docs/architecture/multi-graph-world-refactor.md` contains the original detailed refactor/sequencing record. Project-relative documentation under `docs/industrial-signals/` is the preferred navigation surface going forward.
