# Factory daily dispatch

Run daily at `12:05 America/Toronto`.

1. Submit the observed tick and checked-out repository revision to `.github/workflows/dispatcher-preflight.yml`.
2. Download the resulting `dispatcher-due-plan` artifact and require literal `plan.admission == true`.
3. Run `.agents/dispatcher/dispatcher.py verify-plan <archive>`.
4. Run `apply-dispositions`; it re-admits each disposition against the current ledger before append. Do not execute disposed occurrences.
5. For each `plan.dispatch` item, run `claim`. Continue only when its JSON status is `created`; `already_claimed` never authorizes invocation. Commit the claim and wait for automatic qualification on that exact revision.
6. Read the admitted item’s task-owned adapter procedure and execute it with the occurrence and attempt identities.
7. Have the adapter return a `factory.dispatcher.task-completion/v1` reference to its immutable sealed evidence, manifest, report, and summary with exact publication digests. Do not use mutable `latest.json` as result evidence. Run `record-result`; the registered adapter contract derives the common dispatcher state from those documents.
8. Continue with the next independent item even after a recorded task failure.
9. Render the compact `summary` output.

The existing ctrl and epistemic-plant-bootstrap direct signals remain valid. Dispatcher context is optional context layered on those signals; it does not replace them.
