# Private IVAC timeline ingestion and Ibis queries

Tracker: #229, `engineering:adapter:personal.ivac:integration:timeline-ibis`.
CUE authority: `contracts/personal/ivac/workbench/timeline.cue`, composing the
existing workbench/IVAC authority rather than replacing the clinical evidence
world, regulatory qualification or medico-legal review contracts.

## Pipeline

CUE acquisition contract -> generated JSON Schema/Pydantic v2 transports ->
verified package adapter -> Arrow -> DuckDB tables -> analytics IR -> Ibis.

The supported input is the private `ivac.complete.evidence.exchange` 0.2.0 ZIP.
Package-provided Python is never imported or executed. Its previous JSON Schema
is provider metadata, not canonical authority. Provider `content`/`details` stay
lossless opaque JSON; serializing them is not exhaustive clinical abstraction.

The loader reuses `ivac_regulatory_bulk.inspect_zip(require_xml=False)` for path,
collision, symlink, encryption, expansion and compression-ratio checks. Default
regulatory ZIP behavior still requires XML. It verifies the complete package
member manifest, original source hashes where original bytes are present, pinned
text and exact Unicode citation slices before creating the database. CRLF bytes
are decoded directly, without universal-newline normalization.

CUE validates source/event identities, event references and the complete page /
unpaged-payload index. Generated native models validate every exchange/row
record. Runtime verification checks bytes and source text that CUE cannot read.
Caller-selected output paths are not taken from input metadata. The adapter
performs no external acquisition and never claims independent authentication of
provider records, clinical conclusions, credentials or publisher legal status.

## Tables and stable links

All tables carry `dataset_id`, the SHA-256 of the input package. Owner IDs retain
provider identities; generated page/anchor/payload IDs are deterministic hashes.
Joins must include dataset identity as well as record identity.

| Table | Meaning and links |
| --- | --- |
| datasets | Package identity, input version, original authority statement, coverage/gaps; semantic admission remains none. |
| sources | Source identity, URLs, original digest/path, extraction status and lossless source metadata. |
| document_pages | Source/page/text-path identity, pinned text SHA-256 and original serialized text. |
| source_payloads | Source-linked native/workbook serialized payloads without an invented page number. |
| events | Provider event identity, date label, optional normalized ISO date, evidence status and lossless content. |
| evidence_anchors | Owner kind/ID, source ID, page, exact text offsets where available, review attribution and verification state. |
| assessments | Attributed assessment metadata; only explicitly numeric provider percentages are projected numerically. |
| sequela_vectors | Candidate domain, permanence/causation statements, optional class/percentage; not qualification. |
| source_aliases | Legacy/provider IDs mapped by original-artifact or original-and-text digests. Ambiguous aliases are not arbitrarily selected. |
| assessment_comparisons | Preserved provider comparison statements, unresolved status, original artifact path and linked comparison anchors. |

Events join anchors on `dataset_id`, `event_id == owner_id`, with
`owner_kind == "event"`. Other owners use `assessment_id`, `vector_id` or
`comparison_id`. Anchors and aliases join sources on `dataset_id, source_id`.
Pages and unpaged payloads use the same source key.

Raw-byte verification is `original-verified` or `snapshot-only`; native files
without a separate original byte object remain explicit snapshot-only records.
Encrypted original PDFs can be hash-verified while extraction remains blocked.
Unreviewed OCR stays unreviewed. A quote without offsets is locator-only, not an
exact verified span. Older copied source IDs resolve through pinned digests,
not guesses based on filenames. No new dates are inferred from date labels.

Unknown percentages remain NULL, including new candidate vectors. Numeric zero
is retained. Strings/structured percentages remain opaque, with full input JSON
preserved. Decimal128(38,18) is the declared storage boundary; excessive scale is
rejected rather than rounded. This storage choice is not an award formula.

## Reproduce

Install the existing pinned `scripts/requirements-ivac-regulatory.txt` and
CUE 0.16.1, then:

```bash
python3 scripts/generate_ivac_timeline_types.py --check
python3 scripts/test_ivac_timeline.py
python3 scripts/ivac_timeline.py ingest /private/input.zip /private/timeline.duckdb
python3 scripts/ivac_timeline.py query /private/timeline.duckdb chronology
python3 scripts/ivac_timeline.py query /private/timeline.duckdb source-status
python3 scripts/ivac_timeline.py query /private/timeline.duckdb vectors
python3 scripts/ivac_timeline.py query /private/timeline.duckdb assessment-comparisons
python3 scripts/ivac_timeline.py query /private/timeline.duckdb event-evidence
```

CLI queries are CUE-validated `factory.analytics-ir/v1` plans lowered with the
existing Ibis adapter. IR admission is diagnostic execution authorization only.
Direct Ibis access is also available:

```python
import ibis
con = ibis.duckdb.connect('/private/timeline.duckdb', read_only=True)
events = con.table('events')
result = events.order_by('normalized_start', 'event_id').to_pyarrow()
con.disconnect()
```

Creation uses a private staging database and atomic no-overwrite publication.
Re-ingesting the same input verifies existing logical table contents; a changed
dataset or altered projection is rejected. Database bytes are not asserted
bit-for-bit deterministic across DuckDB versions; logical rows, IDs and table
digests are deterministic. Read-only queries consume the current local database;
re-ingestion against the verified package checks for database drift.

Source-provider JSON and Arrow have different responsibilities. Generated row
schemas do not carry all cross-record proofs into Pydantic; full CUE acquisition
validation and runtime byte/reference checks remain required. JSON Schema's
open provider payload values intentionally remain opaque rather than becoming
handwritten duplicate canonical models.

## Validation and scope

Synthetic tests cover deterministic generation/native CUE round trips, complete
persistence/reopening, chronology and dataset-scoped joins, source/manifest/page
and quotation tampering, missing sources, duplicate/dangling IDs, unsafe ZIPs,
NULL versus zero, decimal scale, aliases/comparison links and database drift.

Public code/tests contain invented records only. Private package, database,
query outputs and ingestion reports stay outside Git. The workbench UI,
independent medical/legal review, complete clinical abstraction and complete
regulatory semantic mapping remain separate work.
