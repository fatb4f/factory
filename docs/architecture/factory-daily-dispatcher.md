# Factory Daily Dispatcher

Status: current

The dispatcher is intentionally thin. Factory owns a shared clock, registry, and small scheduler ledger. Each task owns its own procedure and, when declared, its own semantic authority and task-local persistent state.

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
        +--> optional task-owned state/run bundle
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

The project monitors and UQAM event watch declare CUE authority. `world.industrial-constraints.monitor` remains registered but disabled until independent qualification is complete.

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
        +--> contracts/academic/uqam/events/*.cue
        +--> contracts/state/comparison.cue
        |
        v
source-qualified normalized event set
        |
        +--> immutable academic/uqam/events/runs/<run-id>/
        |
        v
admitted baseline comparison
        |
        +--> academic/uqam/events/state/admitted-baseline.json
        |
        v
baseline_established | no_change | new_matches
        |              source_gap | comparison_gap | state_conflict
        v
dispatcher records opaque outcome only
```

The first complete UQAM run with no predecessor is `bootstrap`, not an acquisition failure. It persists the normalized set as the first admitted baseline and returns `baseline_established` without notifying. Subsequent runs compare against that admitted state. Event identity excludes mutable date/time, location, registration, and scope fields so a moved event is a material change rather than a remove/add artifact.

`contracts/state/comparison.cue` contains only shared run/baseline reference and compare-and-swap vocabulary. Event identity, material-change policy, sources, and reporting semantics remain UQAM-profile authority.

## Execution boundary

The dispatcher does not provision containers, archives, local toolchains, or execution sandboxes. Those are task/profile concerns only when explicitly contracted. A contracted task that cannot obtain required executable evidence through its current actuator reports its task-native coverage-gap state; the dispatcher records that outcome without attempting to repair it with a second execution layer.

## Scheduler ledger

Scheduler state lives under `.agents/dispatcher/executions/<task-id>.json`. A normal entry contains task ID, `last_run_at`, an opaque task-native `outcome`, and optional run ID. The dispatcher never interprets `outcome`.

Task comparison state is deliberately separate. For UQAM events, immutable normalized runs live under `academic/uqam/events/runs/` and the single mutable baseline pointer lives under `academic/uqam/events/state/`. The pointer is advanced with compare-and-swap semantics; overlapping runs must not overwrite newer admitted state.

For cutover only, a seed entry may omit `outcome` when it carries `seeded_from: "legacy-recurring-automation"`. This preserves cadence without inventing a historical task result. The first actual dispatcher execution replaces the seed with the normal form.

A task is due when no ledger exists or when at least `cadence.everyDays` calendar days have elapsed since `last_run_at`, evaluated in `America/Toronto`.

## UQAM state cutover

The existing `source_gap` execution ledger remains historical scheduler truth. No event baseline is fabricated from that outcome or from prose summaries.

There is intentionally no initial `academic/uqam/events/state/admitted-baseline.json` in the repository. The next complete UQAM acquisition executes the contractual bootstrap path and creates it from the normalized observation set.

## Cutover state

The dispatcher cutover covers the two established upstream monitors and the UQAM events watch:

1. their latest scheduler checkpoints are represented under `.agents/dispatcher/executions/`;
2. those three registry tasks are enabled;
3. the daily dispatcher is the active scheduler for them;
4. task-specific semantic/state surfaces remain outside the dispatcher ledger.

`world.industrial-constraints.monitor` remains disabled and unqualified. Its existing standalone weekly monitoring automation may continue until the domain profile is independently qualified and explicitly admitted to dispatcher execution.
