# Dispatcher execution ledger

This directory contains scheduler state only. It is not task, domain, evidence, qualification, or publication authority.

Each enabled task may have one file named `<task-id>.json`:

```json
{
  "task_id": "projects.ctrl.upstream-monitor",
  "last_run_at": "2026-08-27T12:05:00-04:00",
  "terminal_state": "terminal_success",
  "run_id": "optional-task-run-id"
}
```

`last_run_at` is used only to determine the next scheduled invocation. Git history preserves earlier scheduler states; the task's own publication surface preserves task evidence and run history.
