# 2026-09-01 Program B — prose capture

Status: **closed / recovery open**  
Capture mode: **pre-P2 conversational evidence**  
Program: `ankle-knee-pelvis-tri-session-v1`  
Session class: `anterior` / Program B  

This run predates the operational Python/JSONL capture bridge. It is persisted as a prose evidence artifact and reliability driver for the future `ObservationCommand -> SessionExecution -> DomainEvent -> session.jsonl` path.

## Evidence discipline

- Direct observations below are limited to facts explicitly reported during the live session.
- Planned work is kept separate from executed work.
- Missing metrics are left missing rather than reconstructed.
- Interpretations are recorded separately and are not canonical observations.
- Recovery remains open; no recovery checkpoint has yet occurred.

## Executed topology

```text
activation
  ankle dorsiflexion
  dead bug
      ↓
primer
  backward walk
  Poliquin step-up
  + Cossack-style lateral shuffle [added]
      ↓
main
  reverse Nordic 3 × 4
  ATG split squat 2 × 5 / side
      ↓
secondary
  resisted hip flexion 2 × 5 / side @ 6 kg
      ↓
session close
  voluntary stop for recovery-dose calibration
```

## Activation and primer

The following prescribed Program B entry exposures were explicitly reported as **performed as prescribed**:

- `ankle-dorsiflexion`: 1 set, prescribed range 8–12 reps;
- `dead-bug`: 1 set, prescribed range 5–8 reps;
- `backward-walk`: one low-fatigue primer exposure;
- `poliquin-step-up`: 2 sets, prescribed range 5–8 reps per side.

Exact performed rep counts inside the programmed ranges were not separately reported and are therefore not reconstructed.

### Added Cossack-style lateral shuffle

**Observed**

- 1 set;
- 5/5 left-to-right shuffles;
- no external load;
- squat stance retained throughout;
- full dorsiflexion reported.

This was an added exposure rather than the canonical Program C `cossack-squat` prescription.

## Reverse Nordic

**Executed dose:** 3 × 4 reps.

### Setup

- single AbMat under both knees;
- resistance band strapped around the torso and anchored overhead/behind;
- band provided assistance through the arc;
- assistance magnitude/tension was not measured;
- same setup inherited across all three sets.

### Set 1 — observed

- 4 smooth reps;
- pelvis stable;
- ribs stacked;
- knees did not move from the single AbMat;
- no knee/femoral rotation reported;
- deep position reached with glutes over heels;
- bottom ROM remained a few inches short of scapula-to-ground contact;
- no attempt was made to force floor contact;
- concentric was reported as coming cleanly through the knees/quads with strong VMO recruitment;
- rep 4 required considerable neuromuscular focus to preserve the clean concentric;
- set was terminated voluntarily at rep 4 to avoid moving too close to failure.

### Sets 2–3 — observed

- 4 reps each set;
- same inherited setup;
- same output and mechanical quality as Set 1;
- no additional compensation or asymmetry reported.

### Interpretation — non-canonical

The repeatable surface for this run is 3 × 4 at the captured ROM and assistance implementation. The immediately visible progression question is whether the same ROM can be repeated with lower concentration cost or a clean additional rep before increasing depth or reducing assistance. This is not yet a progression decision because recovery evidence is pending.

## ATG split squat

**Executed dose:** 2 × 5 reps per side.

### Set 1 — left lead

**Observed**

- neutral heel/toe position;
- left knee flexion tracked over toes;
- 5 reps;
- exertion concentrated at the right anterior-hip region;
- secondary tension reported at the left VMO.

### Set 1 — right lead

**Observed**

- 5 reps / same overall output;
- less observed VMO tension than with the left lead;
- slightly greater left anterior-hip exertion than the right anterior-hip exertion reported in the opposite lead condition.

### Set 2

**Observed**

- identical bilateral output pattern to Set 1;
- 5 reps per side.

### Interpretation — non-canonical

The asymmetry in this run is primarily an effort-distribution observation rather than a reported movement-quality failure: left lead exposed clearer lead-side VMO tension, while right lead exposed relatively greater contralateral anterior-hip effort. No causal or weakness assertion is admitted from this alone.

## Resisted hip flexion

**Executed dose:** 2 × 5 reps per side @ 6 kg.

### Setup

- 6 kg kettlebell, reported as the lightest kettlebell available;
- kettlebell implementation substituted for occupied cable/GHD access;
- exact foot suspension/support geometry was not captured.

### Set 1 — observed

- 5 steady reps each side;
- both sides cleared 90° hip flexion;
- left side observably slightly weaker.

### Set 2 — observed

- identical output pattern;
- 5 reps each side;
- >90° hip flexion maintained;
- left side again observably weaker;
- left side approached failure with at most ~2 RIR remaining.

### Interpretation — non-canonical

The left/right output difference was repeatable across both sets. The observed limiting surface was left-side hip-flexion capacity at this dose rather than reported ROM loss. No load increase is admitted from this session alone; recovery remains pending.

## Equipment / workflow observations

**Observed**

- GHD and cable racks were occupied during the session;
- the direct hip-flexion slot was therefore executed using the admitted kettlebell implementation;
- the session was reordered/substituted around equipment availability.

## Planned but not executed

The following Program B slots were not captured as executed:

- `curtsey-stepdown`;
- optional `assisted-slrdl`;
- `ghd-knee-to-chest`;
- treadmill gait/down-regulation.

These remain planned-only and must not be projected as completed work.

## Session close

**Observed control decision**

The session was intentionally concluded at the current volume in order to experience and measure recovery before adding more work or intentionally moving closer to an MRV threshold.

This is a **recovery-dose calibration stop**, not evidence that MRV was reached.

Immediate close values for energy, cognition, gait, local soreness, and other systemic state were not reported and remain unobserved.

## Capture/model gaps exposed

### `capture-gap`

Band assistance was identified structurally as torso-strapped and anchored, but assistance magnitude/tension remained unknown. Future capture needs to preserve both implementation and optional measured magnitude.

### `semantic-gap`

A rep can remain mechanically admitted while requiring materially greater neuromuscular focus. This state is distinct from RIR, technical failure, and mechanical compensation and needs a stable representation.

### `semantic-gap`

Perceived exertion needs to support `side × mechanical-role` context, for example lead-leg knee-extensor demand versus contralateral rear-anterior-hip demand, rather than only a flat anatomical region.

### `identity-gap`

`Cossack-style lateral shuffle` should not normalize to canonical `cossack-squat`. It is a related but execution-distinct dynamic lateral-transfer pattern and needs its own identity or explicit variant relation.

### `workflow-gap`

Equipment occupancy can produce defer/reorder/substitute transitions without changing the higher-level exercise intent. The future controller should represent equipment unavailability and the resulting plan delta explicitly.

### `capture-gap`

The 6 kg kettlebell hip-flexion exposure lacked exact suspension/support geometry. Setup inheritance requires a structured geometry/equipment configuration surface rather than only `load`.

### `analytics-gap`

Session closure for recovery-dose calibration should be distinguishable from fatigue termination, stop-condition termination, time constraint, equipment failure, or incomplete adherence.

## Recovery handoff

Recovery is now the active continuation of this run.

Useful checkpoints, only when they actually occur:

```text
T+12
T+24
T+48
T+72
```

Capture the smallest available vector from:

- named-region DOMS;
- side-specific differences;
- gait/basic movement availability;
- energy availability;
- cognitive availability / task initiation;
- sleepiness;
- subjective recovery;
- readiness of key Program B movement surfaces.

No checkpoint is fabricated if it does not occur. Longitudinal/progression admission remains pending recovery evidence.
