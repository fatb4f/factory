# Regulatory evidence workbench base

Contract: `contracts/personal/ivac/workbench/model.cue`, version 0.1.0.
Root: `ivacworkbench.#RegulatoryWorkbench`. Dependent tracker: #228, stable key
`engineering:contract:personal.ivac:schema:regulatory-workbench-base`.

This base composes the existing IVAC 0.4.0 graph, regulatory compendium,
qualification and medico-legal review contracts. It does not complete the
legislative corpus, replace those authorities or introduce a second admission
path. PR #223 stays draft; Milestone 2 acceptance remains with #222.

## Base records

| Record | Responsibility |
| --- | --- |
| Corpus target | Declared instrument/provision scope, available versions and gaps; missing is explicit. |
| Corpus version | Existing `#RegulatorySourceVersion`, publication observation and publisher provision-version observation; optional existing compendium bound to that exact source. |
| Evidence text anchor | Existing evidence reference, original artifact SHA-256, pinned page-text SHA-256, page and exact Unicode slice. |
| Case snapshot | Initial, supplement or reassessment with explicit predecessor and increasing ordinal; recording timestamp is separate. |
| Case record | Filing, clinical evaluation, internal opinion, formal decision, supplement or review, with separately represented authored/submitted/received/communicated times. |
| Assessment statement | What the source asserts, with class, percentage and cited legal basis explicitly recorded or unknown. |
| Statement comparison | Explicit same-subject/topic pair and unresolved question; no automatic selection. |
| Rule dependency | Source-version citations and candidate or source-explicit dependency; a candidate requires an opposing reading. |
| Qualification / review draft | Existing `ivaceval.#RegulatoryQualification` and `#MedicoLegalReviewDraft`, preserved as independently gated objects. |

Documentary classification statements are not `#Finding` or
`#CriterionAssessment`. A recorded zero differs from an unknown percentage.
A cited proposal remains observable but cannot supply a workbench qualification.
Recorded unit/class labels are not silently repaired or treated as valid schedule
matches. The actual qualification uses the existing compendium selector gates.

Snapshot ordinal is declared append order, not inferred chronology or causation.
The contract rejects predecessor cycles through strictly increasing ordinals.
Persistence must separately enforce immutable historical snapshots; CUE validates
one assembled object and does not provide transactional storage or time travel.

Publication, consolidation, retrieval, publisher provision version and legal
commencement remain distinct. Known corpus versions reuse the existing source
contract's required dates. If consolidation or commencement cannot be established,
retain a missing/inventory target and upstream acquisition observations rather
than inventing dates to populate a canonical source version. Source observation
is not a case-specific legal applicability selection.

## Projection and execution

`workbenchProjectionSchemas` projects three disposable relations:

- statement: workbench/case/snapshot/record identity and attributed classification;
- anchor: original and page-text digest plus exact page-text slice;
- statementAnchor: source links scoped by workbench and statement identity.

`generate_ivac_workbench_types.py` reuses Factory's existing CUE JSON Schema and
Pydantic v2 generator. It creates `personal/ivac/workbench/generated/rows.*`;
percentages use Decimal, including the zero value. No handwritten Python domain
models are added. The full workbench is validated by CUE before projection;
only transport rows are generated, not the complete canonical workbench object.

`ivac_workbench.verify()` requires explicit runtime path bindings, verifies
original and pinned page-text bytes, then checks quote offsets. Corpus versions
use the existing immutable source verifier. A machine OCR anchor remains marked
unreviewed after successful hashing; hashing cannot establish transcription
accuracy. Paths in untrusted records are never opened automatically.

`project()` deterministically generates and round-trips every native row through
CUE. `missing_anchor_links_plan()` expresses a diagnostic anti-join in
`factory.analytics-ir/v1`; `execute_plan()` validates that IR and uses the existing
Ibis adapter. DuckDB/Arrow tests show that a link in another workbench cannot
hide missing coverage. IR source admission authorizes diagnostic execution only.

## Compatibility and remaining gates

Generated transport types preserve field constraints, identifiers, closed
objects and decimal values. The generator does not encode root dictionary
existence proofs, cross-record subject/topic checks, source-version equality,
predecessor order, proposal exclusion or professional role/admission checks in
these row types. CUE validates those constraints on the complete canonical input;
Python also checks actual byte digests and text slices. Row validation alone is
insufficient. Existing canonical compendium/qualification exporter limitations
remain unchanged.

The compatibility checks also exposed a pre-existing CUE 0.16.1 closure failure
in the medico-legal companion's positive draft/link fixtures. Those definitions
now use CUE's implicit definition closure, with regressions rejecting extra
fields. Clinical and legal professional links explicitly constrain issue category;
wrong-category, actor and reference links remain rejected.

No legal interpretation is selected; no clinician's findings are manufactured;
no clinical fact is upgraded by a source statement. Existing qualification and
review drafts retain their own professional gates. Embedded records and
credentials still require external authentication. Disclosure is not authorized,
and adjudication remains undetermined. The workbench never computes an award.

The fixtures are invented and do not transcribe a real medical report. Private
medical records and derived case datasets must remain outside this repository.

Remaining work includes corpus-wide normalization and semantic coverage,
version/transitional review, immutable private storage, richer typed assessment
links, missing-evidence queries, interpretation scenarios and a user interface.
Neither semantic completeness nor production case ingestion is claimed.

## Reproduce

With CUE 0.16.1 and `scripts/requirements-ivac-regulatory.txt` installed:

```bash
python3 scripts/generate_ivac_workbench_types.py --check
python3 scripts/test_ivac_workbench.py
bash scripts/validate-ivac-regulatory.sh
bash scripts/validate-contracts.sh
bash scripts/validate-ivac-regulatory-integration.sh
```

To validate an assembled workbench without external byte verification:

```bash
cue vet -c ./contracts/personal/ivac/workbench \
  personal/ivac/workbench/synthetic-workbench.json -d '#RegulatoryWorkbench'
```

Structural validation is one gate; use `ivac_workbench.project()` with explicit
`evidence_paths`, `anchor_text_paths` and `corpus_paths` for verified projection.
