---
name: Factory control-loop implementation
about: Plan factory work from root contract authority through materialization, evidence, and gates.
title: "feat(factory): "
labels: factory, contract
---

# Root contract question

```text
N0.root-question:
  How can the root contract express, materialize and gate this?
```

Answer:

- 

# Required control-loop frame

Reference the active CUE control loop:

```text
contracts/factory/reflection.cue
  -> reflection inventory and materialization plan

contracts/factory/control.cue
  -> input -> transform -> output -> sensor -> error-signal -> control-action -> next-state

contracts/factory/introspection.cue
  -> bounded adapter-visible views
  -> AdapterCommand
  -> EvidencePacket
  -> Materialization
```

# DAG implementation model

Implementation plans must be reasoned as a DAG. Start from `N0.root-question`.

```text
Nodes:
  N0.root-question:
    asks how the root contract can express, materialize and gate this

  N1.contract-expression:
    CUE authority surface that expresses the admissible object, state, or transition

  N2.materialization-plan:
    materialization path derived from CUE authority

  N3.adapter-aperture:
    bounded adapter command or runtime ingress declared by introspection

  N4.evidence-sensor:
    generated evidence, fixture, packet, assertion result, or loop-stage export

  N5.gate:
    assertion, drift check, validation command, or control-action decision

  N6.next-state:
    admitted contract state after validation and materialization

Edges:
  N0.root-question -> N1.contract-expression
  N1.contract-expression -> N2.materialization-plan
  N2.materialization-plan -> N3.adapter-aperture
  N3.adapter-aperture -> N4.evidence-sensor
  N4.evidence-sensor -> N5.gate
  N5.gate -> N6.next-state

Parallel edges:
  - 
```

# Contract authority surfaces

```text
Authority surfaces:
  - contracts/factory/reflection.cue:
  - contracts/factory/control.cue:
  - contracts/factory/introspection.cue:

New or changed CUE values:
  - 

Non-authority inputs:
  - 
```

# Materialization and evidence

```text
Materializations:
  - path:
    kind:
    generatedFrom:
    admittedBy:
    writtenBy:

Evidence packets or loop exports:
  - path:
    schema:
    source view:
    bounded: true
    authority: false

Runtime sensors:
  - 
```

# Gates and control actions

```text
Required gates:
  - cue eval:
  - cue vet:
  - generated check:
  - just target:

Control action:
  action: admit | reject | defer | materialize | block
  reason:
  error-signal evidence:
  next-state evidence:

Drift checks:
  - generated evidence declared
  - generated checks declared
  - adapter commands declared
  - no shell-only generated paths
```

# Acceptance criteria

- [ ] Root contract question is answered before implementation details.
- [ ] Implementation plan is represented as a DAG with named nodes and edges.
- [ ] New semantics are expressed under `contracts/factory/**`.
- [ ] Adapter-visible behavior is declared through `contracts/factory/introspection.cue`.
- [ ] Generated outputs are non-authoritative and have reflected provenance.
- [ ] Materializations are admitted by a declared control action or gate.
- [ ] Evidence lands under `generated/evidence/**` or another declared bounded evidence path.
- [ ] `just check` passes.

# Validation commands

```bash
just generate-validation
just export-validation-loop
just check
```
