# industrial-signals execution procedure

Semantic authority is `contracts/world/industrial-signals/`. This procedure implements the currently selected `event-watch` phase.

The exhaustive monitored-source registry is `contracts/world/industrial-signals/sources.cue`. Source/channel additions or removals belong in that contract first; documentation and execution surfaces project from it.

## Purpose

Track the evolving industrial ecosystem: actors, facilities, projects, technologies, capacity, industrial responses, innovation adoption, public support, project progress and observed outcomes. The monitor is actor- and trajectory-oriented. It does not qualify shortages, financial attractiveness, cross-domain resource contention or Factory POC decisions.

## Source control

A bounded run selects the source channels applicable to its industrial surfaces and hypotheses from `industrialSources` in `sources.cue`.

The registry distinguishes:

- discovery-only surfaces such as GDELT and OpenAlex from source-qualified evidence candidates;
- acquisition providers from evidence sources — for example, Google BigQuery is the provider for GDELT events and also exposes the separately contracted Google Patents public dataset;
- primary records, measurements, asserted events, identity support, funding-accountability evidence, follow-through evidence and access-recovery surfaces;
- source identity/revision/cursor semantics from the mechanism used to acquire a record.

A source being listed does not require every channel to be queried on every run. When a channel is applicable but unavailable, inaccessible, machine-unreadable or missing expected follow-through, preserve a typed acquisition/coverage outcome rather than silently omitting it.

## Event-watch procedure

1. Select applicable source channels from `contracts/world/industrial-signals/sources.cue`. Prefer primary industrial and institutional records where available; discovery-only channels identify candidates that require stronger evidence before admission.
2. Acquire bounded, source-qualified records. Current execution may be manual or agent-assisted using browser, HTTP, API, bulk download, BigQuery, released-record packages or request-based access as permitted by the source contract.
3. Preserve acquisition outcome separately from industrial event semantics. When represented, `#IndustrialAcquisitionAttempt` records source, channel, acquisition mode, outcome and acquisition time; acquired observations preserve source/channel/record/revision/observed-surface provenance independently.
4. Preserve source, channel, source-record identity, revision/publication identity, observed surface and acquisition time. Do not collapse records because actor names or channel names appear equivalent.
5. Record actor labels as observed parties during `event-watch`; do not manufacture canonical identity or cross-source equivalence before the industrial-graph phase.
6. Classify observations as signal, action, funding-award, funding-flow, project-milestone, innovation-exposure or outcome using the contract vocabulary.
7. Treat subsidy/public-support stages independently:
   - award or announcement is not a disbursement;
   - disbursement is not recipient expenditure;
   - recipient-reported expenditure is not audited expenditure;
   - expenditure is not project progress;
   - project progress is not an industrial outcome.
8. For subsidized actors, actively seek follow-through after awards: disbursement records, procurement/capital spending, construction/equipment milestones, hiring/qualification milestones, commissioning, production and measurable outcomes. Record missing follow-through as typed coverage gaps, never as inferred non-performance.
9. Do not infer that an industrial action was caused by a prior signal. Response causality remains a `ResponseHypothesis` until the industrial-graph phase admits it with explicit evidence.
10. Track engineering-to-industry translation only as observed adoption state. A source stating that an actor is evaluating, piloting, qualifying, deploying or scaling a technology is evidence of that state, not proof of technical success.
11. Prefer longitudinal updates that change an actor/project trajectory over repetitive announcements with no new state.
12. Write admitted runs under `world/industrial-signals/runs/<run-id>/manifest.json` conforming to `#RunManifest`.

Return `events_observed`, `no_material_events`, or `source_gap` exactly as contracted.

## Source-specific boundaries

- GDELT (`gdelt-bq.gdeltv2.events`) is discovery-only. It may identify candidate industrial events but does not substitute for primary evidence.
- Google BigQuery is an acquisition provider for GDELT and a contracted source surface for Google Patents (`patents-public-data.patents.publications`). BigQuery execution does not change evidence authority.
- OpenAlex is discovery/identity support; ROR is organization identity support. Neither creates canonical industrial identity by itself.
- ATI/ATIP request summaries are discovery/access-recovery surfaces. Released packages or targeted-request records must retain institution/package provenance and still undergo normal industrial admission.
- Generic institutional, operator/supplier/customer, regulatory, permit and standards channels remain source-qualified observations. Publisher assertions do not become downstream outcome or causal claims merely by acquisition.

## Fail-closed boundaries

Current `event-watch` output may establish only that source-qualified industrial observations were acquired and classified. It may not publish canonical industrial graph edges, admitted response causality, funding-accountability judgments, binding choke points, financial opportunity claims, resource-allocation conjunctions or POC decisions.
