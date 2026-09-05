# Factory weekly dispatch

Run weekly on Monday morning in `America/Toronto`.

Use GitHub to read `fatb4f/factory@main`, then follow `.agents/dispatcher/AGENTS.md`.

The dispatcher is only a scheduler and ledger. Read `registry.cue`, run enabled tasks whose declared weekly weekday is due and which have not already run on the same local calendar date, follow each task's declared `AGENTS.md`, then update that task's ledger after it returns its task-native outcome.

Do not create a separate semantic workflow, CUE admission step, CI preflight, due-plan archive, claim, disposition, or dispatcher result qualification. A declared task authority remains authoritative over this prompt; tasks without one must not be given an invented semantic contract.
