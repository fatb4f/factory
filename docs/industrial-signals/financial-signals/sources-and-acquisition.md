# Financial signals — sources and acquisition

## Authority boundary

Semantic authority: `contracts/world/financial-signals/`.

Execution procedure: `world/financial-signals/.agents/AGENTS.md`.

The financial graph owns issuer, reporting-segment, instrument, capital-structure, financing-relation and time-qualified financial/market state. It must not duplicate industrial, engineering, policy-demand, resource-allocation or investment-opportunity semantics.

The registry currently keeps this monitor disabled until an initial issuer/hypothesis/source universe is explicitly configured.

## Monitoring objective

Build reproducible, time-qualified financial state that can later support explicit industrial-financial bridges and downstream opportunity qualification without making market or issuer data a substitute for industrial evidence.

## Monitored source families

Prefer primary or reproducible financial records.

| Source family | Typical surfaces | Intended evidence |
| --- | --- | --- |
| Regulatory filings | securities regulators, statutory filings and issuer reporting repositories | audited/reported financial state, securities, material events |
| Issuer reporting | annual/interim reports, issuer IR, financing disclosures | revenue/earnings, segment state, debt/equity financing, guidance as issuer claim |
| Exchange/reference data | exchange listings, instrument/reference masters, official security identifiers | instrument/listing identity and reference attributes |
| Financing disclosures | prospectuses, offering documents, credit/debt disclosures, public financing announcements | capital structure and financing events |
| Reproducible market data | market/benchmark observations with source and timestamp | time-qualified prices, returns, benchmark context |
| Public economic/reference series | official rates, commodity/reference series where relevant | external financial context, explicitly time-qualified |

Media, newsletters, analyst reports and commentary are discovery/supporting evidence unless an owning contract explicitly admits their claims. Analyst estimates must not silently become issuer-reported facts.

## Current acquisition — manual / agent-assisted

When the financial event-watch is enabled, the current execution mode is bounded source-qualified acquisition:

```text
configured issuer / hypothesis / source universe
        ↓
inspect regulatory, issuer, exchange, financing and market surfaces
        ↓
acquire bounded record or observation
        ↓
preserve source + record/revision + observation time + acquisition provenance
        ↓
classify financial observation / measurement candidate
        ↓
CUE validation
        ↓
observation OR explicit source/coverage gap
```

Market measurements must carry an observation timestamp or interval appropriate to their semantics. A newer market observation does not overwrite historical state.

The acquisition mechanism is execution metadata and may be manual, browser/API-assisted, downloaded dataset based, or agent-assisted.

## Projected automated data pipeline

Target realization is product-neutral:

```text
configured financial universe + source obligations
        ↓
scheduler / acquisition request
        ↓
replaceable source adapters
  regulatory filing
  issuer reporting
  exchange/reference
  financing disclosure
  market/benchmark series
        ↓
immutable raw capture / time-qualified observation batch
        ↓
canonical instrument/issuer reference candidates
        ↓
normalization into typed financial observations and measurements
        ↓
CUE validation + identity/relation qualification
        ↓
domain admission
        ↓
immutable time-qualified financial-signals snapshot
```

Adapters must preserve historical observations and revision lineage rather than reducing a time series to the latest value.

Automated issuer/instrument matching may propose identity candidates only. Industrial actor identity and financial issuer identity remain independently admitted until an explicit bridge is established.

## Identity and provenance requirements

Preserve, where applicable:

- source identity and source-local record identifier;
- filing/reporting period and publication/revision identity;
- issuer-reported versus regulator-filed versus market-observed evidence class;
- instrument identifiers and listing venue/reference context;
- measurement timestamp/interval and unit/currency;
- acquisition time as provenance;
- immutable captured-content digest for mutable external records;
- correction/restatement/revision lineage;
- explicit unresolved issuer/instrument/segment relationship state.

A financial relation is not admitted merely because two entities share a name, ticker-like token, corporate parent label, or industrial association.

## Publication boundary

The target graph emits immutable, time-qualified financial snapshots. Downstream consumers may correlate those snapshots with industrial state only through explicit admitted bridges.

Financial measurements or market movements must not manufacture industrial constraints, resource-allocation decisions, or investment-opportunity admission.

## Tracking

- GitHub issue #140 — time-qualified financial-signals graph snapshots.
