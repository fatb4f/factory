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

The dispatcher does not create a second semantic control plane.

## Registry boundary

Root `registry.cue` records unit/task identity, optional semantic-authority path, task-local agent path, enabled state, and explicit weekly weekday cadence. CUE is structured repository configuration here; there is no dispatcher CUE admission package and no CUE CI job.

Current task registrations are:

```text
projects.ctrl.upstream-monitor                         enabled / Monday
projects.epistemic-plant-bootstrap.upstream-monitor   enabled / Monday
academic.uqam.events                                  enabled / Monday
academic.uqam.catalog                                 enabled / Monday
world.industrial-constraints.monitor                  enabled / Monday
```

The external ChatGPT scheduler provides the Monday-morning wall-clock tick. Task cadence remains repository-declared so an accidental off-day dispatcher invocation does not make tasks due.

## Due semantics

Schedule dates are evaluated in `America/Toronto`.

For a weekly task:

```text
due = enabled
   && current_weekday == cadence.weekday
   && no scheduler ledger shows a run on the same local calendar date
```

The ledger therefore provides same-day deduplication rather than elapsed-day gating. A direct ad-hoc task invocation may update the task ledger after a real task-native outcome; a later Monday on a different date remains due.

## Task authority

For a contracted upstream monitor:

```text
unit-local AGENTS.md
        |
        +--> contracts/workers/upstream-monitor/contract.cue
        +--> selected contracts/workers/upstream-monitor/profiles_<profile>/*.cue
        |
        v
profile-owned run/publication surface
```

For industrial constraints, the current execution phase is deliberately narrower than the target data platform:

```text
world/industrial-constraints/.agents/AGENTS.md
        |
        +--> contracts/world/industrial-constraints/*.cue
        |
        v
bounded public-source acquisition
        |
        v
source-qualified documents + event observations
        |
        v
relevance classification
        |
        v
admitted observation report/run bundle
```

The contract separately models the future `relational-pipeline` target:

```text
bounded acquisition adapters
        |
        v
typed relational normalization + canonical identity
        |
        v
Ibis projections / DuckDB admitted state
        |
        v
graph correlation
        |
        v
evidence-backed constraint claims
```

The future pipeline is not a prerequisite for current event tracking. While `contract.execution.phase == "event-watch"`, the task may publish source-qualified events and coverage gaps but must not publish canonical graph propagation, assessments, or constraint claims. Missing Ibis/DuckDB/BigQuery execution is therefore a future-capability gap rather than an event-watch failure.

The industrial task is domain-owned and does not route through the generic upstream-monitor worker.

For UQAM tasks, academic contracts remain semantic authority and their task-local baseline/comparison state remains separate from dispatcher state.

## Scheduler ledger

Scheduler state lives under `.agents/dispatcher/executions/<task-id>.json`. A normal entry contains task ID, `last_run_at`, an opaque task-native `outcome`, and optional run ID. The dispatcher never interprets `outcome`.

Task-owned state, evidence, qualification, comparison baselines, and immutable run bundles remain outside this ledger.

## Execution boundary

The dispatcher does not provision containers, archives, local toolchains, or execution sandboxes. Those are task/profile concerns only when explicitly contracted. A task that cannot obtain evidence required by its currently selected execution phase must preserve the task-native coverage gap rather than allowing the dispatcher to fabricate validation.

The active scheduler topology is one Monday-morning dispatcher over all enabled registered tasks. Legacy task-specific recurring automations are not part of Factory authority and should remain disabled once their function is represented by the dispatcher.
