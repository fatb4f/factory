# epistemic-plant-bootstrap upstream impact

## Run identity

Run `20261127T153503Z` • terminal_success • executable_validated • authority `b5aef69c512e17d111a496ded80b1a8a32ce7e39` • subject `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`.

## Subject authority

The subject pins GUAC v1.1.0, Gemara v1.4.1, CUE v0.17.1, Go 1.25.0 and uv 0.12.0. The subject revision and all five pin revisions match the September sealed run.

## Source state

September 14 baseline 20260914T123208Z. 11 source channels resolved. Channels added since that baseline are marked individually. GitHub may cap changed-file lists at 300. Range totals describe commit-graph distance, not severity.

| Source and channel | Observed commit | Comparison with September 14 |
| --- | --- | --- |
| guac / pinned | [a399a54801bfbffc36bc8748dd97d2d2b3bea378](https://github.com/guacsec/guac/commit/a399a54801bfbffc36bc8748dd97d2d2b3bea378) | Unchanged |
| guac / main | [e130b879490cc7ba2e606e7f894df8b891f92c7b](https://github.com/guacsec/guac/commit/e130b879490cc7ba2e606e7f894df8b891f92c7b) | 83 commits ahead |
| gemara / pinned | [4822ce0071b1f2ff478f8a9eece35c4636ba0c0b](https://github.com/gemaraproj/gemara/commit/4822ce0071b1f2ff478f8a9eece35c4636ba0c0b) | Unchanged |
| gemara / main | [8c36799b5ee1d8b1ed388be9ac8f16cef81f5beb](https://github.com/gemaraproj/gemara/commit/8c36799b5ee1d8b1ed388be9ac8f16cef81f5beb) | 65 commits ahead |
| cue / pinned | [fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3](https://github.com/cue-lang/cue/commit/fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3) | Unchanged |
| cue / master | [407453d39d80c630c0a5dbe55d58db2d64b3a863](https://github.com/cue-lang/cue/commit/407453d39d80c630c0a5dbe55d58db2d64b3a863) | 1468 commits ahead |
| cyclonedx / master | [5fee6af48d43c751dc6a5b31138f06af2b10bac5](https://github.com/CycloneDX/specification/commit/5fee6af48d43c751dc6a5b31138f06af2b10bac5) | 29 commits ahead |
| golang / pinned | [6e676ab2b809d46623acb5988248d95d1eb7939c](https://github.com/golang/go/commit/6e676ab2b809d46623acb5988248d95d1eb7939c) | Unchanged |
| golang / master | [8b3939d32aaf5e27293155e7d817c29ce5109a13](https://github.com/golang/go/commit/8b3939d32aaf5e27293155e7d817c29ce5109a13) | 1635 commits ahead |
| uv / pinned | [b88d7c5c46cbe3c9896544f10255f85a8f0a8a5e](https://github.com/astral-sh/uv/commit/b88d7c5c46cbe3c9896544f10255f85a8f0a8a5e) | Unchanged |
| uv / main | [9bf01bef71c76643290ca17635970076fab1bd0d](https://github.com/astral-sh/uv/commit/9bf01bef71c76643290ca17635970076fab1bd0d) | 1004 commits ahead |

## Authority separation

Pinned fixture bytes provide the source oracle, GUAC observes candidates, Python proposes, and CUE verifies source closure. Operational failures yield an inconclusive result.

## Dependency and admission graph

Pinned sources → GUAC candidate query → coordinate normalization → graph generation → proposal → CUE qualification → receipt → observation. Forecast migration also requires deterministic results across two fresh generations.

## Correlation lineage

Digest-qualified source declarations join with normalized package coordinates. Receipt and observation digests preserve lineage. Backend identifiers, ordering, ports and timestamps are volatile.

## Critical

**GUAC changed the query used to collect dependency candidates.** The 83-commit comparison touches the keyvalue implementation and GraphQL resolver for IsDependency. Before promoting the GUAC pin, replay queries, normalization and two independent graph generations over the pinned corpus.

**Gemara changed the evidence vocabulary and validation examples.** The 65-commit comparison changes evidence.cue and fixtures for missing or reused evidence identifiers. Keep the v1.4.1 vocabulary pinned until local outcome and evidence-receipt fixtures qualify under the new schema.

**CUE changed required-field subsumption.** The forecast evaluator rejects a required field that is absent on the subsumed value. The active v0.17.1 revision is unchanged. Run the declared positive and adversarial source-closure and receipt checks before migrating the evaluator.

## High

No separately classified item.

## Notes

No separately classified item.

## No local action

No separately classified item.

## Executable validation

The existing [qualify job](https://github.com/fatb4f/epistemic-plant-bootstrap/actions/runs/31395890416/job/93478571495) for this exact subject commit and unchanged pins records successful locked sync and just qualify. This monitor reused that execution. Forecast migrations have no qualifying replay. Archived job logs returned HTTP 410, so the current check establishes recorded step and job conclusions. It does not independently recover a hypothesis verdict.

## Publication

Immutable directory `projects/epistemic-plant-bootstrap/upstream-monitor/runs/20261127T153503Z/`, containing report.md, summary.md, evidence.json and manifest.json. The latest.json publication revision identifies the manifest seal.
