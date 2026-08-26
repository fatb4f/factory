# Factory daily dispatcher

This surface is a scheduling procedure, not semantic authority. Root `registry.cue` says which tasks are enabled, their cadence, their authority path, and which task-local `AGENTS.md` to follow.

At each daily tick:

1. Read current `registry.cue` from `fatb4f/factory@main`.
2. For each enabled task, read `.agents/dispatcher/executions/<task-id>.json` when present.
3. A task is due when it has no ledger entry or when at least `cadence.everyDays` calendar days have elapsed since `last_run_at` in `America/Toronto`.
4. For each due task, read its declared `agent` file and execute that existing task workflow exactly as instructed. The task's own contract remains responsible for authority, evidence, qualification, publication, and terminal state.
5. After the task reaches a terminal state, write or replace its single scheduler ledger file with the task ID, run time, terminal state, and run ID when available.
6. Continue with other due tasks even when one task ends in failure, deferral, or coverage gap.
7. Return a compact per-task summary.

Do not run a CUE CI job, generate due-plan archives, create claim/disposition records, or perform a second dispatcher-level result admission. The dispatcher only decides when to invoke a task and records when it ran.
