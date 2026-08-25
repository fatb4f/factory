# Factory daily dispatch

Run daily at `12:05 America/Toronto`.

1. Submit the observed tick and checked-out repository revision to `.github/workflows/dispatcher-preflight.yml`.
2. Download the resulting `dispatcher-due-plan` artifact and require literal `plan.admission == true`.
3. Run `.agents/dispatcher/dispatcher.py verify-plan <archive>`.
4. Run `apply-dispositions` once; do not execute those occurrences.
5. For each `plan.dispatch` item, run `claim`, wait for claim validation, read the item’s task-owned adapter, and execute it with the occurrence and attempt identities.
6. Normalize the task-local result, run `record-result`, and continue with the next independent item even after a recorded task failure.
7. Render the compact `summary` output.

The existing ctrl and epistemic-plant-bootstrap direct signals remain valid. Dispatcher context is optional context layered on those signals; it does not replace them.
