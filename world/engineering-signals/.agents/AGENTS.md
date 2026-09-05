# engineering-signals execution procedure

Semantic authority is `contracts/world/engineering-signals/`. This procedure implements the currently selected `event-watch` phase.

## Purpose

Track engineering mechanisms, technologies, experiments, standards, patents, prototypes, test results and industrially relevant failure analysis that may change what is technically feasible. The monitor exists to support engineering-to-industry translation and POC discovery; it is not a generic science-news feed.

## Event-watch procedure

1. Acquire bounded, source-qualified records from primary technical sources where possible: papers, standards bodies, patents, laboratories, vendors, engineering organizations and primary test/publication surfaces.
2. Classify only against the contract's engineering surfaces.
3. Preserve source, channel, source-record identity, revision/publication identity and acquisition time.
4. Record claimed performance changes as observations, not established facts, unless the source itself provides the relevant measurement and provenance.
5. Prefer events that expose a new mechanism, meaningful performance boundary, manufacturability change, scaling result, failure mode, substitution path or integration technique.
6. Mark `poc-candidate` only as a watch disposition. It does not admit a Factory POC.
7. Do not create industrial graph edges, economic claims or POC decisions during this phase.
8. Write admitted runs under `world/engineering-signals/runs/<run-id>/manifest.json` conforming to `#RunManifest`.

Return `events_observed`, `no_material_events`, or `source_gap` exactly as contracted.
