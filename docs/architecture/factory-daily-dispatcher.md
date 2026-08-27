# Factory Daily Dispatcher

Status: proposed operational simplification

The dispatcher is intentionally thin. Factory owns a shared clock, registry, and small scheduler ledger. Each task owns its own procedure and, when declared, its own semantic authority.

## Control model

```text
ChatGPT daily clock
        |
        v
registry.cue
        |
        v
enabled + due?
        |
        v
unit-local task AGENTS.md
        |
        v
task-native workflow/outcome
        |
        v
scheduler ledger update
```

The dispatcher does not create a second semantic control plane.

## Registry boundary

Root `registry.cue` records unit/task identity, optional semantic-authority path, task-local agent path, enabled state, and cadence in days. CUE is structured repository configuration here; there is no dispatcher CUE admission package and no CUE CI job.

Current task registrations are:

```text
projects.ctrl.upstream-monitor
projects.epistemic-plant-bootstrap.upstream-monitor
academic.uqam.events
```

The project monitors declare CUE authority. The UQAM event watch does not: it is currently a procedural condition watch. All remain disabled in the dispatcher registry until an intentional cutover.

## Task execution

For a contracted upstream monitor:

```text
projects/ctrl/.agents/AGENTS.md
        |
        +--> contracts/workers/upstream-monitor/AGENTS.md
        +--> contracts/workers/upstream-monitor/contract.cue
        +--> contracts/workers/upstream-monitor/profiles_ctrl/*.cue
        |
        v
projects/ctrl/upstream-monitor/
```

The same shape applies to another registered upstream-monitor profile by substituting its selected `profiles_<profile>/` package and unit-local `.agents` procedure. `ctrl` is an example profile, not dispatcher or worker-core authority.

For UQAM events:

```text
academic/uqam/.agents/events/AGENTS.md
        |
        v
current public event sources
        |
        v
new_matches | no_change | source_gap
```

No contract, qualification state, evidence bundle, or publication surface is invented for the UQAM task.

## Execution boundary

The dispatcher does not provision containers, archives, local toolchains, or execution sandboxes. Those are task/profile concerns only when explicitly contracted. A contracted monitor that cannot obtain required executable evidence through its current actuator reports its task-native coverage-gap state; the dispatcher records that outcome without attempting to repair it with a second execution layer.

## Scheduler ledger

Scheduler state lives under `.agents/dispatcher/executions/<task-id>.json` and contains only task ID, `last_run_at`, an opaque task-native `outcome`, and optional run ID. The dispatcher never interprets `outcome`.

A task is due when no ledger exists or when at least `cadence.everyDays` calendar days have elapsed since `last_run_at`, evaluated in `America/Toronto`.

## Cutover

Cutover remains separate from repository wiring:

1. keep existing recurring automations active;
2. validate registered task paths;
3. seed scheduler state from the existing automations;
4. enable selected registry tasks;
5. activate the daily dispatcher;
6. disable only the recurring automations replaced by that dispatcher.

Until cutover, registry entries stay disabled and no duplicate execution is introduced.
