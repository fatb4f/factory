# epistemic-plant-bootstrap project task overlay

This surface adapts dispatcher invocations to the existing epistemic-plant-bootstrap upstream-monitor profile authority. It is procedure, not semantic authority. Read the typed mapping in `projects/epistemic-plant-bootstrap/contract.cue`, then follow the referenced profile authority without changing its direct invocation or publication paths.

When invoked by the dispatcher, preserve `occurrence_id` and `attempt_id` in the run context. Before acquiring new evidence, inspect the declared publication root for an already sealed bundle carrying that identity.
