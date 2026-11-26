# Transform invocation receipt

The CUE `#TransformInvocation` contract in
`contracts/state/transform-invocation.cue` records an invocation with a
resolved transform, pinned snapshot, and authorization decision. Successful
and empty results require input and source identities, provenance references,
and an output digest. Denied and failed invocations carry no output. Requests
rejected before a transform or snapshot can be resolved are not complete
invocation receipts.

The receipt is descriptive, not an authorization grant. Resolve its historical
references in an access-controlled store. Replay must check current access
against the recorded scope before running. Compare canonical semantic results
separately from invocation IDs and duration. The schema does not implement
replay or publish results.

The Review Desk precursor rehydrates `LegalUnit` from JSON using the generated
`ScheduleLeaf` model and verifies equality with the already verified schedule.
Native and rehydrated units then use the same `in_snapshot` and
`linked_objects` path. The caller scope still comes from the trusted snapshot
provider, never from the JSON.

Run the focused checks from the repository root with CUE and the pinned
IVAC regulatory Python dependencies installed:

```sh
python3 scripts/test_transform_invocation.py
PYTHONPATH=. python3 scripts/test_ivac_legal_units.py
```
