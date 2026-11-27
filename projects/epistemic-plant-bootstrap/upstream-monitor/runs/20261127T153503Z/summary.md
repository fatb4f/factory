# epistemic-plant-bootstrap monitoring summary

## Run identity

Run `20261127T153503Z` • terminal_success • executable_validated • authority `b5aef69c512e17d111a496ded80b1a8a32ce7e39` • subject `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`.

## Baseline

September 14 baseline 20260914T123208Z. 11 source channels resolved. Channels added since that baseline are marked individually. GitHub may cap changed-file lists at 300. Range totals describe commit-graph distance, not severity. All exact source heads appear in the [source table](report.md#source-state) and [typed evidence](evidence.json).

## Decisions

3 blocking-gate, 0 contract-update, 0 note, 0 none.

- GUAC changed the query used to collect dependency candidates
- Gemara changed the evidence vocabulary and validation examples
- CUE changed required-field subsumption

## Authority separation

Pinned fixture bytes provide the source oracle, GUAC observes candidates, Python proposes, and CUE verifies source closure. Operational failures yield an inconclusive result.

## Qualification state

executable_validated

## Subject executable validation

The existing [qualify job](https://github.com/fatb4f/epistemic-plant-bootstrap/actions/runs/31395890416/job/93478571495) for this exact subject commit and unchanged pins records successful locked sync and just qualify. This monitor reused that execution. Forecast migrations have no qualifying replay. Archived job logs returned HTTP 410, so the current check establishes recorded step and job conclusions. It does not independently recover a hypothesis verdict.

## Bundle

Immutable directory `projects/epistemic-plant-bootstrap/upstream-monitor/runs/20261127T153503Z/`, containing report.md, summary.md, evidence.json and manifest.json. The latest.json publication revision identifies the manifest seal.
