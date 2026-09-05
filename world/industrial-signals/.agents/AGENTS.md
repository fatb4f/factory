# industrial-signals execution procedure

Semantic authority is `contracts/world/industrial-signals/`. This procedure implements the currently selected `event-watch` phase.

## Purpose

Track the evolving industrial ecosystem: actors, facilities, projects, technologies, capacity, industrial responses, innovation adoption, public support, project progress and observed outcomes. The monitor is actor- and trajectory-oriented. It does not qualify shortages, financial attractiveness, cross-domain resource contention or Factory POC decisions.

## Event-watch procedure

1. Acquire bounded, source-qualified records from primary industrial and institutional surfaces where possible: actor publications, government award/disbursement records, procurement records, regulatory filings, facility/project updates, suppliers, customers, standards participation, permits and other primary operational sources.
2. Preserve source, channel, source-record identity, revision/publication identity, observed surface and acquisition time. Do not collapse records because actor names or channel names appear equivalent.
3. Record actor labels as observed parties during `event-watch`; do not manufacture canonical identity or cross-source equivalence before the industrial-graph phase.
4. Classify observations as signal, action, funding-award, funding-flow, project-milestone, innovation-exposure or outcome using the contract vocabulary.
5. Treat subsidy/public-support stages independently:
   - award or announcement is not a disbursement;
   - disbursement is not recipient expenditure;
   - recipient-reported expenditure is not audited expenditure;
   - expenditure is not project progress;
   - project progress is not an industrial outcome.
6. For subsidized actors, actively seek follow-through after awards: disbursement records, procurement/capital spending, construction/equipment milestones, hiring/qualification milestones, commissioning, production and measurable outcomes. Record missing follow-through as coverage gaps, never as inferred non-performance.
7. Do not infer that an industrial action was caused by a prior signal. Response causality remains a `ResponseHypothesis` until the industrial-graph phase admits it with explicit evidence.
8. Track engineering-to-industry translation only as observed adoption state. A source stating that an actor is evaluating, piloting, qualifying, deploying or scaling a technology is evidence of that state, not proof of technical success.
9. Prefer longitudinal updates that change an actor/project trajectory over repetitive announcements with no new state.
10. Write admitted runs under `world/industrial-signals/runs/<run-id>/manifest.json` conforming to `#RunManifest`.

Return `events_observed`, `no_material_events`, or `source_gap` exactly as contracted.

## Fail-closed boundaries

Current `event-watch` output may establish only that source-qualified industrial observations were acquired and classified. It may not publish canonical industrial graph edges, admitted response causality, funding-accountability judgments, binding choke points, financial opportunity claims, resource-allocation conjunctions or POC decisions.
