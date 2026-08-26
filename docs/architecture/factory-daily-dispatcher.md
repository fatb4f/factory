# Factory Daily Dispatcher

Status: proposed operational simplification

The dispatcher is intentionally thin. The existing `ctrl` and `epistemic-plant-bootstrap` upstream-monitor workflows already own their authority, evidence, qualification, publication, and terminal-state semantics. Factory only needs a shared clock, task registry, and small scheduler ledger.

## Control model

```text
ChatGPT daily clock
        |
        v
root registry.cue
        |
        v
is task enabled and due?
        |
        v
task-local AGENTS.md
        |
        v
existing contracted task workflow
        |
        v
existing task publication + terminal state
        |
        v
simple scheduler ledger update
```

The dispatcher does not create a second semantic control plane.

## Registry boundary

Root `registry.cue` records only:

- unit identity and `.agents` root;
- task identity;
- task semantic-authority path;
- task-local agent path;
- enabled state; and
- cadence in days.

CUE is used as structured repository configuration. There is no dispatcher CUE admission package and no CUE CI job.

The first task registrations are:

```text
projects.ctrl.upstream-monitor
projects.epistemic-plant-bootstrap.upstream-monitor
```

Both retain their existing upstream-monitor profile authority. They remain disabled in the dispatcher registry until the existing scheduled monitor is intentionally cut over.

## Task execution

The task-local agent is a thin invocation surface. For example:

```text
projects.ctrl/.agents/AGENTS.md
        |
        v
contracts/factory/workers/upstream-monitor/
        +
profiles_ctrl/
        |
        v
contracts/upstream-monitor/ctrl/contract-surface/AGENTS.md
        |
        v
existing ctrl workflow and publication plan
```

The epistemic-plant-bootstrap task follows the equivalent existing authority chain.

The scheduler never translates `terminal_success`, `terminal_abort`, `terminal_deferred`, `coverage_gap`, qualification state, report content, or publication evidence into another dispatcher result schema. It records the task's existing terminal state only for scheduling history.

## Scheduler ledger

Scheduler state lives under:

```text
.agents/dispatcher/executions/<task-id>.json
```

Each file contains only the most recent invocation time, terminal state, and task run ID when one exists. Git history provides scheduler-history provenance; the task's own sealed run bundles remain the authoritative run record.

A task is due when:

```text
no scheduler ledger exists
    OR
calendar days since last_run_at >= cadence.everyDays
```

Calendar-day evaluation uses `America/Toronto`, matching the daily dispatcher clock.

A task-local failure, deferral, or coverage gap does not suppress another due task. It still counts as that scheduled invocation, matching the behavior of the existing recurring workflows.

## Daily ChatGPT task

The single recurring ChatGPT task runs daily at `12:05 America/Toronto` and:

1. reads current `fatb4f/factory@main`;
2. reads `registry.cue`;
3. checks each enabled task against its scheduler ledger;
4. follows the declared task-local `AGENTS.md` for each due task;
5. lets the existing task contract govern the entire run;
6. updates the task's scheduler ledger after a terminal outcome; and
7. returns a compact per-task summary.

## Explicit non-goals

The dispatcher does not require or produce:

```text
GitHub Actions preflight
CUE runtime admission
resolved due-plan archives
registry or workflow digests
claim records
attempt leases
misfire dispositions
dispatcher result admission
task publication re-validation
```

If a concrete operational failure later demonstrates the need for one of these mechanisms, it can be introduced at the narrowest layer that requires it.

## Cutover

Cutover is separate from this repository simplification:

1. keep the existing combined upstream-monitor automation active;
2. validate the simplified registry and task-local agent paths manually;
3. configure the daily dispatcher task;
4. seed or record scheduler state from the last existing invocation as appropriate;
5. enable the two dispatcher registry entries; and
6. disable the previous combined scheduled task.

Until those steps are performed, the repository changes do not alter the current recurring monitor schedule.
