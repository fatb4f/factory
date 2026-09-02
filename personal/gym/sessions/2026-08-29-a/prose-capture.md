# 2026-08-29 Program A — prose capture

Status: **closed / seed exemplar only**  
Capture mode: **pre-P2 conversational evidence**  
Program: `ankle-knee-pelvis-tri-session-v1`  
Session class: `posterior` / Program A  

This run predates the operational Python/JSONL capture bridge. It is persisted as a prose evidence artifact because it produced the posterior-chain program contract, but it is **not a comparable longitudinal run** and must remain excluded from adaptation-trend calculations.

## Evidence discipline

- Direct observations below are limited to facts explicitly preserved from the live session and the canonical posterior seed-session summary.
- Planned topology is not projected as executed work unless execution was reported.
- Missing dose, ROM, tempo, assistance magnitude, systemic state, and camera geometry remain missing.
- Interpretations are separated from observations.
- This artifact is a seed exemplar for programming and schema validation, not a normalized baseline.

## Known executed topology

```text
posterior preparation / acquisition
      ↓
reverse hyper
  bilateral, ~5 lb / ankle
      ↓
GHR
  blue-band assistance
  2 working sets: 6, 5 reps
  deliberately partial ROM
      ↓
short-lever Copenhagen
  1 × 8 / side
      ↓
gait / down-regulation
  easy treadmill walk → light jog
  short backward walk
```

The exact ordering and dose of any additional activation-gate work were not standardized sufficiently to reconstruct them here.

## GHR

**Executed dose:** 2 working sets, 6 reps then 5 reps, using blue-band assistance.

### Observed

- ROM remained deliberately partial;
- hips and torso remained stacked;
- pelvis remained neutral through the observed concentric work;
- neutral-ankle cueing was used;
- no gastrocnemius or medial-hamstring cramping occurred;
- no reported loss of pelvic organization terminated either working set.

### Interpretation — non-canonical

This run established that assisted partial-ROM GHR work could expose the posterior chain without reproducing the prior cramp/organization failure mode. It does **not** establish a progression threshold because assistance tension, exact ROM, tempo, per-rep quality, and recovery state were not captured to a repeatable protocol.

## Reverse hyper

**Known implementation:** bilateral reverse hyper with approximately 5 lb at each ankle.

### Observed

- pelvis remained organized through the reported work;
- no lumbar substitution was observed;
- a small controlled weighted eccentric stretch at end range was tolerated;
- no swing-driven lumbar compensation was reported.

Exact set count, rep count, and tempo were not preserved and are not reconstructed.

### Interpretation — non-canonical

The reverse hyper functioned as a mechanically clean posterior-chain exposure and informed its later dual role as a light primer and controlled secondary movement. The seed data are insufficient for longitudinal loading comparison.

## Short-lever Copenhagen

**Executed dose:** 1 × 8 reps per side.

### Setup / observed

- short-lever implementation using bench + AbMat support;
- no observed rib flare;
- no observed pelvic rotation;
- no observed hip hike;
- the limiting demand appeared local to the adductor complex rather than the trunk;
- the right adductor side reached the local limiter earlier than the left.

### Interpretation — non-canonical

This exposed frontal-plane/adductor capacity as a useful posterior-day integration surface while preserving trunk-pelvis organization. The side difference is retained as an observation, not promoted to a diagnosis or fixed weakness identity.

## Gait / down-regulation

### Easy forward treadmill exposure

**Observed**

- easy walking progressed into light jogging;
- gait showed an apparently functional heel-to-push-off pressure sequence;
- pronation/supination transition appeared usable under the low-intensity locomotor readout.

### Short backward walk

**Observed**

- both dorsiflexors were strongly recruited;
- a local medial-right-knee working sensation was reported.

The backward exposure was diagnostic/coordination-oriented rather than conditioning work.

## Recovery evidence

The posterior seed run was followed by low local soreness relative to historical hamstring-dominant sessions, while systemic energy/cognitive cost remained a relevant recovery signal. The original session did not use standardized recovery checkpoints, so later recovery observations are not promoted here into normalized `T+12/T+24/T+48/T+72` records.

The run therefore remains useful for identifying the recovery dimensions that later sessions must capture, but not for quantitative progression admission.

## Missing / insufficiently standardized observations

The canonical seed-session record identifies the following gaps:

- baseline systemic state;
- exact GHR ROM;
- GHR tempo;
- blue-band assistance tension;
- complete per-set/per-rep mechanical-quality capture;
- exact reverse-hyper sets and reps;
- immediate session-close systemic state;
- standardized recovery checkpoints;
- repeatable video/camera geometry.

These fields must remain absent rather than inferred from the later Program A prescription.

## Contract consequences exposed by this run

### `capture-gap`

Assistance identity alone is insufficient. Future GHR observations need implementation plus assistance magnitude/tension and repeatable ROM geometry.

### `mechanical-state`

A set can remain admitted because pelvis, torso, femur, and ankle relationships remain organized even when ROM is intentionally constrained. Partial ROM is therefore setup/progression state, not automatically a failed rep.

### `limiter-locality`

Copenhagen work showed that a local adductor limiter can terminate useful exposure while the trunk-pelvis constraint remains intact. Limiter identity must be represented independently from global set success/failure.

### `recovery-gap`

Mechanical success alone is insufficient for progression. Systemic energy and cognitive recovery cost need explicit post-session observation alongside DOMS and movement availability.

### `gait-readout`

Forward and backward locomotion provide distinct integration observations and should remain readout surfaces rather than being normalized as generic conditioning volume.

## Longitudinal admission

```text
seed exemplar
  ├─ valid for program/schema derivation
  ├─ valid as historical qualitative evidence
  └─ invalid for comparable adaptation-trend calculations
```

The first future Program A run captured through the normalized session contract should become the true comparable baseline.
