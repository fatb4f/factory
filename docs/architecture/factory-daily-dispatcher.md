# Factory Daily Dispatcher

Status: current

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
projects.ctrl.upstream-monitor                         enabled
projects.epistemic-plant-bootstrap.upstream-monitor   enabled
academic.uqam.events                                  enabled
world.industrial-constraints.monitor                  disabled / unqualified
```

The project monitors declare CUE authority. The UQAM event watch does not: it is a procedural condition watch. `world.industrial-constraints.monitor` remains registered but disabled until independent qualification is complete.

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

For industrial constraints:

```text
world/industrial-constraints/.agents/AGENTS.md
        |
        +--> contracts/world/industrial-constraints/*.cue
        |
        v
bounded acquisition + Ibis projections
        |
        v
admitted relational state
        |
        v
constraint/evidence assessment + admitted run bundle
```

This task is domain-owned and does not route through `contracts/workers/upstream-monitor/`. Registration does not imply qualification or dispatcher admission.

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

The dispatcher does not provision containers, archives, local toolchains, or execution sandboxes. Those are task/profile concerns only when explicitly contracted. A contracted task that cannot obtain required executable evidence through its current actuator reports its task-native coverage-gap state; the dispatcher records that outcome without attempting to repair it with a second execution layer.

## Scheduler ledger

Scheduler state lives under `.agents/dispatcher/executions/<task-id>.json`. A normal entry contains task ID, `last_run_at`, an opaque task-native `outcome`, and optional run ID. The dispatcher never interprets `outcome`.

For cutover only, a seed entry may omit `outcome` when it carries `seeded_from: "legacy-recurring-automation"`. This preserves cadence without inventing a historical task result. The first actual dispatcher execution replaces the seed with the normal form.

A task is due when no ledger exists or when at least `cadence.everyDays` calendar days have elapsed since `last_run_at`, evaluated in `America/Toronto`.

## Cutover state

The dispatcher cutover covers the two established upstream monitors and the UQAM events watch:

1. their latest scheduler checkpoints are seeded into `.agents/dispatcher/executions/`;
2. those three registry tasks are enabled;
3. the daily dispatcher is the active scheduler for them;
4. their replaced recurring automations are disabled after the dispatcher is activated.

`world.industrial-constraints.monitor` remains disabled and unqualified. Its existing standalone weekly monitoring automation may continue until the domain profile is independently qualified and explicitly admitted to dispatcher execution. This partial cutover therefore intentionally retains that one external schedule rather than silently dropping industrial monitoring.
