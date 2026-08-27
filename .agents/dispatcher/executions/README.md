# Dispatcher execution ledger

This directory contains scheduler state only. It is not task, domain, evidence, qualification, or publication authority.

Each enabled task may have one file named `<task-id>.json`:

```json
{
  "task_id": "projects.ctrl.upstream-monitor",
  "last_run_at": "2026-08-27T12:05:00-04:00",
  "outcome": "terminal_success",
  "run_id": "optional-task-run-id"
}
```

`outcome` is an opaque task-native label. For a contracted upstream monitor it may be a terminal state; for another task it may be `new_matches`, `no_change`, `source_gap`, or another procedure-defined value. The scheduler does not interpret it.

`last_run_at` alone determines the next scheduled invocation. Git history preserves earlier scheduler state; task-specific publication surfaces preserve task evidence and run history where such surfaces exist.
