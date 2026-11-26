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
IVAC regulatory Python dependencies and the pilot extension installed:

```sh
python3 scripts/test_transform_invocation.py
PYTHONPATH=. python3 scripts/test_ivac_legal_units.py
```

## Review Desk pilot

Install the independently packaged extension next to Factory's runtime and
IVAC scripts. The server-side `ReviewDeskTransforms` adapter binds an already
validated `Snapshot` and the trusted caller-scope provider. For this pilot,
the snapshot's recorded timestamp is the cutoff. Native and JSON calls share
the executor and use the existing Analytics IR and Ibis path.

Discovery reads installed entry-point metadata without importing the module.
An operator enables the exact distribution version and installed-entry digest
from their trusted deployment record. This pilot digest covers distribution
identity, entry-point identity, and installed module bytes, not the Core
package or the full wheel. The installed module and process are trusted.
The extension sees only the already scoped, detached legal relationship
view. There is no untrusted-code isolation in M1.

Use the receipt's invocation ID to reference synthetic pilot feedback without
copying result contents into an issue. In the same caller-bound session,
`replay(id)` reruns the recorded transform against the historical inputs and
checks current authorization first. `replay(id, candidate_version=...)`
allows a new enabled version to be tested against that exact context. Compare
`Execution.semantic_output` or its digest, not the full receipt. This session
keeps successful and empty execution records in memory. Cross-process replay,
a persisted operational attempt log, and a graphical Desk action are not
implemented by this adapter.

The synthetic review case rehearses a reported omission, exact replay,
candidate correction, and permission withdrawal:

```sh
python3 -m pip install -r scripts/requirements-ivac-regulatory.txt ./extensions/review-desk-navigation
PYTHONPATH=. python3 scripts/test_ivac_legal_units.py LegalUnitTests.test_installed_review_extension_and_historical_replay
```
