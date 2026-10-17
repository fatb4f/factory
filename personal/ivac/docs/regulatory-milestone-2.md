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
