# IVAC project dispatcher

Use this entry point for IVAC work, including work in `contracts/personal/ivac/`
and `scripts/ivac_*`. This file is procedural routing, not a new semantic authority.
The repository root `AGENTS.md` and issue-tracking procedure continue to apply.

## Resolve current state

Inspect the current branch, commit, working tree and relevant GitHub PR/issue
state before modifying code. Preserve unrelated changes and work on the existing
implementation branch when the task targets it. Do not assume remembered commit
IDs, PR status, coverage counts or private artifact versions are current.

Read the narrow CUE authority and corresponding implementation before extending
it. Reuse established Factory projection patterns. Track durable engineering work
by `factory-issue-key` under `contracts/state/tracker.cue` and
`.github/ISSUES/AGENTS.md`; do not silently expand another issue's acceptance.

## Route by task

Paths below are relative to the repository root.

| Task | Authority and implementation entry points |
| --- | --- |
| Case graph and clinical evidence | `contracts/personal/ivac/graph.cue`, `contracts/personal/ivac/clinical.cue` |
| Regulatory source, compendium and qualification | `contracts/personal/ivac/`, `contracts/personal/ivac/evaluations/regulatory.cue`, `scripts/ivac_regulatory.py`, `scripts/ivac_regulatory_sources.py` |
| Official bulk acquisition and integrity | `scripts/ivac_regulatory_bulk.py`, `personal/ivac/docs/regulatory-milestone-2.md` |
| Private documentary snapshots | `contracts/personal/ivac/workbench/model.cue`, `contracts/personal/ivac/workbench/projections.cue`, `scripts/ivac_workbench.py`, `personal/ivac/docs/regulatory-workbench.md` |
| Interpretation and professional review | `contracts/personal/ivac/evaluations/medico_legal_review.cue`, `personal/ivac/docs/medico-legal-review.md`, `personal/ivac/docs/regulatory-semantic-specification.md` |
| Analytical execution | `personal/ivac/docs/evaluation-and-ibis.md`, `runtime/ibis_adapter.py`, `contracts/state/` |

For timeline acquisition and ingestion, first check whether the current ref has
`contracts/personal/ivac/workbench/timeline.cue`, `scripts/ivac_timeline.py` and
`personal/ivac/docs/timeline-ingestion.md`. If absent, inspect the relevant open PR
and report the capability as unavailable on the checked ref. Do not replace it
with a competing implementation or assume an unmerged adapter is on main.

## Preserve authority boundaries

Use CUE as semantic authority. Reuse the existing generation pipeline for
JSON Schema and Pydantic v2 types; use `factory.analytics-ir/v1` and the existing
Ibis lowering for relational execution. DuckDB is the local backend; other
backends remain optional where implemented. Generated models, Arrow schemas,
SQL tables and query results remain projections. Validate complete canonical
inputs through CUE, including constraints not expressible in generated types.

Distinguish acquired bytes, extraction candidates, reviewed regulatory records,
attributed document statements, qualified clinical findings, legal selections and
adjudicated outcomes. No downstream tool may invent legal or clinical semantics.
Keep unknown distinct from zero and retain exact decimal percentages.

## Private evidence and continuity

Keep identifiable medical records, derived case JSON, databases, text and images
outside Git. Public fixtures must be invented. Do not place private case facts,
amounts, personal identifiers, private artifact IDs or runtime paths in repository
instructions or public tracker issues.

Resolve the relevant versioned private artifact using the user's authorized
source location; verify original and pinned text digests and exact citation
offsets through existing adapters. Missing sources are explicit gaps. Successful
hashing does not establish OCR accuracy or semantic review.

Keep the original filing, supporting treating report, internal medical opinion,
formal decision and revised-claim hypotheses distinct. Never relabel a treating
report as an application or an internal recommendation as a formal decision.
Preserve authored, submitted, received, communicated and retrieval dates
separately. Record a baseline snapshot before supplements/reassessments; do not
overwrite historical evidence to reflect a later interpretation.

Retain competing readings, contrary evidence, baseline uncertainties and overlap
controls. Source statements do not automatically establish causation, permanence,
legal applicability, criterion satisfaction or entitlement. Keep professional
qualification and legal selection gates explicit. No automatic award inference.

## Validate and report

For contract or adapter changes, run the affected focused checks and the required
repository suites as documented in the owning implementation:

```bash
bash scripts/validate-ivac-regulatory.sh
bash scripts/validate-contracts.sh
bash scripts/validate-ivac-regulatory-integration.sh
```

For documentation-only changes, check referenced repository paths and the diff;
do not report runtime suites as passed unless actually run. For private snapshot
generation, use CUE validation and the existing verified projection adapter;
structural validation alone is insufficient.

Report the repository commit/ref and private evidence version used, validation
actually performed, and implemented/partial/blocked status. Identify remaining
source, semantic coverage and professional-review gaps. Repository instructions
do not imply deployment, PR merge, source acquisition or clinical/legal review.
