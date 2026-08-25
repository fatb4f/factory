# epistemic-plant-bootstrap project task overlay

This surface adapts dispatcher invocations to the existing epistemic-plant-bootstrap upstream-monitor contract. It is procedure, not semantic authority. Read `projects/epistemic-plant-bootstrap/contract.cue`, then follow the legacy authority chain without changing its direct invocation or publication paths.

When invoked by the dispatcher, preserve `occurrence_id` and `attempt_id` in the run context. Before acquiring new evidence, inspect the declared publication root for an already sealed bundle carrying that identity.
