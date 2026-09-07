# Industrial signals — source surface / adapter / interface matrix

This document maps **potential technical interfaces** over the exhaustive source registry in `contracts/world/industrial-signals/sources.cue`.

It is a capability and design-space projection, not adapter implementation state and not semantic authority. The source registry remains authoritative for what Factory monitors; this matrix answers a different question:

> Given an admitted source/channel obligation, what native surfaces and replaceable technical interfaces could Factory use to acquire, normalize, query, or transform it?

## Capability classes

Use these classes consistently:

| Class | Meaning |
| --- | --- |
| **Native/direct** | The upstream source or platform exposes the interface directly. Example: BigQuery SQL, BigQuery REST/client libraries, Ibis BigQuery backend, `dbt-bigquery`. |
| **Generic acquisition** | A general-purpose adapter can consume the source's published transport without the source natively integrating with that tool. Example: `httpx` reading an official CSV URL. |
| **Post-landing** | The tool becomes applicable after raw/source-qualified material is normalized or staged into Parquet, DuckDB, BigQuery, or another analytical relation. Example: dbt over a CSV source after loading it into BigQuery. |
| **Human/request workflow** | Acquisition requires browser navigation, an access request, released package handling, or other stateful workflow before machine analysis. |

Do not write `supports Ibis` or `supports dbt` for a file/web source when the actual relationship is post-landing.

## Exhaustive source/channel matrix

| Source / channel | Native upstream surfaces | Direct or generic acquisition candidates | Analytical/query interfaces | Transformation / orchestration candidates | Factory status / preferred boundary |
| --- | --- | --- | --- | --- | --- |
| `gdelt/events` | **BigQuery** `gdelt-bq.gdeltv2.events`; GDELT raw CSV archives; browser Analysis Service | BigQuery SQL/API; `google-cloud-bigquery`; **Ibis BigQuery backend**; **dbt-bigquery**; JDBC/ODBC; raw HTTP/CSV download | **Direct:** BigQuery SQL, Ibis, BigQuery DataFrames/BigFrames, pandas/PyArrow via BigQuery clients. **Raw-file path:** DuckDB, Polars, Pandas, Arrow | dbt-bigquery direct on BigQuery; scheduler/query-window adapter; raw-file ELT via HTTP/file tooling | Discovery-only evidence. Legacy BigQuery acquisition projection exists under `industrial-constraints`; no production `industrial-signals` adapter is implied. |
| `google-bigquery/google-patents` | **BigQuery** `patents-public-data.patents.publications` | BigQuery SQL/API; `google-cloud-bigquery`; Ibis; dbt-bigquery; JDBC/ODBC | **Direct:** Ibis, SQL, BigFrames, pandas/PyArrow; query results may stream through BigQuery Storage API | dbt-bigquery; scheduled SQL; Ibis relational projection | Source-qualified candidate surface. BigQuery is transport/query substrate, not evidence authority. |
| `gc-grants/awards` | Open Government consolidated **CSV**; JSON schema; XLSX dictionary; searchable HTML | HTTP/file fetch with `httpx`/`requests`; generic ELT/file adapter such as dlt; resumable bulk download | DuckDB `read_csv`, Polars, Pandas, PyArrow; **post-landing:** Ibis via DuckDB/BigQuery, dbt via warehouse | Bulk snapshot + modified-record reconciliation; CSV→Parquet/DuckDB/BigQuery; dbt after landing | Prefer immutable raw CSV capture plus source record ID/revision. Current execution may remain manual/agent-assisted. |
| `canadabuys/procurement` | CanadaBuys **CSV** datasets for tender notices, award notices, contract history, standing offers/supply arrangements; XML data dictionary; browser UI | Direct HTTP CSV fetch; `httpx`/`requests`; generic file/ELT adapter; date/fiscal-file scheduler | DuckDB, Polars, Pandas, PyArrow directly on CSV; post-landing Ibis/dbt | Incremental CSV reconciliation → Parquet/DuckDB/BigQuery; dbt after landing | Treat tender, award and contract-history records as distinct source records. |
| `statcan/tables` | Statistics Canada **WDS REST/JSON**, **SDMX REST/XML**, full-table CSV, Delta File, bulk downloads | REST client (`httpx`/`requests`); SDMX client; bulk/delta downloader; generic ELT REST/file adapter | JSON/CSV → DuckDB, Polars, Pandas, PyArrow; SDMX-aware clients; post-landing Ibis/dbt | WDS incremental calls for bounded updates; Delta File for high-volume change capture; warehouse transforms after landing | Strong machine surface. Select WDS vs Delta/full-table based on volume/cursor requirement. |
| `quebec-enterprise-register/enterprises` | Données Québec ZIP containing **six CSV files**, joined by NEQ; browser/catalog metadata | HTTP ZIP download; generic file adapter; unzip/extract pipeline; Données Québec catalog API for resource discovery | DuckDB multi-CSV joins, Polars, Pandas, PyArrow; post-landing Ibis/dbt | Snapshot-diff by published ZIP; normalize six-file relational model keyed by NEQ | Natural identity-support source. Preserve source snapshot and licensing constraints. |
| `hydro-quebec/open-data` | Hydro-Québec/Données Québec **JSON**, CSV, XLSX and catalog API surfaces; some JSON feeds update frequently | HTTP JSON/CSV fetch; catalog API; generic REST/file adapter | DuckDB JSON/CSV, Polars, Pandas, PyArrow; post-landing Ibis/dbt | Feed polling or versioned file snapshots; normalize measurements to typed time series | Prefer machine-readable JSON/CSV over page scraping when available. |
| `nserc/awards-partnerships` | NSERC Awards Database browser/search; downloadable Open Government dataset | Browser/HTTP; bulk dataset fetch where published; generic file adapter | Downloaded tabular data → DuckDB, Polars, Pandas, Arrow; post-landing Ibis/dbt | Periodic bulk snapshot plus targeted web lookup for detail pages | Preserve application/award identifiers and partner/institution labels separately from canonical identity. |
| `openalex/works-organizations` | **REST/JSON API**; public **S3 snapshot in JSONL and Parquet**; paid daily snapshot | REST client; generic REST ELT; S3 via AWS CLI/SDK, `boto3`, `s3fs`/`fsspec`; direct Parquet readers | **Direct on snapshot:** DuckDB, Polars, PyArrow; REST JSON → Pandas/Polars; **post-landing:** Ibis/dbt | API cursor/paging for bounded lookup; S3 Parquet for bulk analytics; snapshot/version reconciliation | Discovery/identity-support only in current industrial contract. Parquet snapshot is the richest bulk analytical surface. |
| `ror/organizations` | **ROR REST API JSON**; versioned Zenodo **JSON/CSV data dump** | REST client; generic REST ELT; HTTP/Zenodo release downloader | DuckDB, Polars, Pandas, PyArrow; post-landing Ibis/dbt | API for point resolution; versioned dump for deterministic snapshot joins | Good canonical-identifier candidate source, but industrial identity admission remains separate. |
| `cipo/ip-horizons` | IP Horizons researcher **CSV/TXT**; patent **ST.96 XML**; historical ST.36; CIPO **SFTP** | HTTP file fetch; SFTP client/adapter; generic file adapter; XML parser | CSV/TXT → DuckDB/Polars/Pandas/Arrow; XML → structural parser then relational landing; post-landing Ibis/dbt | Snapshot/download pipeline; XML normalization; Parquet conversion | As of Aug. 19, 2026 new patent XML is ST.96-only; adapter design should not assume continuing ST.36 production. |
| `ati-atip/completed-request-summaries` | Open Government **CSV**, JSON schema, XLSX dictionary, HTML search, dataset metadata/feeds | HTTP CSV fetch; generic file/ELT adapter; optional metadata feed polling | DuckDB, Polars, Pandas, PyArrow; post-landing Ibis/dbt | Monthly snapshot/diff; filter and route relevant request summaries to follow-up workflow | Discovery/access-recovery only; summary existence is not evidence of package contents. |
| `ati-atip/released-packages` | Institution-provided released record packages: PDF, office files, ZIPs, scans, correspondence | HTTP/browser acquisition; package downloader; document extraction; OCR only when unavoidable | Normalize extracted tables/text/metadata to Arrow/Parquet/DuckDB; then Ibis/dbt | Stateful package ingestion, file hashing, structural extraction, provenance manifest | Human/request workflow may be required. Preserve each released file and package revision. |
| `ati-atip/targeted-requests` | ATIP request portals/forms/email + resulting released packages | Human/agent request workflow; portal/browser automation where permissible; attachment/package ingestion | No meaningful direct analytical interface before release; post-release normalize to DuckDB/Parquet → Ibis/dbt | Request-state tracker → receipt → immutable package capture → extraction | Request workflow itself is operational state, not industrial evidence. |
| `institutional-web/government-of-canada` | Official HTML, PDF, CSV/JSON datasets, RSS/Atom where exposed, Open Government resources | Prefer official API/data file; otherwise `httpx`/`requests`; RSS/Atom parser; browser/Playwright fallback for JS-only pages; document extraction | Structured files → DuckDB/Polars/Arrow; documents → normalized relations → Ibis/dbt post-landing | Source-specific HTTP/feed adapters; document pipeline; scheduler by publication/update window | Coordinating pages are discovery surfaces when a narrower authoritative record exists. |
| `institutional-web/government-of-quebec` | Official HTML/PDF; Données Québec CSV/JSON/ZIP/API resources; agency-specific feeds | Données Québec/API/file adapters; HTTP/browser; document extraction | Structured resources → DuckDB/Polars/Arrow; post-landing Ibis/dbt | Catalog-driven resource discovery; file/feed snapshots | Prefer Données Québec machine resource over scraping the presentation page when equivalent. |
| `institutional-web/nrc` | NRC HTML/PDF/program/project publications; datasets/APIs when specifically exposed | HTTP/browser; RSS/feed if present; document/file adapter | Normalize to DuckDB/Parquet; then Ibis/dbt; direct CSV/JSON readers when published | Publication watch → immutable capture → extraction | Source-specific adapter should be chosen only after an actual NRC machine surface is identified. |
| `institutional-web/ised` | ISED HTML/PDF; open datasets; program/award records; CIPO-related machine files | HTTP/browser; Open Government file/API; document extraction | Structured files → DuckDB/Polars/Arrow; post-landing Ibis/dbt | Program-specific source adapters; publication/file reconciliation | Avoid duplicating CIPO channel acquisition when CIPO is the narrower authority. |
| `institutional-web/nrcan` | NRCan HTML/PDF; program/project records; open datasets/APIs where exposed | HTTP/browser; Open Government data; file/API adapter | Structured files → DuckDB/Polars/Arrow; post-landing Ibis/dbt | Publication/data watch → normalization | Route clean-energy-specific facts to the clean-energy authority when that is the semantic owner. |
| `institutional-web/c2mi` | C2MI HTML/PDF/news/project/technology-transfer publications | HTTP/browser; RSS/feed if available; document extraction | Normalize text/tables → DuckDB/Parquet; post-landing Ibis/dbt | Web publication adapter + structural extraction | Likely web-first until a stable machine feed is identified. |
| `institutional-web/cmc` | CMC Microsystems HTML/PDF/project/technology publications | HTTP/browser; feed/API if exposed; document extraction | Normalize → DuckDB/Parquet; post-landing Ibis/dbt | Web/feed adapter + extraction | Machine interface should remain capability-discovered rather than assumed. |
| `institutional-web/selected-universities` | University/college/institute/research-network sites; RSS/Atom; repositories; news APIs/data feeds where exposed | Source-specific HTTP/feed/repository adapter; browser fallback; document extraction | Structured output → DuckDB/Parquet; post-landing Ibis/dbt | Institution-specific adapters behind one normalized projection | Treat source heterogeneity as adapter-layer variation, not schema variation. |
| `operator-supplier-web/official-publication` | Company/project/facility HTML, PDFs, IR/news feeds, technical documents, occasional APIs | RSS/Atom or API when available; HTTP/browser; document extraction; repository/download adapter | Normalize → DuckDB/Parquet; post-landing Ibis/dbt | Actor-specific adapters; follow-up scheduler keyed by trajectory state | Prefer primary actor/project records over media reporting. |
| `regulatory-standards-web/regulatory-filings` | Regulator HTML/PDF, filing portals, APIs/bulk datasets where exposed | Source-specific API/bulk adapter; HTTP/browser; document extraction | Structured filings → DuckDB/Arrow; documents → normalized relations; post-landing Ibis/dbt | Regulator-specific connector behind common filing projection | Do not assume one regulatory transport across agencies. |
| `regulatory-standards-web/permits-approvals` | Permit/approval registries, HTML/PDF, GIS/open-data APIs, bulk datasets depending authority | API/bulk/GIS adapter where exposed; HTTP/browser; document extraction | Structured records → DuckDB/Polars/Arrow; post-landing Ibis/dbt | Authority-specific permit adapter → normalized milestone candidate | Permit identity/revision semantics matter more than transport choice. |
| `regulatory-standards-web/standards-participation` | Standards-body HTML/PDF/catalog APIs where exposed; committee/participation records | API/feed if exposed; HTTP/browser; document extraction | Normalize → DuckDB/Parquet; post-landing Ibis/dbt | Standards-body-specific adapter; revision/version watcher | Standards publication/version and participation evidence should remain separate records. |

## Tool/interface capability matrix

The same tools play different roles depending on the source surface.

| Interface / adapter | Direct-native fit | Generic / post-landing fit | Factory architectural role |
| --- | --- | --- | --- |
| **BigQuery Standard SQL** | GDELT BigQuery tables; Google Patents public dataset | Any source loaded to BigQuery | Query/execution substrate; never evidence authority by itself |
| **Ibis** | Direct BigQuery backend for GDELT/Google Patents | Ibis over DuckDB/BigQuery after CSV/JSON/Parquet/document normalization | Strong candidate for typed relational projection over replaceable backends |
| **dbt** | `dbt-bigquery` directly transforms BigQuery relations; BigQuery also supports dbt Python models with BigQuery DataFrames | File/API/web sources after loading to a dbt-supported warehouse/engine | Transformation/testing/documentation layer, not raw-source authority |
| **google-cloud-bigquery** | Direct BigQuery API/client interface | N/A | Native Python control/query adapter for BigQuery sources |
| **BigQuery DataFrames / BigFrames** | Direct BigQuery-backed DataFrame interface | N/A | Large-scale Python/DataFrame analysis without pulling entire data locally |
| **pandas / pandas-gbq** | BigQuery query/load integration; native CSV/JSON/XLSX processing | All normalized tabular captures | Analyst interoperability; not preferred semantic layer |
| **PyArrow** | BigQuery result transfer through Storage API; native Parquet/CSV datasets | Canonical interchange after landing | Preferred columnar interchange boundary candidate |
| **DuckDB** | Direct local/HTTP/S3 reads for many CSV/JSON/Parquet surfaces | Normalized landing/query engine for every non-BigQuery source | Strong local execution/materialization substrate |
| **Polars** | Direct CSV/JSON/Parquet file analysis | Normalized tabular captures | Fast eager/lazy DataFrame inspection/normalization candidate |
| **`httpx` / `requests`** | REST/HTTP APIs and static file URLs | Generic web/file acquisition | Minimal replaceable transport adapter |
| **dlt / generic ELT** | Suitable REST/file sources when endpoint/file semantics fit | Load normalized/raw captures into DuckDB/BigQuery/etc. | Candidate ingestion realization; must not own source semantics |
| **S3 tooling (`aws`, `boto3`, `s3fs`/`fsspec`)** | OpenAlex snapshot | Any future object-store publication | Bulk object acquisition; snapshot-oriented |
| **SFTP client/adapter** | CIPO bulk IP products | Other explicitly published SFTP sources | Bulk file acquisition |
| **SDMX clients** | Statistics Canada SDMX service | Other SDMX statistical authorities | Typed statistical interchange acquisition |
| **RSS/Atom/feed parsers** | Sources that publish official feeds | Institutional/operator web monitoring | Efficient publication detection before full record acquisition |
| **Browser / Playwright** | Human-facing or JS-rendered pages | Fallback only when a stable API/feed/file is unavailable | Acquisition adapter of last resort, not a semantic source class |
| **Document extraction** | PDF/office/released packages | Institutional, actor, regulatory and ATI/ATIP records | Structural projection from immutable source file into typed candidates |

## Recommended projection hierarchy

Prefer the narrowest stable machine surface available:

```text
native database / API / versioned bulk data
            ↓
structured feed / static CSV, JSON, Parquet, XML
            ↓
HTML/PDF official publication
            ↓
stateful browser/request workflow
```

Then keep the analytical layer replaceable:

```text
source-native occurrence
      ↓
transport adapter
      ↓
immutable raw capture
      ↓
normalization
      ↓
Arrow / Parquet / relational candidate
      ↓
Ibis logical expression
      ↓
DuckDB / BigQuery / other admitted execution backend
      ↓
optional dbt transformation/testing projection
```

This is deliberately not:

```text
source → dbt
source → Ibis
```

for every source. Those shortcuts are valid only when the upstream surface is already a compatible database/query backend.

## High-leverage interfaces by source class

### BigQuery-native

GDELT and Google Patents have the broadest direct interface surface:

```text
BigQuery dataset
  ├─ Standard SQL
  ├─ REST / Google client libraries
  ├─ Ibis
  ├─ dbt-bigquery
  ├─ BigQuery DataFrames / BigFrames
  ├─ pandas / PyArrow via client + Storage API
  └─ JDBC / ODBC
```

For Factory this makes Ibis especially attractive: source-specific BigQuery expressions can project into the same logical relational layer used by a DuckDB-backed normalized file source.

### Structured open-data files/APIs

GC grants, CanadaBuys, StatCan, Québec enterprise data, Hydro-Québec, NSERC, OpenAlex, ROR and CIPO generally follow:

```text
REST / CSV / JSON / Parquet / XML / ZIP / SFTP
      ↓
generic source adapter
      ↓
immutable file/object capture
      ↓
DuckDB / Arrow / Polars normalization
      ↓
Ibis logical relation
      ↓
optional dbt / warehouse realization
```

### Document/web/request sources

Institutional, actor, regulatory and ATI/ATIP package sources generally follow:

```text
HTML / PDF / office files / released package
      ↓
HTTP/browser/request adapter
      ↓
immutable document capture
      ↓
structural extraction
      ↓
typed source-qualified candidate
      ↓
Arrow / Parquet / DuckDB
      ↓
Ibis / dbt only after landing
```

## Implementation-state rule

A technology appearing in this matrix means **technically viable**, not implemented.

The current industrial monitor remains manual/agent-assisted `event-watch`. A production adapter should be claimed only when repository implementation and qualification evidence exist for that source/channel.

## Verified upstream interface references

These references were checked while producing this matrix and should be refreshed when interface behavior materially changes:

- BigQuery + Ibis: https://ibis-project.org/backends/bigquery
- BigQuery + dbt / BigQuery DataFrames: https://docs.cloud.google.com/bigquery/docs/dataframes-dbt
- BigQuery Python and DataFrame libraries: https://docs.cloud.google.com/bigquery/docs/python-libraries
- BigQuery APIs, REST, JDBC and ODBC: https://docs.cloud.google.com/bigquery/docs/reference
- GDELT query/download surfaces: https://gdeltproject.org/data.html
- Statistics Canada developer surfaces: https://www.statcan.gc.ca/en/developers
- Statistics Canada WDS: https://www.statcan.gc.ca/en/developers/wds
- OpenAlex API: https://help.openalex.org/api/
- OpenAlex S3 JSONL/Parquet snapshot: https://help.openalex.org/access/snapshot/
- ROR REST API: https://ror.readme.io/docs/rest-api
- ROR versioned data dump: https://ror.readme.io/docs/data-dump
- CanadaBuys procurement datasets: https://canadabuys.canada.ca/en/procurement-and-contracting-data
- Government of Canada Grants and Contributions dataset: https://open.canada.ca/data/en/dataset/432527ab-7aac-45b5-81d6-7597107a7013
- Completed ATI request summaries dataset: https://open.canada.ca/data/en/dataset/0797e893-751e-4695-8229-a5066e4fe43c
- Québec enterprise register dataset: https://www.donneesquebec.ca/recherche/fr/dataset/registre-des-entreprises
- CIPO IP Horizons: https://ised-isde.canada.ca/site/canadian-intellectual-property-office/en/canadian-intellectual-property-statistics/ip-horizons-download-intellectual-property-data

## Reconciliation rule

A source registry change is documentation-incomplete until both are reconciled:

1. `source-catalog.md` — **what** is monitored;
2. this matrix — **how it could technically be reached and analyzed**.

Neither document is allowed to manufacture a new authoritative source or claim an adapter implementation.