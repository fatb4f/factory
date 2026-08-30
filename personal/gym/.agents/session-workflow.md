# Gym session workflow

This document defines the conversational operating protocol for a Gym training run. It is subordinate to the CUE contracts under `contracts/personal/gym/` and is referenced by `AGENTS.md`.

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

For the ankle-knee-pelvis program, the active session class is one of:

```text
posterior
anterior
distal-integrated
```

Resolve its prescription from `contracts/personal/gym/tri_session_program.cue`.

## 1. Session start

Typical triggers include statements such as:

- `starting GHR day`;
- `at Anytime now, posterior session`;
- `let's do anterior day`;
- `starting the ankle session`.

On start:

1. Resolve the program and session class from explicit wording and active conversation context.
2. Load the corresponding tri-session prescription.
3. Present a compact ordered plan for the session, including activation, primary work, core/integration, and down-regulation.
4. Capture a `#SessionStart` with the minimum required identity, timestamp, and intent.
5. Capture baseline systemic/movement state only when already stated, quickly observable, or materially useful.
6. Do not force optional baseline fields merely for completeness.

The start response should optimize for immediate execution, not documentation ceremony.

### Start baseline

Prefer the smallest useful vector:

```text
energy available      0-4, if known
cognitive available   0-4, if known
gait                   if meaningfully abnormal/normal is stated
hinge availability     if relevant
knee-flexion state     if relevant
residual DOMS          named region + 0-5, if present
```

If the user reports no baseline information beyond the session intent, start the run anyway and leave the optional fields unobserved.

## 2. Exposure setup

Before the first working observation for an exercise, establish only the setup that later sets should inherit:

- exercise/variant;
- equipment or machine;
- assistance/load;
- lever, support, pad, or stance configuration;
- intended mechanical constraints.

Example:

```text
GHR
blue band
ankle neutral
hips/torso stacked
pelvis neutral
```

This is setup, not a mechanical-quality result.

When the setup remains unchanged, later set reports should be treated as deltas. Do not ask the user to repeat the band, machine, support, or stance on every set.

## 3. In-session capture

While ACTIVE, terse natural-language reports are the preferred interface.

Example:

```text
Set 2, 6 reps. Same band. No pelvic fail, medial ham started to load near the bottom.
```

Normalize supported facts into append-only `#ExposureObservation` / `#CaptureEnvelope` records.

Capture, when stated:

- exercise and set sequence;
- reps/hold duration;
- load or assistance delta;
- ROM stage or qualifier;
- mechanical constraint state;
- limiter region/kind/onset;
- cramp, pain, instability, or compensation event;
- media/measurement references.

### Capture response behavior

After a normal set report:

1. acknowledge the relevant captured facts in one compact statement;
2. state the next programmed exposure or the current progression gate when useful;
3. avoid unsolicited long analysis between sets.

If a stated event matches a program `stopOn` condition, surface that immediately and regress/terminate the exposure according to the program contract. This is a control decision, not a diagnosis.

### Observation versus interpretation

Keep these separate:

```text
fact:
  right adductor reached mechanical failure first

not raw fact:
  right adductor is weak
```

```text
fact:
  lumbar extension appeared at deeper GHR ROM

not raw fact:
  lumbar spine is compensating because of a nerve lesion
```

If the user asks for interpretation during the session, provide the reasoning in prose while keeping the canonical capture fact-only.

### Corrections

When the user corrects a prior statement:

- do not overwrite history silently;
- append the replacement observation;
- link it with `#Supersession` when persisted.

## 4. Program deviations

The prescription is a controller, not a requirement to finish every listed exposure.

If the user skips, substitutes, changes assistance, shortens ROM, or ends an exercise early:

- record what was actually executed;
- preserve the planned prescription separately;
- do not synthesize an observation for work that was planned but not performed.

If no canonical plan-delta record exists yet, keep the plan change conversational and represent only executed exposures in canonical capture.

## 5. Media and device capture

When video becomes available:

1. register the media artifact;
2. link it to the session/exposure/set;
3. preserve camera/device/acquisition metadata when available;
4. keep observed visual facts separate from derived pose/angle/velocity measurements;
5. do not treat a video-derived result as automatically more authoritative than direct observations.

Dual-scale, wearable, and future sensor data follow the same rule: raw reading first, derived metric later.

## 6. Down-regulation

Down-regulation remains part of the ACTIVE session, not recovery.

For the current tri-session program this may include:

- easy treadmill walking;
- gait readout;
- optional short backward walking where programmed;
- non-aggressive mobility if used.

Capture gait or local responses when the user reports them. Do not convert a good post-session gait readout into a progression decision.

## 7. Session end

Typical triggers:

- `done`;
- `session done`;
- `that's it`;
- explicit report that the finisher/down-regulation is complete.

On close:

1. capture the immediate `#SessionClose` state;
2. use already-reported observations rather than re-asking them;
3. ask for an omitted close field only if it is both important and not inferable;
4. summarize actual executed work and notable direct events;
5. identify capture gaps without backfilling them;
6. transition the run into recovery.

Preferred immediate close vector:

```text
energy available
cognitive available
gait
meaningfully changed hinge/knee-flexion state
named local response
notable events: cramp, pain, instability, unexpected compensation
```

Do not label the session `successful`, `failed`, `ready to progress`, or `excessive` at close. Those are downstream assessments.

## 8. Recovery handoff

Recovery is part of the same run.

Useful checkpoints are approximately:

```text
T+12
T+24
T+48
T+72
```

They are not mandatory if no observation exists.

Capture the smallest useful vector from `templates/recovery-check.md`:

- DOMS by named region;
- energy;
- cognitive availability;
- task initiation;
- sleepiness;
- subjective recovery;
- gait and key movement availability.

Do not fabricate a missing checkpoint and do not automatically schedule reminders unless the user asks for them.

## 9. Analysis admission

A session becomes eligible for longitudinal comparison only through downstream analysis and only when the program's observation requirements are satisfied.

For `ankle-knee-pelvis-tri-session-v1`:

```text
mechanical quality required
AND recovery cost required
AND partial runs are not comparable
```

Therefore:

```text
mechanically clean session
+ missing recovery evidence
!= progression-admitted session
```

Likewise:

```text
more ROM / less assistance / more reps
+ higher systemic recovery cost
!= automatic progress
```

Progression remains one dimension at a time and is admitted only inside the recovery budget.

## 10. Partial sessions and historical reports

A partial observation is still useful evidence but must remain marked as partial outside canonical fields unless/until a dedicated completeness schema exists.

Do not reconstruct missing historical metrics from conversational plausibility.

The 2026-08-29 posterior session is the model example: it is useful for validating the session contract and programming, but it lacks sufficient predeclared capture to serve as authoritative longitudinal baseline data.

## Contract links

- `contracts/personal/gym/session.cue` — `#SessionStart`, `#SessionClose`;
- `contracts/personal/gym/exposure.cue` — exposure observations;
- `contracts/personal/gym/capture.cue` — append-only capture envelope and supersession;
- `contracts/personal/gym/recovery.cue` — recovery checkpoints;
- `contracts/personal/gym/tri_session_program.cue` — active session prescriptions and progression constraints;
- `contracts/personal/gym/analysis.cue` and `analysis_policy.cue` — downstream assessment boundary.

## Operational shorthand

The intended interaction should feel like:

```text
User: Starting posterior day.
Agent: resolves posterior template, gives compact plan, captures start.

User: GHR set 1, 6 reps blue band. Pelvis clean, ROM partial.
Agent: captures delta, preserves setup, gives next gate.

User: Set 2, 5. Same. Medial ham loaded but no cramp.
Agent: appends observation; no questionnaire.

User: Reverse hyper 5 lb ankles, clean pelvis/lumbar.
Agent: updates current exposure and next step.

User: Done. Gait clean, energy lower but okay.
Agent: captures close, summarizes observed run, opens recovery window.

User next day: medial ham DOMS 3, cognition down 1, gait normal.
Agent: appends recovery checkpoint; only then can downstream recovery analysis begin.
```
