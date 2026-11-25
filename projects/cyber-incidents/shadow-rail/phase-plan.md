# Shadow Rail and shared transforms implementation plan

This is an engineering plan, not authority to admit evidence, assert attribution, or activate collection. The owning CUE contracts govern those decisions.

| Track | Gate | Exit condition |
| --- | --- | --- |
| Phase 3A | Review and integrate [#274](https://github.com/fatb4f/factory/pull/274). | Source-qualified Shadow Galaxy vocabulary is on main, with mapping gaps and no inferred affiliation. |
| Phase 3B | Retarget [#275](https://github.com/fatb4f/factory/pull/275) to main after 3A, verify the adapter-only diff and check the refreshed head. | Deterministic MISP projection is qualified against pinned schemas with stable UUIDs and explicit loss. This is not MISP server certification. |
| Plan | Publish this plan to main after Phase 3. | Main contains the plan and exit conditions for both fronts. |
| Domain / Phase 4 | Begin after the plan lands. | A versioned bitemporal Shadow Graph contract passes fixtures for identity, valid time versus knowledge time, evidence links, cross-rail reconciliation, and attribution boundaries. |
| Infrastructure / T0–T1 | Begin alongside Phase 4. | T0 defines native object boundaries and the typed transform interface. T1 qualifies pinned upstream libraries with executable acceptance cases. |
| Independent CI | Continue [#278](https://github.com/fatb4f/factory/pull/278), tracked by [#276](https://github.com/fatb4f/factory/issues/276). | Project-only and shared dependency changes exercise the correct validators without weakening required checks. |
| Independent BigQuery | Unblock [#277](https://github.com/fatb4f/factory/issues/277) with a configured billing project and an authorized read-only identity. | Each resource has dated qualification or an explicit gap. Live checks verify permissions, location, schema and partitioning, and bounded queries produce digest-addressed captures with provenance. |

## Domain semantics

Start with immutable relationship revisions and two separate clocks. Valid time
describes when a claim applies, while knowledge time describes when that revision
was available. Replay takes both cutoffs and must never see a later correction.
Keep support, contradiction and reconciliation distinct. Reconciliation links
source-qualified references without merging identities or upgrading claims into
facts. Preserve disputes and alternatives. Attribution remains a separate
admission decision and cannot be inferred from a relationship or similarity.
[Shadow Rail World](world/README.md) supplies vocabulary, not evidence.

## Shared infrastructure

Extend the existing [CUE-to-native binding bridge](../../../docs/architecture/python-native-bindings.md).
Keep CUE as semantic authority, native objects as typed runtime representations,
and Pydantic as a wire boundary. Define typed input, output, provenance and failure
behavior without coupling the interface to Ibis, a storage engine or the UI.
Qualify declaration evidence and runtime behavior separately against exact
upstream versions. Start Ibis execution with deterministic backend fixtures and
add graph enrichment as a downstream transform that preserves provenance and
does not admit new facts.

## Incident Desk convergence

Integrate only after a stable, versioned typed transform interface can supply
validated, replayable graph projections and explicit losses. Incident Desk
consumes those outputs without reconstructing graph semantics. Defer frontend
development until that interface stabilizes.
