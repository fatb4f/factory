# Gym tri-session adaptation program

Status: baselining program contract; progression thresholds remain provisional until comparable runs exist.

## Purpose

The ankle-knee-pelvis program is a coupled multi-region load-transfer problem, not a collection of isolated weak-muscle exercises. The current working model is that distal instability and rotational uncertainty can propagate through the tibia and femur into pelvic instability, with compensatory stiffness or load absorption appearing in the hip flexor, adductor, hamstring, and lumbar systems.

The program therefore separates the major adaptation domains instead of exhausting ankle, anterior femoral, posterior femoral, pelvic, and trunk capacity in the same session.

```text
A — posterior transfer
ankle → hamstring → glute → pelvis

B — anterior / rotational femoral control
ankle → quad / adductor / hip flexor → femur → pelvis

C — distal + integrated redistribution
foot / ankle → tibia → femur → pelvis → trunk
```

The shared invariant is:

> Maintain pelvic organization while progressively transferring more force through the chain at equal or lower systemic recovery cost.

The machine-readable topology is defined in `contracts/personal/gym/tri_session_program.cue` and attaches to the existing `ankle-knee-pelvis-stability` program.

## Common session lifecycle

All three session classes use the same lifecycle:

```text
activation gate
    ↓
primer where required
    ↓
primary exposure
    ↓
secondary / integration exposure
    ↓
core constraint
    ↓
gait / down-regulation
    ↓
recovery observation
```

Activation is signal preparation, not additional training volume. A warm-up exposure should improve recruitment or coordination without producing pump, shaking, cramping, or meaningful local fatigue.

Mechanical failure is not a target. A set terminates when the active constraint can no longer be preserved, even if prime-mover force remains available.

## A — posterior-chain transfer

### Objective

Restore posterior-chain force transfer while preserving distal, femoral, pelvic, and lumbar organization.

### Activation and primer

Low-dose sequence:

1. ankle inversion/eversion;
2. neutral-ankle calf raise;
3. heel-dig hamstring isometric with graded tension;
4. bridge-march or equivalent low-cost trunk-pelvis activation;
5. very light reverse hyper as a proximal posterior-chain primer.

The calf is deliberately kept near neutral rather than aggressively plantar-flexed. This reduces the tendency to shorten the gastrocnemius under load while the muscle is also contributing to knee-flexion stability.

The hamstring is acquired before long-lever loading. If one side has difficulty initiating output, isometric acquisition and a few assisted concentric curls may be used as a state-setting gate rather than as work sets.

### Primary GHR contract

Working range begins conservatively with sufficient assistance.

```text
ankle neutral
AND femoral position organized
AND hamstring acquired
AND hips / torso stacked
AND pelvis neutral
→ rep admitted
```

Stop or regress when any of the following appear:

- pelvic rotation or tilt;
- lumbar takeover;
- delayed hamstring acquisition after the loaded portion begins;
- gastrocnemius or medial-hamstring cramp threat;
- loss of femoral rotational control.

Progression is intentionally ordered:

```text
clean eccentric ROM
→ less assistance
→ additional reps / external load
```

Only one progression dimension should move at a time.

### Reverse hyper

Reverse hyper has two roles:

- very-light primer before GHR;
- controlled secondary work after GHR.

The secondary exposure remains hip-driven with a stable pelvis and no lumbar swing. A small weighted eccentric stretch at end range is acceptable when it remains controlled; the objective is not maximal swing amplitude.

### Integration and core

A low-load assisted SLRDL or equivalent unilateral hinge can test whether posterior recruitment survives standing femoral negotiation.

Short-lever Copenhagen work supplies frontal-plane pelvic control and adductor exposure. If the adductor complex fails before the trunk while the pelvis remains stacked, that is recorded as the local limiter rather than treated as failed core work.

Dynamic GHD knee-to-chest work is optional on posterior day and should not be added when posterior tissues are already gripping to stabilize the pelvis.

### Down-regulation

Use easy treadmill walking for approximately 5–10 minutes as a circulation and gait readout rather than conditioning. A very short backward walk may be used diagnostically.

Do not automatically finish with aggressive loaded stretching. Long-length hamstring and adductor loading are separate adaptive exposures and should not be layered onto a posterior session simply because the session is ending.

## B — anterior / rotational femoral control

### Objective

Restore anterior-hip and knee-extension capacity while testing whether posterior-chain and trunk support can preserve femur-pelvis organization under deep unilateral and bilateral anterior-chain demand.

Program B borrows selected ATG/Knees Over Toes movement families, but it is not intended to reproduce an official ATG session. Movements are admitted only when they serve the ankle-knee-pelvis contract and do not create redundant fatigue.

### Activation and knee-control primer

Start with low-fatigue dorsiflexion and anterior trunk-pelvis activation. A short backward walk, resisted backward walk, or backward treadmill exposure may be used as a knee-extension primer when it improves movement quality without becoming conditioning work.

A Poliquin step-up then exposes unilateral knee-extension control before the deeper main lifts. Progress step height and reduce hand support before adding substantial external load.

```text
clean low step
→ greater controlled step height
→ less hand support
→ external load
```

The step-up is a primer and measurement surface, not a third maximal quad lift.

### ATG split squat

The ATG split squat is a defining Program B lift because it couples several requirements in one asymmetric task:

```text
front leg
  deep knee flexion + ankle dorsiflexion + quad output

rear leg
  hip-extension tolerance / anterior-hip length

pelvis
  bilateral force transfer + femoral organization
```

Begin with front-foot elevation and/or hand support as required. The progression order is:

```text
clean supported ROM
→ deeper controlled ROM
→ lower front-foot elevation / less assistance
→ external load
```

Depth is admitted only while the pelvis remains organized, the front knee tracks under control, and rear-hip extension is not manufactured through lumbar extension.

### Reverse Nordic

Reverse Nordic remains the other defining anterior-chain lift.

```text
clean shallow ROM
→ deeper ROM
→ slower eccentric
→ cleaner deep-flexion-to-concentric reversal
→ external load
```

Hips remain extended, ribs stacked, and depth is not manufactured through lumbar extension.

The deep-flexion reversal is a specific observation boundary. Preserve the starting knee relationship rather than forcibly squeezing the knees together. Record uncontrolled knee separation, femoral rotation, pelvic drift, or lumbar substitution as the first failing constraint.

Useful repeatable observations include knee separation, knee angle, eccentric duration, and the quality or duration of the initial concentric reversal. A front view is therefore part of the preferred video set in addition to side/oblique views.

### Direct resisted hip flexion

Program B now includes a direct hip-flexion slot rather than relying only on GHD knee-to-chest work.

The canonical exercise is `resisted-hip-flexion`; loading implementation is setup data rather than exercise identity. Supported implementations include:

- bilateral cable hip flexion with an attachment connecting both ankles;
- unilateral cable knee drive;
- controlled foot-suspended resistance such as a kettlebell when secure and mechanically clean.

The unilateral implementation adds stance-side pelvic control. Active ankle dorsiflexion may be intentionally coupled to the knee drive when the goal is anterior-chain integration; if so, record it as a setup/constraint rather than assuming tibialis contribution from the exercise name.

Progress clean ROM and repeatability before increasing load. Pelvic rotation, rib flare, lumbar arching, or momentum terminate the useful set.

### Rotational integration

A curtsey-stepdown or related controlled unilateral pattern follows the principal sagittal-plane work to expose femoral translation/rotation under a relatively quiet pelvis. Assisted SLRDL remains optional as a low-load cross-chain probe when it does not shift the session back toward posterior-chain fatigue.

### Core

This remains the preferred session for dynamic anterior compression through a GHD bent-knee knee-to-chest / leg-raise pattern.

The movement contract is:

```text
hips near pad edge
→ ribs controlled
→ femurs flex
→ pelvis finishes with deliberate posterior curl
```

Bent knees precede long-lever or straight-leg variants. The objective is controlled anterior pelvic compression rather than simply maximizing hip-flexor torque.

### Deliberate omission: deep squat

Deep/slant/KOT squatting is not part of the current baseline Program B. Step-up + ATG split squat + reverse Nordic already provide three knee-extension exposures with distinct mechanical roles. A deep squat may later replace one of those slots, but should not initially be stacked on top as a fourth primary quad exposure.

## C — distal / integrated redistribution

### Objective

Give the ankle and foot a direct adaptive dose, then test whether the resulting mechanics remain available when demand propagates upward.

This should usually be the lowest-load and highest-observation session.

### Distal exposure

Direct work may include:

- inversion / eversion;
- dorsiflexion;
- plantar-flexion / calf raise;
- foot-pressure transitions;
- controlled pronation and resupination.

Unlike posterior day, these are allowed to constitute actual training volume.

### Integration

Use a small set of unilateral and cross-chain movements such as assisted SLRDL, curtsey/stepdown, bridge-march, Pallof work, carries, or later Roman-chair lateral control.

The governing question is:

> Does corrected distal control survive when force is transmitted through the femur, pelvis, and trunk?

Roman-chair side bending should begin with isometric or small-ROM control. The lengthened side controls the eccentric and then contracts to return the trunk toward neutral; pelvic hiking should not manufacture the rep.

### Gait readout

Gait is a primary integration output:

```text
heel loading
→ pronation
→ midstance
→ resupination
→ push-off
```

Backward walking remains a small coordination/diagnostic dose. Local dorsiflexor recruitment is expected; focal or persistent joint pain changes the interpretation and should not be trained through.

## Recovery-gated sequencing

The topology is state-driven rather than weekday-driven:

```text
posterior
    ↓ recovery gate
anterior
    ↓ recovery gate
distal-integrated
    ↓ recovery gate
repeat
```

Initial recovery windows are provisional:

| Session | Initial recovery window |
| --- | --- |
| posterior | 48–72 h |
| anterior | 24–48 h |
| distal / integrated | 24–48 h |

Time alone does not admit the next exposure. Walking, basic movement availability, local tissue state, energy, cognitive bandwidth, and the program recovery budget remain relevant.

A mechanically successful session followed by excessive systemic or cognitive recovery cost is not eligible for progression.

## Progress model

External load is only one coordinate.

Useful progress includes:

- greater clean ROM at unchanged assistance;
- lower assistance at unchanged mechanical quality;
- greater output with lower asymmetry;
- reduced concentration of the limiter into one region;
- cleaner gait integration after the session;
- reduced DOMS or movement alteration for an equivalent exposure;
- lower energy/cognitive cost for equal or greater mechanical capacity.

The target is therefore a Pareto improvement in usable capacity, mechanical quality, redistribution, and recovery cost rather than a conventional strength PR.

## 2026-08-29 posterior seed session

The session that produced this program contract was not captured against a complete observation protocol and is therefore **not a comparable longitudinal run**. It can be used only as a seed exemplar for programming and schema validation.

Known observations were:

- GHR: approximately 2 sets of 5–6 with blue-band assistance;
- GHR ROM remained deliberately partial;
- hips and torso remained stacked;
- pelvis remained neutral through the observed concentric work;
- no gastrocnemius or medial-hamstring cramping occurred with neutral-ankle cueing;
- bilateral reverse hyper used approximately 5 lb at each ankle;
- reverse hyper showed no observed lumbar substitution and tolerated a small controlled weighted eccentric stretch at end range;
- short-lever Copenhagen was performed for 8 repetitions each side with no observed rib flare, pelvic rotation, or hip hike;
- Copenhagen limiter appeared local to the adductor complex, earlier on the right;
- easy treadmill walking progressed into light jogging with an apparently functional heel-to-push-off pressure sequence;
- a short backward walk strongly recruited both dorsiflexors and produced a local medial-right-knee working sensation.

Missing or insufficiently standardized observations include baseline systemic state, exact ROM, tempo, assistance tension, complete per-set quality capture, immediate systemic state, recovery checkpoints, and video geometry. The run must therefore remain excluded from adaptation trend calculations.

## Capture implications

Future sessions should be captured against the existing Gym observation contracts before progression analytics are attempted.

Minimum useful session evidence is:

```text
planned exposure
+ actual dose / assistance / ROM
+ mechanical constraint state
+ limiter / compensation observations
+ session-close gait and systemic state
+ later recovery checkpoints
```

Video should eventually add repeatable sagittal, frontal/rear, and low-angle distal views with fixed camera geometry. Video-derived measurements remain derived observations and do not replace the fact-only session record.
