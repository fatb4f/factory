# Shadow Galaxy

`galaxy.cue` defines a versioned catalog of source-qualified vocabulary terms, each linked to an SRW concept and an explicitly qualified external alignment or an unmapped reason. Catalog and term IDs are stable identifiers; revisions do not change identity. Sources and external targets are references, not evidence admissions or assertions of equivalence. A term cannot declare an actor affiliation. This contract contains no real-world catalog entries, graph, or attribution findings.

Run `bash projects/cyber-incidents/shadow-rail/galaxy/validate.sh` to validate a synthetic catalog and rejection cases. The validation checks duplicate term IDs in addition to CUE structural constraints. Consumers must enforce uniqueness when accepting catalogs. The separate MISP adapter must define its own mapping, stable UUID algorithm, schema validation, and loss report; this contract does not claim MISP compatibility.
