# Gym executable session, event, analytics, and UI architecture

Status: proposed architecture; not yet an implemented runtime contract.

## Objective

Model a Gym training session as a bounded executable episode rather than a flat workout log.

The operational program is Python-native, but Python does not become an independent semantic authority. CUE remains the semantic contract source under `contracts/personal/gym/`; generated/projected Python types provide the executable object model used by session code, analysis, and UI adapters.

The intended flow is:

```text
Gym CUE semantic authority
        ↓ projection / generation
Python program object graph
        ↓ instantiate
SessionInput / SessionPlan
        ↓
executable Marimo session workbook
        ↓ specialized domain functions
DomainEvent
   ├──→ append session.jsonl
   ├──→ emit correlated OTel
   └──→ update live session representation
        ↓
recovery continuation / finalization
        ↓
sealed session bundle
        ↓
DuckDB corpus
        ↓
Ibis scoped expressions
   ├──→ Marimo analytical views
   ├──→ UI projections
   └──→ GitHub progression scopes
```

This borrows the useful control boundary from `fatb4f/ctrl`: a session-scoped Marimo controller may normalize and project an append-only JSONL ledger, but the ledger remains the durable event evidence and the reactive workbook remains reconstructable from it. See [`fatb4f/ctrl` workbook architecture](https://github.com/fatb4f/ctrl/blob/main/spec/.codex/hooks/WORKBOOK_ARCHITECTURE.md) and its independent [qualification/sealing boundary](https://github.com/fatb4f/ctrl/blob/main/docs/qualification-p0-plan/40-qualification-kernel-and-sealing.md).

## Authority and runtime boundaries

```text
CUE contracts
    semantic authority
        ↓
generated/projected Python domain types
    executable semantic representation
        ↓
Marimo / JSONL / OTel / DuckDB / Ibis / UI / GitHub
    runtime, evidence, query, and presentation projections
```

Hard constraints:

- do not hand-maintain a second Gym semantic schema in Python;
- do not make Marimo notebook state authoritative;
- do not make OTel attributes the Gym vocabulary authority;
- do not make DuckDB tables or Ibis expressions canonical storage;
- do not make GitHub Issues the observation store;
- do not make a UI data model a competing workout schema.

The runtime may be almost entirely Python while remaining generated from, validated against, or otherwise traceable to the CUE contracts.

## Core session types

Keep four concepts separate:

```text
ProgramDefinition
    persistent program graph and progression/control rules

SessionPlan
    one instantiated prescription from a program revision

SessionExecution
    what was actually executed and observed

SessionBundle
    bounded executable artifact plus durable evidence and provenance
```

A program revision and a performance change are therefore distinguishable. Cross-session analysis can compare executions under equal program revisions, or explicitly account for revision changes.

## Executable session bundle

A candidate physical layout is:

```text
sessions/<session-id>/
├── session.py          # executable Marimo workbook / controller
├── input.json          # normalized initial parameters and plan binding
├── session.jsonl       # append-only observed event ledger
├── manifest.json       # identities, revisions, artifact references, digests
├── telemetry/          # optional local/export receipts or OTel references
└── media/              # optional video/sensor references, not necessarily bytes
```

`session.py` is the executable control/capture surface. `session.jsonl` is the durable factual artifact.

The workbook must be reconstructable from:

```text
qualified workbook/program revision
+ normalized SessionInput
+ committed session.jsonl prefix
+ explicitly referenced external evidence
```

Reactive reruns must not duplicate already-committed domain events.

## Session JSONL contract

Each line represents one immutable typed event or capture envelope. It should carry enough identity to remain useful when read outside the original workbook.

Illustrative records:

```json
{"session_id":"2026-09-01-b","event_id":"e-001","ts":"2026-09-01T14:02:11Z","kind":"set.completed","element":"reverse_nordic","set":1,"reps":8,"assistance":"medium"}
{"session_id":"2026-09-01-b","event_id":"e-002","ts":"2026-09-01T14:02:13Z","kind":"constraint.observed","element":"reverse_nordic","phase":"terminal_concentric","constraint":"knee_extension_capacity"}
{"session_id":"2026-09-01-b","event_id":"e-003","ts":"2026-09-01T14:11:42Z","kind":"quality.observed","element":"atg_split_squat","side":"right","metric":"pelvic_stability","value":"stable"}
```

The concrete envelope belongs in CUE before implementation. The example only establishes the shape of the persistence boundary.

Required behavioral properties:

- append-only during capture;
- one stable event identity per committed record;
- explicit session/program/schema revision identity;
- corrections append a superseding record rather than mutating history;
- planned work and executed work remain distinguishable;
- raw observation and downstream interpretation remain distinguishable;
- media/sensor values retain acquisition provenance.

The existing `#CaptureEnvelope` and `#Supersession` semantics should project naturally into this ledger rather than be replaced by a new event vocabulary.

## Capture and control loop

The live conversational/session workflow becomes an input adapter to the executable session:

```text
prescription
    ↓
execution
    ↓
terse feedback / sensor input
    ↓ normalization
SessionInput delta / DomainEvent
    ↓
specialized program function
    ├── control decision for next exposure
    ├── append factual event
    └── emit telemetry projection
```

Example user feedback:

```text
Set 2, 6 reps. Same band. No pelvic fail, medial ham started to load near the bottom.
```

can normalize into stable typed facts without forcing the user to operate a form during the session.

The controller may adapt the next exposure, but the control decision and the factual observation are separate records.

## OTel projection

OTel is a correlated observability projection from the same typed domain events.

A useful mapping is:

```text
traces
    session → exercise → set → bounded phase/operation

metrics
    reps, load, ROM, assistance, duration, RPE/RIR,
    symmetry, recovery quantities, sensor measures

span events / logs
    constraint observed, quality observed, stop condition,
    correction, user feedback, device/media acquisition
```

The domain event is created first conceptually:

```text
DomainEvent
   ├── JSONL encoder
   ├── OTel adapter
   ├── live Marimo projection
   └── optional GitHub/UI adapter
```

OTel correlation identifiers should make trace/metric/log material joinable back to `session_id`, `event_id`, program element identity, and program/schema revision. OTel is not the authoritative event ledger.

## Close, recovery, and sealing

`SessionClose` ends active training execution, but existing Gym semantics treat recovery as part of the same run. Therefore sealing must not erase the recovery lifecycle.

Recommended lifecycle:

```text
ACTIVE
  → SessionClose
  → append-only RECOVERY continuation
  → analysis-admission decision or explicit partial/inconclusive terminal state
  → manifest reconciliation
  → seal exact committed event prefix + identities + digests
```

A checkpoint may record the closed execution prefix before recovery completes, but a final analytical bundle should bind the exact recovery evidence used for admission.

Sealing means the admitted artifact set and event prefix are immutable and content-addressable. It does not mean every derived analytical interpretation must be stored inside the bundle.

## Raw evidence versus derived analytics

The first implementation should keep `session.jsonl` focused on direct/normalized observed facts and control receipts.

Typical observed event families:

```text
session.started
exposure.configured
set.completed
constraint.observed
quality.observed
stop_condition.observed
plan.deviated
feedback.received
session.closed
recovery.observed
observation.superseded
```

Typical derived analytical concepts:

```text
progression.delta
constraint.transition
asymmetry.detected
equilibrium.score
helper.exposure
recovery.cost
```

Prefer deriving the second group through versioned Ibis expressions/views over the event corpus. If derived records are later materialized, store them separately from raw observation history and include `derived_from` event identities plus model/query revision provenance.

## DuckDB and Ibis analytical plane

The generated session artifact is intentionally queryable without reconstructing a flat per-session tracker.

Conceptually:

```text
sessions/*/session.jsonl
        ↓ DuckDB scan / normalized views
Gym relational projections
        ↓
Ibis expressions
```

`Session` is primarily a provenance and execution boundary. It is not the mandatory analytical unit.

Queries may instead scope over:

```text
program element
movement / movement phase
mechanical demand or constraint
mechanical role
side
complex
primary contributor
passive/helper relation
program revision
recovery horizon
calendar window
```

This enables surgically scoped longitudinal questions such as:

- terminal-concentric knee-flexion observations across all GHR executions;
- right-side frontal-plane stability wherever an adductor participates as primary contributor or helper;
- GHR progression after reverse-hyper helper exposure within a bounded recovery horizon;
- constraint migration within one complex across program revisions;
- multi-region equilibrium changes without collapsing them into one session score.

The Python domain graph can generate query scopes while Ibis performs the relational lowering:

```text
PosteriorChain.scope(include_helpers=True)
        ↓
stable element/relation identities
        ↓
Ibis predicate / joins
        ↓
DuckDB execution
```

This keeps domain navigation object-native without embedding analytics storage semantics into the domain classes.

## GitHub progression scopes

GitHub Issues remain useful for long-lived problem/progression scopes:

```text
issue: improve right adductor / pelvic integration
        ↑
links evidence from session bundles and analytical views
```

An Issue may identify a complex, element, constraint, or progression objective and receive links/summaries from multiple bundles. It should not replace the JSONL event history.

If decorators or metadata bind a Python domain object to an Issue, bind through a stable semantic scope key and resolve the GitHub issue identity in an adapter/registry rather than hard-coding issue numbers into biomechanics semantics.

## UI projection

This architecture deliberately opens a first-class UI layer because the UI no longer has to own the workout data model.

[`WhyAsh5114/MyFit`](https://github.com/WhyAsh5114/MyFit) is a useful interaction reference: it demonstrates a web/mobile-oriented workout surface centered on active logging, progression history, and training feedback. Gym should treat it as a UX/reference implementation only, not inherit its persistence schema or make conventional progressive-overload formulas authoritative.

Candidate Gym UI surfaces:

```text
Active session
    program → exercise → set
    current setup / gate / next action
    terse structured feedback capture

Element / complex progression
    scoped history
    current limiting constraint
    helper/passive-helper exposure
    mechanical quality + recovery cost

Cross-session analysis
    Ibis-backed query scopes
    side / phase / role / constraint filters
    progression and constraint-migration representations

Recovery
    current checkpoint window
    observed DOMS/systemic state
    admission completeness

Progression workspace
    stable GitHub issue/problem scope
    linked bundles, evidence, and analytical summaries
```

The same typed service/query layer should support Marimo analytical views and a dedicated web/mobile UI:

```text
sealed JSONL corpus
      ↓
DuckDB + Ibis
      ↓
typed query/result adapters
   ├── Marimo
   └── web/mobile UI
```

No UI-specific database is required for the first slice.

## Minimal vertical slice

Implement one narrow end-to-end episode before expanding the schema:

1. project one current Gym program into generated Python objects;
2. instantiate one typed `SessionInput`;
3. execute/capture it through one Marimo `session.py`;
4. append normalized observations to `session.jsonl`;
5. mirror selected events into correlated OTel;
6. close the session and append at least one recovery observation;
7. reconcile and seal a manifest for the exact event prefix;
8. execute a DuckDB scan across at least two session artifacts;
9. express one surgically scoped progression query in Ibis;
10. render the same result in a Marimo analytical view and a minimal UI projection.

A strong first analytical query is one current program element plus its declared helpers, constrained to equal setup/revision and compared on mechanical quality plus recovery cost.

## Open contract decisions

Before implementation, resolve upstream in CUE:

- event-envelope identity and required revision fields;
- exact mapping from current `#CaptureEnvelope` / `#Supersession` to JSONL;
- program Python projection/generation boundary;
- session input/plan/execution transport types;
- OTel semantic-convention namespace and correlation identifiers;
- session-close versus final-recovery seal semantics;
- bundle manifest and digest contract;
- DuckDB normalization views over heterogeneous event kinds;
- Ibis scope-generation interface from Python domain objects;
- stable GitHub progression-scope binding;
- typed analytical result contract consumed by Marimo and UI adapters.

Until those are closed, this document is architectural direction rather than a competing schema.
