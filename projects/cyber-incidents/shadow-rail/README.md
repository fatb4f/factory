# Shadow Rail

A research and source-registry scaffold for strategic analysis alongside cyber incident reporting and technical evidence. Candidate explanations remain hypotheses, not established attribution. This is a proposed project surface; it does not activate monitoring, import data, admit evidence, or implement an analytical graph.

The separate [cyber-incidents starter contracts](https://github.com/fatb4f/factory/pull/259) are under review. If integrated, they own incident and replay semantics; a future integration must explicitly connect to those contracts rather than duplicate them here.

- [Architecture](architecture.md)
- Research: [ecosystem](research/ecosystem-review.md), [ontologies](research/intelligence-ontologies.md), [attribution](research/attribution-frameworks.md)
- Upstream: [source registry](upstream/registry.cue), [BigQuery resources and policy](upstream/bigquery.cue), [licensing](upstream/licensing.md)
- Canonical vocabulary and CCO crosswalk: [Shadow Rail World](world/README.md)
- Reserved surfaces: `galaxy`, `graph`, `flows`, `playbooks`, `projections`, `evaluation`. Their READMEs describe intended boundaries, not implemented capabilities.

Validate the registry with `cue vet -c ./projects/cyber-incidents/shadow-rail/upstream` and the ontology with `bash projects/cyber-incidents/shadow-rail/world/validate.sh`. Live BigQuery permissions, table schemas, adapters and query enforcement have not been tested.
