# Official legal and administrative corpus acquisition

Tracker: `engineering:adapter:personal.ivac.official-corpus:adapter:official-corpus-acquisition` (#243).

## Contract and scope

`contracts/personal/ivac/corpus/model.cue` owns acquisition observations for official
statutes, regulations, directives, ethics frameworks, legacy policies and official
guidance. It composes existing regulatory digest/citation constraints and uses
the existing bulk ZIP/XML verifier. It does not replace `#RegulatorySourceVersion`
or admit a compendium, interpretation, clinical finding or applicable legal version.

The checked source inventory is `personal/ivac/corpus/official-request.json`.
It includes the published IVAC directive index, all 32 directives discovered on
16 November 2026, LAPVIC and its regulation with schedules, LVFC, the Criminal
Code, ethics/privacy/administrative-justice instruments, concurrent regimes, and
the legacy IVAC statutes, regulations and policy manual. The separate supplement
includes the full CNESST administrators' code, a 2026 access-disclosure scan of
the ethics guide, and alternate LAPVIC PDF representations. Refresh the official
index before assuming this bounded request remains exhaustive.

Full original bytes and pinned text are retained outside Git. Each source has a
retrieval timestamp, requested and final transport URLs, SHA-256 digests, size,
format, conversion/version, and explicit success or failure. Québec XML members
also retain their original ZIP member name, ZIP digest and complete container.
The catalogue acquisition remains under the existing bulk contract. Its resource
date is distinct from legal commencement, publication and consolidation dates.

Canonical observations keep publication/consolidation/effective dates unknown
until separately reviewed. Exact source mentions can be indexed with existing
`#RegulatoryCitation` anchors. XML `date-eev` attributes remain publisher metadata;
they are not automatically a consolidation date or a case-specific interval.

## Reproduce

With CUE 0.16.1, the pinned requirements in
`scripts/requirements-ivac-regulatory.txt`, and Poppler:

```bash
python scripts/generate_ivac_corpus_types.py --check
python scripts/ivac_regulatory_bulk.py acquire /absolute/new-bulk-directory
python scripts/ivac_official_corpus.py acquire /absolute/new-corpus-directory \
  --request personal/ivac/corpus/official-request.json \
  --bulk-directory /absolute/new-bulk-directory
python scripts/ivac_official_corpus.py retry /absolute/new-corpus-directory --limit 5
python scripts/ivac_official_corpus.py verify /absolute/new-corpus-directory --reconvert
python scripts/ivac_official_corpus.py project /absolute/new-corpus-directory
```

Acquisition is opt-in, bounded to approved government HTTPS origins and refuses
an existing destination. Redirects are checked against the same allowlist.
`retry` operates only on failures, in bounded batches; it retains each attempt
and the previous manifest and never overwrites acquired originals. An image-only
PDF is retained even if text extraction is empty; its OCR gap remains explicit.
Retry does not refresh a successful source. Use a new directory for a new snapshot.

`repositoryCommit` identifies the checkout base at acquisition time; it does not
assert the worktree was clean. Record the final verification commit separately
when running an adapter that is still being developed. Source artifacts and their
timestamps are not relabelled as newly acquired merely because they are verified.

## Generated projections and analytical boundary

The existing generator creates JSON Schema and Pydantic v2 source, full-text and
anchor transport rows. Complete manifests are validated through CUE, bytes and
anchors are verified, native rows are round-tripped through CUE, and storage types
are derived from the generated schema rather than inferred from data values.
Unknown dates therefore remain SQL NULL even in all-unknown columns.

`project` creates a new persistent DuckDB database with `sources`, `source_text`
and `anchors`. It executes a CUE-validated `factory.analytics-ir/v1` missing-source
query through the existing Ibis lowerer and emits its plan, results and a CSV
inventory. This is diagnostic execution permission, not legal admission.

The canonical cross-field acquired/failed constraints, uniqueness, source/anchor
references and actual byte/quote checks are not supplied by native row validity
alone. Schema projections do not weaken those upstream gates. Text extraction
is machine-unreviewed; XML linearization and PDF layout text do not preserve all
visual/table meaning. Original representations must be consulted for semantics.

## Validation and remaining coverage

Six synthetic test groups exercise native/CUE round trips, unknown dates,
original/text/anchor tampering, unsafe paths/origins, identity and admission
guards, failed acquisition and append-only recovery, persistent full-text
projection, the IR/Ibis missing-source query, and deterministic generation.
Existing bulk tests separately exercise malicious ZIP/XML inputs.

```bash
python scripts/test_ivac_official_corpus.py
bash scripts/validate-ivac-regulatory.sh
bash scripts/validate-contracts.sh
bash scripts/validate-ivac-regulatory-integration.sh
```

The old Gazette text fixtures require Poppler 24.02.0 for exact regeneration.
Poppler 25.03.0 changes their extracted bytes and correctly fails those checks;
do not rewrite retained text to accommodate a converter upgrade. New acquisitions
record their actual converter and require that converter for exact reconversion.

Acquisition completeness is bounded by the request, not by the universe of
relevant law. Unpublished internal procedures, exhaustive amendment history,
indexed-amount tables, jurisprudence, role-specific ethics applicability and
case-specific transitional selection remain separate review tasks. The workbench
and qualification gates remain unchanged. No identifiable case evidence is used.
