# Industrial signals — sources and acquisition

## Authority boundary

Semantic authority: `contracts/world/industrial-signals/`.

Authoritative monitored-source registry: `contracts/world/industrial-signals/sources.cue`.

Current execution procedure: `world/industrial-signals/.agents/AGENTS.md`.

This document is descriptive. It does not establish canonical actor identity, response causality, binding industrial constraints, financial opportunity, resource-allocation decisions, or Factory POC admission.

## Exhaustive monitored source inventory

See [source-catalog.md](source-catalog.md).

That catalog is the exhaustive human-facing projection of `industrialSources` in `contracts/world/industrial-signals/sources.cue`. Source-family prose is explanatory only and must not be used as a substitute for the source/channel inventory.

The authoritative registry currently covers:

- GDELT events through Google BigQuery;
- Google Patents public data through Google BigQuery;
- Government of Canada Grants and Contributions;
- CanadaBuys procurement;
- Statistics Canada tables;
- Québec enterprise-register open data;
- Hydro-Québec open data;
- NSERC awards and partnerships;
- OpenAlex;
- ROR;
- CIPO / IP Horizons;
- ATI/ATIP completed-request summaries, released packages and targeted requests;
- Government of Canada, Government of Québec, NRC, ISED, NRCan, C2MI, CMC and selected higher-education / research / technology-transfer institutional publications;
- operator, supplier, customer, project-proponent and facility publications;
- regulatory filings, permits/approvals and standards-participation records.

GDELT and OpenAlex are contracted as discovery-only channels. Google BigQuery is both the provider for the GDELT dataset and the acquisition surface for the separately contracted Google Patents dataset. Transport does not determine evidence authority.

## Monitoring objective

Track the evolving industrial ecosystem longitudinally: actors, facilities, projects, technologies, capacity, supply/demand/lead-time signals, industrial actions, innovation adoption, public support, project progress, commissioning/production and observed outcomes.

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

The current `event-watch` is bounded manual or agent-assisted acquisition over applicable channels selected from the authoritative source registry.

```text
industrialSources
        ↓
select channels applicable to the monitored industrial surface / trajectory
        ↓
manual or agent-assisted acquisition
  browser | HTTP | API | bulk | BigQuery | released package | request
        ↓
typed acquisition outcome
        ↓
source-qualified captured occurrence
        ↓
preserve source/channel/record/revision/observed-surface provenance
        ↓
classify typed industrial observation
        ↓
seek longitudinal follow-through where applicable
        ↓
observation OR explicit typed coverage/follow-through gap
        ↓
admitted event-watch run
```

`#IndustrialAcquisitionAttempt` represents execution state separately from industrial event semantics. It can preserve source, channel, acquisition mode, outcome, acquisition time, source record/revision hints, payload digest and typed coverage/follow-through state without making the acquisition mechanism part of the semantic observation identity.

A source being in the registry does not mean every run must query it. Applicability is bounded. An applicable source that is unavailable, inaccessible, machine-unreadable or missing expected follow-through must be represented as typed acquisition/coverage state instead of silently disappearing from the run.

## Projected automated data pipeline

Target realization is product-neutral:

```text
contracts/world/industrial-signals/sources.cue
        ↓
source/channel selection + schedule
        ↓
replaceable acquisition realization
  BigQuery query
  HTTP/API adapter
  bulk/snapshot adapter
  browser/manual fallback
  released-package adapter
  ATI/ATIP request workflow
        ↓
immutable raw capture
  source + channel + record ID + revision + observed surface + payload digest + acquiredAt
        ↓
canonicalization / structural extraction
        ↓
identity and relationship candidate resolution
        ↓
typed industrial observation candidates
        ↓
CUE validation + typed coverage/follow-through state
        ↓
domain admission
        ↓
immutable industrial-signals graph snapshot
```

Automation changes acquisition realization, not semantic authority. Automated identity matching may generate candidates only; it may not create canonical actor equivalence or cross-source relationships without the owning industrial admission path.

## GDELT / BigQuery execution boundary

The source registry makes the distinction explicit:

```text
GDELT event discovery
  source: gdelt
  channel: events
  provider: google-bigquery
  dataset: gdelt-bq.gdeltv2.events
  admission use: discovery-only

Google Patents
  source: google-bigquery
  channel: google-patents
  dataset: patents-public-data.patents.publications
  admission use: source-qualified candidate
```

The older `contracts/world/industrial-constraints/sources.cue` and acquisition projections still contain these structured reads for the constraint domain's retained pre-refactor event-watch compatibility. Industrial source authority for the engineering-to-industry graph now belongs in `contracts/world/industrial-signals/sources.cue`.

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

- source and channel from the authoritative registry;
- acquisition mode separately from semantic identity;
- source-local record identifier;
- revision/publication/version identity;
- observed surface;
- acquisition time as provenance;
- immutable captured-payload digest for mutable external state;
- observed actor/project labels separately from canonical identity;
- evidence supporting any admitted cross-source equivalence;
- funding stage and evidence class;
- explicit unresolved identity, relationship, access, machine-readability or follow-through gaps.

## Publication boundary

Current `event-watch` output is source-qualified observation state only.

Immutable industrial graph snapshots may be published only through the industrial graph realization/admission path. Workbook, analytics, acquisition adapters, external databases and model-generated correlations remain downstream projections or candidates.

## Tracking

- GitHub issue #143 — industrial source acquisition state and follow-through gaps.
- GitHub issue #200 — exhaustive documentation projection of the industrial source registry.
- GitHub issue #139 — immutable industrial-signals graph snapshots, completed.
