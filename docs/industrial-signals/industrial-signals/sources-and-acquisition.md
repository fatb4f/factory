# Industrial signals — sources and acquisition

## Authority boundary

Semantic authority: `contracts/world/industrial-signals/`.

Current execution procedure: `world/industrial-signals/.agents/AGENTS.md`.

This document is descriptive. It does not establish canonical actor identity, response causality, binding industrial constraints, financial opportunity, resource-allocation decisions, or Factory POC admission.

## Monitoring objective

Track the evolving industrial ecosystem longitudinally: actors, facilities, projects, technologies, capacity, supply/demand/lead-time signals, industrial actions, innovation adoption, public support, project progress, commissioning/production and observed outcomes.

## Monitored source families

Prefer primary operational, institutional, regulatory, procurement, funding and actor records.

| Source family | Typical surfaces | Intended evidence |
| --- | --- | --- |
| Industrial actors | company/project publications, technical updates, IR where operationally relevant, supplier/customer disclosures | actor/project state, actions, capacity, deployment, milestones |
| Government funding | federal/provincial grants and contributions, program records, award/disbursement disclosures | award/authorization, disbursement, program obligations |
| Research partnerships | NSERC partnership/award records and comparable programs | academic-industry relationships, funded translation activity |
| Research / organization identity support | OpenAlex, ROR and comparable sources | research/organization discovery and identity evidence; not automatic canonical identity |
| Procurement | CanadaBuys and other public procurement records | purchases, contracts, equipment/services, execution evidence |
| Patents / IP | CIPO/IP Horizons, EPO and other primary patent records | industrial IP activity, assignee observations, translation evidence |
| Regulatory / permitting | regulatory filings, permits, environmental/operational approvals | facility/project obligations and progress |
| Institutions / networks | universities, colleges, institutes, technology-transfer offices, research networks, specialized academic-industry bridge entities | pilots, partnerships, commercialization, facilities, translation activity |
| Recipient/project follow-through | recipient updates, project reports, construction/equipment/hiring/qualification/commissioning disclosures | expenditure and milestone trajectory |
| Access-to-information surfaces | completed ATI/ATIP request summaries, released packages, targeted ATI/ATIP requests where ordinary publication is insufficient | otherwise unavailable official records and follow-through evidence |
| Standards participation | standards bodies and participation records | qualification/interoperability/adoption trajectory |

Secondary reporting may be used for discovery or triangulation, but missing primary follow-through must remain a coverage gap rather than being replaced by inference.

## Funding-accountability monitoring

Public support is tracked as a staged trajectory:

```text
announcement / program
        ↓
authorized award
        ↓
disbursement
        ↓
recipient expenditure
        ↓
project milestone
        ↓
commissioning / production / capacity
        ↓
measured industrial outcome
```

These stages must never be collapsed. In particular:

- award != disbursement;
- disbursement != expenditure;
- recipient-reported expenditure != audited expenditure;
- expenditure != milestone;
- milestone != outcome.

Missing downstream evidence is a coverage gap, not proof of non-performance.

## Current acquisition — manual / agent-assisted

The current `event-watch` is bounded manual or agent-assisted acquisition.

```text
source obligations / reconnaissance
        ↓
inspect applicable actor, government, procurement, institutional, IP or ATI/ATIP surface
        ↓
acquire bounded source record
        ↓
preserve source/channel/record/revision/observed-surface/acquisition provenance
        ↓
classify typed industrial observation
        ↓
seek longitudinal follow-through
        ↓
observation OR explicit coverage/follow-through gap
        ↓
admitted event-watch run
```

Current acquisition may use browser inspection, public APIs, downloadable datasets, public registers, released record packages, repository/document retrieval, or agent-assisted research.

The acquisition mechanism is execution metadata, not semantic identity. Actor labels remain source-qualified observations until an explicit identity-admission path establishes equivalence.

## Projected automated data pipeline

Target realization is product-neutral:

```text
contracted source obligations / source registry
        ↓
scheduler / acquisition request
        ↓
replaceable source adapters
  actor API/feed
  grants/contributions dataset
  procurement API/dataset
  research/organization index
  patent/IP source
  regulatory/permit source
  institutional publication source
  ATI/ATIP released-record source
        ↓
immutable raw capture
  locator + record id + revision hints + observed surface + payload digest + acquiredAt
        ↓
canonicalization / structural extraction
        ↓
identity and relationship candidate resolution
        ↓
typed industrial observation candidates
        ↓
CUE validation + coverage/follow-through state
        ↓
domain admission
        ↓
immutable industrial-signals graph snapshot
```

Automated identity matching may generate candidates only. It may not create canonical actor equivalence or cross-source relationships without the owning industrial admission path.

## Acquisition obligations by trajectory

A pipeline should be able to schedule follow-up based on previously admitted state. Examples:

```text
funding award observed
  → seek disbursement
  → seek expenditure evidence
  → seek project milestones
  → seek commissioning/production/outcome

technology evaluation observed
  → seek pilot
  → seek qualification
  → seek deployment
  → seek scaling/outcome

facility announcement observed
  → seek permits/procurement/construction
  → seek equipment/hiring
  → seek commissioning/capacity
```

Failure to obtain the next expected surface produces typed coverage state; it does not synthesize the missing stage.

## Identity and provenance requirements

Preserve, where available:

- source family and source identity;
- channel and observed surface;
- source-local record identifier;
- revision/publication/version identity;
- acquisition time as provenance;
- immutable captured-payload digest for mutable external state;
- observed actor/project labels separately from canonical identity;
- evidence supporting any admitted cross-source equivalence;
- funding stage and evidence class;
- explicit unresolved identity, relationship, access, or follow-through gaps.

## Publication boundary

Current `event-watch` output is source-qualified observation state only.

Immutable industrial graph snapshots may be published only through the industrial graph realization/admission path. Workbook, analytics, acquisition adapters, external databases and model-generated correlations remain downstream projections or candidates.

## Tracking

- GitHub issue #143 — manual industrial-source acquisition and follow-through gaps.
- GitHub issue #139 — immutable industrial-signals graph snapshots, completed.
