# Dispatcher execution ledger

This directory contains scheduler state only. It is not task, domain, evidence, qualification, comparison, or publication authority.

A normal dispatcher execution writes one file named `<task-id>.json`:

```json
{
  "task_id": "projects.ctrl.upstream-monitor",
  "last_run_at": "2026-08-27T12:05:00-04:00",
  "outcome": "terminal_success",
  "run_id": "optional-task-run-id"
}
```

`outcome` is an opaque task-native label. For a contracted upstream monitor it may be a terminal state; for another task it may be `baseline_established`, `new_matches`, `no_change`, `source_gap`, `comparison_gap`, `state_conflict`, or another procedure-defined value. The scheduler does not interpret it.

Task-owned persistent state belongs with the task. For example, UQAM event comparison state lives under `academic/uqam/events/state/`; it must not be copied into this scheduler ledger.

During scheduler cutover only, an existing recurring automation may seed cadence without fabricating an outcome:

```json
{
  "task_id": "academic.uqam.events",
  "last_run_at": "2026-08-27T07:55:21-04:00",
  "seeded_from": "legacy-recurring-automation"
}
```

A seed may also carry an existing task `run_id` when one is independently available. `seeded_from` is scheduler migration metadata, not task evidence. The first actual dispatcher execution replaces the seed with the normal form and removes `seeded_from`.

`last_run_at` alone determines the next scheduled invocation. Git history preserves earlier scheduler state; task-specific state, publication surfaces, and run bundles preserve task semantics where declared.
