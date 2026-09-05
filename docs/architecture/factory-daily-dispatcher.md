# Factory Weekly Dispatcher

Status: current

The dispatcher is intentionally thin. Factory owns one shared weekly clock, root task registration, and a small scheduler ledger. Each task owns its own procedure and, when declared, its own semantic authority and task-local persistent state.

## Control model

```text
ChatGPT Monday-morning clock
        |
        v
registry.cue
        |
        v
enabled + weekday due + not already run today?
        |
        v
unit-local task AGENTS.md
        |
        v
task-native workflow/outcome
        |
        +--> optional task-owned state/run bundle
        |
        v
scheduler ledger update
```

The dispatcher does not create a second semantic control plane and does not infer task ordering from names, domains, or apparent data dependencies.

## Registry boundary

Root `registry.cue` records unit/task identity, optional semantic-authority path, task-local agent path, enabled state, and explicit weekly weekday cadence. CUE is structured repository configuration here; there is no dispatcher semantic admission package.

### Enabled Monday tasks

```text
projects.ctrl.upstream-monitor
projects.epistemic-plant-bootstrap.upstream-monitor
academic.uqam.events
academic.uqam.catalog
world.industrial-constraints.monitor
world.engineering-signals.monitor
world.canada-clean-energy.monitor
world.canada-climate-readiness.monitor
```

The four world intelligence watches currently execute independently:

```text
engineering-signals        engineering frontier / mechanisms / tests
industrial-constraints     engineering-to-industry / capacity / industrial events
canada-clean-energy        policy/project demand relevant to engineering/industry
canada-climate-readiness   resilience/adaptation demand relevant to engineering/industry
```

They are observation phases, not a currently executable multi-graph correlation pipeline.

### Registered but disabled

```text
world.financial-signals.monitor
world.resource-allocation.correlate
world.financial-opportunities.qualify
projects.engineering-pocs.qualify
```

These tasks remain disabled until their prerequisite source universes, graph snapshots, bridges, conjunctions or qualification evidence exist. Registration is discovery/configuration, not an assertion of executable capability.

## Due semantics

Schedule dates are evaluated in `America/Toronto`.

For a weekly task:

```text
due = enabled
   && current_weekday == cadence.weekday
   && no scheduler ledger shows a run on the same local calendar date
```

The ledger provides same-day deduplication rather than elapsed-day gating. A direct ad-hoc task invocation may update the ledger after a real task-native outcome; a later Monday on another date remains due.

## Multi-graph execution boundary

The architecture target is documented in `docs/architecture/multi-graph-world-refactor.md`.

Current execution is deliberately pre-correlation:

```text
engineering event watch ------+
industrial event watch -------+--> independent admitted observations
clean-energy event watch -----+
climate-readiness event watch +
```

Future execution may add:

```text
independent immutable graph snapshots
        |
        v
resource-allocation correlation
        |
        +--> intervention / POC qualification
        |
        `--> financial qualification / opportunity decisions
```

Do not add generic scheduler `dependsOn` semantics merely because these future relationships are architecturally known. Add explicit task dependencies only when the first real correlation task is enabled and requires scheduler ordering. Until then, the current watches remain independent scheduled tasks.

## Industrial phase boundary

`world.industrial-constraints` currently selects `event-watch`; its relational/Ibis/DuckDB graph pipeline remains a modeled target. Missing relational execution is therefore not an event-watch failure. Current publication may contain source-qualified event observations and coverage gaps, but not canonical graph propagation or constraint claims.

The same observation-first discipline applies to the new engineering, clean-energy and climate-readiness domains: an event may establish that a source published or changed something within scope; it does not establish cross-domain identity, resource contention, economic capture or POC priority.

## Scheduler ledger

Scheduler state lives under `.agents/dispatcher/executions/<task-id>.json`. A normal entry contains task ID, `last_run_at`, an opaque task-native `outcome`, and optional run ID. The dispatcher never interprets `outcome`.

Task-owned evidence, graph snapshots, hypotheses, qualification state, immutable run bundles and future conjunctions remain outside the scheduler ledger.

## Execution environment

The dispatcher does not provision containers, archives, analytical engines or source credentials. Those remain task/domain realization concerns. A task that cannot obtain evidence required by its selected execution phase must preserve the task-native coverage gap rather than fabricate validation.

The active scheduler topology remains one Monday-morning dispatcher over all enabled registered tasks. Legacy task-specific recurring automations should remain disabled once their function is represented by the dispatcher.
