# Gym session workflow v2

This is the active conversational operating protocol for `ankle-knee-pelvis-tri-session-v2`.

It is subordinate to the CUE contracts under `contracts/personal/gym/`. Historical v1 sessions continue to use `session-workflow.md` and `ankle-knee-pelvis-tri-session-v1`.

## State machine

```text
IDLE
  -> STARTED
  -> ACTIVE
  -> CLOSING
  -> CLOSED
  -> RECOVERY
  -> ANALYZABLE
```

A session may remain partial at any state. Missing observations are never inferred merely to advance the state machine.

Active session classes remain:

```text
posterior
anterior
distal-integrated
```

Resolve the active prescription from `contracts/personal/gym/tri_session_program_v2.cue`.

## 1. Session start

On start:

1. Resolve Program A/B/C from explicit wording and active context.
2. Load the v2 prescription.
3. Resolve every `exercise.id` through `exerciseProfiles`.
4. Present a compact ordered plan.
5. Preserve the loaded-exposure budget.
6. Capture baseline systemic/movement state only when already stated, quickly observable, or materially useful.

The start response should optimize for execution, not documentation ceremony.

### Current loaded-exposure budgets

```text
A
3 lower working exposures
1 upper working exposure

B
3 lower working exposures
1 upper working exposure

C
2 lower working exposures maximum
1 upper working exposure
```

Activation gates, primers, and gait readouts do not become extra working sets simply because the user feels good.

For Program C, exactly one principal integration family is selected:

```text
cossack-squat
OR
modified-standing-bow-slrdl
```

Do not schedule both as working lifts in the same current-baseline C run.

## 2. Exposure setup

Before the first working observation for an exercise, establish only the setup that later sets should inherit:

- canonical exercise/variant;
- equipment;
- assistance/load;
- lever/support/stance;
- intended mechanical constraints.

When setup remains unchanged, later set reports are deltas.

## 3. In-session capture

Terse natural-language reports are the preferred interface.

Capture, when stated:

- exercise and set sequence;
- reps/hold duration;
- load or assistance delta;
- ROM stage or qualifier;
- mechanical constraint state;
- limiter region/kind/onset;
- cramp, pain, instability, or compensation event;
- media/measurement references.

Keep fact and interpretation separate.

Example:

```text
fact:
neck tension increased on rep 7

not raw fact:
posterior delt weakness caused cervical compensation
```

If the user corrects a prior statement, append the replacement observation and link supersession when persisted.

## 4. Upper-body distributed slot

There is no separate Program D in v2.

```text
A -> rear-delt high row
B -> overhead press
C -> lateral raise
```

The upper exposure occurs after the required lower/core work and before final gait/down-regulation unless equipment/state requires a harmless reorder.

Initial upper work is conservative, generally around 3–4 RIR.

Upper progression requires:

- neck relatively quiet;
- levator not becoming the dominant stabilizer;
- no increase in sternal/anterior-thorax tension;
- controlled humeral position;
- exercise-appropriate free scapular movement.

If those constraints fail, stop or regress the upper exposure. Do not chase the programmed rep range.

A-Y-W, band pulls, dip-bar push-ups, and similar habitual work are not automatically added to the formal session. During hard recovery they are not automatically treated as permissible training.

## 5. Program deviations

The prescription is a controller, not a requirement to finish every listed exposure.

If the user skips, substitutes, changes assistance, shortens ROM, or ends early:

- record what was executed;
- preserve planned prescription separately;
- do not synthesize observations for planned-only work.

Do not fill an open equipment slot with an unplanned lower-chain accessory merely because it is available. Current v2 explicitly constrains exercise-count creep.

## 6. Down-regulation

Down-regulation remains part of the ACTIVE session.

Use easy gait as a readout, not conditioning.

Capture only observed changes. A good post-session gait readout does not itself admit progression.

## 7. Session close

On close:

1. capture the immediate `#SessionClose` state;
2. use already-reported observations rather than re-asking them;
3. summarize executed work and notable direct events;
4. identify capture gaps without backfilling them;
5. transition into hard recovery.

Preferred close vector:

```text
energy available
cognitive available
gait
meaningfully changed movement state
named local response
notable pain / instability / compensation events
```

Do not label the session successful, failed, progressed, or excessive at close.

## 8. Hard recovery gate

Recovery is currently a no-training domain.

Current calibration:

```text
posterior / A: last observed ~72 h
anterior / B:  last observed ~48 h
C:             not yet baselined
```

These are observations, not guaranteed timers.

No new training session is admitted until:

```text
lower-chain movement availability acceptable
AND local tissue state acceptable
AND systemic energy acceptable
AND cognitive / academic availability acceptable
```

Time alone does not admit the next session.

Useful recovery checkpoints remain approximately:

```text
T+12
T+24
T+48
T+72
```

Capture the smallest useful vector when observations actually occur. Do not fabricate checkpoints.

## 9. Analysis admission

For `ankle-knee-pelvis-tri-session-v2`:

```text
mechanical quality required
AND recovery cost required
AND cognitive cost required
AND partial runs are not comparable
```

Therefore:

```text
mechanically clean session
+ incomplete recovery evidence
!= progression-admitted session
```

Likewise:

```text
more ROM / reps / load
+ greater chain reorganization
or greater cognitive recovery cost
!= automatic progress
```

Progress one dimension at a time.

Exercise-count expansion is itself a progression dimension and remains blocked until the lower chain is substantially more stable across repeated sessions.

## 10. Historical compatibility

Do not reinterpret sessions explicitly captured against `ankle-knee-pelvis-tri-session-v1` as if the v2 exposure budget had applied at the time.

v1 remains historical evidence.

v2 governs future sessions from activation onward.

## Contract links

- `contracts/personal/gym/tri_session_program_v2.cue` — active program and recovery/budget constraints;
- `contracts/personal/gym/tri_session_program.cue` — historical v1 program;
- `contracts/personal/gym/exercise_registry.cue` — canonical exercise identity;
- `contracts/personal/gym/session.cue` — session start/close;
- `contracts/personal/gym/exposure.cue` — exposure observations;
- `contracts/personal/gym/capture.cue` — append-only capture and supersession;
- `contracts/personal/gym/recovery.cue` — recovery checkpoints;
- `contracts/personal/gym/analysis.cue` and `analysis_policy.cue` — downstream assessment boundary.
