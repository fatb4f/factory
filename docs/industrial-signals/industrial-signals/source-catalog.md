# Industrial signals — exhaustive monitored source catalog

This document is the exhaustive human-facing projection of `contracts/world/industrial-signals/sources.cue`.

The CUE source registry is authoritative. This catalog must be reconciled whenever `industrialSources` changes; prose source-family summaries elsewhere in the docs do not replace this inventory.

## Registry semantics

Each row preserves the contracted source/channel boundary:

- **Modes** describe supported acquisition mechanisms. They are execution metadata, not semantic identity.
- **Roles** describe what kind of evidence the channel can contribute.
- **Admission use** distinguishes discovery-only channels from channels that may yield source-qualified industrial candidates.
- **Identity / revision / cursor** controls how repeated acquisition is correlated without treating acquisition time as source identity.

A source being in the registry does not imply every channel is queried on every run. Applicability remains bounded by the industrial surface and acquisition objective. Applicable but unavailable/inaccessible/machine-unreadable sources or missing expected follow-through must terminate as typed acquisition/coverage state rather than silent omission.

## Exhaustive source/channel inventory

| Source ID | Channel | Dataset / monitored surface | Modes | Roles | Admission use | Identity / revision / cursor |
| --- | --- | --- | --- | --- | --- | --- |
| `gdelt` | `events` | `gdelt-bq.gdeltv2.events` | BigQuery via `google-bigquery` | discovery | discovery-only | composite source key / query window / date window |
| `google-bigquery` | `google-patents` | `patents-public-data.patents.publications` | BigQuery | primary record; identity support | source-qualified candidate | stable source ID / dataset snapshot / snapshot diff |
| `gc-grants` | `awards` | Government of Canada Grants and Contributions | bulk; HTTP; browser | primary record; funding accountability; follow-through | source-qualified candidate | stable source ID / record update time / modified since |
| `canadabuys` | `procurement` | CanadaBuys tenders, awards and contracts | bulk; API; HTTP; browser | primary record; follow-through | source-qualified candidate | stable source ID / record update time / modified since |
| `statcan` | `tables` | Statistics Canada data tables | API; bulk; HTTP; browser | measurement | source-qualified candidate | composite source key / source version / modified since |
| `quebec-enterprise-register` | `enterprises` | Registraire des entreprises open data | bulk; HTTP; browser | primary record; identity support | source-qualified candidate | stable source ID / dataset snapshot / snapshot diff |
| `hydro-quebec` | `open-data` | Hydro-Québec open data | API; bulk; HTTP; browser | measurement; asserted event | source-qualified candidate | composite source key / source version / modified since |
| `nserc` | `awards-partnerships` | NSERC awards and partnership records | bulk; HTTP; browser | primary record; funding accountability; follow-through; identity support | source-qualified candidate | stable source ID / record update time / modified since |
| `openalex` | `works-organizations` | OpenAlex works and organization metadata | API; bulk; HTTP | discovery; identity support | discovery-only | stable source ID / source version / modified since |
| `ror` | `organizations` | Research Organization Registry | API; bulk; HTTP | identity support | source-qualified candidate | stable source ID / source version / modified since |
| `cipo` | `ip-horizons` | CIPO / IP Horizons patent data | bulk; HTTP; browser | primary record; identity support | source-qualified candidate | stable source ID / dataset snapshot / snapshot diff |
| `ati-atip` | `completed-request-summaries` | Government of Canada completed Access to Information request summaries | bulk; HTTP; browser | discovery; access recovery | discovery-only | stable source ID / record update time / modified since |
| `ati-atip` | `released-packages` | Previously released ATI/ATIP record packages | HTTP; browser; released package | primary record; access recovery; follow-through | source-qualified candidate | composite source key / request-package version / request follow-up |
| `ati-atip` | `targeted-requests` | Institution-specific ATI/ATIP requests | request | access recovery; follow-through | source-qualified candidate | composite source key / request-package version / request follow-up |
| `institutional-web` | `government-of-canada` | Official Government of Canada institutional publications | HTTP; browser | asserted event; primary record; follow-through | source-qualified candidate | composite source key / publication date / date window |
| `institutional-web` | `government-of-quebec` | Official Government of Québec institutional publications | HTTP; browser | asserted event; primary record; follow-through | source-qualified candidate | composite source key / publication date / date window |
| `institutional-web` | `nrc` | National Research Council Canada publications and program/project records | HTTP; browser | asserted event; primary record; follow-through | source-qualified candidate | composite source key / publication date / date window |
| `institutional-web` | `ised` | Innovation, Science and Economic Development Canada publications and program/project records | HTTP; browser | asserted event; primary record; funding accountability; follow-through | source-qualified candidate | composite source key / publication date / date window |
| `institutional-web` | `nrcan` | Natural Resources Canada publications and program/project records | HTTP; browser | asserted event; primary record; funding accountability; follow-through | source-qualified candidate | composite source key / publication date / date window |
| `institutional-web` | `c2mi` | C2MI publications and project/technology-transfer records | HTTP; browser | asserted event; follow-through | source-qualified candidate | composite source key / publication date / date window |
| `institutional-web` | `cmc` | CMC Microsystems publications and project/technology-transfer records | HTTP; browser | asserted event; follow-through | source-qualified candidate | composite source key / publication date / date window |
| `institutional-web` | `selected-universities` | Selected university, college, institute, research-network and technology-transfer publications | HTTP; browser | asserted event; identity support; follow-through | source-qualified candidate | composite source key / publication date / date window |
| `operator-supplier-web` | `official-publication` | Official operator, supplier, customer, project-proponent and facility publications | HTTP; browser | asserted event; follow-through | source-qualified candidate | composite source key / publication date / date window |
| `regulatory-standards-web` | `regulatory-filings` | Official regulatory filings and operational disclosures | HTTP; browser; API; bulk | primary record; follow-through | source-qualified candidate | stable source ID / record update time / modified since |
| `regulatory-standards-web` | `permits-approvals` | Official permit, approval and authorization records | HTTP; browser; API; bulk | primary record; follow-through | source-qualified candidate | stable source ID / record update time / modified since |
| `regulatory-standards-web` | `standards-participation` | Official standards-body participation, qualification and standards-change records | HTTP; browser; API; bulk | primary record; asserted event; follow-through | source-qualified candidate | composite source key / publication date / date window |

## GDELT and BigQuery

GDELT and BigQuery are separate contract concepts:

```text
Google BigQuery
    ├── provider for GDELT acquisition
    │      └── gdelt-bq.gdeltv2.events
    │              role: discovery-only
    │
    └── source surface: Google Patents public data
           └── patents-public-data.patents.publications
                   role: primary-record + identity-support candidate
```

A BigQuery row is not more authoritative because it is queried through BigQuery. Transport/execution and evidence authority remain separate.

GDELT events may discover industrial developments, actors or candidate milestones. They must be resolved to stronger source-qualified evidence before Factory treats the underlying industrial state as established.

## Source coverage by industrial purpose

The registry collectively covers these acquisition obligations:

| Industrial purpose | Contracted channels |
| --- | --- |
| Broad event discovery | GDELT; OpenAlex; ATI/ATIP completed-request summaries |
| Patent / technology evidence | Google Patents via BigQuery; CIPO / IP Horizons; OpenAlex; standards participation |
| Actor / organization identity support | Québec enterprise register; ROR; OpenAlex; CIPO; Google Patents; institutional sources |
| Public awards and support | GC Grants and Contributions; NSERC; ISED/NRCan/federal and Québec institutional publications |
| Disbursement / expenditure follow-through | GC grants updates; procurement; institutional records; recipient/project publications; ATI/ATIP packages; regulatory filings |
| Procurement / equipment / execution | CanadaBuys; operator/supplier/project publications; regulatory filings; permits/approvals |
| Industrial measurements | Statistics Canada; Hydro-Québec open data; regulatory records where measurements are source-qualified |
| Academic-industry translation | NSERC; selected universities/institutes/networks; C2MI; CMC; OpenAlex; ROR; CIPO; standards participation |
| Facility / project trajectory | operator/supplier/customer/project publications; institutional publications; permits; regulatory filings; procurement |
| Access recovery | ATI/ATIP completed summaries, released packages and targeted requests |

## Current versus projected acquisition

The registry defines what may be monitored and the acquisition modes that preserve its source/channel identity. It does **not** claim that production adapters exist for every channel.

Current execution remains manual/agent-assisted `event-watch`. The structured BigQuery/acquisition projections historically defined under `contracts/world/industrial-constraints/` demonstrate the GDELT/Google-Patents read shape, but they do not make that legacy constraint package the industrial source authority and they do not prove a production ingestion service exists.

Projected automation remains:

```text
industrialSources registry
        ↓
applicable source/channel selection
        ↓
replaceable adapter / BigQuery query / request workflow
        ↓
immutable captured occurrence
        ↓
normalization + typed acquisition state
        ↓
source-qualified industrial observation candidate
        ↓
CUE validation / admission
        ↓
industrial-signals state / immutable graph snapshot
```

## Reconciliation rule

A change to `industrialSources` is incomplete until this catalog is reconciled. Conversely, adding a source only to this Markdown file does not make it monitored or authoritative.
