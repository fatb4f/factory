# Factory weekly dispatcher

This surface is a scheduling procedure, not semantic authority. Root `registry.cue` says which tasks are enabled, their cadence, an optional semantic-authority path, and which task-local `AGENTS.md` to follow.

At each dispatcher tick:

1. Read current `registry.cue` from `fatb4f/factory@main`.
2. Evaluate schedule dates in `America/Toronto`.
3. For each enabled task whose `cadence.frequency` is `weekly`, the task is due only when the current local weekday equals `cadence.weekday` and there is no scheduler ledger showing that task already ran on the same local calendar date.
4. For each due task, read its declared `agent` file and execute that task procedure exactly as instructed. When an `authority` path is declared, preserve that task's semantic contract and do not reinterpret it. Task-owned comparison state, run bundles, qualification state, or evidence remain task-local surfaces; the dispatcher neither supplies nor interprets them. When `authority` is absent, do not invent a semantic contract, qualification layer, or publication protocol.
5. After a task finishes, replace its scheduler ledger with task ID, run time, the task-native outcome label, and run ID when available. Remove any cutover-only `seeded_from` field.
6. Continue with other due tasks even when one task reports failure, deferral, coverage gap, `source_gap`, `comparison_gap`, `state_conflict`, or another task-native non-success outcome.
7. Return a compact per-task summary.

An ad-hoc direct invocation of a task is outside dispatcher due selection. When such an invocation is intentionally performed as a real task run, its completed task-native outcome may update the same scheduler ledger; that does not suppress a later scheduled run on a different local calendar date.

A cutover seed ledger may omit `outcome` only when it contains `seeded_from: "legacy-recurring-automation"`. Its sole purpose is to preserve the prior scheduler checkpoint without inventing a task-native result. The next actual dispatcher execution replaces it with a normal ledger entry.

Do not run a CUE CI job, generate due-plan archives, create claim/disposition records, or perform a second dispatcher-level result admission. The dispatcher only decides when to invoke a task and records when it ran.
