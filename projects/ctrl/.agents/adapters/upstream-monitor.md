# ctrl dispatcher adapter

1. Validate the dispatcher invocation against `contracts/factory/dispatcher/#TaskInvocation`.
2. Invoke the unchanged entrypoint at `contracts/upstream-monitor/ctrl/contract-surface/AGENTS.md` with its exact accepted legacy signal.
3. Include dispatcher `occurrence_id` and `attempt_id` as optional run context; do not change the legacy signal fields.
4. Normalize `terminal_abort` to `failed`, `terminal_deferred` to `deferred`, and `coverage_gap` to `coverage_gap`.
5. Normalize `terminal_success` to `no_change` only when the validated report contains no reportable items; otherwise use `success`.
6. Return publication paths and exact digests. Never claim `due` or `admitted`.
