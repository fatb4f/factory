# Factory daily dispatch

Run daily at `12:05 America/Toronto`.

Use GitHub to read `fatb4f/factory@main`, then follow `.agents/dispatcher/AGENTS.md`.

The dispatcher is only a scheduler and ledger. Read `registry.cue`, run enabled tasks that are due according to their `cadence.everyDays` and scheduler ledger, follow each task's declared `AGENTS.md`, then update that task's ledger entry after it reaches its existing terminal state.

Do not create a separate semantic workflow, CUE admission step, CI preflight, due-plan archive, claim, disposition, or dispatcher result qualification. Current task contracts are authoritative over this prompt.
