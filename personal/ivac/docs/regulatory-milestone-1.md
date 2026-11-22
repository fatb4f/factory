# IVAC regulatory evidence — Milestone 1

The additive `personal.ivac.regulatory@1.0.0` surface extends IVAC v0.4.0. CUE is semantic authority. This milestone delivers regulatory contracts, source discovery, a pinned extraction/verifier adapter, and synthetic qualification tests. It does **not** publish an admitted transcription of the Québec compendium.

## Official source and versions

The relevant instrument is the **Règlement d’application de la Loi visant à aider les personnes victimes d’infractions criminelles et à favoriser leur rétablissement**, **P-9.2.1, r. 1**, **Annexe I**, “Répertoire des séquelles permanentes d’ordre fonctionnel ou esthétique”, under P-9.2.1. The annex names articles 18, 24 and 26. Read the chapter III evaluation provisions, including article 23 on permanence, alongside the schedule. Original decree: D. 1266-2021.

Official discovery references, inspected 2026-10-16 UTC:

- [Initial consolidation, 2021-10-13](https://www.legisquebec.gouv.qc.ca/fr/document/rc/P-9.2.1%2C%20r.%201/20211013).
- [Annex provision history](https://www.legisquebec.gouv.qc.ca/fr/version/rc/P-9.2.1%2C%20r.%201?code=sc-nb%3A1&historique=20241028), which displays commencement on 2021-10-13.
- [Current consolidated instrument](https://www.legisquebec.gouv.qc.ca/fr/document/rc/P-9.2.1%2C%20r.%201), whose retrieved search representation displayed “À jour au 1er janvier 2026”. This is an observed consolidation date, not proof of completeness through October 2026.
- [Enabling Act and transitional rules](https://www.legisquebec.gouv.qc.ca/fr/document/lc/P-9.2.1), particularly articles 179–184 when determining treatment of older files.

`regulatory_sources.cue` records discovery metadata, not admitted source bytes. Direct HTML and PDF acquisition returned HTTP 502 in this execution environment. No invented official digest, missing historical version, or inferred repeal date is recorded. The observed history identifies the annex's initial effective date; a full amendment-history audit and official snapshot acquisition remain necessary before production ingestion. Do not substitute the similarly worded automobile-insurance schedule A-25, r. 10 or an old-regime impairment schedule for this instrument.

Three independent times are retained:

1. `consolidatedAsOf`: the publisher's consolidation date;
2. `effective`: provision applicability interval, inclusive `from`, exclusive `until`, with explicit `open`, `bounded`, or `unknown` end;
3. `retrievedAt`: acquisition time of the pinned representation.

A qualification also records a legal selector's `asOf` and rationale. The incident, application or decision date alone does not select a regime. Transitional applicability requires legal review. Source IDs must be immutable and version-specific; repeated acquisitions with different bytes receive different IDs, even if their consolidation dates agree. New compendia are separate values with references scoped to their own source version.

## Functional structure

The annex has 24 numbered functional headings containing **40 functional units**, followed by heading 25 containing **8 aesthetic units**. Group headings must not be counted as additional independently rated units. This count is derived from the official annex contents; it does not claim completed transcription.

| Heading | Functional domain | Independently rated unit numbers |
|---|---|---|
| 1 | Psychique | 1 |
| 2 | Conscience | 2 |
| 3 | Aspect cognitif du langage | 3 |
| 4 | Appareil visuel | 4.1–4.2 |
| 5 | Appareil auditif | 5.1–5.2 |
| 6 | Goût et odorat | 6 |
| 7 | Sensibilité cutanée | 7.1–7.7 |
| 8 | Troubles de l’équilibre | 8 |
| 9 | Phonation | 9 |
| 10 | Mimique | 10 |
| 11 | Déplacement et maintien de la tête | 11 |
| 12 | Déplacement et maintien du tronc | 12 |
| 13 | Déplacement et maintien du membre supérieur | 13.1–13.2 |
| 14 | Dextérité manuelle | 14.1–14.2 |
| 15 | Locomotion | 15 |
| 16 | Protection assurée par le crâne | 16 |
| 17 | Protection par la cage thoracique et la paroi abdominale | 17 |
| 18 | Respiration rhino-pharyngée | 18 |
| 19 | Fonctions digestives | 19.1–19.4 |
| 20 | Fonction cardio-respiratoire | 20 |
| 21 | Fonctions urinaires | 21.1–21.2 |
| 22 | Fonctions génito-sexuelles | 22.1–22.3 |
| 23 | Fonctions endocrinienne, hématologique, immunitaire et métabolique | 23 |
| 24 | Paraplégie et tétraplégie | 24 |
| 25 | Esthétique | 25.1–25.8 (aesthetic) |

This table is a discovery index. The future transcription retains exact French labels and spelling in cited text rather than treating these abbreviated labels as quotations.

## Contract design

- `#RegulatorySourceVersion` binds instrument, jurisdiction, language, publisher, URL, dates, exact snapshot digest and original artifact digest. The snapshot is UTF-8 plain text; the original artifact and conversion command/version are separately retained. Calendar dates and RFC3339 acquisition timestamps are validated by CUE.
- `#RegulatoryCitation` binds a source version and legal locator to exact text and half-open Unicode code-point offsets in the pinned snapshot. No Unicode normalization, newline conversion or whitespace cleanup occurs in the span adapter.
- `#RegulatoryUnit` identifies a leaf unit and optional parent number, retains evaluation rules, and owns severity classes. A group heading is represented through child `parentNumber` values rather than a second rated unit.
- `#RegulatorySeverityClass` retains cited source text and a discriminated fixed/range/not-specified percentage. “Not specified” is not zero. Percentages are schedule values; aggregation, bilateral formulae and monetary awards are not implemented here.
- Each class has `any-of` alternative paths; every path has `all-of` criteria with separately cited text. Original compound prose may remain a single criterion until a reviewer explicitly decomposes it. Empty alternatives and duplicate path/criterion identities are rejected. Rules, exclusions, comparability and exceptions must remain visible in the retained citations; this limited normal form is not an automatic statute interpreter.
- `#RegulatoryCompendium` enforces map-key identity and same-version citations. Coverage is explicitly partial or complete; “complete” is a reviewer assertion and requires a separate transcription audit. A reviewed state records a reviewer and rationale, not a governmental legal certification.
- `#RegulatoryQualification` is a companion to the existing permanent-sequela evaluation instance. Its criterion assessments reuse IVAC observation, finding, evidence, actor and assessment-disposition types. It resolves every supplied reference using explicit nonempty matches.

## Reproducible pipeline

Use CUE v0.16.1 and Python 3. No Python domain model or package installation is required.

1. Acquire an official HTML/PDF artifact and preserve its original bytes. Record SHA-256, official URL, publisher, consolidation date, provision interval and acquisition timestamp in a source-version record. For PDF/HTML, retain the exact conversion command and tool version plus resulting UTF-8 bytes. Conversion is currently operator-controlled; OCR/table reconstruction is not implemented.
2. Create a reviewed span plan with locator, `start`, `end` and `exactText`. The adapter verifies the supplied offsets instead of searching for an ambiguous matching occurrence.
3. Run `extract`. Both source/origin digests must match; source and output shapes are validated through CUE. Output has fixed `candidate` status and deterministic sorted JSON. No clock, network request or random identifier enters extraction.
4. A reviewer maps candidate excerpts into units, rules, classes and qualifying paths, preserving exact citations. Set partial coverage until a completeness audit succeeds. Record reviewer/rationale separately from extraction. An extraction success cannot itself set review state.
5. Run `verify` on the resulting compendium. It checks CUE integrity, both digests, every citation's version, bounds and exact source slice. CUE cannot read artifact bytes; this verifier is a required provenance check before admission/use, not a substitute for legal review.
6. Bind a private admitted case and an explicit evaluation instance to the qualification companion. Validate it with CUE. Keep all identifiable case bindings outside this public repository and cloud environment. Public validation exercises only invented regulatory text and existing synthetic IVAC records.

Reproduce the synthetic extraction from repository root:

```sh
python3 scripts/ivac_regulatory.py extract \
  personal/ivac/regulatory/fixtures/source.json \
  personal/ivac/regulatory/fixtures/synthetic.txt \
  personal/ivac/regulatory/fixtures/synthetic.txt \
  --plan personal/ivac/regulatory/fixtures/plan.json > /tmp/ivac-extraction.json

python3 scripts/ivac_regulatory.py verify \
  personal/ivac/regulatory/fixtures/compendium.json \
  personal/ivac/regulatory/fixtures/synthetic.txt \
  personal/ivac/regulatory/fixtures/synthetic.txt

bash scripts/validate-ivac-regulatory.sh
```

The fixture percentage and criteria are deliberately invented and must never be presented as Québec law. `usage: synthetic-test` is incompatible with an official source; `usage: case-assessment` requires an official source. The test runner constructs case bindings from the repository's existing synthetic `mockClinicalCase`, avoiding duplicated clinical fixtures.

The qualification companion can be validated in a private local workspace with `cue vet -c /private/qualification.json contracts/personal/ivac/evaluations/*.cue -d '#RegulatoryQualification'`. That private path is illustrative and must never be populated with identifiable records in this cloud environment.

## Permanent-sequela integration

The existing `permanentSequelaContract@1.0.0`, its questions, selectors, edge transforms, logical indices and `#AssessmentBundle` remain unchanged. The companion binds the same instance evaluator/profile and an admitted claim axis, plus a source-versioned unit/class/alternative. It neither writes into the evidence world nor changes the recognized decision state.

Criterion support requires an explicit evaluator assessment with at least one admitted finding and evidence artifact. Observations may be linked for traceability, but observation presence, diagnosis, keyword match or graph traversal never creates support. This is a structural qualification gate, not proof that the evaluator's medical or legal reasoning is correct.

`insufficient-evidence` requires an explicit missing-evidence item. An incomplete qualification requires at least one explicit `coverageGaps` item, including when no criteria have yet been assessed. Causation retains unresolved/supported/contradicted state; supported causation must reference an admitted causal/aggravation opinion on the selected axis. Applicability selection must name an existing legal representative and fit the source interval. A `qualified-candidate` requires a reviewed compendium, selected applicability, supported causation and supported assessments for **all criteria in one selected alternative**. Unassessed alternative paths do not count against that path. Incomplete assessments remain usable without manufacturing a negative finding.

A qualified candidate is only a criterion-path candidate: it does not certify every global evaluation rule, permanence, stabilization, the highest comparable class, independent-unit treatment or an award. Those remain explicit questions in the existing evaluation and later legal/adjudicative steps. `adjudication` is fixed to `not-determined`.

## Downstream projection extensions

Follow the existing `cue → json-schema → pydantic → relational → ibis` convention. No generated Python schema or hand-written Pydantic authority is introduced by this milestone.

| CUE authority | JSON Schema extension | Pydantic v2 / relational projection |
|---|---|---|
| Source version and interval | Immutable version ID, digest pattern, date formats, explicit interval-end variants | Generated frozen source value; preserve unknown end distinctly from absent/false; version ID keys all joins |
| Citation | Required locator/version/exact-text/offsets | Generated citation value; link table with sourceVersionID and text offsets; byte verification remains adapter work |
| Unit and class | Closed objects and map schemas; percentage discriminated union | `extra='forbid'`, generated fixed/range/not-specified variants; Decimal for percentage fidelity |
| Alternatives and criteria | Explicit any-of/all-of operator fields, nonempty arrays | Child rows keyed by version/unit/class/path/criterion; preserve ordering and all alternative paths |
| Extraction and review | Fixed candidate status, adapter version, reviewer/rationale | Separate acquisition/extraction/review rows; never map extraction to admission automatically |
| Criterion assessment | Existing disposition enum, conditional findings/evidence/gap requirements | Generated references and child link/gap rows; no observation-to-support coercion |
| Qualification companion | Existing evaluation-instance reference, explicit applicability/causation/status | Separate evaluation-owned assessment projection; no update of canonical clinical or adjudicative rows |

Generated schemas will not necessarily express CUE cross-record existence proofs, actor constraints, date comparisons, duplicate identities or all conditional path-completeness rules. A generator must report those losses; retain CUE validation before admission and round-trip every generated instance through CUE. Optional fields, explicit unknown states, empty evidence arrays and zero percentages must remain distinguishable. Pydantic validators may enforce projected checks but cannot introduce new authority.

Future Ibis views join version-scoped source/unit/class/path/criterion rows to explicit assessment and evidence links. Anti-joins can expose missing evidence/criteria, without interpreting missing rows as false. Existing graph-edge transforms remain clinical projections; do not manufacture clinical causal edges from regulatory paths. Production row schemas, JSON Schema/Pydantic generation and Ibis adapters are follow-up work.

## Remaining work

Acquire and pin official initial/current artifacts; audit amendments and transitional applicability; transcribe and legally review all 40 functional and 8 aesthetic units with rule/exclusion fidelity; add version-diff and completeness qualification; implement the declared downstream projections and round-trip tests. No production case or award calculation is admitted by this milestone.
