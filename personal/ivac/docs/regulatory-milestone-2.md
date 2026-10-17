# IVAC regulatory sources — Milestone 2 acquisition checkpoint

Status: **partial implementation; milestone acceptance remains open**. Based on
merged Milestone 1 (`f3d3907`, PR #221). CUE remains semantic authority. No medical
attachments or identifiable case data were accessed, copied or committed.

## Verified source coverage

Three official original PDFs are retained under `personal/ivac/regulatory/sources/`.
Each has an acquisition JSON record with official URL, retrieval time, publication
date, original byte count and SHA-256, converted-text SHA-256, and conversion tool
version. Publication date is not a consolidation or effective date.

| Acquisition | Official publication | Coverage and authority |
|---|---|---|
| `gazette-2021-39` | Gazette officielle, 29 September 2021, issue 39 | D.1266-2021, original regulation and complete Annex I; original commencement in article 219 is 13 October 2021 |
| `act-2021-13` | Annual statute 2021, c.13, assented 13 May 2021 | Original enabling Act, including articles 179–184 and 198; not a present-day consolidated Act |
| `gazette-2026-04` | Gazette officielle, 28 January 2026, issue 4 | Proposal 87136, pages 328–330; **not evidence of adoption**, even though it prints a proposed commencement date |

The original PDFs are not edited, cropped, re-saved or normalized. Complete issue
PDFs are retained because they are the verified available official acquisition
route. Text is generated using Poppler 24.02.0:

```sh
pdftotext -layout -enc UTF-8 original.pdf original.txt
```

PDF fonts can produce `Invalid Font Weight` conversion warnings in the Act.
Conversion succeeds; retained text is checked byte-for-byte against regeneration.
Representative psychiatric and aesthetic table pages were rendered and inspected.
This spot check is not a complete visual or legal review of every table.

Direct Légis Québec HTML, historical HTML and PDF routes repeatedly returned HTTP
502 on 2026-10-17. The alternate Gazette route succeeded. Original annual statute
publication succeeded separately. No search-engine reconstruction, third-party
copy, fabricated digest or unverified current consolidation is substituted.

## Lossless candidate serialization

`annex-i-2021.candidate.json` is a deterministic, source-anchored extraction work
queue, **not an admitted `#RegulatoryCompendium`**. Its CUE contract is
`#RegulatorySerializationCandidate`. Existing regulatory/evaluation contracts and
public exports are preserved.

- The complete initial Annex I is partitioned into its contents and 25 numbered
  sections. Joining them reproduces the complete retained annex slice exactly.
- The inventory identifies every **40 functional and 8 aesthetic leaf units** by
  exact TOC labels, including shared section ownership for bilateral/grouped units.
- Every section retains its complete prose, tables, rules, class descriptions,
  percentages, alternatives, exclusions, comparability clauses and page artifacts.
- Chapter III is retained as a global-rule source span. The layout extraction has
  two columns there; it must be visually reviewed before semantic decomposition.
- The index includes 214 severity-label occurrences, 339 percentage occurrences,
  498 lexical `ou` occurrences and 25 evaluation-rule headings. These are **token
  counts, not counts of legally distinct classes, rates or alternative paths**.
- Exact text uses half-open Unicode code-point offsets in the pinned complete
  Gazette text. No whitespace, Unicode or page-header cleanup occurs after pinning.

Source-text completeness is separately typed from semantic completeness, amendment
history and case applicability. The latter three remain pending/incomplete/
unresolved. A candidate cannot claim reviewed status or substitute for the existing
qualification input. No clinical observation, finding or causal relation is created.

This checkpoint does **not** complete normalized class/criterion serialization.
Shared evaluation rules, dominance-conditioned percentages, aesthetic weighted
tables and nested alternatives require explicit mapping into Milestone 1's
`#RegulatoryCompendium`. A lexical `ou` must not be promoted to a standalone
qualifying path. In particular, criteria sharing prerequisites must retain those
prerequisites. Until mapping and review finish, no complete or admitted normalized
compendium is published.

## History and applicability audit

`history-audit.json` is CUE-validated under `#RegulatoryHistoryAudit`. Nine findings
link to original-source spans: the original Act's articles 179–184 and 198, the
regulation's article 219, and the 2026 proposal. Their interpretations are explicitly
limited to original text or unestablished legal effect.

The original transitional text distinguishes prior final decisions, pending
requests, later applications concerning earlier offences, and specified old-law
permanent-incapacity requests. Article 184 preserves ancillary provisions for the
requests it identifies. Therefore an offence date alone cannot safely select the
schedule. Original deadlines and benefit-duration clauses are **not represented as
current law** without auditing later amendments.

The proposal concerns health professionals and medication reimbursements; it is
not admitted as a later regulatory version. An enactment search and current
consolidation are still required. These sources do not prove Annex I has remained
unchanged since 2021. No exhaustive 2021–2026 amendment audit or applicable-version
selection is claimed.

## Reproduce and verify

From the repository root, with CUE v0.16.1, Python 3.12 and Poppler 24.02.0:

```sh
python3 scripts/ivac_regulatory_sources.py build \
  personal/ivac/regulatory/sources/gazette-2021-39.json > /tmp/annex-i.json
cmp /tmp/annex-i.json personal/ivac/regulatory/annex-i-2021.candidate.json
python3 scripts/ivac_regulatory_sources.py verify \
  personal/ivac/regulatory/annex-i-2021.candidate.json
python3 scripts/ivac_regulatory_sources.py audit personal/ivac/regulatory/history-audit.json
python3 scripts/test_ivac_regulatory_sources.py
bash scripts/validate-contracts.sh
```

Network acquisition is opt-in and refuses to overwrite an existing artifact:

```sh
python3 scripts/ivac_regulatory_sources.py acquire personal/ivac/regulatory/sources/reacquisition
```

Each new acquisition receives its actual retrieval time and new artifact records;
do not overwrite the historical records. Compare original digests before accepting
any new response. Same bytes at a later retrieval are not a new legislative version.

The `compare` command takes two independently verified candidate files and reports
added/removed/changed sections. It performs exact text comparison, including layout
and headers, with `authority: none` and `legalEffect: not-determined`. Formatting
changes are not inferred to be legislative amendments. Tests use an explicitly
synthetic revision; no second enacted Annex I is invented.

CI runs offline. It checks original/text integrity, regeneration, 48 leaf-unit
coverage, 25-section partition, marker completeness, deterministic generation,
history provenance, proposal/admission boundaries, and negative tampering tests.
The original Milestone 1 qualification tests remain part of the same suite.

## Remaining acceptance and projections

1. Acquire official later consolidated versions and complete amendment/provision
   history, including confirmation of enactments following proposal 87136.
2. Audit later changes to the enabling Act's transitional provisions; preserve
   explicit unresolved applicability until competent case-specific legal selection.
3. Map all retained classes, conditional percentages, weighted tables, global/shared
   rules and alternative criteria into the existing compendium authority. Review
   every class against the original page; retain candidate status until reviewed.
4. Add independently reviewed class/path/rule completeness manifests and actual
   inter-version comparisons. Raw marker counts cannot satisfy those gates.
5. Generate JSON Schema and Pydantic v2 projections from CUE, then round-trip them
   through CUE. Report conditional/reference constraints lost in projection. No new
   handwritten Python domain model or Ibis authority is introduced here.

The separate Milestone 2 PR is a draft checkpoint, not a completed regulatory
database, and must not merge automatically.

## Continuation — 17 October 2026

Implemented on the existing Milestone 2 branch, starting at `61ca486`. The prior
PR CI failure was a missing `pdftotext` executable; the workflow now installs
`poppler-utils` instead of skipping conversion verification.

### Official bulk acquisition

`ivac_regulatory_bulk.py` verifies the live CKAN dataset identity and selects
resources by exact catalogue names, rather than assuming dated filenames. The
catalogue now advertises **20261009**, not the previously discovered October 6
archives. Both XML ZIPs and the French CSV were downloaded and verified. Exact
catalogue response bytes are retained with a digest; acquisition observations
include actual resource IDs, URLs, retrieval timestamps, ZIP/member digests,
original member paths, media types, publisher XML attributes and byte counts.
`bulk-observations-20261017.json` is CUE-validated metadata, not a compendium.

Actual ZIP paths use backslashes. The adapter treats them as separators for safe
inspection without rewriting original member identities. It rejects traversal,
absolute/drive paths, duplicate/case-colliding names, encrypted and symlink
members, excessive sizes/ratios and unexpected identities. XML parsing forbids
DTD, entity and external expansion. Selected members must independently identify
the exact French instrument. CRC checking and SHA-256 verification are required.
The member bytes remain unchanged; deterministic text views are separately hashed.
Provision anchors include **byte offsets in original XML** and **Unicode code-point
offsets in the derived text**, explicitly separate coordinate systems.

The regulation and Act roots each expose `date-eev="20241201"`; Annex I and the
selected evaluation/transitional provisions expose their own attributes. These
are publisher observations. Neither a ZIP filename nor a root attribute is
silently promoted to publication date, consolidation date or a legal interval.
Those dates remain unknown/review-required where not separately established.

The catalogue declares **CC-BY-NC-ND 4.0**. This checkpoint publishes acquisition
metadata, hashes, code and a content-free comparison summary. Bulk archives,
extracted XML and transformed text remain in the acquisition workspace; they are
**not mirrored in Git** pending redistribution/licensing review. Reacquisition
is supported; durable archival and permission to redistribute derivative content
remain open. Existing Gazette PDFs/text remain unchanged.

Reproduce (network acquisition is opt-in; use a new directory):

```sh
python3 -m pip install -r scripts/requirements-ivac-regulatory.txt
python3 scripts/ivac_regulatory_bulk.py acquire /tmp/ivac-official-new
python3 scripts/ivac_regulatory_bulk.py verify /tmp/ivac-official-new
python3 scripts/ivac_regulatory_coverage.py /tmp/ivac-official-new
```

The coverage report binds the original 2021 PDF/text offsets to the acquired ZIP,
XML member and exact Annex I byte span. A whitespace-token comparison records
representation changes only. PDF headers, layout and XML table boundaries differ;
**it establishes neither an amendment nor semantic equality**. Article 18/24/25/26,
Annex I and regulation amendment-list anchors, plus Act articles 179–184, are
included for the next legal audit. The January 2026 proposal remains a proposal;
the later XML acquisition does not itself establish that proposal's disposition.

### Native types and analytical execution

Repository reconciliation found an existing CUE-owned dataclass projection
(`generate_semantic_runtime_types.py`), CUE source introspection, and a working
`runtime/ibis_adapter.py`. No executable CUE→JSON Schema→Pydantic generator or
IVAC typeshed bridge was present. Typeshed/type introspection cannot express
regulatory semantics or replace schema validation.

Added CUE-owned disposable row schemas for units, classes, alternatives, criteria,
citations and unit evaluation rules. A new deterministic generator invokes CUE's
JSON Schema exporter and pinned `datamodel-code-generator`, then adapts numeric
Python fields to Decimal. No Python domain classes are handwritten. Scalar
intersection normalization and nonempty-string normalization are explicit,
equivalent exporter compatibility transformations. Generated rows forbid extras;
identifiers, source-version keys, alternative order, unknown percentage kinds
and exact zero are preserved. Decimal is emitted as JSON numeric tokens for CUE
round-trip checks, not strings or binary floats.

**Partial:** these are native row types, not a generated canonical compendium or
qualification model. Direct CUE v0.16.1 export of `#RegulatoryCompendium` and
`#RegulatoryExtraction` fails with `bad argument to unary comparison` on
field-dependent constraints. Discriminated canonical percentage unions,
conditional presence, range ordering, map identity, clinical actor/reference
integrity and criterion-path completeness are not fully represented in these row
schemas. The adapter therefore requires full upstream CUE validation and source
verification before projection, then validates every Pydantic row back through
CUE. Never reconstruct or admit a compendium from row validity alone. Source and
qualification native model generation remains blocked on a qualified exporter
strategy; no canonical CUE constraint was weakened to obtain generated output.

The analytical adapter reuses `factory.analytics-ir/v1` and the existing Ibis
lowerer. A tested source-version/compendium/unit anti-join exposes units missing
class rows. The caller must explicitly authorize diagnostic projection sources;
IR's `admitted` state is authorization of diagnostic input, **not legal admission**.
Arrow transfers typed test tables into in-memory DuckDB. Missing rows remain
coverage gaps. This view emits no clinical qualification, applicability or award.
BigQuery is an optional untested backend, not an installed requirement. General
evidence-linked views, global/shared rule rows, conditional calculations and
weighted aesthetic tables remain pending.

No dlt/fsspec dependency is added: bounded official HTTP acquisition already has
immutable-byte verification and needs no incremental cursor/loading machinery.
A future recurring transport can supply bytes to the same verifier; it must not
create a parallel provenance or admission system.

### Coverage and validation

Official initial unit-label coverage remains **40 functional + 8 aesthetic**.
Normalized official class/criterion coverage and independently reviewed unit
coverage remain **0**. Complete semantic transcription, conditional and weighted
percentages, all-of/any-of paths, exclusions, comparability and global rules are
not claimed by this increment. Synthetic rows exercise those projection shapes
without asserting invented official records.

```sh
bash scripts/validate-ivac-regulatory.sh
bash scripts/validate-contracts.sh
bash scripts/validate-ivac-regulatory-integration.sh
```

The optional integration suite verifies deterministic generation, six bulk
security/integrity test groups, Pydantic/CUE row round trips, exact Decimal values,
unknown versus zero, rejected source-version mismatches, and real Ibis/DuckDB
version-scoped anti-join correctness. CI installs its pinned integration
requirements explicitly. Original M1 qualification and M2 source suites remain
mandatory. Online acquisition and the cross-format comparison are reproducible
commands, not network-dependent CI assertions.

## Dependent legal-semantics investigation

Issue #226 (`engineering:contract:personal.ivac:investigation:regulatory-interpretation-opportunities`)
tracks the expanded legal analysis separately from #222 acceptance. See
`regulatory-semantic-specification.md` and `../regulatory/interpretation/` for the
25-opportunity register, 25 synthetic review scenarios, source/rubric coverage,
primary-authority ledger and eight executable Ibis comparison outputs.

Two primary TAQ texts were inspected: C.M., 2026 QCTAQ 02260 (IVAC settlement and
reconsideration; psychiatric class not contested), and J.V., 2012 QCTAQ 04180
(SAAQ; favorable full-evidence psychiatric classification and adverse analogy
reasoning). Neither is presented as a binding resolution of all IVAC class paths.
Appeal/finality verification, exhaustive jurisprudence, full class/table semantics
and independent legal review remain open. Research annotation contracts and
arithmetic/scenario programs cannot establish clinical support or entitlement.
The original M1 documentation's mistaken reference to article25 for permanence
is corrected to article23; canonical M1 qualification contracts are preserved.


A final exporter probe distinguishes two failure modes: direct compendium and
extraction export fails with `bad argument to unary comparison`; qualification
export returns success but only an unconstrained `$schema` document. That output
is rejected, not accepted as a qualification projection. Reproduce with
`python3 scripts/ivac_regulatory_projection_gaps.py`; the retained report is
`../regulatory/generated/projection-gaps.json`. Native generation now explicitly
refuses a vacuous schema. The canonical projection remains blocked pending a
qualified exporter and constraint-loss audit, rather than every root failing
with the same diagnostic.
