# ctrl dispatcher adapter

1. Validate the dispatcher invocation against `contracts/factory/dispatcher/#TaskInvocation` and bind it to the ctrl profile's dispatcher context.
2. Invoke the unchanged entrypoint at `contracts/upstream-monitor/ctrl/contract-surface/AGENTS.md` with its exact accepted legacy signal.
3. Include dispatcher `occurrence_id` and `attempt_id` as optional run context; do not change the legacy signal fields.
4. Seal the task-local run bundle with the same dispatcher context in `evidence.json` and `manifest.json`, then update `latest.json` according to the profile publication contract.
5. Return `factory.dispatcher.task-completion/v1` with the exact immutable evidence, manifest, report, and summary paths and SHA-256 digests. Do not use mutable `latest.json` as result evidence or return a dispatcher state, `reportableItems`, `due`, or `admitted` claim.
6. The typed adapter contract at `projects/ctrl/upstream-monitor/contract.cue` validates the bundle and derives the dispatcher state.
