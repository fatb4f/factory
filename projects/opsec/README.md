# Opsec operational contract

The root defines the eight phases of the manual awareness loop in OPSEC CA 001 v1.0. Frame establishes the decision question. Observe is phase 02 and the first phase with a detailed implementation contract.

| Branch | Manual activity | Output |
| --- | --- | --- |
| Wireless capture | `preflight` | Receiver and datasource checks, evidence destination, coverage and release or hold reason |
| Wireless capture | `capture` | Native Kismet artifact and actual coverage interval, or a collection failure record |
| Wireless capture | `register_artifacts` | Manifest with the original file reference, size, SHA-256 and coverage reference |
| Wireless inspection | `project_capture` | Derived relations with source references, filters, counts and exclusions |
| Wireless inspection | `inspect_projection` | Observations and coverage for Reconcile Quality, including unresolved comparisons |

The operator uses Xonsh for manual interaction and Kismet for capture. The contract assigns artifact handling to Python adapters, with CUE-derived Pydantic v2 models at their exchange boundaries. Ibis defines the relational projection, DuckDB executes it, and Marimo supports interactive review. A previously registered capture can enter at `project_capture` when its manifest and digest verify.

## Validate and inspect

From the repository root, run:

```sh
cue vet -c ./projects/opsec
cue export ./projects/opsec -e operation
```

The first command checks the combined CUE package. The second exports the operation, including the branch and leaf order. Each activity starts at `not_evaluated`. A field evaluation requires run-specific evidence, conditions and a result. This revision documents the adapters and their artifact boundaries; executable adapters are separate work.
