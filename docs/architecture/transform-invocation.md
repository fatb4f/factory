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

### Run the graphical pilot

The owner workspace in the separately maintained Review Desk Site exposes **Legal relationship pilot** when its executor is available. The pilot binds the public schedule's leaf 4.1 to the invented initial snapshot. Its inputs are independent of the private evidence selected elsewhere in the Desk. **Find linked records** shows each authorized relationship, its evidence excerpt and exact offsets, and the supporting schedule passages. **Copy invocation ID** supplies a reference suitable for tracking.

For a local run use CUE 0.16.1, Python 3.12, the pinned dependencies and the pilot extension. The reviewed installed-entry identity for the extension in this PR is `sha256:ed080412e6d3b96bb9c5214d7d392aa46c30a257d708fccc54a57978df1cb833`. This identifies the navigation extension. The Core candidate has a separate wheel digest.

From the Factory root in a virtual environment, run these commands in a shell with an owner-private state directory. The generated token is ephemeral and scoped to the loopback rehearsal.

```sh
python3 -m pip install -r scripts/requirements-ivac-regulatory.txt ./extensions/review-desk-navigation
export FACTORY_REVIEW_TOKEN="$(python3 -c 'import secrets; print(secrets.token_hex(32))')"
export FACTORY_REVIEW_URL=http://127.0.0.1:8765/api/review-desk/action
review_state="$(mktemp -d)"
PYTHONPATH=. python3 scripts/ivac_review_desk.py --history "$review_state/history.sqlite" \
  --version 0.1.0 --approved-digest sha256:ed080412e6d3b96bb9c5214d7d392aa46c30a257d708fccc54a57978df1cb833 &
```

In the same shell, switch to the actual Review Desk Site source checkout, build the Worker with `npm run build`, and run `npm run dev -- --port 3000`. Open `http://127.0.0.1:3000`. Keep the history path to exercise a service restart. The hosted Worker uses the same action after its authenticated owner guard. To enable it, configure a private HTTPS action URL in `FACTORY_REVIEW_URL` and matching service credentials in `FACTORY_REVIEW_TOKEN` on both sides. Keep the Python service behind TLS and the database in private persistent storage. Guest and import credentials have no access to this action.

### History and feedback

Supply a trusted `caller_id` and `history_path` when constructing `ReviewDeskTransforms` for durable SQLite history. Omitting the path keeps the existing in-memory session behavior. Receipts are validated before they are saved. Fully bound execution and output-validation failures produce a failed receipt with no semantic output. A request rejected before its execution context is established has no invocation receipt.

`list_receipts()` and `get_receipt(id)` check the caller, snapshot and current scope. `replay(id)` uses the recorded inputs and exact approved extension identity, and checks that the semantic digest matches. `replay(id, candidate_version=...)` evaluates an explicitly enabled candidate against the same historical scope. A wider current grant does not widen the replay. A withdrawn grant prevents access. The executing Core rejects declared losses that this pilot receipt cannot represent.

In the Desk, choose **Run earlier test version** to reproduce the seeded omission. Record feedback on that invocation, then choose **Verify correction** in the history panel. The private record retains the original ID, both comparison IDs and both semantic digests. **Inspect candidate result** opens the candidate output and its sources. A reviewer determines whether the change addresses the report. Use only the copyable invocation ID in public issue tracking.

The checked-in service tests run with `PYTHONPATH=. python3 scripts/test_ivac_review_desk.py`. The Site checkout includes a restart and authorization exercise against the built Worker:

```sh
node scripts/qualify-pilot.mjs /absolute/path/to/factory sha256:ed080412e6d3b96bb9c5214d7d392aa46c30a257d708fccc54a57978df1cb833
```
