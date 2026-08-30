# Factory daily dispatcher

This surface is a scheduling procedure, not semantic authority. Root `registry.cue` says which tasks are enabled, their cadence, an optional semantic-authority path, and which task-local `AGENTS.md` to follow.

At each daily tick:

1. Read current `registry.cue` from `fatb4f/factory@main`.
2. For each enabled task, read `.agents/dispatcher/executions/<task-id>.json` when present.
3. A task is due when it has no ledger entry or when at least `cadence.everyDays` calendar days have elapsed since `last_run_at` in `America/Toronto`.
4. For each due task, read its declared `agent` file and execute that task procedure exactly as instructed. When an `authority` path is declared, preserve that task's semantic contract and do not reinterpret it. Task-owned comparison state, run bundles, qualification state, or evidence remain task-local surfaces; the dispatcher neither supplies nor interprets them. When `authority` is absent, do not invent a semantic contract, qualification layer, or publication protocol.
5. After a task finishes, replace its scheduler ledger with task ID, run time, the task-native outcome label, and run ID when available. Remove any cutover-only `seeded_from` field.
6. Continue with other due tasks even when one task reports failure, deferral, coverage gap, `source_gap`, `comparison_gap`, `state_conflict`, or another task-native non-success outcome.
7. Return a compact per-task summary.

A cutover seed ledger may omit `outcome` only when it contains `seeded_from: "legacy-recurring-automation"`. Its sole purpose is to preserve the prior scheduler checkpoint without inventing a task-native result. The next actual dispatcher execution replaces it with a normal ledger entry.

Do not run a CUE CI job, generate due-plan archives, create claim/disposition records, or perform a second dispatcher-level result admission. The dispatcher only decides when to invoke a task and records when it ran.
