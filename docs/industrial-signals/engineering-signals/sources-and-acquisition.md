# Engineering signals — sources and acquisition

## Authority boundary

Semantic authority: `contracts/world/engineering-signals/`.

Current execution procedure: `world/engineering-signals/.agents/AGENTS.md`.

This document is descriptive. It does not admit engineering facts, industrial adoption, economic claims, or Factory POC decisions.

## Monitoring objective

Track engineering mechanisms, technologies, experiments, standards, patents, prototypes, test results, manufacturability/scaling changes, failure modes, substitution paths, and integration techniques that may change what is technically feasible.

## Monitored source families

Prefer primary technical evidence where possible.

| Source family | Typical surfaces | Intended evidence |
| --- | --- | --- |
| Primary research | papers, preprints where primary, lab publications, conference proceedings | mechanism, measurement, experiment, failure analysis |
| Research indexes | OpenAlex and comparable research metadata/index surfaces | discovery, identity, citation/publication context; not automatic semantic admission |
| Standards | standards bodies, working groups, technical specifications | normative technical requirements, interoperability, maturity signals |
| Patents / IP | CIPO/IP Horizons, EPO and other primary patent records | claimed mechanisms, assignees, filing/publication chronology |
| Laboratories | university, public, corporate and independent lab publications | prototypes, test results, measured boundaries |
| Vendors / engineering organizations | technical notes, datasheets, release/test publications | productized capability, integration constraints, declared performance |
| Primary test surfaces | qualification reports, benchmark/test records, reproducible demonstrations | measured performance and failure boundaries |

Secondary media or commentary may support discovery, but should not replace an available primary technical source.

## Current acquisition — manual / agent-assisted

The current `event-watch` is bounded manual or agent-assisted acquisition.

```text
source reconnaissance
        ↓
select applicable primary surface
        ↓
acquire bounded record
        ↓
preserve source/channel/record/revision/publication/acquisition provenance
        ↓
classify against engineering contract vocabulary
        ↓
observation OR explicit source/coverage gap
        ↓
admitted event-watch run
```

Current acquisition may use browser inspection, public APIs, downloadable datasets, repository/publication search, or agent-assisted retrieval. The acquisition mechanism is execution metadata; it is not semantic identity.

For mutable or externally hosted records, capture sufficient immutable occurrence identity to reproduce the observed payload when practicable, including canonical content/payload digest plus source locator and revision/version hints.

A blocking acquisition gap must remain explicit. Missing or inaccessible evidence must not be converted to `no_material_events`.

## Projected automated data pipeline

Target realization is product-neutral:

```text
contracted source obligations / source registry
        ↓
scheduler / acquisition request
        ↓
replaceable source adapter
  API | dataset | feed | repository | document fetch
        ↓
immutable raw capture
  locator + source record + revision hints + payload digest + acquiredAt
        ↓
canonicalization
        ↓
structural extraction / normalization
        ↓
typed engineering observation candidate
        ↓
CUE validation + coverage state
        ↓
domain admission
        ↓
immutable engineering-signals graph snapshot
```

Pipeline adapters must remain replaceable. A specific ingestion product, crawler, research index, vector store, query engine, or warehouse must not become engineering semantic authority.

## Identity and provenance requirements

Preserve, where available:

- source family and source identity;
- channel/surface;
- source-local record identifier;
- publication/revision/version identity;
- acquisition time as provenance;
- immutable captured-content digest for mutable external state;
- exact measurement/test provenance where a performance claim is recorded;
- explicit unresolved identity or insufficient-evidence state.

Observed labels, titles, authors, organizations, patent assignees, or vendor names do not by themselves establish canonical cross-source identity.

## Publication boundary

Current event-watch output remains source-qualified observation state.

The target graph realization may publish immutable engineering snapshots only through the authoritative engineering graph admission path. Graph state may not manufacture industrial adoption, industrial response, economic impact, or POC admission.

## Tracking

- GitHub issue #142 — manual engineering-source acquisition and operational gaps.
- GitHub issue #138 — immutable engineering-signals graph snapshots.
